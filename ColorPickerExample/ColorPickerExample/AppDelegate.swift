//
//  AppDelegate.swift
//  ColorPickerExample
//
//  Created by Devin Abbott on 8/26/18.
//  Copyright © 2018 BitDisco, Inc. All rights reserved.
//

import AppKit
import ColorPicker

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet weak var window: NSWindow!


    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application

        let contentView = NSView(frame: NSRect(x: 0, y: 0, width: 300, height: 600))

        let dualAxisPicker = DualAxisColorPicker()
        dualAxisPicker.colorValue = NSColor.orange
        dualAxisPicker.onChangeColorValue = { color in
            dualAxisPicker.colorValue = color
        }

        contentView.addSubview(dualAxisPicker)

        dualAxisPicker.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10).isActive = true
        dualAxisPicker.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10).isActive = true
        dualAxisPicker.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10).isActive = true
        dualAxisPicker.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10).isActive = true

        window.contentView = contentView
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }


}

