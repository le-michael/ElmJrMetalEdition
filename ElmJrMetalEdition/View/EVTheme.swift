//
//  EVTheme.swift
//  ElmJrMetalEdition
//
//  Created by Thomas Armena on 2021-01-02.
//  Copyright © 2021 Thomas Armena. All rights reserved.
//

import UIKit

let keywordsHex = "#FF7AB2"
let operatorsHex = "#ffffff"
let numbersHex = "#A79DF8"
let stringsHex = "#FC6A5D"
let typeHex = "#8AD1C3"
let greenHex = "#91D462"
let cyanHex = "#8AD1C3"
let foregroundHex = "#FFFFFF"
let backgroundHex = "#292A30"

class EVTheme {
    
    class Colors {
        static let background = UIColor(hex: backgroundHex)
        static let foreground = UIColor(hex: foregroundHex)
        static let activeSelectionBackground = UIColor(hex: numbersHex)
        static let highlighted = UIColor(hex: cyanHex)
        static let secondaryHighlighted = UIColor(hex: greenHex) //
        static let identifier = UIColor(hex: keywordsHex)
        static let reserved = UIColor(hex: keywordsHex)
        static let number = UIColor(hex: greenHex)
        static let string = UIColor(hex: stringsHex)
        static let symbol = UIColor(hex: operatorsHex)
        static let function = UIColor(hex: "#FF816F")
        
        
        class ProjectionalEditor {
            static let action = UIColor(hex: numbersHex) //
            
        }
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
