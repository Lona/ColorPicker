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

    var color = Color(red: 0.1, green: 0.5, blue: 1, alpha: 0.5)

    let colorWellPicker = ColorWellPicker()
    let contentView = NSView(frame: NSRect(x: 0, y: 0, width: 100, height: 40))

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        setUpViews()
        setUpConstraints()

        update()

        window.contentView = contentView
    }

    func setUpViews() {
        contentView.addSubview(colorWellPicker)

        colorWellPicker.onChangeColorValue = { colorValue in
            self.color = colorValue
            self.update()
        }
    }

    func setUpConstraints() {
        contentView.translatesAutoresizingMaskIntoConstraints = false
        colorWellPicker.translatesAutoresizingMaskIntoConstraints = false

        colorWellPicker.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10).isActive = true
        colorWellPicker.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10).isActive = true
        colorWellPicker.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10).isActive = true
        colorWellPicker.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10).isActive = true
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    private func update() {
        colorWellPicker.colorValue = color
    }
}

