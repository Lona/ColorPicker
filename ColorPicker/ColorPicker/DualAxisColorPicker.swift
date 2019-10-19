//
//  DualAxisColorPicker.swift
//  ColorPicker
//
//  Created by Devin Abbott on 8/26/18.
//  Copyright © 2018 BitDisco, Inc. All rights reserved.
//

import AppKit
import Colors
import Foundation

// MARK: - DualAxisColorPicker

public class DualAxisColorPicker: NSView {

    // MARK: Lifecycle

    public init(colorValue: Color = .black) {
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

    public var cornerRadius: CGFloat = 3 { didSet { update() } }
    public var outlineWidth: CGFloat = 1 { didSet { update() } }
    public var outlineColor = NSColor.black.withAlphaComponent(0.3) { didSet { update() } }
    public var shadowColor = NSColor.black { didSet { update() } }
    public var shadowRadius: CGFloat = 2 { didSet { update() } }
    public var cursorSize: CGFloat = 7 { didSet { update() } }
    public var cursorOutlineWidth: CGFloat = 1.5 { didSet { update() } }
    public var cursorOutlineColor = NSColor.white { didSet { update() } }

    // MARK: Private

    private let whiteGradient = NSGradient(colors: [
        NSColor(red: 1, green: 1, blue: 1, alpha: 1),
        NSColor(red: 1, green: 1, blue: 1, alpha: 0),
        ])

    private let blackGradient = NSGradient(colors: [
        NSColor(red: 0, green: 0, blue: 0, alpha: 0),
        NSColor(red: 0, green: 0, blue: 0, alpha: 1),
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

        // Draw current color as fill

        NSColor(hue: CGFloat(colorValue.hsv.hue / 360), saturation: 1, brightness: 1, alpha: 1).set()

        dirtyRect.fill()

        // Draw white gradient background (saturation)

        whiteGradient?.draw(in: dirtyRect, angle: 0)

        // Draw black gradient background (brightness)

        blackGradient?.draw(in: dirtyRect, angle: 270)

        // Setup shadow

        let shadow = NSShadow()
        shadow.shadowColor = shadowColor
        shadow.shadowBlurRadius = shadowRadius
        shadow.set()

        // Draw cursor

        let components = colorValue.hsv
        let x = CGFloat(components.saturation / 100) * bounds.width
        let y = CGFloat(components.value / 100) * bounds.height

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
        var color = Color(
            hue: components.hue,
            saturation: Float(ratio.x * 100),
            value: Float(ratio.y * 100))
        color.alpha = colorValue.alpha

        onChangeColorValue?(color)
    }

    private var mouseDownColorValue: Color?

    public override func mouseDown(with event: NSEvent) {
        let point = convert(event.locationInWindow, from: nil)
        mouseDownColorValue = colorValue

        triggerColorChange(with: point)
    }

    public override func mouseDragged(with event: NSEvent) {
        guard let mouseDownColorValue = mouseDownColorValue else { return }
        var point = convert(event.locationInWindow, from: nil)

        let isShiftEnabled = event.modifierFlags.contains(NSEvent.ModifierFlags.shift)

        if isShiftEnabled {
            let initialPoint = NSPoint(
                x: CGFloat(mouseDownColorValue.hsv.saturation) / 100 * bounds.width,
                y: CGFloat(mouseDownColorValue.hsv.value) / 100 * bounds.height
            )

            let dx = point.x - initialPoint.x
            let dy = point.y - initialPoint.y
            
            if abs(dx) > abs(dy) {
                point.y = initialPoint.y
            } else {
                point.x = initialPoint.x
            }
        }

        triggerColorChange(with: point)
    }

    public override func mouseUp(with event: NSEvent) {
        mouseDownColorValue = nil
    }
}
