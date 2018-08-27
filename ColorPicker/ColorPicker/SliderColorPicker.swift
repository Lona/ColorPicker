//
//  SliderColorPicker.swift
//  ColorPicker
//
//  Created by Devin Abbott on 8/27/18.
//  Copyright © 2018 BitDisco, Inc. All rights reserved.
//

import AppKit
import Colors
import Foundation

// MARK: - SliderColorPicker

public class SliderColorPicker: NSView {

    // MARK: Lifecycle

    public init(colorValue: Color = Color.black) {
        self.colorValue = colorValue

        super.init(frame: .zero)

        setUpViews()
        setUpConstraints()

        update()

        addTrackingArea(trackingArea)
    }

    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        removeTrackingArea(trackingArea)
    }

    // MARK: Public

    public var onChangeColorValue: ((Color) -> Void)? { didSet { update() } }
    public var colorValue: Color { didSet { update() } }
    
    public var cornerRadius: CGFloat = 4 { didSet { update() } }
    public var outlineWidth: CGFloat = 1 { didSet { update() } }
    public var outlineColor = NSColor.black.withAlphaComponent(0.3) { didSet { update() } }
    public var shadowColor = NSColor.black { didSet { update() } }
    public var shadowRadius: CGFloat = 2 { didSet { update() } }
    public var cursorSize: CGFloat = 7 { didSet { update() } }
    public var cursorOutlineWidth: CGFloat = 1.5 { didSet { update() } }
    public var cursorOutlineColor = NSColor.white { didSet { update() } }

    // MARK: Private

    private let hueGradient = NSGradient(colors: [
        NSColor(red: 0xFF / 0xFF, green: 0x00 / 0xFF, blue: 0x00 / 0xFF, alpha: 1),
        NSColor(red: 0xFF / 0xFF, green: 0x00 / 0xFF, blue: 0x99 / 0xFF, alpha: 1),
        NSColor(red: 0xCD / 0xFF, green: 0x00 / 0xFF, blue: 0xFF / 0xFF, alpha: 1),
        NSColor(red: 0x32 / 0xFF, green: 0x00 / 0xFF, blue: 0xFF / 0xFF, alpha: 1),
        NSColor(red: 0x00 / 0xFF, green: 0x66 / 0xFF, blue: 0xFF / 0xFF, alpha: 1),
        NSColor(red: 0x00 / 0xFF, green: 0xFF / 0xFF, blue: 0xFD / 0xFF, alpha: 1),
        NSColor(red: 0x00 / 0xFF, green: 0xFF / 0xFF, blue: 0x66 / 0xFF, alpha: 1),
        NSColor(red: 0x35 / 0xFF, green: 0xFF / 0xFF, blue: 0x00 / 0x00, alpha: 1),
        NSColor(red: 0xCD / 0xFF, green: 0xFF / 0xFF, blue: 0x00 / 0x00, alpha: 1),
        NSColor(red: 0xFF / 0xFF, green: 0x99 / 0xFF, blue: 0x00 / 0x00, alpha: 1),
        NSColor(red: 0xFF / 0xFF, green: 0x00 / 0xFF, blue: 0x00 / 0x00, alpha: 1),
        ])

    private lazy var trackingArea = NSTrackingArea(
        rect: self.frame,
        options: [.mouseEnteredAndExited, .activeAlways, .mouseMoved, .inVisibleRect],
        owner: self)

    private func setUpViews() {}

    private func setUpConstraints() {
        translatesAutoresizingMaskIntoConstraints = false
    }

    private func update() {
        needsDisplay = true
    }

    override public func draw(_ dirtyRect: NSRect) {
        NSGraphicsContext.saveGraphicsState()

        // Clip to rounded rect

        NSBezierPath(roundedRect: dirtyRect, xRadius: cornerRadius, yRadius: cornerRadius).setClip()

        // Draw rainbow gradient background

        hueGradient?.draw(in: dirtyRect, angle: 180)

        // Setup shadow

        let shadow = NSShadow()
        shadow.shadowColor = shadowColor
        shadow.shadowBlurRadius = shadowRadius
        shadow.set()

        // Draw cursor

        let x = CGFloat(colorValue.hsv.hue / 360) * bounds.width
        let y = bounds.height / 2

        cursorOutlineColor.setStroke()

        let cursorRect = NSRect(
            x: x - cursorSize / 2,
            y: y - cursorSize / 2,
            width: cursorSize,
            height: cursorSize)
        let cursor = NSBezierPath(ovalIn: cursorRect)
        cursor.lineWidth = cursorOutlineWidth
        cursor.stroke()

        // Draw outline

        outlineColor.setStroke()

        let outline = NSBezierPath(roundedRect: dirtyRect, xRadius: cornerRadius, yRadius: cornerRadius)
        outline.lineWidth = outlineWidth
        outline.stroke()

        NSGraphicsContext.restoreGraphicsState()
    }

    private func ratioWithinBounds(of point: NSPoint) -> NSPoint {
        let x = max(min(point.x, bounds.maxX), bounds.minX)
        let y = max(min(point.y, bounds.maxY), bounds.minY)

        return NSPoint(x: x / bounds.width, y: y / bounds.height)
    }

    private func triggerColorChange(with point: NSPoint) {
        let ratio = ratioWithinBounds(of: point)

        let components = colorValue.hsv
        let color = Color(
            hue: Float(ratio.x * 360),
            saturation: components.saturation,
            value: components.value)

        onChangeColorValue?(color)
    }

    public override func mouseDown(with event: NSEvent) {
        let point = convert(event.locationInWindow, from: nil)
        triggerColorChange(with: point)
    }

    public override func mouseDragged(with event: NSEvent) {
        let point = convert(event.locationInWindow, from: nil)
        triggerColorChange(with: point)
    }
}

