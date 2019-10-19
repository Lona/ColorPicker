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

    // MARK: Private

    private var inputType: InputType

    private var inputViews: [PaddedTextInput] = []
    private var labelViews: [NSTextField] = []

    private func setUpViews() {
        switch inputType {
        case .hex:
            let hexInputView = PickerTextInput()

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
            labelViews = [PickerLabelView(labelWithString: "HEX")]
        case .hsla:
            inputViews = [PaddedTextInput(), PaddedTextInput(), PaddedTextInput(), PaddedTextInput()]
            labelViews = ["H", "S", "L", "A"].map { PickerLabelView(labelWithString: $0) }
        case .rgba:
            let rInputView = PickerNumberInput()
            let gInputView = PickerNumberInput()
            let bInputView = PickerNumberInput()
            let aInputView = PickerNumberInput()

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
            labelViews = ["R", "G", "B", "A"].map { PickerLabelView(labelWithString: $0) }
        }

        for inputView in inputViews {
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

                inputViews[offset - 1].nextKeyView = view
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
                view.textValue = InputFieldColorPicker.formatter.string(from: NSNumber(value: component)) ?? "0"
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

