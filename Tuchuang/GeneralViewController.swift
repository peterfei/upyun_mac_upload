//
//  GeneralViewController.swift
//  图床
//
//  Created by peterfei on 2016/11/25.
//  Copyright © 2016年 peterfei. All rights reserved.
//

import Cocoa
import MASPreferences

var linkType: Int {
get {
    if let version = NSUserDefaults.standardUserDefaults().valueForKey("linkType") {
        return version as! Int
    }
    return 0
}
set {
    NSUserDefaults.standardUserDefaults().setValue(newValue, forKey: "linkType")
}

}

class GeneralViewController: NSViewController, MASPreferencesViewController {
    
    override var identifier: String? { get { return "general" } set { super.identifier = newValue } }
    var toolbarItemLabel: String? { get { return "基本" } }
    var toolbarItemImage: NSImage? { get { return NSImage(named: NSImageNamePreferencesGeneral) } }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
}
