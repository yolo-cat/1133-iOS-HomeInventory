import SwiftUI
import AVFoundation // 引入 AVFoundation 框架，用於相機和條碼掃描

// CameraRepresentable 是一個 SwiftUI 視圖，它能夠呈現一個 UIKit 的 UIView
struct CameraRepresentable: UIViewRepresentable {
    // @Binding 屬性，用於從父視圖接收和更新掃描到的條碼資訊 [先前對話]
    @Binding var scannedCode: String?
    // @Binding 屬性，用於控制掃描會話的啟動和停止狀態
    @Binding var isScanning: Bool

    // MARK: - UIViewRepresentable Methods

    // 創建並返回用於顯示相機預覽的 UIView
    func makeUIView(context: Context) -> UIView {
        // 設定相機並返回預覽視圖，這些操作都在 Coordinator 中處理
        context.coordinator.setupCamera()
        return context.coordinator.previewView
    }

    // 當 SwiftUI 狀態更新時，這個方法會被呼叫，用於更新 UIKit 視圖
    func updateUIView(_ uiView: UIView, context: Context) {
        // 根據 isScanning 的值來啟動或停止相機會話
        if isScanning {
            context.coordinator.startSession()
        } else {
            context.coordinator.stopSession()
        }
    }

    // 創建 Coordinator，它將作為 AVCaptureMetadataOutputObjectsDelegate 的代理
    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    // 當視圖從 SwiftUI 階層中移除時，呼叫此方法停止相機會話，釋放資源
    static func dismantleUIView(_ uiView: UIView, coordinator: Coordinator) {
        coordinator.stopSession()
    }

    // MARK: - Coordinator Class
    // Coordinator 是一個遵循 NSObject 和 AVCaptureMetadataOutputObjectsDelegate 協定的類別
    class Coordinator: NSObject, AVCaptureMetadataOutputObjectsDelegate {
        var parent: CameraRepresentable // 引用父 SwiftUI 視圖
        var captureSession: AVCaptureSession! // 相機捕捉會話
        var previewLayer: AVCaptureVideoPreviewLayer! // 相機預覽層
        let previewView = UIView() // 宿主 UIView，用於顯示預覽

        init(parent: CameraRepresentable) {
            self.parent = parent
        }

        // 設定相機輸入、輸出和預覽層
        func setupCamera() {
            captureSession = AVCaptureSession()

            // 嘗試取得預設的視訊捕捉裝置 (後置相機)
            guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else { return }
            let videoInput: AVCaptureDeviceInput
            do {
                videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
            } catch {
                print("無法創建視訊輸入: \(error.localizedDescription)")
                return
            }

            // 將視訊輸入新增到捕捉會話
            if captureSession.canAddInput(videoInput) {
                captureSession.addInput(videoInput)
            } else {
                print("無法將視訊輸入新增到會話。")
                parent.isScanning = false // 掃描失敗，設置 isScanning 為 false
                return
            }

            // 設定條碼元數據輸出
            let metadataOutput = AVCaptureMetadataOutput()

            // 將元數據輸出新增到捕捉會話
            if captureSession.canAddOutput(metadataOutput) {
                captureSession.addOutput(metadataOutput)

                // 設定代理和隊列，當檢測到條碼時會呼叫 delegate 方法
                metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
                // 設定要檢測的條碼類型。這裡包含了常見的條碼和 QR Code [超出來源範疇，但為 AVFoundation 常見用法]
                metadataOutput.metadataObjectTypes = [
                    .qr, .ean8, .ean13, .pdf417, .aztec, .code128,
                    .code39, .code93, .dataMatrix, .interleaved2of5, .itf14, .upce
                ]
            } else {
                print("無法將元數據輸出新增到會話。")
                parent.isScanning = false // 掃描失敗，設置 isScanning 為 false
                return
            }

            // 設定相機預覽層，將相機畫面顯示在 previewView 上
            previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
            previewLayer.frame = previewView.layer.bounds // 讓預覽層填滿整個視圖
            previewLayer.videoGravity = .resizeAspectFill // 填充模式
            previewView.layer.addSublayer(previewLayer)

            // 在背景線程啟動捕捉會話，避免阻塞 UI [超出來源範疇，但為 AVFoundation 常見用法]
            DispatchQueue.global(qos: .userInitiated).async {
                self.captureSession.startRunning()
            }
        }

        // 啟動相機會話
        func startSession() {
            if !captureSession.isRunning {
                DispatchQueue.global(qos: .userInitiated).async {
                    self.captureSession.startRunning()
                }
            }
        }

        // 停止相機會話
        func stopSession() {
            if captureSession.isRunning {
                DispatchQueue.global(qos: .userInitiated).async {
                    self.captureSession.stopRunning()
                }
            }
        }

        // MARK: - AVCaptureMetadataOutputObjectsDelegate

        // 當檢測到元數據對象 (例如條碼) 時，這個代理方法會被呼叫
        func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
            stopSession() // 找到條碼後停止掃描，避免重複檢測

            if let metadataObject = metadataObjects.first {
                // 嘗試將檢測到的對象轉換為可讀的機器碼對象
                guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject else { return }
                // 取得條碼的字串值
                guard let stringValue = readableObject.stringValue else { return }

                // 提供觸覺回饋（震動）[超出來源範疇，但為良好使用者體驗]
                AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))

                // 在主線程更新 SwiftUI 狀態
                DispatchQueue.main.async {
                    self.parent.scannedCode = stringValue // 更新綁定的掃描結果
                    self.parent.isScanning = false // 將掃描狀態設為完成
                }
            }
        }
    }
}
