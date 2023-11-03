//
//  edit.swift
//  Pantry
//
//  Created by nabbit on 02/11/2023.
//

import SwiftUI

struct EditNotesView: View {
    
    @Environment(\.dismiss) var dismiss
    @Environment(\.managedObjectContext) private var viewContext
    @State var name: String = ""
    @ObservedObject var item: Item
    var body: some View {
        VStack(alignment: .leading) {
            Text("Edit Note")
                .font(.title3)
                .padding(.horizontal)
            
            Divider()
            
            Group {
                HStack {
                    TextEditor(text: $item.notes.toUnwrapped(defaultValue: ""))
                        .disableAutocorrection(false)
                }
            }
            
            Divider()
            
            HStack{
                Spacer()
                Button(action: {
                    do {
                        try viewContext.save()
                    } catch {
                        // Replace this implementation with code to handle the error appropriately.
                        // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                        let nsError = error as NSError
                        fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
                    }
                    dismiss()
                }) {
                    Label("Save Note", systemImage: "cart.badge.plus.fill")
                }
                .padding(.top)
                .buttonStyle(GrowingButton())
                Spacer()
            }
        }
        .padding()
    }
}

#Preview {
    return EditNotesView(item: PersistenceController.shared.samepleItem)
}

