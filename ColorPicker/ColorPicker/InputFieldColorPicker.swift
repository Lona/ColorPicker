//
//  InputFieldColorPicker.swift
//  ColorPicker
//
//  Created by Devin Abbott on 8/27/18.
//  Copyright © 2019 BitDisco, Inc. All rights reserved.
//

import AppKit
import Colors
import ControlledComponents
import Foundation

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

// MARK: - NumberInput

open class PaddedNumberInput: PaddedTextInput {
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

// MARK: - InputFieldColorPicker

public class InputFieldColorPicker: NSView {

    public enum InputType {
        case rgba, hsla, hex
    }

    // MARK: Lifecycle

    public init(inputType: InputType, colorValue: Color = Color.black) {
        self.inputType = inputType
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
    public var onChangeColorValue: ((Color) -> Void)? { didSet { update() } }

    public var cornerRadius: CGFloat = 3 { didSet { update() } }
    public var outlineWidth: CGFloat = 1 { didSet { update() } }
    public var outlineColor = NSColor.black.withAlphaComponent(0.3) { didSet { update() } }
    public var shadowColor = NSColor.black { didSet { update() } }
    public var shadowRadius: CGFloat = 2 { didSet { update() } }

    // MARK: Private

    private var inputType: InputType

    private var inputViews: [PaddedTextInput] = []
    private var labelViews: [NSTextField] = []

    private func setUpViews() {
        func makeLabelView(string label: String) -> NSTextField {
            let labelView = NSTextField(labelWithString: label)
            labelView.font = NSFont.systemFont(ofSize: NSFont.systemFontSize(for: .mini), weight: .regular)
            labelView.alphaValue = 0.7
            return labelView
        }

        switch inputType {
        case .hex:
            let hexInputView = PaddedTextInput()

            hexInputView.onChangeTextValue = { [weak self] value in
                let inputView = hexInputView
                guard let self = self else { return }
                if value.isEmpty || value.count != 7 {
                    inputView.textValue = value.uppercased()
                    return
                }
                self.onChangeColorValue?(Color(hex: value))
            }

            inputViews = [hexInputView]
            labelViews = [makeLabelView(string: "HEX")]
        case .hsla:
            inputViews = [PaddedTextInput(), PaddedTextInput(), PaddedTextInput(), PaddedTextInput()]
            labelViews = ["H", "S", "L", "A"].map(makeLabelView)
        case .rgba:
            let rInputView = PaddedNumberInput()
            let gInputView = PaddedNumberInput()
            let bInputView = PaddedNumberInput()
            let aInputView = PaddedNumberInput()

            rInputView.onChangeTextValue = { [weak self] value in
                let inputView = rInputView
                guard let self = self else { return }
                guard let number = InputFieldColorPicker.formatter.number(from: value) else {
                    if value.isEmpty {
                        inputView.textValue = value
                    }
                    return
                }
                let components = self.colorValue.rgb
                let color = Color(
                    red: max(0, min(1, number.floatValue / 255)),
                    green: components.green,
                    blue: components.blue,
                    alpha: self.colorValue.alpha
                )
                self.onChangeColorValue?(color)
            }

            gInputView.onChangeTextValue = { [weak self] value in
                let inputView = gInputView
                guard let self = self else { return }
                guard let number = InputFieldColorPicker.formatter.number(from: value) else {
                    if value.isEmpty {
                        inputView.textValue = value
                    }
                    return
                }
                let components = self.colorValue.rgb
                let color = Color(
                    red: components.red,
                    green: max(0, min(1, number.floatValue / 255)),
                    blue: components.blue,
                    alpha: self.colorValue.alpha
                )
                self.onChangeColorValue?(color)
            }

            bInputView.onChangeTextValue = { [weak self] value in
                let inputView = bInputView
                guard let self = self else { return }
                guard let number = InputFieldColorPicker.formatter.number(from: value) else {
                    if value.isEmpty {
                        inputView.textValue = value
                    }
                    return
                }
                let components = self.colorValue.rgb
                let color = Color(
                    red: components.red,
                    green: components.green,
                    blue: max(0, min(1, number.floatValue / 255)),
                    alpha: self.colorValue.alpha
                )
                self.onChangeColorValue?(color)
            }

            aInputView.onChangeTextValue = { [weak self] value in
                let inputView = aInputView
                guard let self = self else { return }
                guard let number = InputFieldColorPicker.formatter.number(from: value) else {
                    if value.isEmpty {
                        inputView.textValue = value
                    }
                    return
                }
                let components = self.colorValue.rgb
                let color = Color(
                    red: components.red,
                    green: components.green,
                    blue: components.blue,
                    alpha: max(0, min(1, number.floatValue / 100))
                )
                self.onChangeColorValue?(color)
            }

            inputViews = [rInputView, gInputView, bInputView, aInputView]
            labelViews = ["R", "G", "B", "A"].map(makeLabelView)
        }

        for inputView in inputViews {
            inputView.bezelStyle = .roundedBezel
            inputView.controlSize = .small
            inputView.font = NSFont.systemFont(ofSize: NSFont.systemFontSize(for: .small), weight: .regular)
            inputView.delegate = inputView
            addSubview(inputView)
        }

        for labelView in labelViews {
            addSubview(labelView)
        }
    }

    private func setUpConstraints() {
        translatesAutoresizingMaskIntoConstraints = false

        for (offset, view) in inputViews.enumerated() {
            view.translatesAutoresizingMaskIntoConstraints = false
            view.topAnchor.constraint(equalTo: topAnchor).isActive = true

            if view == inputViews.first {
                view.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
            } else {
                view.leadingAnchor.constraint(equalTo: inputViews[offset - 1].trailingAnchor, constant: 5).isActive = true
                view.widthAnchor.constraint(equalTo: inputViews[offset - 1].widthAnchor).isActive = true
            }

            if view == inputViews.last {
                view.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
            }
        }

        for (offset, view) in labelViews.enumerated() {
            let inputView = inputViews[offset]

            view.translatesAutoresizingMaskIntoConstraints = false
            view.topAnchor.constraint(equalTo: inputView.bottomAnchor, constant: 2).isActive = true
            view.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
            view.centerXAnchor.constraint(equalTo: inputView.centerXAnchor).isActive = true
        }
    }

    private func update() {
        switch inputType {
        case .hex:
            let view = inputViews[0]

            view.textValue = colorValue.hexString.uppercased()
        case .hsla:
            break
        case .rgba:
            let rgbComponents = colorValue.rgb
            let components: [Int] = [
                Int(rgbComponents.red * 255),
                Int(rgbComponents.green * 255),
                Int(rgbComponents.blue * 255),
                Int(colorValue.alpha * 100)
            ]

            zip(inputViews, components).forEach { view, component in
                Swift.print("update", view.textValue, InputFieldColorPicker.formatter.string(from: NSNumber(value: component)) ?? "0")
                view.textValue = InputFieldColorPicker.formatter.string(from: NSNumber(value: component)) ?? "0"
                Swift.print("updated", view.textValue)
            }
        }
    }

    static var formatter: NumberFormatter {
        let formatter = NumberFormatter()

        formatter.numberStyle = .none
        formatter.usesGroupingSeparator = false

        return formatter
    }
}

