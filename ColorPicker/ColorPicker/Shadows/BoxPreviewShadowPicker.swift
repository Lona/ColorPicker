//
//  BoxPreviewShadowPicker.swift
//  ColorPicker
//
//  Created by Devin Abbott on 10/19/19.
//  Copyright © 2019 BitDisco, Inc. All rights reserved.
//

import AppKit
import Foundation
import WebKit

// MARK: - BoxPreviewShadowPicker

public class BoxPreviewShadowPicker: NSView {

    // MARK: Lifecycle

    public init(shadowValue: PickerShadow = .init()) {
        self.shadowValue = shadowValue

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

    public var onChangeShadowValue: ((PickerShadow) -> Void)? { didSet { update() } }
    public var shadowValue: PickerShadow { didSet { update() } }

    public var cornerRadius: CGFloat = 3 { didSet { update() } }
    public var outlineWidth: CGFloat = 1 { didSet { update() } }
    public var outlineColor = NSColor.black.withAlphaComponent(0.3) { didSet { update() } }
    public var shadowColor = NSColor.black { didSet { update() } }
    public var shadowRadius: CGFloat = 2 { didSet { update() } }
    public var boxPreviewSize: CGFloat = 60 { didSet { update() } }

    // MARK: Private

    private lazy var trackingArea = NSTrackingArea(
        rect: self.frame,
        options: [.activeAlways, .mouseMoved, .inVisibleRect],
        owner: self)

    private var webView = WKWebView()

    private func setUpViews() {
        addSubview(webView)

        let html = """
        <html>
            <head>
                <style>
                    * { margin: 0; padding: 0; }

                    html, body {
                        width: 100%;
                        height: 100%;
                        overflow: hidden;
                        display: flex;
                        justify-content: center;
                        align-items: center;
                    }
                </style>
            </head>
            <body>
                <div id="box" style="width: 60px; height: 60px;" />
            </body>
        </html>
        """

        webView.loadHTMLString(html, baseURL: nil)
    }

    private func setUpConstraints() {
        translatesAutoresizingMaskIntoConstraints = false
        webView.translatesAutoresizingMaskIntoConstraints = false

        webView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 1).isActive = true
        webView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -1).isActive = true
        webView.topAnchor.constraint(equalTo: topAnchor, constant: 1).isActive = true
        webView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -1).isActive = true
    }

    private func update() {
        needsDisplay = true

        let javaScript = """
            var element = document.getElementById("box")
            element.style.boxShadow = "\(shadowValue.x)px \(shadowValue.y)px \(shadowValue.blur)px \(shadowValue.radius)px"
        """

        webView.evaluateJavaScript(javaScript, completionHandler: nil)
    }

    override public func draw(_ dirtyRect: NSRect) {
        NSGraphicsContext.saveGraphicsState()

        // Clip to rounded rect

        NSBezierPath(roundedRect: dirtyRect, xRadius: cornerRadius, yRadius: cornerRadius).setClip()

        // Draw background color

        NSColor.white.setFill()

        dirtyRect.fill()

        // Draw outline

        let shadow = NSShadow()
        shadow.shadowColor = shadowColor
        shadow.shadowBlurRadius = shadowRadius
        shadow.set()

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

    public override func hitTest(_ point: NSPoint) -> NSView? {
        let result = super.hitTest(point)

        if result == webView {
            return self
        }

        return result
    }

    private var mouseDownPoint: NSPoint?
    private var mouseDownShadowValue: PickerShadow?

    public override func mouseDown(with event: NSEvent) {
        let point = convert(event.locationInWindow, from: nil)
        mouseDownPoint = point
        mouseDownShadowValue = shadowValue
    }

    public override func mouseDragged(with event: NSEvent) {
        guard let mouseDownPoint = mouseDownPoint, let mouseDownShadowValue = mouseDownShadowValue else { return }
        let point = convert(event.locationInWindow, from: nil)

        let isShiftEnabled = event.modifierFlags.contains(NSEvent.ModifierFlags.shift)

        var dx = Int(point.x - mouseDownPoint.x)
        var dy = Int(point.y - mouseDownPoint.y)

        if isShiftEnabled {
            if abs(dx) > abs(dy) {
                dy = 0
            } else {
                dx = 0
            }
        }

        let newShadowValue = shadowValue.with(
            x: mouseDownShadowValue.x + dx,
            y: mouseDownShadowValue.y - dy
        )
        onChangeShadowValue?(newShadowValue)
    }

    public override func mouseUp(with event: NSEvent) {
        mouseDownPoint = nil
        mouseDownShadowValue = nil
    }
}
