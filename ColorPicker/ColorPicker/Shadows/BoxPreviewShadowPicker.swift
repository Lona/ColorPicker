//
//  BoxPreviewShadowPicker.swift
//  ColorPicker
//
//  Created by Devin Abbott on 10/19/19.
//  Copyright © 2019 BitDisco, Inc. All rights reserved.
//

import AppKit
import ControlledComponents
import Foundation
import WebKit

// MARK: - BoxShadowView

fileprivate class BoxShadowView: NSView {

    public enum Platform {
        case iOS
        case macOS

        var scaleFactor: CGFloat {
            switch self {
            case .iOS:
                return 2
            case .macOS:
                return 1
            }
        }
    }

    public var boxPreviewSize: CGFloat = 60 { didSet { update() } }
    public var shadowValue: PickerShadow = .init() { didSet { update() } }
    public var platform: Platform = .iOS { didSet { update() } }

    private func update() {
        needsDisplay = true
    }

    override public func draw(_ dirtyRect: NSRect) {
        NSGraphicsContext.saveGraphicsState()

        // Clip to rounded rect

        NSBezierPath(rect: dirtyRect).setClip()

        // Draw background color

        NSColor.white.setFill()

        dirtyRect.fill()

        // Draw box preview

        let boxPreviewShadow = NSShadow()
        boxPreviewShadow.shadowColor = NSColor.black
        boxPreviewShadow.shadowBlurRadius = CGFloat(shadowValue.blur) * platform.scaleFactor
        boxPreviewShadow.shadowOffset = .init(width: shadowValue.x, height: -shadowValue.y)

        let boxPreviewRect = NSRect(
            x: bounds.midX - boxPreviewSize / 2,
            y: bounds.midY - boxPreviewSize / 2,
            width: boxPreviewSize,
            height: boxPreviewSize)

        let boxPreviewAlignedRect = backingAlignedRect(boxPreviewRect, options: .alignAllEdgesNearest)

        // Fill box preview rect

        boxPreviewShadow.set()

        NSColor.white.setFill()

        boxPreviewAlignedRect.fill()

        // Draw outline

        NSGraphicsContext.restoreGraphicsState()
    }
}

// MARK: - BoxPreviewShadowPicker

public class BoxPreviewShadowPicker: NSView {

    public static let emulationKey = "picker.shadow.emulation"
    public static var defaultEmulationMode: ShadowPicker.EmulationMode {
        return .init(index: UserDefaults.standard.integer(forKey: emulationKey))
    }

    // MARK: Lifecycle

    public init(
        shadowValue: PickerShadow = .init(),
        emulationMode: ShadowPicker.EmulationMode = BoxPreviewShadowPicker.defaultEmulationMode) {
        self.shadowValue = shadowValue
        self.emulationMode = emulationMode

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
    public var emulationMode: ShadowPicker.EmulationMode { didSet { update() } }

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

    private let webView = WKWebView()
    private let boxShadowView = BoxShadowView()
    private let emulationDropdown = ControlledDropdown()
    private let emulationDropdownBackground = NSBox()
    private let webKitLabelView = PickerLabelView(labelWithString: "Web")
    private let appKitLabelView = PickerLabelView(labelWithString: "iOS")

    private func setUpViews() {
        addSubview(webView)
        addSubview(boxShadowView)
        addSubview(webKitLabelView)
        addSubview(appKitLabelView)
        addSubview(emulationDropdownBackground)
        addSubview(emulationDropdown)

        emulationDropdown.controlSize = .small
        emulationDropdown.font = NSFont.systemFont(ofSize: NSFont.systemFontSize(for: .small))
        emulationDropdown.values = ShadowPicker.EmulationMode.allCases.map { $0.title }
        emulationDropdown.onChangeIndex = { [unowned self] index in
            UserDefaults.standard.set(index, forKey: BoxPreviewShadowPicker.emulationKey)
            self.emulationMode = .init(index: index)
        }

        emulationDropdownBackground.boxType = .custom
        emulationDropdownBackground.borderType = .noBorder
        emulationDropdownBackground.fillColor = NSColor.windowBackgroundColor.withAlphaComponent(0.8)
        emulationDropdownBackground.cornerRadius = 4

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
                <div id="box" style="width: \(boxPreviewSize)px; height: \(boxPreviewSize)px; box-shadow: \(shadowValue.boxShadow)" />
            </body>
        </html>
        """

        webView.loadHTMLString(html, baseURL: nil)
    }

    var webViewTrailingAnchor = NSLayoutConstraint()
    var boxShadowViewLeadingAnchor = NSLayoutConstraint()

    private func setUpConstraints() {
        translatesAutoresizingMaskIntoConstraints = false
        webView.translatesAutoresizingMaskIntoConstraints = false
        boxShadowView.translatesAutoresizingMaskIntoConstraints = false
        webKitLabelView.translatesAutoresizingMaskIntoConstraints = false
        appKitLabelView.translatesAutoresizingMaskIntoConstraints = false
        emulationDropdown.translatesAutoresizingMaskIntoConstraints = false
        emulationDropdownBackground.translatesAutoresizingMaskIntoConstraints = false

        webView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 1).isActive = true
        webView.topAnchor.constraint(equalTo: topAnchor, constant: 1).isActive = true
        webView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -1).isActive = true

        webKitLabelView.bottomAnchor.constraint(equalTo: webView.bottomAnchor, constant: -8).isActive = true
        webKitLabelView.centerXAnchor.constraint(equalTo: webView.centerXAnchor).isActive = true

        boxShadowView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -1).isActive = true
        boxShadowView.topAnchor.constraint(equalTo: topAnchor, constant: 1).isActive = true
        boxShadowView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -1).isActive = true

        appKitLabelView.bottomAnchor.constraint(equalTo: boxShadowView.bottomAnchor, constant: -8).isActive = true
        appKitLabelView.centerXAnchor.constraint(equalTo: boxShadowView.centerXAnchor).isActive = true

        emulationDropdown.topAnchor.constraint(equalTo: topAnchor, constant: 4).isActive = true
        emulationDropdown.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8).isActive = true

        emulationDropdownBackground.topAnchor.constraint(equalTo: emulationDropdown.topAnchor, constant: 3).isActive = true
        emulationDropdownBackground.bottomAnchor.constraint(equalTo: emulationDropdown.bottomAnchor, constant: -3).isActive = true
        emulationDropdownBackground.leadingAnchor.constraint(equalTo: emulationDropdown.leadingAnchor, constant: 5).isActive = true
        emulationDropdownBackground.trailingAnchor.constraint(equalTo: emulationDropdown.trailingAnchor, constant: 1).isActive = true
    }

    private func update() {
        needsDisplay = true

        let javaScript = """
            var element = document.getElementById("box")
            element.style.boxShadow = "\(shadowValue.boxShadow)"
        """

        webView.evaluateJavaScript(javaScript, completionHandler: nil)

        boxShadowView.boxPreviewSize = boxPreviewSize
        boxShadowView.shadowValue = shadowValue

        emulationDropdown.selectedIndex = emulationMode.index

        NSLayoutConstraint.deactivate([
            webViewTrailingAnchor,
            boxShadowViewLeadingAnchor
        ])

        let labelColor = NSColor.black.withAlphaComponent(0.7)
        webKitLabelView.textColor = labelColor
        appKitLabelView.textColor = labelColor

        switch emulationMode {
        case .appKit:
            boxShadowViewLeadingAnchor = boxShadowView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 1)
            boxShadowViewLeadingAnchor.isActive = true

            webView.isHidden = true
            boxShadowView.isHidden = false
            webKitLabelView.isHidden = true
            appKitLabelView.isHidden = true
        case .webKit:
            webViewTrailingAnchor = webView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -1)
            webViewTrailingAnchor.isActive = true

            webView.isHidden = false
            boxShadowView.isHidden = true
            webKitLabelView.isHidden = true
            appKitLabelView.isHidden = true
        case .split:
            webViewTrailingAnchor = webView.trailingAnchor.constraint(equalTo: boxShadowView.leadingAnchor, constant: -2)
            webViewTrailingAnchor.isActive = true

            boxShadowViewLeadingAnchor = webView.widthAnchor.constraint(equalTo: boxShadowView.widthAnchor)
            boxShadowViewLeadingAnchor.isActive = true

            webView.isHidden = false
            boxShadowView.isHidden = false
            webKitLabelView.isHidden = false
            appKitLabelView.isHidden = false
        }
    }

    override public func draw(_ dirtyRect: NSRect) {
        NSGraphicsContext.saveGraphicsState()

        // Clip to rounded rect

        NSBezierPath(roundedRect: dirtyRect, xRadius: cornerRadius, yRadius: cornerRadius).setClip()

        // Draw background color

        NSColor.white.setFill()

        dirtyRect.fill()

        // Draw divider

        switch emulationMode {
        case .appKit, .webKit:
            break
        case .split:
            NSColor.black.withAlphaComponent(0.03).setFill()

            NSRect(x: webView.frame.maxX, y: 1, width: boxShadowView.frame.minX, height: bounds.height - 1).fill()
        }

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

        if result == webView || result == boxShadowView {
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
