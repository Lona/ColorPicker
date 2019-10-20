//
//  ShadowPicker.swift
//  ColorPicker
//
//  Created by Devin Abbott on 10/19/19.
//  Copyright © 2019 BitDisco, Inc. All rights reserved.
//

import AppKit
import Colors
import Foundation

// MARK: - ShadowPicker

open class ShadowPicker: NSView {

    public enum EmulationMode: CaseIterable {
        case split
        case appKit
        case webKit

        public init(index: Int) {
            self = EmulationMode.allCases[index]
        }

        public var index: Int {
            return EmulationMode.allCases.firstIndex(of: self)!
        }

        public var title: String {
            switch self {
            case .appKit: return "iOS renderer"
            case .webKit: return "Web renderer"
            case .split: return "Split renderer"
            }
        }
    }

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

    public var onChangeShadowValue: ((PickerShadow) -> Void)? { didSet { update() } }
    public var shadowValue: PickerShadow { didSet { update() } }

    // MARK: Private

    private let boxPreviewShadowPicker = BoxPreviewShadowPicker()
    private let inputFieldShadowPicker = InputFieldShadowPicker()

    private func setUpViews() {
        addSubview(boxPreviewShadowPicker)
        addSubview(inputFieldShadowPicker)

        let handleChangeShadowValue: (PickerShadow) -> Void = { [weak self] shadowValue in
            self?.onChangeShadowValue?(shadowValue)
        }

        boxPreviewShadowPicker.onChangeShadowValue = handleChangeShadowValue
        inputFieldShadowPicker.onChangeShadowValue = handleChangeShadowValue
    }

    private func setUpConstraints() {
        translatesAutoresizingMaskIntoConstraints = false

        boxPreviewShadowPicker.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        boxPreviewShadowPicker.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        boxPreviewShadowPicker.topAnchor.constraint(equalTo: topAnchor).isActive = true

        boxPreviewShadowPicker.bottomAnchor.constraint(equalTo: inputFieldShadowPicker.topAnchor, constant: -4).isActive = true

        inputFieldShadowPicker.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        inputFieldShadowPicker.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        inputFieldShadowPicker.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
    }

    private func update() {
        boxPreviewShadowPicker.shadowValue = shadowValue
        inputFieldShadowPicker.shadowValue = shadowValue
    }
}

