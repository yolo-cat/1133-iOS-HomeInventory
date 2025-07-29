import Foundation // 引入 Foundation 框架
import Combine    // 引入 Combine 框架，用於 @Published

// 定義 ItemListViewModel 類別，遵循 ObservableObject 協議
class ItemListViewModel: ObservableObject {
    // @Published 屬性包裝器確保當 items 數組內容改變時，
    // 任何觀察此 ViewModel 的 SwiftUI 視圖都會自動更新
    @Published var items: [Item]

    // 初始化方法，可在此處載入初始數據或範例數據
    init() {
        self.items = [
            Item(name: "鍵盤", quantity: 50, description: "機械式鍵盤，青軸"),
            Item(name: "滑鼠", quantity: 120, description: "無線藍牙滑鼠"),
            Item(name: "螢幕", quantity: 30, description: "27吋 4K 解析度螢幕")
        ]
    }

    // 新增物品的方法
    func addItem(name: String, quantity: Int, description: String) {
        let newItem = Item(name: name, quantity: quantity, description: description)
        items.append(newItem) // 添加新物品會觸發視圖更新
    }

    // 刪除物品的方法，用於 List 的 onDelete 修飾符
    func deleteItems(at offsets: IndexSet) {
        items.remove(atOffsets: offsets) // 刪除物品會觸發視圖更新
    }

    // 更新物品的方法 (您可以根據需求添加，例如編輯物品詳情)
    func updateItem(item: Item, newName: String, newQuantity: Int, newDescription: String) {
        if let index = items.firstIndex(where: { $0.id == item.id }) {
            items[index].name = newName
            items[index].quantity = newQuantity
            items[index].description = newDescription
            // SwiftUI 會自動檢測到 items[index] 的修改，並更新相關視圖
            // 因為 Item 是一個 struct，修改其屬性會視為整個 struct 的改變，進而觸發 @Published
        }
    }
}
