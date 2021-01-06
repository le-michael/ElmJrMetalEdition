//
//  EVTheme.swift
//  ElmJrMetalEdition
//
//  Created by Thomas Armena on 2021-01-02.
//  Copyright © 2021 Thomas Armena. All rights reserved.
//

import UIKit

class EVTheme {
    
    class Colors {
        static let background = UIColor(hex: "#272822")
        static let foreground = UIColor(hex: "#f8f8f2")
        static let activeSelectionBackground = UIColor(hex: "#575b6180")
        static let highlighted = UIColor(hex: "#A6E22E")
        static let secondaryHighlighted = UIColor(hex: "#AE81FF")
        static let identifier = UIColor(hex: "#A6E22E")
        static let reserved = UIColor(hex: "#F92672")
        static let number = UIColor(hex: "#AE81FF")
        static let string = UIColor(hex: "#E6DB74")
        static let symbol = UIColor(hex: "#f8f8f2")
    }
    
    class Fonts {
        static var editor = UIFont(name: "Menlo", size: 16)
    }
    
}

extension UIColor {
    public convenience init?(hex: String) {
        let r, g, b, a: CGFloat

        if hex.hasPrefix("#") {
            let start = hex.index(hex.startIndex, offsetBy: 1)
            var hexColor = String(hex[start...])

            if hexColor.count == 6 {
                hexColor += "ff" // Add transparency of 1.0 if not specified
            }
            
            if hexColor.count == 8 {
                let scanner = Scanner(string: hexColor)
                var hexNumber: UInt64 = 0

                if scanner.scanHexInt64(&hexNumber) {
                    r = CGFloat((hexNumber & 0xff000000) >> 24) / 255
                    g = CGFloat((hexNumber & 0x00ff0000) >> 16) / 255
                    b = CGFloat((hexNumber & 0x0000ff00) >> 8) / 255
                    a = CGFloat(hexNumber & 0x000000ff) / 255
                    self.init(red: r, green: g, blue: b, alpha: a)
                    return
                }
            }
        }

        return nil
    }
}
