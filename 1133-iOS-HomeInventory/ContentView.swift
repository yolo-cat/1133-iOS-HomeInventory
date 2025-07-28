import SwiftUI

struct ContentView: View {
    @StateObject var viewModel = ItemListViewModel()
    @State private var showScanner = false
    
    // 集中管理展開的項目 ID
    @State private var expandedItemIDs = Set<UUID>()
    
    var body: some View {
        NavigationView {
            VStack {
                // 切換全部展開 / 全部收合按鈕
                HStack {
                    Button(action: {
                        withAnimation {
                            if expandedItemIDs.count == viewModel.items.count {
                                // 全部收合
                                expandedItemIDs.removeAll()
                            } else {
                                // 全部展開
                                expandedItemIDs = Set(viewModel.items.map { $0.id })
                            }
                        }
                    }) {
                        Text(expandedItemIDs.count == viewModel.items.count ? "全部收合" : "全部展開")
                            .fontWeight(.semibold)
                    }
                    .padding()
                    
                    Spacer()
//                    // 編輯按鈕，啟動拖曳排序模式
//                     EditButton()
//                         .padding()
                 }
                
                if viewModel.items.isEmpty {
                    Text("請按下方按鈕掃描條碼來新增物品")
                        .padding()
                } else {
                    List {
                        ForEach($viewModel.items) { $item in
                            ItemRowView(
                                item: $item,
                                isExpanded: expandedItemIDs.contains(item.id),
                                onToggleExpand: {
                                    withAnimation {
                                        if expandedItemIDs.contains(item.id) {
                                            expandedItemIDs.remove(item.id)
                                        } else {
                                            expandedItemIDs.insert(item.id)
                                        }
                                    }
                                }
                            )
                        }
                    }
                    .listStyle(PlainListStyle())
                }
                
                Spacer()
                
                Button("掃描條碼") {
                    showScanner = true
                }
                .padding()
                .sheet(isPresented: $showScanner) {
                    BarcodeScannerView { scannedCode in
                        viewModel.addItem(barcode: scannedCode)
                        showScanner = false
                    }
                }
            }
            .navigationTitle("生活物品管理")
        }
    }
    // 重新排序函式
    func moveItem(from source: IndexSet, to destination: Int) {
        viewModel.items.move(fromOffsets: source, toOffset: destination)
    }
}

#Preview {
    ContentView()
}
