//
//  ImagePreferencesViewController.swift
//  图床
//
//  Created by peterfei on 2016/11/25.
//  Copyright © 2016年 peterfei. All rights reserved.
//

import Cocoa
import MASPreferences

class ImagePreferencesViewController: NSViewController, MASPreferencesViewController {
    
    override var identifier: String? { get { return "image" } set { super.identifier = newValue } }
    var toolbarItemLabel: String? { get { return "图床" } }
    var toolbarItemImage: NSImage? { get { return NSImage(named: NSImageNameUser) } }
    
    var window: NSWindow?
    
    @IBOutlet weak var statusLabel: NSTextField!
    @IBOutlet weak var apiKeyTextField: NSTextField!
    
    
    @IBOutlet weak var bucketNameTextField: NSTextField!
    
    @IBOutlet weak var urlPrefixTextField: NSTextField!
    
    @IBOutlet weak var checkButton: NSButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if isUseSet {
            statusLabel.cell?.title = "目前使用自定义图床"
            statusLabel.textColor = .magentaColor()
        } else {
            statusLabel.cell?.title = "目前使用默认图床"
            statusLabel.textColor = .redColor()
        }
        
        apiKeyTextField.cell?.title = apiKey
        bucketNameTextField.cell?.title = bucket
        urlPrefixTextField.cell?.title = urlPrefix
    }
    @IBAction func setDefault(sender: AnyObject) {
        isUseSet = false
        statusLabel.cell?.title = "目前使用默认图床"
        statusLabel.textColor = .redColor()
        
    }
    
    @IBAction func setUpYunConfig(sender: AnyObject) {
        if (apiKeyTextField.cell?.title.characters.count == 0 ||
            bucketNameTextField.cell?.title.characters.count == 0 ||
            urlPrefixTextField.cell?.title.characters.count == 0) {
            showAlert("有配置信息未填写", informative: "请仔细填写")
            return
        }
        
        urlPrefixTextField.cell?.title = (urlPrefixTextField.cell?.title.stringByReplacingOccurrencesOfString(" ", withString: ""))!
        
        if !(urlPrefixTextField.cell?.title.hasPrefix("http://"))! && !(urlPrefixTextField.cell?.title.hasPrefix("https://"))! {
            urlPrefixTextField.cell?.title = "http://" + (urlPrefixTextField.cell?.title)!
        }
        
        if !(urlPrefixTextField.cell?.title.hasSuffix("/"))! {
            urlPrefixTextField.cell?.title = (urlPrefixTextField.cell?.title)! + "/"
        }
        
        let ak = (apiKeyTextField.cell?.title)!
        let bck = (bucketNameTextField.cell?.title)!
        

        let ts = "1"
        checkButton.title = "验证中"
        checkButton.enabled = false
        let up = UPFormUploader()
        up.upload(ts.dataUsingEncoding(NSUTF8StringEncoding),
                  fileName: "1",
                  formAPIKey: ak,
                  bucketName: bck,
                  saveKey: "1",
                  otherParameters: nil,
                  success: {[weak self](response, responseObject) in
                    print("success \(responseObject)")
                    self?.checkButton.enabled = true
                    self?.checkButton.title = "验证配置"
                    self?.showAlert("验证成功", informative: "配置成功。")
                    apiKey = (self?.apiKeyTextField.cell?.title)!
                    bucket = (self?.bucketNameTextField.cell?.title)!
                    urlPrefix = (self?.urlPrefixTextField.cell?.title)!
                    self?.statusLabel.cell?.title = "目前使用自定义图床"
                    self?.statusLabel.textColor = .magentaColor()
                    isUseSet = true
                  },
                  failure: { (error, response, responseObject) in
                    print("failure: \(error)")
                    print("failure: \(responseObject)")
                  },
                  progress: {(completedBytesCount, totalBytesCount) in
            })

    }
    
    func showAlert(message: String, informative: String) {
        let arlert = NSAlert()
        arlert.messageText = message
        arlert.informativeText = informative
        arlert.addButtonWithTitle("确定")
        if message == "验证成功" {
            arlert.icon = NSImage(named: "Icon_32x32")
        }
        else {
            arlert.icon = NSImage(named: "Failure")
        }
        
        arlert.beginSheetModalForWindow(self.window!, completionHandler: { (response) in
            
        })
    }
    
}