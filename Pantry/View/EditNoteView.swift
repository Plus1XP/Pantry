//
//  edit.swift
//  Pantry
//
//  Created by nabbit on 02/11/2023.
//

import SwiftUI

struct EditNoteView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.managedObjectContext) private var viewContext
//    @State var tempItem: Item = Item()
    @State var tempNote: String = ""
    @ObservedObject var note: Note
    
//    init(item: Item) {
//        self.tempItem = item
//        self.tempNote = self.tempItem.notes!
//    }
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Edit Note")
                .font(.title3)
                .padding(.horizontal)
            Divider()
            Group {
                HStack {
                    TextEditor(text: $tempNote)
                        .disableAutocorrection(false)
                }
            }
            Divider()
            HStack{
                Spacer()
                Button("Save", systemImage: "plus.circle", action: {
                    note.body = self.tempNote
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
            self.tempNote = note.body ?? ""
        })
    }
}

#Preview {
    return EditNoteView(note: PersistenceController.shared.samepleNote)
}

