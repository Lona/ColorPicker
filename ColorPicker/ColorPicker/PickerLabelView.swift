//
//  PickerLabelView.swift
//  ColorPicker
//
//  Created by Devin Abbott on 10/18/19.
//  Copyright © 2019 BitDisco, Inc. All rights reserved.
//

import AppKit

// MARK: - PickerLabelView

open class PickerLabelView: NSTextField {
    convenience init(labelWithString string: String) {
        self.init(frame: .zero)

        isEditable = false
        isSelectable = false
        textColor = NSColor.labelColor.withAlphaComponent(0.7)
        backgroundColor = .controlColor
        drawsBackground = false
        isBezeled = false
        alignment = .natural
        lineBreakMode = .byClipping
        cell?.isScrollable = true
        cell?.wraps = false

        sharedInit()

        stringValue = string
        sizeToFit()
    }

    public override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        sharedInit()
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        sharedInit()
    }

    private func sharedInit() {
        font = NSFont.systemFont(ofSize: NSFont.systemFontSize(for: .mini), weight: .regular)
    }
}
