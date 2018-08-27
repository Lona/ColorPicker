//
//  Colors+NSColor.swift
//  ColorPicker
//
//  Created by Devin Abbott on 8/27/18.
//  Copyright © 2018 BitDisco, Inc. All rights reserved.
//

import Colors
import Foundation

public extension Color {
    init(_ color: NSColor) {
        self.init(
            red: Float(color.redComponent),
            green: Float(color.greenComponent),
            blue: Float(color.blueComponent),
            alpha: Float(color.alphaComponent))
    }
}
