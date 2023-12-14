//
//  NewNoteView.swift
//  Pantry
//
//  Created by nabbit on 08/11/2023.
//

import SwiftUI

struct NewNoteView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var noteStore: NoteStore
    @State var name: String = ""
    @State var isPinned: Bool = false
    @State var noteBody: String = ""
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
                        TextEditor(text: $noteBody)
                            .focused($isNoteFocused)
                            .multilineTextAlignment(.leading)
                            .disableAutocorrection(false)
                        if !isNoteFocused && noteBody.isEmpty {
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
                    noteStore.addNewEntry(name: self.name, noteBody: self.noteBody, isPinned: self.isPinned)
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
