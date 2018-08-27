//
//  Colors+NSColor.swift
//  ColorPicker
//
//  Created by Devin Abbott on 8/27/18.
//  Copyright © 2018 BitDisco, Inc. All rights reserved.
//

import Colors
import Foundation

extension NSColor {
    var color: Color {
        get {
            return Color(
                red: Float(redComponent),
                green: Float(greenComponent),
                blue: Float(blueComponent),
                alpha: Float(alphaComponent))
        }
    }
}
