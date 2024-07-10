//
//  Character.swift
//  PantryPal
//
//  Created by nabbit on 01/07/2024.
//

import Foundation

extension Character {
    var isEmoji: Bool {
        guard let scalar = unicodeScalars.first else { return false }
        return scalar.properties.isEmoji && (scalar.value > 0x238C || unicodeScalars.count > 1)
    }
}
