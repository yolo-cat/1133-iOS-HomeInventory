import SwiftUI

// 主庫存清單視圖
struct InventoryListView: View {
    // 使用 @StateObject 來建立並擁有 ViewModel 的實例。
    // 這確保 ViewModel 的生命週期與 InventoryListView 視圖綁定。
    @StateObject var viewModel = ItemListViewModel()
    @State private var isShowingScanner: Bool = false // 控制 sheet 顯示與隱藏的狀態變數
//    @State private var isShowingScanner = false

    var body: some View {
        // NavigationStack 是 iOS 16 後推薦的導航方式，
        // 提供了更結構化的路徑導航 [10]。
        NavigationStack {
            List {
                // ForEach 遍歷 viewModel.items 數組
                // 由於 Item 遵循 Identifiable，可以直接傳遞 Item 對象
                ForEach(viewModel.items) { item in
                    // NavigationLink 現在直接傳遞整個 Item 對象作為其 value
                    NavigationLink(value: item) {
                        VStack(alignment: .leading) {
                            Text(item.name)
                                .font(.headline)
                            Text("數量: \(item.quantity)")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                    }
                }
                // 啟用 List 的滑動刪除功能，並連結到 ViewModel 中的 deleteItems 方法
                .onDelete(perform: viewModel.deleteItems)
            }
            .navigationTitle("庫存清單") // 設定導航標題
            // navigationDestination 定義了當 NavigationLink 傳遞 Item.self 類型時，
            // 應該導航到哪個視圖 [16]。
            .navigationDestination(for: Item.self) { item in
                // 創建 ItemDetailView 來顯示所選物品的詳細資訊
                ItemDetailView(item: item)
            }
            // 工具列，提供導航欄上的操作按鈕
//            .toolbar {
//                ToolbarItem(placement: .navigationBarTrailing) {
//                    // 新增物品按鈕
//                    Button("新增") {
//                        // 這裡可以觸發一個模態視圖 (sheet) 或導航到一個新的添加表單
//                        // 為了範例簡潔，這裡只打印訊息，實際應用中會是導航或呈現新視圖。
//                        viewModel.addItem(name: "新物品", quantity: 1, description: "這是新加入的物品。")
//                    }
//                }
//                ToolbarItem(placement: .navigationBarLeading) {
//                    // 列表的編輯按鈕，允許使用者重新排序或刪除項目
//                    EditButton()
//                }
//            }
        }
        
        VStack {
            Button {
                            isShowingScanner = true // 點擊按鈕時，將狀態設置為 true，觸發 sheet 顯示 [8, 9]
                        } label: {
                            Text("掃描條碼")
                        }
                    }
                    // 使用 .sheet 修飾器來呈現 BarcodeScannerView [10, 11]
        // 使用 .sheet 修飾器來呈現 BarcodeScannerView [10, 11]
        .sheet(isPresented: $isShowingScanner) {
            // 在這裡實例化 BarcodeScannerView，並將 isShowingScanner 的綁定傳遞給它
////            BarcodeScannerView(isPresented: $isShowingScanner, onCodeScanned)
//                // 您目前的 sheet 相關修飾器
//                .presentationDetents([.fraction(1)]) // 設置 sheet 佔據全螢幕的比例 [非來源資訊]
//                .presentationDragIndicator(.visible) // 顯示拖曳指示器 [非來源資訊]
//                .presentationCornerRadius(0) // 設置圓角為 0，使其看起來像全螢幕 [非來源資訊]
                    }
    }
}

// 物品詳細資訊視圖
struct ItemDetailView: View {
    let item: Item // 接收一個 Item 對象來顯示其詳細資訊

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("物品名稱: \(item.name)")
                .font(.largeTitle)
                .bold()
            Text("數量: \(item.quantity)")
                .font(.title2)
                .foregroundColor(.secondary)
            Text("描述: \(item.description)")
                .font(.body)
                .padding(.top)
            Spacer() // 將內容推到頂部
        }
        .padding()
        .navigationTitle(item.name) // 將物品名稱作為詳細視圖的標題
        .navigationBarTitleDisplayMode(.inline) // 標題顯示模式
    }
}

struct BarcodeScanner: View {
    @State private var isShowingCover = false

    var body: some View {
        /// Refer to the examples in ``VStack_Demo``
        VStack {
            Button {
                isShowingCover = true
            } label: {
                Text("Show Full Screen Cover")
            }
        }
        .fullScreenCover(isPresented: $isShowingCover) {
                Image(systemName: "star.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                    .background(Color.yellow)
                    .cornerRadius(20)
            Button {
                isShowingCover = false
            } label: {
                Text("Dismiss")
            }
        }
    }
}

// 預覽提供器，用於在 Xcode Canvas 中顯示視圖
#Preview {
        InventoryListView()
    }
