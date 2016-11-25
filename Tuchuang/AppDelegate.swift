//
//  AppDelegate.swift
//  Tuchuang
//
//  Created by peterfei on 2016/11/25.
//  Copyright © 2016年 peterfei. All rights reserved.
//

import Cocoa

var appDelegate: NSObject?
var statusItem: NSStatusItem!

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet weak var window: NSWindow!


    func applicationDidFinishLaunching(aNotification: NSNotification) {
        // Insert code here to initialize your application
        appDelegate = self
        statusItem = NSStatusBar.systemStatusBar().statusItemWithLength(NSSquareStatusItemLength)
//        let statusBarButton = DragDestinationView(frame: (statusItem.button?.bounds)!)
//        statusItem.button?.superview?.addSubview(statusBarButton, positioned: .Below, relativeTo: statusItem.button)
        let iconImage = NSImage(named: "StatusIcon")
        iconImage?.template = true
        statusItem.button?.image = iconImage
        statusItem.button?.target = self
    }

    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
    }


}

