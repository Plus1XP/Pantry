//
//  NewNoteView.swift
//  Pantry
//
//  Created by nabbit on 08/11/2023.
//

import SwiftUI

struct NewNoteView: View {
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var noteStore: NoteStore
    @State private var name: String = ""
    @State private var noteBody: String = ""
    @State private var switchTitle: String = ""
    @State var isPinned: Bool = false
    @State var isSwitchOn: Bool = false
    @State private var cancelAnimation: Bool = false
    @State private var saveAnimation: Bool = false
    @State private var canSaveChanges: Bool = false
    @Binding var isHideKeyboardButtonAcitve: Bool
    @FocusState private var isFocus: NoteField?
    private let sectionTitleColor: Color = Color.secondary
    private let bigScale: CGFloat = 1.1
    private let normalScale: CGFloat = 1
    private let smallScale: CGFloat = 0.9
    
    var body: some View {
        VStack {
            HStack {
                // Dummy Toggle to center note Title
                Toggle(isOn: $isPinned) {
                    Image(systemName: self.isPinned ? "pin.fill" : "pin")
                        .symbolEffect(.bounce.down, value: self.isPinned)
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
                Toggle(isOn: $isPinned) {
                    Image(systemName: self.isPinned ? "pin.fill" : "pin")
                        .symbolEffect(.bounce.down, value: self.isPinned)
                        .contentTransition(.symbolEffect(.replace))
                }
                .font(.title3)
                .foregroundStyle(.orange, .orange)
                .tint(.clear)
                .toggleStyle(.button)
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
                Toggle(isOn: $isSwitchOn) {
                    TextField("Untitled Switch", text: Binding(get: {self.switchTitle}, set: {self.switchTitle = $0}))
                        .multilineTextAlignment(.leading)
                        .textCase(nil)
                        .disableAutocorrection(false)
                        .padding(EdgeInsets(top: 0, leading: self.isFocus == .switchTitle ? 15: 0, bottom: 0, trailing: self.isFocus == .switchTitle ? 15: 0))
                        .focused($isFocus, equals: .switchTitle)
                        .scaleEffect(self.isFocus == .switchTitle ? self.bigScale: self.normalScale)
                }
                .padding([.leading, .trailing], 20)
            }
            .padding(.leading)
            .padding(.trailing)
            .padding(.bottom, (self.isFocus != nil) ? 5 : nil)
            
            if self.canSaveChanges {
                HStack {
                    Spacer()
                    Button(action: {
                        self.cancelAnimation = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                            self.cancelAnimation = false
                            self.noteStore.discardChanges()
                            self.canSaveChanges = false
                            self.isHideKeyboardButtonAcitve = false
                            self.hideKeyboard()
                            self.dismiss()
                        }
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
                .padding(.bottom, (self.isFocus != nil) ? 5 : nil)
                .disabled(!self.canSaveChanges)
            }
        }
        .padding(.top)
        .presentationDragIndicator(.visible)
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
        if self.name != "" || self.noteBody != "" || self.switchTitle != "" || self.isSwitchOn != false || self.isPinned != false {
            return true
        } else {
            return false
        }
    }
    
    private func saveNoteToStore() -> Void {
        self.noteStore.addNewEntry(name: self.name, body: self.noteBody, switchTitle: self.switchTitle, isSwitchOn: self.isSwitchOn, isPinned: self.isPinned)
        self.noteStore.saveChanges()
    }
}

#Preview {
    NewNoteView(isHideKeyboardButtonAcitve: .constant(false))
        .environmentObject(ItemStore())
        .preferredColorScheme(.light)
}
