//
//  AppDelegate.swift
//  Tuchuang
//
//  Created by peterfei on 2016/11/25.
//  Copyright © 2016年 peterfei. All rights reserved.
//

import Cocoa
import MASPreferences
import TMCache
import Carbon
var appDelegate: NSObject?
var statusItem: NSStatusItem!

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet weak var window: NSWindow!
    @IBOutlet weak var statusMenu: NSMenu!
    
    lazy var preferencesWindowController: NSWindowController = {
        
        let imageViewController = ImagePreferencesViewController()
        let generalViewController = GeneralViewController()
        let controllers = [generalViewController, imageViewController]
        let wc = MASPreferencesWindowController(viewControllers: controllers, title: "设置")
        imageViewController.window = wc.window
        return wc
    }()
    func applicationDidFinishLaunching(aNotification: NSNotification) {
        // Insert code here to initialize your application
        window.center()
        appDelegate = self
        statusItem = NSStatusBar.systemStatusBar().statusItemWithLength(NSSquareStatusItemLength)
//        let statusBarButton = DragDestinationView(frame: (statusItem.button?.bounds)!)
//        statusItem.button?.superview?.addSubview(statusBarButton, positioned: .Below, relativeTo: statusItem.button)
        let iconImage = NSImage(named: "StatusIcon")
        iconImage?.template = true
        statusItem.button?.image = iconImage
        statusItem.button?.action = #selector(showMenu)
        statusItem.button?.target = self
    }

    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
    }
    func showMenu() {
        statusItem.popUpStatusItemMenu(statusMenu)
    }
    @IBAction func statusMenuClicked(sender: NSMenuItem) {
        switch sender.tag{
        case 1:
            break
        case 2:
            // 设置
            print("click preferencesWindow")
            preferencesWindowController.showWindow(nil)
            preferencesWindowController.window?.center()
            NSApp.activateIgnoringOtherApps(true)
        case 3:
            // 退出
            NSApp.terminate(nil)
        default:
            break
        
        }
    }

    
}

