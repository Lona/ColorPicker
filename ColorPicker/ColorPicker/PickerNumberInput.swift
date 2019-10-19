//
//  PickerNumberInput.swift
//  ColorPicker
//
//  Created by Devin Abbott on 10/18/19.
//  Copyright © 2019 BitDisco, Inc. All rights reserved.
//

import AppKit
import ControlledComponents

// MARK: - PaddedTextInput

open class PaddedTextInput: TextInput {
    override open class var cellClass: AnyClass? {
        get { return PaddedTextInputCell.self }
        set {}
    }
}

open class PaddedTextInputCell: NSTextFieldCell {
    public var inset = NSSize(width: -6, height: 0)

    override open func drawingRect(forBounds rect: NSRect) -> NSRect {
        return super.drawingRect(forBounds: rect).insetBy(dx: inset.width, dy: inset.height)
    }
}

// MARK: - PickerTextInput

open class PickerTextInput: PaddedTextInput {
    public override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        sharedInit()
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        sharedInit()
    }

    private func sharedInit() {
        bezelStyle = .roundedBezel
        controlSize = .small
        font = NSFont.systemFont(ofSize: NSFont.systemFontSize(for: .small), weight: .regular)
    }
}

// MARK: - PickerNumberInput

open class PickerNumberInput: PickerTextInput {
    public override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        sharedInit()
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        sharedInit()
    }

    private func sharedInit() {
        delegate = self
    }

    override open func control(_ control: NSControl, textView: NSTextView, doCommandBy commandSelector: Selector) -> Bool {
        var changeBy: Float?

        if commandSelector == #selector(moveUp(_:)) { changeBy = 1.0 }
        if commandSelector == #selector(moveUpAndModifySelection(_:)) { changeBy = 10.0 }
        if commandSelector == #selector(moveDown(_:)) { changeBy = -1.0 }
        if commandSelector == #selector(moveDownAndModifySelection(_:)) { changeBy = -10.0 }

        if let changeBy = changeBy, let number = InputFieldColorPicker.formatter.number(from: textValue)?.floatValue {
            let newValue = number + changeBy
            if let newTextValue = InputFieldColorPicker.formatter.string(from: NSNumber(value: newValue)) {
                onChangeTextValue?(newTextValue)
                return true
            }
        }

        return super.control(control, textView: textView, doCommandBy: commandSelector)
    }
}
