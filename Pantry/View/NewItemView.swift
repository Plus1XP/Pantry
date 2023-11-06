//
//  new.swift
//  Pantry
//
//  Created by nabbit on 02/11/2023.
//

import SwiftUI

struct NewItemView: View {
    
    @Environment(\.dismiss) var dismiss
    @Environment(\.managedObjectContext) private var viewContext
    @State var name: String = ""
    @State var total: Int64 = 0
    @State var notes: String = ""
    @FocusState private var isNoteFocused: Bool

    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Add an item")
                .font(.title3)
                .padding(.horizontal)
            Divider()
            Group {
                HStack {
                    EmojiTextField(text: $name, placeholder: "Emoji of new item")
                        .multilineTextAlignment(.leading)
                        .disableAutocorrection(false)
                }
                HStack {
                    TextField("Total of new item", value: $total, formatter: Formatter.myNumberFormat)
                        .multilineTextAlignment(.leading)
                        .keyboardType(.decimalPad)
                }
                HStack {
                    // TextEditor does not have a placeholder
                    // Using a ZStack & FocusState as a work around.
                    ZStack(alignment: .topLeading) {
                        TextEditor(text: $notes)
                            .focused($isNoteFocused)
                            .multilineTextAlignment(.leading)
                            .disableAutocorrection(false)
                        if !isNoteFocused && notes.isEmpty {
                            Text("Notes of new item")
                                .multilineTextAlignment(.leading)
                                .disableAutocorrection(false)
                                .foregroundColor(Color(uiColor: .placeholderText))
                                .padding(.top, 10)
                                .allowsHitTesting(false)
                        }
                    }
                }
            }
            Divider()
            HStack{
                Spacer()
                Button("Add", systemImage: "plus.circle.fill", action: {
                    let newItem = Item(context: viewContext)
                    newItem.id = UUID()
                    newItem.created = Date()
                    newItem.modified = Date()
                    newItem.name = self.name
                    newItem.quantity = self.total
                    newItem.total = self.total
                    newItem.notes = self.notes
                    do {
                        try viewContext.save()
                    } catch {
                        // Replace this implementation with code to handle the error appropriately.
                        // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                        let nsError = error as NSError
                        fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
                    }
                    isNoteFocused = false
                    dismiss()
                })
                .padding(.top)
                .buttonStyle(.borderedProminent)
                Spacer()
            }
        }
        .padding()
    }
}

#Preview {
    NewItemView()
}
