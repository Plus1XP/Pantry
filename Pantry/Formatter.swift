//
//  Formatter.swift
//  Pantry
//
//  Created by nabbit on 01/11/2023.
//

import Foundation

extension Formatter {
    static let myNumberFormat: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .none
        formatter.zeroSymbol  = ""     // Show empty string instead of zero
        return formatter
    }()
}
