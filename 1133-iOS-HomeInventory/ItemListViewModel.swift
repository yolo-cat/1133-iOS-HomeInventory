import Foundation
import CoreTransferable

class ItemListViewModel: ObservableObject {
    @Published var items: [Item] = []
    
    init() {
        // 預設三筆示範資料
        items = [
            Item(name:"iMac M1", barcode: "1234567890123", dateAdded: Date()),
            Item(name:"iPhone 16", barcode: "9876543210987", dateAdded: Date()),
            Item(name:"", barcode: "5555555555555", dateAdded: Date())
        ]
    }

    func addItem(barcode: String) {
        // 可以加簡單判斷避免重複
        guard !items.contains(where: { $0.barcode == barcode }) else { return }
        let newItem = Item(name: "name", barcode: barcode, dateAdded: Date())
        items.append(newItem)
    }
}
