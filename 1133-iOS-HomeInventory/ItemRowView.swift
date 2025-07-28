import SwiftUI

struct ItemRowView: View {
    @Binding var item: Item
    let isExpanded: Bool
    let onToggleExpand: () -> Void
    
    @State private var isEditingName = false
    @State private var tempName: String = ""
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                if isEditingName {
                    TextField("請輸入品名", text: $tempName, onCommit: {
                        commitNameChange()
                    })
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .frame(maxWidth: 200)
                    .onAppear {
                        self.tempName = item.name
                    }
                } else if item.name.isEmpty {
                    Button("輸入品名") {
                        withAnimation {
                            isEditingName = true
                        }
                    }
                    .foregroundColor(.blue)
                    
                    Text(item.barcode)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .padding(.leading, 6)
                } else {
                    Text(item.name)
                        .font(.headline)
                        .onTapGesture {
                            withAnimation {
                                isEditingName = true
                            }
                        }
                }

                Spacer()

                // 改用外部傳進來的 isExpanded 和 tapHandler
                Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                    .foregroundColor(.gray)
                    .onTapGesture {
                        onToggleExpand()
                    }
            }
            .contentShape(Rectangle())
            .onTapGesture {
                onToggleExpand()
            }
            .padding(.vertical, 4)
            
            if isExpanded {
                VStack(alignment: .leading, spacing: 4) {
                    Text("名稱: \(item.name.isEmpty ? "尚未設定" : item.name)")
                    Text("條碼: \(item.barcode)")
                    Text("加入時間: \(item.dateAdded, formatter: dateFormatter)")
                }
                .font(.subheadline)
                .foregroundColor(.secondary)
                .padding(.top, 4)
            }
        }
        .padding(.vertical, 4)
    }
    
    private func commitNameChange() {
        if !tempName.trimmingCharacters(in: .whitespaces).isEmpty {
            item.name = tempName.trimmingCharacters(in: .whitespaces)
        }
        isEditingName = false
    }
}

private let dateFormatter: DateFormatter = {
    let df = DateFormatter()
    df.dateStyle = .short
    df.timeStyle = .short
    return df
}()
