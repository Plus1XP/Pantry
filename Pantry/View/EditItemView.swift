//
//  EditItemView.swift
//  Pantry
//
//  Created by nabbit on 08/11/2023.
//

import SwiftUI

struct EditItemView: View {
@Environment(\.dismiss) var dismiss
@Environment(\.managedObjectContext) private var viewContext
//    @State var tempItem: Item = Item()
    @State var tempName: String = ""
    @State var tempTotal: Int64 = 0
@State var tempNote: String = ""
@ObservedObject var item: Item
    @FocusState private var isNoteFocused: Bool


//    init(item: Item) {
//        self.tempItem = item
//        self.tempNote = self.tempItem.notes!
//    }

var body: some View {
    VStack(alignment: .leading) {
        Text("Edit Note")
            .font(.title3)
            .frame(maxWidth: .infinity, alignment: .center)
        Divider()
        Group {
            HStack {
                EmojiTextField(text: $tempName, placeholder: "Emoji of new item")
                    .disableAutocorrection(false)
                    .textFieldStyle(.plain)
                                .multilineTextAlignment(.center)
            }
        }
        Divider()
        Group {
            HStack {
                TextField("Total of new item", value: $tempTotal, formatter: Formatter.myNumberFormat)
                    .keyboardType(.decimalPad)
                    .textFieldStyle(.plain)
                                .multilineTextAlignment(.center)
            }
        }
        Divider()
        Group {
            HStack {
                // TextEditor does not have a placeholder
                // Using a ZStack & FocusState as a work around.
                ZStack(alignment: .topLeading) {
                    TextEditor(text: $tempNote)
                        .focused($isNoteFocused)
                        .multilineTextAlignment(.leading)
                        .disableAutocorrection(false)
                    if !isNoteFocused && tempNote.isEmpty {
                        Text("Notes of new item")
                            .multilineTextAlignment(.leading)
                            .disableAutocorrection(false)
                            .foregroundColor(Color(uiColor: .placeholderText))
                            .padding(.top, 10)
                            .allowsHitTesting(false)
                    }
                }
//                TextEditor(text: $tempNote)
//                    .disableAutocorrection(false)
            }
        }
        Divider()
        HStack{
            Spacer()
            Button("Save", systemImage: "plus.circle", action: {
                item.name = self.tempName
                item.total = self.tempTotal
                item.notes = self.tempNote
                do {
                    try viewContext.save()
                } catch {
                    // Replace this implementation with code to handle the error appropriately.
                    // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                    let nsError = error as NSError
                    fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
                }
                dismiss()
            })
            .padding(.top)
            .buttonStyle(.borderedProminent)
            .tint(.green)
            Spacer()
            Button("Cancel", systemImage: "xmark.circle", action: {
                dismiss()
            })
            .padding(.top)
            .buttonStyle(.borderedProminent)
            .tint(.red)
            Spacer()
        }
        .foregroundStyle(.white, .white)
    }
    .padding()
    .onAppear(perform: {
        self.tempName = item.name ?? ""
        self.tempTotal = item.total ?? 0
        self.tempNote = item.notes ?? ""
    })
}
}

#Preview {
return EditItemView(item: PersistenceController.shared.samepleItem)
}
