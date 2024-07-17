//
//  EmojiTextField.swift
//  Pantry
//
//  Created by nabbit on 02/11/2023.
//

import SwiftUI

// Allows a user to pick an emoji character using the Emoji keyboard.
/// - Note: This does not prevent the user from manually switching to other keyboards and inputting a non-Emoji character
struct EmojiPicker: UIViewRepresentable {
    @Binding var emoji: String
    var placeholder: String = ""
    var emojiAlignment: NSTextAlignment = .left
    var isEmoji: Bool = true
    var fontStyle: UIFont.TextStyle = .body
    var fontSize: CGFloat = 16
    
    init(emoji: Binding<String>, placeholder: String, emojiAlignment: NSTextAlignment) {
        self._emoji = emoji
        self.placeholder = placeholder
        self.emojiAlignment = emojiAlignment
    }
    
    init(emoji: Binding<String>, placeholder: String, emojiAlignment: NSTextAlignment, isEmoji: Bool) {
        self._emoji = emoji
        self.placeholder = placeholder
        self.emojiAlignment = emojiAlignment
        self.isEmoji = isEmoji
    }
    
    init(emoji: Binding<String>, placeholder: String, emojiAlignment: NSTextAlignment, fontStyle: UIFont.TextStyle) {
        self._emoji = emoji
        self.placeholder = placeholder
        self.emojiAlignment = emojiAlignment
        self.fontStyle = fontStyle
    }
    
    init(emoji: Binding<String>, placeholder: String, emojiAlignment: NSTextAlignment, fontSize: CGFloat) {
        self._emoji = emoji
        self.placeholder = placeholder
        self.emojiAlignment = emojiAlignment
        self.fontSize = fontSize
    }
    
    init(emoji: Binding<String>, placeholder: String, emojiAlignment: NSTextAlignment, isEmoji: Bool, fontStyle: UIFont.TextStyle) {
        self._emoji = emoji
        self.placeholder = placeholder
        self.emojiAlignment = emojiAlignment
        self.isEmoji = isEmoji
        self.fontStyle = fontStyle
    }
    
    init(emoji: Binding<String>, placeholder: String, emojiAlignment: NSTextAlignment, isEmoji: Bool, fontSize: CGFloat) {
        self._emoji = emoji
        self.placeholder = placeholder
        self.emojiAlignment = emojiAlignment
        self.isEmoji = isEmoji
        self.fontSize = fontSize
    }
    
    func makeUIView(context: UIViewRepresentableContext<EmojiPicker>) -> EmojiUITextField {
        let emojiTextField = EmojiUITextField(frame: .zero)
        emojiTextField.text = emoji
        emojiTextField.placeholder = placeholder
        emojiTextField.delegate = context.coordinator
        emojiTextField.autocorrectionType = .no
        emojiTextField.returnKeyType = .done
        emojiTextField.textAlignment = emojiAlignment
        emojiTextField.font = UIFont.preferredFont(forTextStyle: fontStyle)
        emojiTextField.font = UIFont.systemFont(ofSize: fontSize)
        emojiTextField.tintColor = .clear
        
        // Changes the size of the place holder text to 17, equal to default body size.
//        emojiTextField.attributedPlaceholder = NSAttributedString(string: placeholder, attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 17)])
        return emojiTextField
    }
    
    func updateUIView(_ uiView: EmojiUITextField, context: Context) {
        uiView.text = emoji
    }
    
    func makeCoordinator() -> EmojiTextFieldCoordinator {
        return EmojiTextFieldCoordinator(self)
    }
}

internal class EmojiTextFieldCoordinator: NSObject, UITextFieldDelegate {
    var emojiTextField: EmojiPicker
    
    init(_ textField: EmojiPicker) {
        self.emojiTextField = textField
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        self.emojiTextField.emoji = textField.text!
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        textField.text = string
        
        if let text = textField.text, text.count == 1 {
            self.emojiTextField.emoji = textField.text!
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        }
        
        return true
    }
}

internal class EmojiUITextField: UITextField {
    override var textInputContextIdentifier: String? {
        return ""
    }
    
    override var textInputMode: UITextInputMode? {
        return .activeInputModes.first(where: { $0.primaryLanguage == "emoji" })
    }
    
    override func selectionRects(for range: UITextRange) -> [UITextSelectionRect] {
        return []
    }
}
