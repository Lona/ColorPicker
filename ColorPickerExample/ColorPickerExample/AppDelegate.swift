//
//  AppDelegate.swift
//  ColorPickerExample
//
//  Created by Devin Abbott on 8/26/18.
//  Copyright © 2018 BitDisco, Inc. All rights reserved.
//

import AppKit
import ColorPicker
import Colors

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet weak var window: NSWindow!

    let margin: CGFloat = 10

    var color = Color.orange

    let dualAxisPicker = DualAxisColorPicker()
    let hueSliderPicker = SliderColorPicker()

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        let contentView = NSView(frame: NSRect(x: 0, y: 0, width: 300, height: 600))

        contentView.addSubview(dualAxisPicker)
        contentView.addSubview(hueSliderPicker)

        dualAxisPicker.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: margin).isActive = true
        dualAxisPicker.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -margin).isActive = true
        dualAxisPicker.topAnchor.constraint(equalTo: contentView.topAnchor, constant: margin).isActive = true

        dualAxisPicker.bottomAnchor.constraint(equalTo: hueSliderPicker.topAnchor, constant: -4).isActive = true

        hueSliderPicker.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: margin).isActive = true
        hueSliderPicker.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -margin).isActive = true
        hueSliderPicker.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -margin).isActive = true

        hueSliderPicker.heightAnchor.constraint(equalToConstant: 10).isActive = true

        window.contentView = contentView

        dualAxisPicker.onChangeColorValue = { color in
            self.color = color
            self.update()
        }

        hueSliderPicker.onChangeColorValue = { color in
            self.color = color
            self.update()
        }

        update()
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    private func update() {
        dualAxisPicker.colorValue = color
        hueSliderPicker.colorValue = color
    }
}

