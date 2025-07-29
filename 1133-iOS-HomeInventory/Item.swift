import Foundation // 引入 Foundation 框架

// 定義 Item 結構體，遵循 Identifiable 和 Hashable 協議
struct Item: Identifiable, Hashable {
    // id 屬性為 UUID，確保每個 Item 實例都有唯一的識別符
    // 這對於 List 和 NavigationLink 的效能和行為至關重要
    let id = UUID()
    
    // 庫存項目的屬性
    var name: String        // 物品名稱
    var quantity: Int       // 物品數量
    var description: String // 物品描述
    // 您可以根據需求添加更多屬性，例如：
    // var price: Double
    // var category: String
    // var imageUrl: String?
}
