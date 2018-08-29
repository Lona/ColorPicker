//
//  SwatchColorPicker.swift
//  ColorPicker
//
//  Created by Devin Abbott on 8/27/18.
//  Copyright © 2018 BitDisco, Inc. All rights reserved.
//

import AppKit
import Colors
import Foundation

// MARK: - SwatchColorPicker

public class SwatchColorPicker: NSView {

    // MARK: Lifecycle

    public init(colorValue: Color = Color.black) {
        self.colorValue = colorValue

        super.init(frame: .zero)

        setUpViews()
        setUpConstraints()

        update()
    }

    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Public

    public var colorValue: Color { didSet { update() } }

    public var cornerRadius: CGFloat = 3 { didSet { update() } }
    public var outlineWidth: CGFloat = 1 { didSet { update() } }
    public var outlineColor = NSColor.black.withAlphaComponent(0.3) { didSet { update() } }
    public var shadowColor = NSColor.black { didSet { update() } }
    public var shadowRadius: CGFloat = 2 { didSet { update() } }
    
    // MARK: Private

    private let cellAlignmentOptions: AlignmentOptions = [.alignMinXNearest, .alignMinYNearest, .alignMaxXNearest, .alignMaxYNearest]

    private func setUpViews() {}

    private func setUpConstraints() {
        translatesAutoresizingMaskIntoConstraints = false
    }

    private func update() {
        needsDisplay = true
    }

    private func cellRect(column: Int, row: Int) -> NSRect {
        let cellWidth = CGFloat(bounds.height / 3)
        let cellHeight = CGFloat(bounds.height / 3)
        let x = CGFloat(column) * cellWidth
        let y = CGFloat(row) * cellHeight
        let rect = NSRect(x: x, y: y, width: cellWidth, height: cellHeight)
        return backingAlignedRect(rect, options: cellAlignmentOptions)
    }

    override public func draw(_ dirtyRect: NSRect) {
        NSGraphicsContext.saveGraphicsState()

        // Clip to rounded rect

        NSBezierPath(roundedRect: dirtyRect, xRadius: cornerRadius, yRadius: cornerRadius).setClip()

        // Draw checkerboard background

        for x in 0..<3 {
            for y in 0..<3 {
                let color = (x % 2 == y % 2) ? NSColor(white: 0.9, alpha: 1) : NSColor.white
                color.set()
                NSBezierPath.fill(cellRect(column: Int(x), row: Int(y)))
            }
        }

        // Draw current color as fill

        colorValue.NSColor.set()

        dirtyRect.fill()

        // Setup shadow

        let shadow = NSShadow()
        shadow.shadowColor = shadowColor
        shadow.shadowBlurRadius = shadowRadius
        shadow.set()

        // Draw outline

        outlineColor.setStroke()

        let outline = NSBezierPath(roundedRect: dirtyRect, xRadius: cornerRadius, yRadius: cornerRadius)
        outline.lineWidth = outlineWidth
        outline.stroke()

        NSGraphicsContext.restoreGraphicsState()
    }
}

