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

    var color = Color.orange

    let colorPicker = ColorPicker()
    let contentView = NSView(frame: NSRect(x: 0, y: 0, width: 300, height: 340))

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        setUpViews()
        setUpConstraints()

        update()

        window.contentView = contentView
    }

    func setUpViews() {
        contentView.addSubview(colorPicker)

        colorPicker.onChangeColorValue = { colorValue in
            self.color = colorValue
            self.update()
        }
    }

    func setUpConstraints() {
        contentView.translatesAutoresizingMaskIntoConstraints = false
        colorPicker.translatesAutoresizingMaskIntoConstraints = false

        colorPicker.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10).isActive = true
        colorPicker.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10).isActive = true
        colorPicker.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10).isActive = true
        colorPicker.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10).isActive = true
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    private func update() {
        colorPicker.colorValue = color
    }
}

