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
    @State var isPinned: Bool = false
    @State var isSwitchOn: Bool = false
    @State private var clearAnimation: Bool = false
    @State private var saveAnimation: Bool = false
    @State private var canSaveChanges: Bool = false
    @FocusState private var isNameFieldFocus: Bool
    @FocusState private var isBodyFieldFocus: Bool
    @FocusState private var isSwitchTitleFieldFocus: Bool
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
                    .scaleEffect(self.isNameFieldFocus ? self.bigScale: self.normalScale)
                    .padding(.leading, 20)
                    .padding(EdgeInsets(top: 0, leading: self.isNameFieldFocus ? 15: 0, bottom: 0, trailing: self.isNameFieldFocus ? 15: 0))
                    .frame(maxWidth: .infinity, alignment: .center)
                
                Toggle(isOn: $isPinned) {
                    Image(systemName: self.isPinned ? "pin.fill" : "pin")
                        .symbolEffect(.bounce.down, value: self.isPinned)
                        .contentTransition(.symbolEffect(.replace))
                }
                .font(.title3)
                .foregroundStyle(.orange, .orange)
                .tint(.clear)
                .toggleStyle(.button)
                .onChange(of: self.isPinned, {
                    self.canSaveChanges = self.hasAnyNoteValueChanged()
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
                Toggle(isOn: $isSwitchOn) {
                    TextField("Untitled Switch", text: Binding(get: {self.switchTitle}, set: {self.switchTitle = $0}))
                        .multilineTextAlignment(.leading)
                        .textCase(nil)
                        .disableAutocorrection(false)
                        .padding(EdgeInsets(top: 0, leading: self.isSwitchTitleFieldFocus ? 15: 0, bottom: 0, trailing: self.isSwitchTitleFieldFocus ? 15: 0))
                        .focused($isSwitchTitleFieldFocus)
                        .scaleEffect(self.isSwitchTitleFieldFocus ? self.bigScale: self.normalScale)
                }
                .padding([.leading, .trailing], 20)
                .onChange(of: self.isSwitchOn, {
                    self.canSaveChanges = self.hasAnyNoteValueChanged()
                })
            }
            .padding(.leading)
            .padding(.trailing)
            .padding(.bottom)
            
            if self.canSaveChanges {
                HStack {
                    Spacer()
                    Button(action: {
                        self.clearAnimation = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                            self.clearAnimation = false
                            self.noteStore.discardChanges()
                            self.canSaveChanges = false
                            self.resetFocusState()
                            self.dismiss()
                        }
                    }, label: {
                        Image(systemName: self.clearAnimation ? "xmark.circle" : "xmark.circle.fill")
                    })
                    .buttonStyle(CancelButtonStyle(clearAnimation: $clearAnimation))
                    Spacer()
                    Button(action: {
                        self.saveAnimation = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                            self.saveAnimation = false
                            self.noteStore.addNewEntry(name: self.name, body: self.noteBody, switchTitle: self.switchTitle, isSwitchOn: self.isSwitchOn, isPinned: self.isPinned)
                            self.noteStore.saveChanges()
                            self.canSaveChanges = false
                            self.dismiss()
                        }
                    }, label: {
                        Image(systemName: self.saveAnimation ? "checkmark.circle" : "checkmark.circle.fill")
                    })
                    .buttonStyle(SaveButtonStyle(saveAnimation: $saveAnimation))
                    Spacer()
                }
                .frame(maxWidth: .infinity)
                .padding(.leading)
                .padding(.trailing)
                .padding(.bottom)
                .disabled(!self.canSaveChanges)
            }
        }
        .padding(.top)
        .presentationDragIndicator(.visible)
        .background(Color.setViewBackgroundColor(colorScheme: self.colorScheme))
    }
    
    private func hasAnyNoteValueChanged() -> Bool {
        if self.name != "" || self.noteBody != "" || self.switchTitle != "" || self.isSwitchOn != false || self.isPinned != false {
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
    
    private func resetFocusState() -> Void {
        self.isNameFieldFocus = false
        self.isBodyFieldFocus = false
        self.isSwitchTitleFieldFocus = false
    }
}

#Preview {
    NewNoteView()
        .environmentObject(ItemStore())
        .preferredColorScheme(.light)
}
