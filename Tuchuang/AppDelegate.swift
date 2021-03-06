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
var imagesCacheArr: [[String: AnyObject]] = Array()
func arc() -> UInt32 { return arc4random() % 100000 }
var picUrlPrefix = "http://patienthome.b0.upaiyun.com/"
var apiKeyVal = ""
var bucketVal = ""
var isUseSet: Bool {
get {
    if let isUseSet = NSUserDefaults.standardUserDefaults().valueForKey("isUseSet") {
        return isUseSet as! Bool
    }
    return false
}
set {
    NSUserDefaults.standardUserDefaults().setValue(newValue, forKey: "isUseSet")
}

}
var urlPrefix: String {
get {
    if let urlPrefix = NSUserDefaults.standardUserDefaults().valueForKey("urlPrefix") {
        return urlPrefix as! String
    }
    return ""
}
set {
    NSUserDefaults.standardUserDefaults().setValue(newValue, forKey: "urlPrefix")
}

}

var apiKey: String {
get {
    if let apiKey = NSUserDefaults.standardUserDefaults().valueForKey("apiKey") {
        return apiKey as! String
    }
    return ""
}
set {
    NSUserDefaults.standardUserDefaults().setValue(newValue, forKey: "apiKey")
}

}



var bucket: String {
get {
    if let bucket = NSUserDefaults.standardUserDefaults().valueForKey("bucket") {
        return bucket as! String
    }
    return ""
}
set {
    NSUserDefaults.standardUserDefaults().setValue(newValue, forKey: "bucket")
}

}
func upload(pboard:NSPasteboard) -> Void {
    
    // 是否自定义
    if isUseSet {

        picUrlPrefix = urlPrefix
        apiKeyVal = apiKey
        bucketVal = bucket
        
    } else {
        picUrlPrefix = "http://patienthome.b0.upaiyun.com/"
        apiKeyVal = "W6RALa1sP37BjE2FEXfMrjINTOA="
        bucketVal = "patienthome"
    }
    
    let files: NSArray? = pboard.propertyListForType(NSFilenamesPboardType) as? NSArray
//    let data:NSData = (pboard.propertyListForType(NSFilenamesPboardType) as? NSData)!
    let up = UPBlockUploader()
    
    
    
    if let files = files {
        statusItem.button?.image = NSImage(named: "StatusIcon")
        statusItem.button?.image?.template = true
        let filePath:String? = files.firstObject as? String
        if let filePath = filePath {
            let fileName = getDateString() + "\(arc())" + NSString(string: filePath).lastPathComponent
            guard let _ = NSImage(contentsOfFile: files.firstObject as! String) else {
                return
            }
            print("url is \(picUrlPrefix)")
            print("apiKey is \(apiKeyVal)")
            print("bucket is \(bucketVal)")
            up.upload(filePath,
                      fileName: fileName,
                      apiKey: apiKeyVal,
                      bucketName: bucketVal,
                      saveKey: fileName,
                      otherParameters: nil,
                      success: { (response, responseObject) in
                        statusItem.button?.image = NSImage(named: "StatusIcon")
                        statusItem.button?.image?.template = true
//                        print("success: \(responseObject["path"]!)")
//                        let key = responseObject["path"]! as! String
                        NSPasteboard.generalPasteboard().clearContents()
                        NSPasteboard.generalPasteboard()
                        NSPasteboard.generalPasteboard().setString("![" + NSString(string: filePath).lastPathComponent + "](" + picUrlPrefix + fileName + ")", forType: NSStringPboardType)
                        NotificationMessage("上传图片成功", isSuccess: true)
                        var picUrl: String!
                        if linkType == 0 {
                            picUrl = "![" + fileName + "](" + picUrlPrefix + fileName + ")"
                        }
                        else {
                            picUrl = picUrlPrefix + fileName
                        }
                        NSPasteboard.generalPasteboard().setString(picUrl, forType: NSStringPboardType)
                },
                      failure: { (error, response, responseObject) in
                        print("failure: \(error)")
                        print("failure: \(responseObject)")
                },
                      progress: { (completedBytesCount, totalBytesCount) in
                        print("上传进程: \(completedBytesCount) | \(totalBytesCount)")
                        print("上传百分比: \((completedBytesCount*10/totalBytesCount))")
//                        (completedBytesCount/totalBytesCount)*10
//                        let percentagevalue: Double = .roundTo0f

                        statusItem.button?.image = NSImage(named: "loading-\((completedBytesCount*10/totalBytesCount))")
                        statusItem.button?.image?.template = true
            })
            
        }
        
        
    }
    

}
func NotificationMessage(message: String, informative: String? = nil, isSuccess: Bool = false) {
    
    let notification = NSUserNotification()
    let notificationCenter = NSUserNotificationCenter.defaultUserNotificationCenter()
    notificationCenter.delegate = appDelegate as? NSUserNotificationCenterDelegate
    notification.title = message
    notification.informativeText = informative
    if isSuccess {
        notification.contentImage = NSImage(named: "success")
        notification.informativeText = "链接已经保存在剪贴板里，可以直接粘贴"
    } else {
        notification.contentImage = NSImage(named: "Failure")
    }
    
    notification.soundName = NSUserNotificationDefaultSoundName;
    notificationCenter.scheduleNotification(notification)
    
}

var autoUp: Bool {
get {
    if let autoUp = NSUserDefaults.standardUserDefaults().valueForKey("autoUp") {
        return autoUp as! Bool
    }
    return false
}
set {
    NSUserDefaults.standardUserDefaults().setValue(newValue, forKey: "autoUp")
}
}
@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    let pasteboardObserver = PasteboardObserver()
    @IBOutlet weak var window: NSWindow!
    @IBOutlet weak var statusMenu: NSMenu!
    @IBOutlet weak var uploadMenuItem: NSMenuItem!
    @IBOutlet weak var autoUpItem: NSMenuItem!
    @IBOutlet weak var MarkdownItem: NSMenuItem!
    lazy var preferencesWindowController: NSWindowController = {
        
        let imageViewController = ImagePreferencesViewController()
        let generalViewController = GeneralViewController()
        let controllers = [generalViewController, imageViewController]
        let wc = MASPreferencesWindowController(viewControllers: controllers, title: "设置")
        imageViewController.window = wc.window
        return wc
    }()
    func applicationDidFinishLaunching(aNotification: NSNotification) {
        pasteboardObserver.addSubscriber(self)
        
        if autoUp {
            
            pasteboardObserver.startObserving()
            autoUpItem.state = 1
            
        }
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(notification), name: "MarkdownState", object: nil)
        // Insert code here to initialize your application
        registerHotKeys()
        pasteboardObserver.addSubscriber(self)
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
    func notification(notification: NSNotification) {
        
        if notification.object?.intValue == 0 {
            MarkdownItem.state = 1
        }
        else {
            MarkdownItem.state = 0
        }
        
    }
    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
    }
    func showMenu() {
        let pboard = NSPasteboard.generalPasteboard()
        let files: NSArray? = pboard.propertyListForType(NSFilenamesPboardType) as? NSArray
        
        if let files = files {
            let i = NSImage(contentsOfFile: files.firstObject as! String)
            i?.scalingImage()
            uploadMenuItem.image = i
            
        } else {
            let i = NSImage(pasteboard: pboard)
            i?.scalingImage()
            uploadMenuItem.image = i
            
        }
        
        let object = TMCache.sharedCache().objectForKey("imageCache")
        if let obj = object as? [[String: AnyObject]] {
            imagesCacheArr = obj
            
        }
//        cacheImageMenuItem.submenu = makeCacheImageMenu(imagesCacheArr)
        statusItem.popUpStatusItemMenu(statusMenu)
    }
    @IBAction func statusMenuClicked(sender: NSMenuItem) {
        switch sender.tag{
        case 1:
            let pboard = NSPasteboard.generalPasteboard()
            upload(pboard)
        case 2:
            // 设置
            print("click preferencesWindow")
            preferencesWindowController.showWindow(nil)
            preferencesWindowController.window?.center()
            NSApp.activateIgnoringOtherApps(true)
        case 3:
            // 退出
            NSApp.terminate(nil)
        case 4:
            print("click autoMenu")
            if sender.state == 0 {
                sender.state = 1
                pasteboardObserver.startObserving()
                autoUp = true
            }
            else {
                sender.state = 0
                pasteboardObserver.stopObserving()
                autoUp = false
            }
        default:
            break
        
        }
    }
    
    
    func makeCacheImageMenu(imagesArr: [[String: AnyObject]]) -> NSMenu {
        let menu = NSMenu()
        if imagesArr.count == 0 {
            let item = NSMenuItem(title: "没有历史", action: nil, keyEquivalent: "")
            menu.addItem(item)
        } else {
            for index in 0..<imagesArr.count {
                let item = NSMenuItem(title: "", action: #selector(cacheImageClick(_:)), keyEquivalent: "")
                item.tag = index
                let i = imagesArr[index]["image"] as? NSImage
                i?.scalingImage()
                item.image = i
                menu.insertItem(item, atIndex: 0)
            }
        }
        
        return menu
    }
    
    func cacheImageClick(sender: NSMenuItem) {
        
        NSPasteboard.generalPasteboard().clearContents()
        
        var picUrl = imagesCacheArr[sender.tag]["url"] as! String
        
        let fileName = NSString(string: picUrl).lastPathComponent
        
        if linkType == 0 {
            picUrl = "![" + fileName + "](" + picUrl + ")"
        }
        
        NSPasteboard.generalPasteboard().setString(picUrl, forType: NSStringPboardType)
        NotificationMessage("图片链接获取成功", isSuccess: true)
        
    }

    func NotificationMessage(message: String, informative: String? = nil, isSuccess: Bool = false) {
        
        let notification = NSUserNotification()
        let notificationCenter = NSUserNotificationCenter.defaultUserNotificationCenter()
        notificationCenter.delegate = appDelegate as? NSUserNotificationCenterDelegate
        notification.title = message
        notification.informativeText = informative
        if isSuccess {
            notification.contentImage = NSImage(named: "success")
            notification.informativeText = "链接已经保存在剪贴板里，可以直接粘贴"
        } else {
            notification.contentImage = NSImage(named: "Failure")
        }
        
        notification.soundName = NSUserNotificationDefaultSoundName;
        notificationCenter.scheduleNotification(notification)
        
    }
    
}

extension AppDelegate: NSUserNotificationCenterDelegate, PasteboardObserverSubscriber {
    // 强行通知
    func userNotificationCenter(center: NSUserNotificationCenter, shouldPresentNotification notification: NSUserNotification) -> Bool {
        return true
    }
    
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String: AnyObject]?, context: UnsafeMutablePointer<Void>) {
        
        print(change)
        
    }
    
    func pasteboardChanged(pasteboard: NSPasteboard) {
        print("pasteboardChanged")
        upload(pasteboard)
        
    }
    
    func registerHotKeys() {
        
        var gMyHotKeyRef: EventHotKeyRef = nil
        var gMyHotKeyIDU = EventHotKeyID()
        var gMyHotKeyIDM = EventHotKeyID()
        var eventType = EventTypeSpec()
        
        eventType.eventClass = OSType(kEventClassKeyboard)
        eventType.eventKind = OSType(kEventHotKeyPressed)
        gMyHotKeyIDU.signature = OSType(32)
        gMyHotKeyIDU.id = UInt32(kVK_ANSI_U);
        gMyHotKeyIDM.signature = OSType(46);
        gMyHotKeyIDM.id = UInt32(kVK_ANSI_M);
        
        RegisterEventHotKey(UInt32(kVK_ANSI_U), UInt32(cmdKey), gMyHotKeyIDU, GetApplicationEventTarget(), 0, &gMyHotKeyRef)
        
        RegisterEventHotKey(UInt32(kVK_ANSI_M), UInt32(controlKey), gMyHotKeyIDM, GetApplicationEventTarget(), 0, &gMyHotKeyRef)
        
        // Install handler.
        InstallEventHandler(GetApplicationEventTarget(), { (nextHanlder, theEvent, userData) -> OSStatus in
            var hkCom = EventHotKeyID()
            GetEventParameter(theEvent, EventParamName(kEventParamDirectObject), EventParamType(typeEventHotKeyID), nil, sizeof(EventHotKeyID), nil, &hkCom)
            switch hkCom.id {
            case UInt32(kVK_ANSI_U):
                let pboard = NSPasteboard.generalPasteboard()
                upload(pboard)
            case UInt32(kVK_ANSI_M):
                if linkType == 0 {
                    linkType = 1
                    NSNotificationCenter.defaultCenter().postNotificationName("MarkdownState", object: 1)
                    guard let imagesCache = imagesCacheArr.last else {
                        return 33
                    }
                    NSPasteboard.generalPasteboard().clearContents()
                    let picUrl = imagesCache["url"] as! String
                    NSPasteboard.generalPasteboard().setString(picUrl, forType: NSStringPboardType)
                    
                }
                else {
                    linkType = 0
                    NSNotificationCenter.defaultCenter().postNotificationName("MarkdownState", object: 0)
                    guard let imagesCache = imagesCacheArr.last else {
                        return 33
                    }
                    NSPasteboard.generalPasteboard().clearContents()
                    var picUrl = imagesCache["url"] as! String
                    let fileName = NSString(string: picUrl).lastPathComponent
                    picUrl = "![" + fileName + "](" + picUrl + ")"
                    NSPasteboard.generalPasteboard().setString(picUrl, forType: NSStringPboardType)
                }
            default:
                break
            }
            
            return 33
            /// Check that hkCom in indeed your hotkey ID and handle it.
            }, 1, &eventType, nil, nil)
        
    }
    
}


