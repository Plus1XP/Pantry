//
//  NoteDetailsView.swift
//  Pantry
//
//  Created by nabbit on 12/11/2023.
//

import SwiftUI

struct NoteDetailsView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var noteStore: NoteStore
    @State var note: Note
    @State var isPinnedTrigger: Bool = false
    @Binding var canEditNote: Bool
    @FocusState private var isNoteFocused: Bool
    
        
    var body: some View {
        Form {
            Section {
//                     TextEditor does not have a placeholder
//                     Using a ZStack & FocusState as a work around.
                    ZStack(alignment: .topLeading) {
                        TextEditor(text: Binding(get: {note.body ?? ""}, set: {note.body = $0}))
                            .focused($isNoteFocused)
                            .multilineTextAlignment(.center)
                            .disableAutocorrection(false)
                        if !isNoteFocused && ((note.body?.isEmpty) == nil) {
                            Text("Notes of new item")
                                .multilineTextAlignment(.leading)
                                .disableAutocorrection(false)
                                .foregroundColor(Color(uiColor: .placeholderText))
                                .padding(.top, 10)
                                .allowsHitTesting(false)
                        }
                    }
                    .disabled(!self.canEditNote)
            } header: {
                ZStack {
                    TextField("Name of new note", text: Binding(get: {note.name ?? ""}, set: {note.name = $0}))
                        .font(.title2)
                        .multilineTextAlignment(.center)
                        .textCase(nil)
                        .disableAutocorrection(false)
                        .disabled(!self.canEditNote)
                    Toggle(isOn: $isPinnedTrigger) {
                        Text(Image(systemName: isPinnedTrigger ? "pin.fill" : "pin"))
                    }
                    .foregroundStyle(.orange, .orange)
                    .toggleStyle(.button)
                    .tint(.clear)
                    .font(.title3)
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .disabled(!self.canEditNote)
                    .onChange(of: isPinnedTrigger, {
                        note.isPinned = isPinnedTrigger
                    })
                }
            } footer: {
                
            }
            Section(header: Text("Last Modified").frame(maxWidth: .infinity, alignment: .center)) {
                HStack {
                    Text(note.modified!, formatter: itemFormatter)
                        .frame(maxWidth: .infinity, alignment: .center)
                }
            }
            if canEditNote {
                HStack{
                    Spacer()
                    Button("Save", systemImage: "plus.circle", action: {
                        note.modified = Date()
                        noteStore.saveChanges()
                        self.canEditNote = false
                        dismiss()
                    })
                    .padding(.top)
                    .buttonStyle(.borderedProminent)
                    .tint(.green)
                    Spacer()
                    Button("Cancel", systemImage: "xmark.circle", action: {
                        noteStore.discardChanges()
                        self.canEditNote = false
                        dismiss()
                    })
                    .padding(.top)
                    .buttonStyle(.borderedProminent)
                    .tint(.red)
                    Spacer()
                }
                .foregroundStyle(.white, .white)
                .listRowBackground(Color.clear)
                .disabled(!self.canEditNote)
            }
            
        }
        .onAppear(perform: {
            isPinnedTrigger = note.isPinned
        })
        .onDisappear(perform:
        {
            self.canEditNote = false
        })
    }
}

private let itemFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .medium
    formatter.timeStyle = .short
    return formatter
}()

#Preview {
    NoteDetailsView(note: PersistenceController.shared.sampleNote, canEditNote: .constant(false))
}
