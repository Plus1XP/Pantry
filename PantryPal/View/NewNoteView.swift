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
    @State var switchTitle: String = ""
    @State var isSwitchOn: Bool = false
    @FocusState private var isNoteFocused: Bool
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Add Note")
                .font(.title3)
                .padding(.horizontal)
            Divider()
            Group {
                HStack {
                    TextField("Name Note", text: $name)
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
                            Text("Enter Contents")
                                .multilineTextAlignment(.leading)
                                .disableAutocorrection(false)
                                .foregroundColor(Color(uiColor: .placeholderText))
                                .padding(.top, 10)
                                .allowsHitTesting(false)
                        }
                    }
                }
                HStack {
                    Toggle(isOn: $isSwitchOn) {
                        TextField("Name Switch", text: $switchTitle)
                            .multilineTextAlignment(.leading)
                            .disableAutocorrection(false)
                    }
                }
                HStack {
                    Toggle(isOn: $isPinned) {
                        Image(systemName: self.isPinned ? "pin.fill" : "pin")
                            .symbolEffect(.bounce.down, value: self.isPinned)
                            .contentTransition(.symbolEffect(.replace))
                    }
                    .font(.title2)
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
                    noteStore.addNewEntry(name: self.name, body: self.noteBody, switchTitle: self.switchTitle, isSwitchOn: self.isSwitchOn, isPinned: self.isPinned)
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
