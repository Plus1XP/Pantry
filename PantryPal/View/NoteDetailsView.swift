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
    @State private var name: String = ""
    @State private var noteBody: String = ""
    @State private var switchTitle: String = ""
    @State private var isPinnedTrigger: Bool = false
    @State private var isSwitchOnTrigger: Bool = false
    @State private var cancelAnimation: Bool = false
    @State private var saveAnimation: Bool = false
    @State private var canSaveChanges: Bool = false
    @State private var canHideLastModifiedField: Bool = false
    @Binding var isHideKeyboardButtonAcitve: Bool
    @FocusState private var isFocus: NoteField?
    var note: Note
    private let sectionTitleColor: Color = Color.secondary
    private let bigScale: CGFloat = 1.1
    private let normalScale: CGFloat = 1
    private let smallScale: CGFloat = 0.9
    
    var body: some View {
        VStack {
            HStack {
                // Dummy Toggle to center note Title
                Toggle(isOn: $isPinnedTrigger) {
                    Image(systemName: self.isPinnedTrigger ? "pin.fill" : "pin")
                        .symbolEffect(.bounce.down, value: self.isPinnedTrigger)
                        .contentTransition(.symbolEffect(.replace))
                }
                .font(.title3)
                .foregroundStyle(.orange, .orange)
                .tint(.clear)
                .toggleStyle(.button)
                .frame(maxWidth: 25, alignment: .center)
                .hidden()
                Spacer()
                TextField("Untitled Note", text: Binding(get: {self.name}, set: {self.name = $0}))
                    .font(.title2)
                    .multilineTextAlignment(.center)
                    .textCase(nil)
                    .disableAutocorrection(false)
                    .focused($isFocus, equals: .name)
                    .scaleEffect(self.isFocus == .name ? self.bigScale: self.normalScale)
                Spacer()
                Toggle(isOn: $isPinnedTrigger) {
                    Image(systemName: self.isPinnedTrigger ? "pin.fill" : "pin")
                        .symbolEffect(.bounce.down, value: self.isPinnedTrigger)
                        .contentTransition(.symbolEffect(.replace))
                }
                .font(.title3)
                .foregroundStyle(.orange, .orange)
                .tint(.clear)
                .toggleStyle(.button)
                .onChange(of: self.isPinnedTrigger, {
                    self.note.isPinned = self.isPinnedTrigger
                    self.noteStore.saveChanges()
                })
                .frame(maxWidth: 25, alignment: .center)
            }
            .padding(.leading)
            .padding(.trailing)
            .padding(.bottom, (self.isFocus != nil) ? 0 : nil)
            
            // TextEditor does not have a placeholder Using a
            // ZStack & FocusState as a work around.
            ZStack(alignment: .topLeading) {
                TextEditor(text: Binding(get: {self.noteBody}, set: {self.noteBody = $0}))
                    .scrollContentBackground(.hidden) // <- Hide it
                    .background(.clear) // To see this
                    .focused($isFocus, equals: .noteBody)

                if (self.isFocus != .noteBody ) && (self.noteBody == "") {
                    Text("No additional text")
                        .foregroundColor(Color(uiColor: .placeholderText))
                        .multilineTextAlignment(.leading)
                        .allowsHitTesting(false)
                }
            }
            .withFocusFieldStyle(colorScheme: self.colorScheme, focusState: self.isFocus == .noteBody)
            .padding(.leading)
            .padding(.trailing)
            .padding(.bottom, (self.isFocus != nil) ? 0 : nil)

            
            HStack {
                Toggle(isOn: $isSwitchOnTrigger) {
                    TextField("Untitled Switch", text: Binding(get: {self.switchTitle}, set: {self.switchTitle = $0}))
                        .multilineTextAlignment(.leading)
                        .textCase(nil)
                        .disableAutocorrection(false)
                        .padding(EdgeInsets(top: 0, leading: self.isFocus == .switchTitle ? 15: 0, bottom: 0, trailing: self.isFocus == .switchTitle ? 15: 0))
                        .focused($isFocus, equals: .switchTitle)
                        .scaleEffect(self.isFocus == .switchTitle ? self.bigScale: self.normalScale)
                }
                .padding([.leading, .trailing], 20)
                .onChange(of: self.isSwitchOnTrigger, {
                    self.note.isSwitchOn = self.isSwitchOnTrigger
                    self.note.modified = Date()
                    self.noteStore.saveChanges()
                })
            }
            .padding(.leading)
            .padding(.trailing)
            .padding(.bottom)
            
            if !self.isHideKeyboardButtonAcitve {
                HStack(alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/, content: {
                    Text("Last Modified")
                        .font(.footnote)
                        .textCase(nil)
                        .foregroundStyle(self.sectionTitleColor)
                })
                HStack(alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/, content: {
                    Text(self.note.modified!, formatter: Formatter.dateFormatter)
                })
                .padding()
                .frame(maxWidth: .infinity)
                .foregroundColor(.primary)
                .background(
                    RoundedRectangle(
                        cornerRadius: 12,
                        style: .continuous
                    )
                    .fill(Color.setFieldBackgroundColor(colorScheme: self.colorScheme))
                )
                .padding(.leading)
                .padding(.trailing)
                .padding(.bottom)
            }
            
            if self.canSaveChanges {
                HStack {
                    Spacer()
                    Button(action: {
                        self.cancelAnimation = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                            self.cancelAnimation = false
                            self.loadNoteFromStore()
                            self.canSaveChanges = false
                            self.isHideKeyboardButtonAcitve = false
                            self.hideKeyboard()                        }
                    }, label: {
                        Image(systemName: self.cancelAnimation ? "xmark.circle" : "xmark.circle.fill")
                    })
                    .buttonStyle(CancelButtonStyle(cancelAnimation: self.cancelAnimation))
                    Spacer()
                    Button(action: {
                        self.saveAnimation = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                            self.saveAnimation = false
                            self.saveNoteToStore()
                            self.canSaveChanges = false
                            self.dismiss()
                        }
                    }, label: {
                        Image(systemName: self.saveAnimation ? "checkmark.circle" : "checkmark.circle.fill")
                    })
                    .buttonStyle(SaveButtonStyle(saveAnimation: self.saveAnimation))
                    Spacer()
                }
                .frame(maxWidth: .infinity)
                .padding(.leading)
                .padding(.trailing)
                .padding(.bottom)
                .disabled(!self.canSaveChanges)
            }
        }
        .onAppear(perform: {
            self.loadNoteFromStore()
        })
        .onChange(of: self.isFocus, {
            if (self.isFocus != nil) {
                self.isHideKeyboardButtonAcitve = true
            }
        })
        .onChange(of: self.isHideKeyboardButtonAcitve, {
            if !self.isHideKeyboardButtonAcitve {
                self.hideKeyboard()
            }
        })
        .onChange(of: self.hasAnyNoteValueChanged(), {
            withAnimation(.bouncy, {
                self.canSaveChanges = self.hasAnyNoteValueChanged()
            })
        })
        .background(Color.setViewBackgroundColor(colorScheme: self.colorScheme))
    }
    
    private func hasAnyNoteValueChanged() -> Bool {
        if self.name != self.note.name || self.noteBody != self.note.body || self.switchTitle != self.note.switchTitle {
            return true
        } else {
            return false
        }
    }
    
    private func loadNoteFromStore() -> Void {
        self.name = self.note.name ?? ""
        self.noteBody = self.note.body ?? ""
        self.switchTitle = self.note.switchTitle ?? ""
        self.isPinnedTrigger = self.note.isPinned
        self.isSwitchOnTrigger = self.note.isSwitchOn
        self.noteStore.discardChanges()
    }
    
    private func saveNoteToStore() -> Void {
        self.note.name = self.name
        self.note.body = self.noteBody
        self.note.switchTitle = self.switchTitle
        self.isPinnedTrigger = self.note.isPinned
        self.isSwitchOnTrigger = self.note.isSwitchOn
        self.note.modified = Date()
        self.noteStore.saveChanges()
    }
}

#Preview {
    NoteDetailsView(isHideKeyboardButtonAcitve: .constant(false), note: PersistenceController.shared.sampleNote)
        .environmentObject(NoteStore())
        .preferredColorScheme(.light)
}

#Preview {
    NoteDetailsView(isHideKeyboardButtonAcitve: .constant(false), note: PersistenceController.shared.sampleNote)
        .environmentObject(NoteStore())
        .preferredColorScheme(.dark)
}
