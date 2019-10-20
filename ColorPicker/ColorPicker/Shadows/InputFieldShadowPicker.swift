//
//  InputFieldShadowPicker.swift
//  ColorPicker
//
//  Created by Devin Abbott on 10/19/19.
//  Copyright © 2019 BitDisco, Inc. All rights reserved.
//

import AppKit
import Colors
import ControlledComponents
import Foundation

// MARK: - InputFieldShadowPicker

public class InputFieldShadowPicker: NSView {

    // MARK: Lifecycle

    public init(shadowValue: PickerShadow = .init()) {
        self.shadowValue = shadowValue

        super.init(frame: .zero)

        setUpViews()
        setUpConstraints()

        update()
    }

    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Public

    public var shadowValue: PickerShadow { didSet { update() } }
    public var onChangeShadowValue: ((PickerShadow) -> Void)? { didSet { update() } }

    // MARK: Private

    private var inputViews: [PaddedTextInput] = []
    private var labelViews: [NSTextField] = []

    private func setUpViews() {
        let xInputView = PickerNumberInput()
        let yInputView = PickerNumberInput()
        let blurInputView = PickerNumberInput()
        let radiusInputView = PickerNumberInput()

        xInputView.onChangeTextValue = { [weak self] value in
            let inputView = xInputView
            guard let self = self else { return }
            guard let number = InputFieldShadowPicker.formatter.number(from: value) else {
                if value.isEmpty || value == "-" {
                    inputView.textValue = value
                }
                return
            }
            self.onChangeShadowValue?(self.shadowValue.with(x: number.intValue))
        }

        yInputView.onChangeTextValue = { [weak self] value in
            let inputView = yInputView
            guard let self = self else { return }
            guard let number = InputFieldShadowPicker.formatter.number(from: value) else {
                if value.isEmpty || value == "-" {
                    inputView.textValue = value
                }
                return
            }
            self.onChangeShadowValue?(self.shadowValue.with(y: number.intValue))
        }

        blurInputView.onChangeTextValue = { [weak self] value in
            let inputView = blurInputView
            guard let self = self else { return }
            guard let number = InputFieldShadowPicker.formatter.number(from: value) else {
                if value.isEmpty {
                    inputView.textValue = value
                }
                return
            }
            self.onChangeShadowValue?(self.shadowValue.with(blur: max(number.intValue, 0)))
        }

        radiusInputView.onChangeTextValue = { [weak self] value in
            let inputView = radiusInputView
            guard let self = self else { return }
            guard let number = InputFieldShadowPicker.formatter.number(from: value) else {
                if value.isEmpty {
                    inputView.textValue = value
                }
                return
            }
            self.onChangeShadowValue?(self.shadowValue.with(radius: max(number.intValue, 0)))
        }

        inputViews = [xInputView, yInputView, blurInputView, radiusInputView]
        labelViews = ["X", "Y", "Blur", "Radius (web)"].map { PickerLabelView(labelWithString: $0) }

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
        let components: [Int] = [
            Int(shadowValue.x),
            Int(shadowValue.y),
            Int(shadowValue.blur),
            Int(shadowValue.radius)
        ]

        zip(inputViews, components).forEach { view, component in
            view.textValue = InputFieldShadowPicker.formatter.string(from: NSNumber(value: component)) ?? "0"
        }
    }

    static var formatter: NumberFormatter {
        let formatter = NumberFormatter()

        formatter.numberStyle = .none
        formatter.usesGroupingSeparator = false

        return formatter
    }
}

