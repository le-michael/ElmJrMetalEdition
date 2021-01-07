//
//  Char.swift
//  ElmJrMetalEdition
//
//  Created by Lucas Dutton on 2020-12-31.
//  Copyright © 2020 Thomas Armena. All rights reserved.
//

import Foundation

/* Given that the Elm implementation works only on single unicode
 scalar values, we only need to check the starting index of the
 character
 */
func _Char_toCode(c: Character) -> Int {
    let scalars = c.unicodeScalars
    let firstScalar = scalars[scalars.startIndex]
    return Int(firstScalar.value)
}

/* This assumes that Swift is able to unwrap a UnicodeScalar
  into the proper representation. The JS implementation breaks
 the input into two separate codepoints if the value is too large
 */
func _Char_fromCode(code: Int) -> Character {
    return (
        (code < 0 || code > 0x10FFFF)
            ? Character("\u{FFD}")
            : Character(UnicodeScalar(code)!)
    )
}

func _Char_toUpper(char: Character) -> Character {
    return Character(char.uppercased())
}

func _Char_toLower(char: Character) -> Character {
    return Character(char.lowercased())
}

func _Char_toLocaleUpper(char: Character) -> Character {
    // Try obtaining the user's current locale, defaulting to empty
    let locale = Locale.current.languageCode ?? ""
    let charStr = String(char)
    return Character(charStr.uppercased(with: Locale(identifier: locale)))
}

func _Char_toLocaleLower(char: Character) -> Character {
    // Try obtaining the user's current locale, defaulting to empty
    let locale = Locale.current.languageCode ?? ""
    let charStr = String(char)
    return Character(charStr.lowercased(with: Locale(identifier: locale)))
}
