import SwiftUI
import AVFoundation // 確保引入 AVFoundation 以進行權限檢查

struct BarcodeScannerView: View {
    // @Environment 屬性，用於控制視圖的解散 (dismiss)
    @Environment(\.dismiss) var dismiss

    // @State 屬性，用於儲存掃描到的條碼結果 [先前對話, 154]
    @State private var scannedCode: String?
    // @State 屬性，控制 CameraRepresentable 是否應該持續掃描 [先前對話, 154]
    @State private var isScanning: Bool = false
    // @State 屬性，追蹤相機權限是否已授予 [先前對話]
    @State private var permissionGranted: Bool = false
    @Binding var isPresented: Bool // 用於控制視圖的顯示與隱藏

    // 閉包，用於將掃描結果傳遞回父視圖 [先前對話]
    var onCodeScanned: (String) -> Void

    var body: some View {
        VStack {
            if permissionGranted {
                // 如果已獲得相機權限，則顯示 CameraRepresentable 視圖
                CameraRepresentable(scannedCode: $scannedCode, isScanning: $isScanning)
                    .edgesIgnoringSafeArea(.all) // 讓相機預覽填滿整個螢幕 [2]
                    .overlay(alignment: .bottom) { // 在底部疊加 UI 元素 [3]
                        VStack {
                            if let code = scannedCode {
                                // 顯示掃描結果
                                Text("掃描結果: \(code)")
                                    .font(.headline)
                                    .padding()
                                    .background(Color.green.opacity(0.7))
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                                    .onAppear {
                                        // 掃描成功後，呼叫 onCodeScanned 閉包並解散視圖
                                        onCodeScanned(code)
                                        // 可以選擇在此處延遲解散或讓父視圖自行處理
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                                            dismiss()
                                        }
                                    }
                            } else {
                                // 提示使用者進行掃描
                                Text("請將條碼對準相機")
                                    .font(.headline)
                                    .padding()
                                    .background(Color.black.opacity(0.5))
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                            }
                            // 加入一個 Spacer 將內容推到最底部 [4]
                            Spacer()
                                .frame(height: 50)
                        }
                        .padding(.bottom, 20) // 調整提示文字位置
                    }
                    .onAppear {
                        isScanning = true // 視圖出現時開始掃描
                    }
                    .onDisappear {
                        isScanning = false // 視圖消失時停止掃描
                    }
            } else {
                // 如果沒有相機權限，顯示提示訊息並提供前往設定的選項
                VStack {
                    Text("需要相機權限才能掃描條碼。")
                        .font(.title2)
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                        .padding()

                    Text("請前往設定應用程式啟用相機權限。")
                        .font(.body)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)

                    Button("開啟設定") {
                        // 導向應用程式設定以允許使用者手動更改權限
                        // (超出來源範疇，但為常見做法)
                        if let url = URL(string: UIApplication.openSettingsURLString) {
                            if UIApplication.shared.canOpenURL(url) {
                                UIApplication.shared.open(url)
                            }
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .padding()
                }
                .onAppear(perform: checkCameraPermission) // 視圖出現時檢查權限
            }
        }
        // 如果掃描狀態改變，確保預覽層也得到更新
//        .onChange(of: isScanning) { newValue in
//            if newValue && scannedCode != nil {
//                scannedCode = nil // 如果重新開始掃描，清空舊的結果
//            }
//        }
    }

    // 檢查相機權限狀態
    private func checkCameraPermission() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            permissionGranted = true
        case .notDetermined:
            // 請求相機權限 [1]
            AVCaptureDevice.requestAccess(for: .video) { granted in
                DispatchQueue.main.async {
                    self.permissionGranted = granted
                    if granted {
                        self.isScanning = true
                    }
                }
            }
        case .denied, .restricted:
            permissionGranted = false
        @unknown default:
            permissionGranted = false
        }
    }
}

//// 預覽（用於 Xcode Canvas）
//#Preview {
//    BarcodeScannerView (isPresented: <#Binding<Bool>#>, onCodeScanned: <#(String) -> Void#>)
//}
                        
