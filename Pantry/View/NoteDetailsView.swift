//
//  NoteDetailsView.swift
//  Pantry
//
//  Created by nabbit on 12/11/2023.
//

import SwiftUI

struct NoteDetailsView: View {
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var noteStore: NoteStore
    @State var note: Note
    @State private var isPinnedTrigger: Bool = false
    @Binding var canEditNote: Bool
    @FocusState private var isNoteFocused: Bool
    
    private let sectionTitleColor: Color = Color.secondary
    
    private let itemFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }()
    
    var body: some View {
        VStack {
            ZStack {
                TextField("Untitled Note", text: Binding(get: {note.name ?? ""}, set: {note.name = $0}))
                    .font(.title2)
                    .multilineTextAlignment(.center)
                    .textCase(nil)
                    .disableAutocorrection(false)
                    .disabled(!self.canEditNote)
                Toggle(isOn: $isPinnedTrigger) {
                    Text(Image(systemName: self.isPinnedTrigger ? "pin.fill" : "pin"))
                }
                .foregroundStyle(.orange, .orange)
                .toggleStyle(.button)
                .tint(.clear)
                .font(.title3)
                .frame(maxWidth: .infinity, alignment: .trailing)
                .disabled(!self.canEditNote)
                .onChange(of: self.isPinnedTrigger, {
                    note.isPinned = self.isPinnedTrigger
                })
            }
            .padding(.leading)
            .padding(.trailing)
            .padding(.bottom)
            
            // TextEditor does not have a placeholder Using a
            // ZStack & FocusState as a work around.
            ZStack(alignment: .topLeading) {
                if self.canEditNote {
                    TextEditor(text: Binding(get: {note.body ?? ""}, set: {note.body = $0}))
                        .scrollContentBackground(.hidden) // <- Hide it
                        .background(.clear) // To see this
                        .focused($isNoteFocused)
                } else {
                    ScrollView { // <-- add scroll around Text
                        Text(note.body ?? "")
                            .lineLimit(nil) // <-- tell Text to use as many lines as it needs (so no truncating)
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading) // <-- tell Text to take the entire space available for ScrollView
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity) // <-- if needed, tell ScrollView to use the full size of its parent too
                }
                if !self.isNoteFocused && (note.body == "") {
                    Text("No additional text")
                        .foregroundColor(Color(uiColor: .placeholderText))
                        .multilineTextAlignment(.leading)
                        .allowsHitTesting(false)
                }
            }
            .padding()
            .foregroundColor(.primary)
            .background(
                RoundedRectangle(
                    cornerRadius: 12,
                    style: .continuous
                )
                .fill(setFieldBackgroundColor(colorScheme: self.colorScheme))
            )
            .padding(.leading)
            .padding(.trailing)
            .padding(.bottom)

            if !self.canEditNote {
                HStack(alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/, content: {
                    Text("Last Modified")
                        .font(.footnote)
                        .textCase(nil)
                        .foregroundStyle(self.sectionTitleColor)
                })
                HStack(alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/, content: {
                    Text(note.modified!, formatter: self.itemFormatter)
                })
                .padding()
                .frame(maxWidth: .infinity)
                .foregroundColor(.primary)
                .background(
                    RoundedRectangle(
                        cornerRadius: 12,
                        style: .continuous
                    )
                    .fill(setFieldBackgroundColor(colorScheme: self.colorScheme))
                )
                .padding(.leading)
                .padding(.trailing)
                .padding(.bottom)
            }
            
            if self.canEditNote {
                HStack{
                    Spacer()
                    Button("Save", systemImage: "plus.circle", action: {
                        self.note.modified = Date()
                        self.noteStore.saveChanges()
                        self.canEditNote = false
                        self.dismiss()
                    })
                    .padding(.top)
                    .buttonStyle(.borderedProminent)
                    .tint(.green.opacity(0.9))
                    Spacer()
                    Button("Cancel", systemImage: "xmark.circle", action: {
                        self.noteStore.discardChanges()
                        self.canEditNote = false
                        self.dismiss()
                    })
                    .padding(.top)
                    .buttonStyle(.borderedProminent)
                    .tint(.red.opacity(0.9))
                    Spacer()
                }
                .foregroundStyle(.white, .white)
                .disabled(!self.canEditNote)
            }
        }
        .background(setViewBackgroundColor(colorScheme: self.colorScheme))
        .onAppear(perform: {
            self.isPinnedTrigger = note.isPinned
        })
    }
}

private func setViewBackgroundColor(colorScheme: ColorScheme) -> Color {
    return colorScheme == .light ? Color.secondaryBackground : Color.background
}

private func setFieldBackgroundColor(colorScheme: ColorScheme) -> Color {
    return colorScheme == .light ? Color.background : Color.secondaryBackground
}

#Preview {
    NoteDetailsView(note: PersistenceController.shared.sampleNote, canEditNote: .constant(false))
        .environmentObject(NoteStore())
        .preferredColorScheme(.light)
}

#Preview {
    NoteDetailsView(note: PersistenceController.shared.sampleNote, canEditNote: .constant(false))
        .environmentObject(NoteStore())
        .preferredColorScheme(.dark)
}
