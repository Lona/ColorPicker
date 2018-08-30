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

    public enum TargetComponent {
        case hue, alpha
    }

    // MARK: Lifecycle

    public init(targetComponent: TargetComponent = .hue, colorValue: Color = Color.black) {
        self.targetComponent = targetComponent
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
    public var targetComponent: TargetComponent = .hue { didSet { update() } }

    public var cornerRadius: CGFloat = 3 { didSet { update() } }
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

    private let cellAlignmentOptions: AlignmentOptions = [.alignMinXNearest, .alignMinYNearest, .alignMaxXNearest, .alignMaxYNearest]

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

    private func cellRect(column: Int, row: Int) -> NSRect {
        let cellWidth = CGFloat(bounds.height)
        let cellHeight = CGFloat(bounds.height)
        let x = CGFloat(column) * cellWidth
        let y = CGFloat(row) * cellHeight - bounds.height / 2
        let rect = NSRect(x: x, y: y, width: cellWidth, height: cellHeight)
        return backingAlignedRect(rect, options: cellAlignmentOptions)
    }

    override public func draw(_ dirtyRect: NSRect) {
        NSGraphicsContext.saveGraphicsState()

        // Clip to rounded rect

        NSBezierPath(roundedRect: dirtyRect, xRadius: cornerRadius, yRadius: cornerRadius).setClip()

        // Draw rainbow gradient or checkerboard background

        switch targetComponent {
        case .hue:
            hueGradient?.draw(in: dirtyRect, angle: 180)
        case .alpha:
            for x in 0..<Int(ceil(bounds.width / bounds.height)) {
                for y in 0..<2 {
                    let color = (x % 2 == y % 2) ? NSColor(white: 0.9, alpha: 1) : NSColor.white
                    color.set()
                    NSBezierPath.fill(cellRect(column: Int(x), row: Int(y)))
                }
            }

            let components = colorValue.hsv
            let saturationGradient = NSGradient(colors: [
                NSColor(
                    hue: CGFloat(components.hue / 360),
                    saturation: CGFloat(components.saturation / 100),
                    brightness: CGFloat(components.value / 100),
                    alpha: 0),
                NSColor(
                    hue: CGFloat(components.hue / 360),
                    saturation: CGFloat(components.saturation / 100),
                    brightness: CGFloat(components.value / 100),
                    alpha: 1)
                ])
            saturationGradient?.draw(in: dirtyRect, angle: 0)
        }

        // Setup shadow

        let shadow = NSShadow()
        shadow.shadowColor = shadowColor
        shadow.shadowBlurRadius = shadowRadius
        shadow.set()

        // Draw cursor

        let x: CGFloat
        switch targetComponent {
        case .hue:
            x = CGFloat(colorValue.hsv.hue / 360) * bounds.width
        case .alpha:
            x = CGFloat(colorValue.alpha) * bounds.width
        }

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

        var color: Color

        switch targetComponent {
        case .hue:
            let components = colorValue.hsv
            color = Color(
                hue: Float(ratio.x * 360),
                saturation: components.saturation,
                value: components.value)
            color.alpha = colorValue.alpha
        case .alpha:
            color = colorValue
            color.alpha = Float(ratio.x)
        }

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

