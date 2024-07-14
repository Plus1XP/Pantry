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
    @State private var name: String = "" {
        didSet {
            self.canSaveChanges = self.hasAnyNoteValueChanged()
        }
    }
    @State private var noteBody: String = "" {
        didSet {
            self.canSaveChanges = self.hasAnyNoteValueChanged()
        }
    }
    @State private var switchTitle: String = "" {
        didSet {
            self.canSaveChanges = self.hasAnyNoteValueChanged()
        }
    }
    @State private var isPinnedTrigger: Bool = false
    @State private var isSwitchOnTrigger: Bool = false
    @State private var clearAnimation: Bool = false
    @State private var saveAnimation: Bool = false
    @State private var canSaveChanges: Bool = false
    @State private var canHideLastModifiedField: Bool = false
    @Binding var isHideKeyboardButtonAcitve: Bool
    @FocusState private var isNameFieldFocus: Bool
    @FocusState private var isBodyFieldFocus: Bool
    @FocusState private var isSwitchTitleFieldFocus: Bool
    var note: Note
    private let sectionTitleColor: Color = Color.secondary
    private let bigScale: CGFloat = 1.1
    private let normalScale: CGFloat = 1
    private let smallScale: CGFloat = 0.9
    
    var body: some View {
        VStack {
            HStack {
                TextField("Untitled Note", text: Binding(get: {self.name}, set: {self.name = $0}))
                    .font(.title2)
                    .multilineTextAlignment(.leading)
                    .textCase(nil)
                    .disableAutocorrection(false)
                    .focused($isNameFieldFocus)
                    .onChange(of: self.isNameFieldFocus, {
                        self.showDismissKeyboardButtonIfTrue(focusState: self.isNameFieldFocus)
                    })
                    .scaleEffect(self.isNameFieldFocus ? self.bigScale: self.normalScale)
                    .padding(.leading, 20)
                    .padding(EdgeInsets(top: 0, leading: self.isNameFieldFocus ? 15: 0, bottom: 0, trailing: self.isNameFieldFocus ? 15: 0))
                    .frame(maxWidth: .infinity, alignment: .center)
                
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
            .padding(.bottom)
            
            // TextEditor does not have a placeholder Using a
            // ZStack & FocusState as a work around.
            ZStack(alignment: .topLeading) {
                TextEditor(text: Binding(get: {self.noteBody}, set: {self.noteBody = $0}))
                    .scrollContentBackground(.hidden) // <- Hide it
                    .background(.clear) // To see this
                    .focused($isBodyFieldFocus)
                    .onChange(of: self.isBodyFieldFocus, {
                        self.showDismissKeyboardButtonIfTrue(focusState: self.isBodyFieldFocus)
                    })
                if !self.isBodyFieldFocus && (self.noteBody == "") {
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
                .fill(Color.setFieldBackgroundColor(colorScheme: self.colorScheme))
            )
            .border(self.isBodyFieldFocus ? self.colorScheme == .light ? .white : Color(UIColor.secondarySystemBackground) : .clear)
            .cornerRadius(12)
            .shadow(color: self.isBodyFieldFocus ? self.colorScheme == .light ? .gray.opacity(0.4) : .white.opacity(0.4) : .clear, radius: 2)
            .padding(.leading)
            .padding(.trailing)
            .padding(.bottom)
            
            HStack {
                Toggle(isOn: $isSwitchOnTrigger) {
                    TextField("Untitled Switch", text: Binding(get: {self.switchTitle}, set: {self.switchTitle = $0}))
                        .multilineTextAlignment(.leading)
                        .textCase(nil)
                        .disableAutocorrection(false)
                        .padding(EdgeInsets(top: 0, leading: self.isSwitchTitleFieldFocus ? 15: 0, bottom: 0, trailing: self.isSwitchTitleFieldFocus ? 15: 0))
                        .focused($isSwitchTitleFieldFocus)
                        .onChange(of: self.isSwitchTitleFieldFocus, {
                            self.showDismissKeyboardButtonIfTrue(focusState: self.isSwitchTitleFieldFocus)
                        })
                        .scaleEffect(self.isSwitchTitleFieldFocus ? self.bigScale: self.normalScale)
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
                        self.clearAnimation = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                            self.clearAnimation = false
                            self.name = self.note.name ?? ""
                            self.noteBody = self.note.body ?? ""
                            self.switchTitle = self.note.switchTitle ?? ""
                            self.isPinnedTrigger = self.note.isPinned
                            self.isSwitchOnTrigger = self.note.isSwitchOn
                            self.noteStore.discardChanges()
                            self.canSaveChanges = false
                            self.resetFocusState()
                        }
                    }, label: {
                        Image(systemName: self.clearAnimation ? "xmark.circle" : "xmark.circle.fill")
                            .font(.largeTitle)
                            .foregroundStyle(.red)
                            .symbolEffect(.bounce, options: .speed(2), value: self.clearAnimation)
                            .symbolEffect(.pulse.wholeSymbol, options: .repeating, value: self.clearAnimation)
                            .contentTransition(.symbolEffect(.replace))
                            .background(
                                Circle()
                                    .fill(Color.setFieldBackgroundColor(colorScheme: self.colorScheme).opacity(1))
                                    .cornerRadius(25.0)
                            )
                    })
                    Spacer()
                    Button(action: {
                        self.saveAnimation = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                            self.saveAnimation = false
                            self.note.name = self.name
                            self.note.body = self.noteBody
                            self.note.switchTitle = self.switchTitle
                            self.isPinnedTrigger = self.note.isPinned
                            self.isSwitchOnTrigger = self.note.isSwitchOn
                            self.note.modified = Date()
                            self.noteStore.saveChanges()
                            self.canSaveChanges = false
                            self.dismiss()
                        }
                    }, label: {
                        Image(systemName: self.saveAnimation ? "checkmark.circle" : "checkmark.circle.fill")
                            .font(.largeTitle)
                            .foregroundStyle(.green)
                            .symbolEffect(.bounce, options: .speed(2), value: self.saveAnimation)
                            .symbolEffect(.pulse.wholeSymbol, options: .repeating, value: self.saveAnimation)
                            .contentTransition(.symbolEffect(.replace))
                            .background(
                                Circle()
                                    .fill(Color.setFieldBackgroundColor(colorScheme: self.colorScheme).opacity(1))
                                    .cornerRadius(25.0)
                            )
                    })
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
            self.name = self.note.name ?? ""
            self.noteBody = self.note.body ?? ""
            self.switchTitle = self.note.switchTitle ?? ""
            self.isPinnedTrigger = self.note.isPinned
            self.isSwitchOnTrigger = self.note.isSwitchOn
        })
        .onChange(of: self.isHideKeyboardButtonAcitve, {
            if !self.isHideKeyboardButtonAcitve {
                self.resetFocusState()
            }
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
    
    private func isAnyFieldFocused() -> Bool {
        if self.isNameFieldFocus == true || self.isBodyFieldFocus == true  || self.isSwitchTitleFieldFocus == true {
            return true
        } else {
            return false
        }
    }
    
    private func showDismissKeyboardButtonIfTrue(focusState: Bool) -> Void {
        if focusState {
            self.isHideKeyboardButtonAcitve = true
        }
    }
    
    private func resetFocusState() -> Void {
        self.isNameFieldFocus = false
        self.isBodyFieldFocus = false
        self.isSwitchTitleFieldFocus = false
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
