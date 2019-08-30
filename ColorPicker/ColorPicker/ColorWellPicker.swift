//
//  ColorWellPickerPicker.swift
//  ColorPicker
//
//  Created by Devin Abbott on 8/29/18.
//  Copyright © 2018 BitDisco, Inc. All rights reserved.
//

import AppKit
import Colors
import Foundation

// MARK: - ColorWellPicker

public class ColorWellPicker: NSView {

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
    public var onChangeColorValue: ((Color) -> Void)?
    public var onShowPopover: (() -> Void)?
    public var onClosePopover: (() -> Void)?

    // MARK: Private

    private let colorWell = ColorWell()

    // TODO: For perf, make a single static viewController and create all its view lazily?
    private let colorPicker = ColorPicker()
    private let colorPickerContainer = NSView()
    private lazy var colorPickerViewController = NSViewController()
    private lazy var popover = NSPopover()

    private func setUpViews() {
        addSubview(colorWell)

        colorPickerContainer.addSubview(colorPicker)

        colorPicker.onChangeColorValue = { colorValue in
            self.onChangeColorValue?(colorValue)
        }

        colorWell.onPress = {
            if self.popover.isShown {
                self.closePopover()
            } else {
                self.openPopover()
            }
        }
    }

    private func setUpConstraints() {
        translatesAutoresizingMaskIntoConstraints = false
        colorWell.translatesAutoresizingMaskIntoConstraints = false
        colorPickerContainer.translatesAutoresizingMaskIntoConstraints = false

        colorWell.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        colorWell.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        colorWell.topAnchor.constraint(equalTo: topAnchor).isActive = true
        colorWell.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true

        colorPicker.leadingAnchor.constraint(equalTo: colorPickerContainer.leadingAnchor, constant: 8).isActive = true
        colorPicker.trailingAnchor.constraint(equalTo: colorPickerContainer.trailingAnchor, constant: -8).isActive = true
        colorPicker.topAnchor.constraint(equalTo: colorPickerContainer.topAnchor, constant: 8).isActive = true
        colorPicker.bottomAnchor.constraint(equalTo: colorPickerContainer.bottomAnchor, constant: -8).isActive = true

        colorPickerContainer.heightAnchor.constraint(equalToConstant: 264).isActive = true
    }

    private func update() {
        colorWell.colorValue = colorValue
        colorPicker.colorValue = colorValue

        needsDisplay = true
    }

    private func closePopover() {
        popover.close()
    }

    private func openPopover() {
        colorPickerViewController.view = colorPickerContainer

        popover.delegate = self
        popover.behavior = .semitransient
        popover.animates = false
        popover.contentViewController = colorPickerViewController

        popover.show(relativeTo: NSRect.zero, of: self, preferredEdge: .maxY)
    }
}

// MARK: - NSPopoverDelegate

extension ColorWellPicker: NSPopoverDelegate {
    public func popoverDidShow(_ notification: Notification) {
        onShowPopover?()
    }

    public func popoverDidClose(_ notification: Notification) {
        onClosePopover?()
    }
}
