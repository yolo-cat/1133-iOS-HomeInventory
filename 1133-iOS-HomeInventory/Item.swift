import Foundation

struct Item: Identifiable, Codable {
    var id = UUID()
    var name: String    // 新增物品名稱欄位
    let barcode: String
    let dateAdded: Date
    var order: Int = 0   // 用來紀錄排序順序
}
