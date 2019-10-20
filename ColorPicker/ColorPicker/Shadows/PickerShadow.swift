//
//  PickerShadow.swift
//  ColorPicker
//
//  Created by Devin Abbott on 10/19/19.
//  Copyright © 2019 BitDisco, Inc. All rights reserved.
//

import Foundation

public struct PickerShadow: Codable, Equatable {
    public var x: Int
    public var y: Int
    public var blur: Int
    public var radius: Int
    public var opacity: Int

    public init(x: Int = 0, y: Int = 0, blur: Int = 0, radius: Int = 0, opacity: Int = 0) {
        self.x = x
        self.y = y
        self.blur = blur
        self.radius = radius
        self.opacity = opacity
    }

    public func with(x: Int? = nil, y: Int? = nil, blur: Int? = nil, radius: Int? = nil, opacity: Int? = nil) -> PickerShadow {
        var clone = self
        if let x = x { clone.x = x }
        if let y = y { clone.y = y }
        if let blur = blur { clone.blur = blur }
        if let radius = radius { clone.radius = radius }
        if let opacity = opacity { clone.opacity = opacity }
        return clone
    }
}

extension PickerShadow {
    public var boxShadow: String {
        return "\(x)px \(y)px \(blur)px \(radius)px"
    }
}
