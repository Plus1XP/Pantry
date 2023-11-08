//
//  NewNoteView.swift
//  Pantry
//
//  Created by nabbit on 08/11/2023.
//

import SwiftUI

struct NewNoteView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.managedObjectContext) private var viewContext
    @State var name: String = ""
    @State var isPinned: Bool = false
    @State var notes: String = ""
    @FocusState private var isNoteFocused: Bool
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Add a Note")
                .font(.title3)
                .padding(.horizontal)
            Divider()
            Group {
                HStack {
                    TextField("Name of new note", text: $name)
                        .multilineTextAlignment(.leading)
                        .disableAutocorrection(false)
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
                HStack {
                    Toggle(isOn: $isPinned) {
                        Text(Image(systemName: self.isPinned ? "pin.fill" : "pin"))
                    }
                    .foregroundStyle(.orange, .orange)
                    .toggleStyle(.button)
                    .tint(.clear)
                }
                .frame(maxWidth: .infinity, alignment: .center)
            }
            Divider()
            HStack{
                Spacer()
                Button("Add", systemImage: "plus.circle.fill", action: {
                    let newNote = Note(context: viewContext)
                    newNote.id = UUID()
                    newNote.created = Date()
                    newNote.modified = Date()
                    newNote.name = self.name
                    newNote.body = self.notes
                    newNote.pinned = self.isPinned
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
    NewNoteView()
}
