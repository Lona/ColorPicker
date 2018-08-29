//
//  ColorWell.swift
//  ColorPicker
//
//  Created by Devin Abbott on 8/29/18.
//  Copyright © 2018 BitDisco, Inc. All rights reserved.
//

import AppKit
import Colors
import Foundation

// MARK: - ColorWell

public class ColorWell: NSView {

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

    public var colorValue: Color { didSet { update() } }
    public var onPress: (() -> Void)?

    public var cornerRadius: CGFloat = 3 { didSet { update() } }
    public var outlineWidth: CGFloat = 1 { didSet { update() } }
    public var outlineColor = NSColor(white: 0.8, alpha: 1) { didSet { update() } }
    public var insetOutlineColor = NSColor.black.withAlphaComponent(0.2) { didSet { update() } }
    public var shadowColor = NSColor.black.withAlphaComponent(0.1) { didSet { update() } }
    public var shadowRadius: CGFloat = 0 { didSet { update() } }
    public var insetCornerRadius: CGFloat = 1 { didSet { update() } }
    public var margin: CGFloat = 6

    // MARK: Private

    private lazy var trackingArea = NSTrackingArea(
        rect: self.frame,
        options: [.mouseEnteredAndExited, .activeAlways, .mouseMoved, .inVisibleRect],
        owner: self)

    private var pressed = false
    private var hovered = false

    private let cellAlignmentOptions: AlignmentOptions = [.alignMinXNearest, .alignMinYNearest, .alignMaxXNearest, .alignMaxYNearest]

    private func setUpViews() {}

    private func setUpConstraints() {
        translatesAutoresizingMaskIntoConstraints = false
    }

    private func update() {
        needsDisplay = true
    }

    private func cellRect(rect: NSRect, column: Int, row: Int) -> NSRect {
        let cellWidth = CGFloat(rect.height / 2)
        let cellHeight = CGFloat(rect.height / 2)
        let x = CGFloat(column) * cellWidth + rect.origin.x
        let y = CGFloat(row) * cellHeight + rect.origin.y
        let rect = NSRect(x: x, y: y, width: cellWidth, height: cellHeight)
        return backingAlignedRect(rect, options: cellAlignmentOptions)
    }

    override public func draw(_ dirtyRect: NSRect) {
        NSGraphicsContext.saveGraphicsState()

        // Clip to rounded rect

        NSBezierPath(roundedRect: dirtyRect, xRadius: cornerRadius, yRadius: cornerRadius).setClip()

        // Set up outline and background colors

        if hovered && pressed {
            NSColor(white: 0.9, alpha: 1).setFill()
        } else {
            NSColor.white.setFill()
        }

        outlineColor.setStroke()

        // Make space for a shadow

        let rect = NSRect(x: 0.5, y: 1.5, width: dirtyRect.width - 1, height: dirtyRect.height - 2)
        let outline = NSBezierPath(roundedRect: rect, xRadius: cornerRadius, yRadius: cornerRadius)

        // Set up shadow

        let shadow = NSShadow()
        shadow.shadowColor = shadowColor
        shadow.shadowBlurRadius = shadowRadius
        shadow.shadowOffset = NSSize(width: 0, height: -1)
        shadow.set()

        // Draw outline and background

        outline.fill()

        NSShadow().set()

        outline.lineWidth = outlineWidth
        outline.stroke()

        // Set up inner rect

        let insetRect = rect.insetBy(dx: 4, dy: 4)
        let insetOutline = NSBezierPath(roundedRect: insetRect, xRadius: insetCornerRadius, yRadius: insetCornerRadius)
        insetOutline.lineWidth = outlineWidth

        // Draw checkerboard background

        insetOutline.setClip()

        for x in 0..<Int(ceil(insetRect.width / (max(insetRect.height, 1) / 2))) {
            for y in 0..<2 {
                let color = (x % 2 == y % 2) ? NSColor(white: 0.9, alpha: 1) : NSColor.white
                color.set()
                cellRect(rect: insetRect, column: Int(x), row: Int(y)).fill()
            }
        }

        outline.setClip()

        // Draw current color as fill with outline

        colorValue.NSColor.set()
        insetOutlineColor.setStroke()

        insetOutline.fill()
        insetOutline.stroke()

        NSGraphicsContext.restoreGraphicsState()
    }

    // MARK: - Event handling

    private func updateHoverState(with event: NSEvent) {
        let hovered = bounds.contains(convert(event.locationInWindow, from: nil))

        if hovered != self.hovered {
            self.hovered = hovered

            update()
        }
    }

    public override func mouseEntered(with event: NSEvent) {
        updateHoverState(with: event)
    }

    public override func mouseMoved(with event: NSEvent) {
        updateHoverState(with: event)
    }

    public override func mouseDragged(with event: NSEvent) {
        updateHoverState(with: event)
    }

    public override func mouseExited(with event: NSEvent) {
        updateHoverState(with: event)
    }

    public override func mouseDown(with event: NSEvent) {
        let pressed = bounds.contains(convert(event.locationInWindow, from: nil))

        if pressed != self.pressed {
            self.pressed = pressed

            update()
        }
    }

    public override func mouseUp(with event: NSEvent) {
        let clicked = pressed && bounds.contains(convert(event.locationInWindow, from: nil))

        if pressed {
            pressed = false

            update()
        }

        if clicked {
            onPress?()
        }
    }
}

