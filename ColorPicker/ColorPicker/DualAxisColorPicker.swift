//
//  DualAxisColorPicker.swift
//  ColorPicker
//
//  Created by Devin Abbott on 8/26/18.
//  Copyright © 2018 BitDisco, Inc. All rights reserved.
//

import AppKit
import Foundation

// MARK: - DualAxisColorPicker

public class DualAxisColorPicker: NSView {

    // MARK: Lifecycle

    public init(colorValue: NSColor = NSColor.black) {
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

    public var onChangeColorValue: ((NSColor) -> Void)? { didSet { update() } }
    public var colorValue: NSColor {
        didSet {
            if let deviceColor = colorValue.usingColorSpace(.deviceRGB) {
                if deviceColor.brightnessComponent.isZero {
                    ratio.y = deviceColor.brightnessComponent
                } else {
                    ratio.x = deviceColor.saturationComponent
                    ratio.y = deviceColor.brightnessComponent
                }

                if !deviceColor.saturationComponent.isZero && !deviceColor.brightnessComponent.isZero {
                    hue = deviceColor.hueComponent
                }
            }

            update()
        }
    }

    public var cornerRadius: CGFloat = 4 { didSet { update() } }
    public var outlineWidth: CGFloat = 1 { didSet { update() } }
    public var outlineColor = NSColor.black.withAlphaComponent(0.3) { didSet { update() } }
    public var shadowColor = NSColor.black { didSet { update() } }
    public var shadowRadius: CGFloat = 2 { didSet { update() } }
    public var cursorSize: CGFloat = 7 { didSet { update() } }
    public var cursorOutlineWidth: CGFloat = 1.5 { didSet { update() } }
    public var cursorOutlineColor = NSColor.white { didSet { update() } }

    // MARK: Private

    private var hue: CGFloat = 0
    private var ratio = NSPoint()

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

        NSColor(hue: hue, saturation: 1, brightness: 1, alpha: 1).set()

        dirtyRect.fill()

        // Draw white gradient background (saturation)

        let whiteGradient = NSGradient(colors: [
            NSColor(red: 1, green: 1, blue: 1, alpha: 1),
            NSColor(red: 1, green: 1, blue: 1, alpha: 0),
            ])
        whiteGradient?.draw(in: dirtyRect, angle: 0)

        // Draw black gradient background (brightness)

        let black = NSGradient(colors: [
            NSColor(red: 0, green: 0, blue: 0, alpha: 0),
            NSColor(red: 0, green: 0, blue: 0, alpha: 1),
            ])
        black?.draw(in: dirtyRect, angle: 270)

        // Setup shadow

        let shadow = NSShadow()
        shadow.shadowColor = shadowColor
        shadow.shadowBlurRadius = shadowRadius
        shadow.set()

        // Draw cursor

        let x = ratio.x * bounds.width
        let y = ratio.y * bounds.height

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

        self.ratio = ratio

        let color = NSColor(hue: hue, saturation: ratio.x, brightness: ratio.y, alpha: colorValue.alphaComponent)

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
