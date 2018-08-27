//
//  ColorPicker.swift
//  ColorPicker
//
//  Created by Devin Abbott on 8/27/18.
//  Copyright © 2018 BitDisco, Inc. All rights reserved.
//

import AppKit
import Colors
import Foundation

// MARK: - ColorPicker

public class ColorPicker: NSView {

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

    public var onChangeColorValue: ((Color) -> Void)? { didSet { update() } }
    public var colorValue: Color { didSet { update() } }

    // MARK: Private

    private let dualAxisPicker = DualAxisColorPicker()
    private let hueSliderPicker = SliderColorPicker()
    private let alphaSliderPicker = SliderColorPicker()
    private let swatchColorPicker = SwatchColorPicker()

    private func setUpViews() {
        alphaSliderPicker.targetComponent = .alpha

        addSubview(dualAxisPicker)
        addSubview(hueSliderPicker)
        addSubview(alphaSliderPicker)
        addSubview(swatchColorPicker)

        let handleChangeColorValue: (Color) -> Void = { colorValue in
            self.colorValue = colorValue
            self.update()
        }

        dualAxisPicker.onChangeColorValue = handleChangeColorValue
        hueSliderPicker.onChangeColorValue = handleChangeColorValue
        alphaSliderPicker.onChangeColorValue = handleChangeColorValue
    }

    private func setUpConstraints() {
        translatesAutoresizingMaskIntoConstraints = false

        dualAxisPicker.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        dualAxisPicker.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        dualAxisPicker.topAnchor.constraint(equalTo: topAnchor).isActive = true

        dualAxisPicker.bottomAnchor.constraint(equalTo: hueSliderPicker.topAnchor, constant: -4).isActive = true

        hueSliderPicker.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        hueSliderPicker.trailingAnchor.constraint(equalTo: swatchColorPicker.leadingAnchor, constant: -5).isActive = true

        hueSliderPicker.heightAnchor.constraint(equalToConstant: 10).isActive = true

        hueSliderPicker.bottomAnchor.constraint(equalTo: alphaSliderPicker.topAnchor, constant: -4).isActive = true

        alphaSliderPicker.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        alphaSliderPicker.trailingAnchor.constraint(equalTo: swatchColorPicker.leadingAnchor, constant: -5).isActive = true
        alphaSliderPicker.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true

        alphaSliderPicker.heightAnchor.constraint(equalToConstant: 10).isActive = true

        swatchColorPicker.topAnchor.constraint(equalTo: hueSliderPicker.topAnchor).isActive = true
        swatchColorPicker.bottomAnchor.constraint(equalTo: alphaSliderPicker.bottomAnchor).isActive = true
        swatchColorPicker.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true

        swatchColorPicker.heightAnchor.constraint(equalToConstant: 24).isActive = true
        swatchColorPicker.widthAnchor.constraint(equalToConstant: 24).isActive = true
    }

    private func update() {
        dualAxisPicker.colorValue = colorValue
        hueSliderPicker.colorValue = colorValue
        alphaSliderPicker.colorValue = colorValue
        swatchColorPicker.colorValue = colorValue
    }
}

