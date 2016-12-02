//
//  ViewController.swift
//  WiBlaze
//
//  Created by Justin Bush on 2016-01-23.
//  Copyright © 2016 Justin Bush. All rights reserved.
//

import UIKit
import WebKit
import Foundation

class ViewController: UIViewController, WKNavigationDelegate, UITextFieldDelegate {
    
    var webView: WKWebView!
    @IBOutlet var textField: UITextField!
    @IBOutlet var backButton: UIBarButtonItem!
    @IBOutlet var bookmarksButton: UIBarButtonItem!
    @IBOutlet var menuButton: UIBarButtonItem!
    @IBOutlet var refreshButton: UIBarButtonItem!
    @IBOutlet var forwardButton: UIBarButtonItem!
    
    override func loadView() {
        webView = WKWebView()
        webView.navigationDelegate = self
        view = webView
        
        UIApplication.shared.statusBarStyle = .default
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        textField.delegate = self
        
        self.backButton.isEnabled = false
        self.refreshButton.isEnabled = false
        self.forwardButton.isEnabled = false
        
        // Load previously saved URL
        if UserDefaults.standard.object(forKey: "savedURL") != nil {
            let url = UserDefaults.standard.object(forKey: "savedURL")!
            let request = URL(string: url as! String)!
            webView.load(URLRequest(url: request))
        }

        webView.allowsBackForwardNavigationGestures = true
        
        // Notification observer for device orientation
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.userDidRotate), name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func setTextFieldWidth() {
        var frame: CGRect = self.textField.frame
        frame.size.width = self.view.frame.width
        self.textField.frame = frame
    }
    
    func userDidRotate() {
        if(UIDeviceOrientationIsLandscape(UIDevice.current.orientation)) {
            print("Orientation Change: Landscape")
            setTextFieldWidth()
        }
        
        if(UIDeviceOrientationIsPortrait(UIDevice.current.orientation)) {
            print("Orientation Change: Portrait")
            setTextFieldWidth()
        }
    }
    
    func textFieldShouldReturn(_ sender: UITextField) -> Bool {
        textField.resignFirstResponder()
        print("Request:", textField.text!)
        
        let request = textField.text!
        
        // Check if request ONLY contains URL prefixes
        let prefixes = ["http://", "https://", "www.", "http://www.", "https://www."]
        
        if prefixes.contains(request) {
            print("URL does contain prefix")
            // URL ONLY contains prefix
            // Load page error: Not a valid URL
        }
        
        // Check if request contains http:// or https:// + a string
        if (request.lowercased().range(of: "http://") != nil) || (request.lowercased().range(of: "https://") != nil) {
            print("String does contain prefix")
            // Replace any spaces with %20
            let request = request.replacingOccurrences(of: " ", with: "%20", options: NSString.CompareOptions.literal, range: nil)
            let formattedURL = URL(string: request)!
            webView.load(URLRequest(url: formattedURL))
        }
        
        // Check if request contains a period
        else if request.range(of: ".") != nil {
            print("Period exists, add http:// and load request as URL")
            let request = request.replacingOccurrences(of: " ", with: "%20", options: NSString.CompareOptions.literal, range: nil)
            let formattedURL = URL(string: "http://" + request)!
            webView.load(URLRequest(url: formattedURL))
            print("Loading URL:", formattedURL)
        }
        
        // Check if request does not pass URL test
        else {
            print("Request does not pass URL test, load as search term")
            let query = request.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
            let formattedURL = URL(string: "https://google.com/#q=\(query)")!
            webView.load(URLRequest(url: formattedURL))
            print("Loading URL:", formattedURL)
        }
        
        return true
    }
    
    // WebView has finished loading
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        print("URL has loaded successfully")
        // Reflect loaded URL in textField
        textField.text = webView.url?.absoluteString as String!
        
        // Save URL for if application quits or crashes
        let url = textField.text!
        UserDefaults.standard.set(url, forKey: "savedURL")
        UserDefaults.standard.synchronize()
        
        // Check if request contains https://
        if (textField.text!.lowercased().range(of: "https://") != nil) {
            print("String is secure https")
            self.textField.textColor = UIColor(red:0.0, green:0.75, blue:0.02, alpha:1.0)
        }
        
        else {
            self.textField.textColor = self.view.tintColor
        }
        
        self.refreshButton.isEnabled = true
        
        if (self.webView.canGoBack) {
            self.backButton.isEnabled = true
        } else {
            self.backButton.isEnabled = false
        }
        
        if (self.webView.canGoForward) {
            self.forwardButton.isEnabled = true
        } else {
            self.forwardButton.isEnabled = false
        }
    }
    
    @IBAction func back(_ sender: AnyObject) {
        if (self.webView.canGoBack) {
            self.webView.goBack()
        }
    }
    
    @IBAction func refresh(_ sender: AnyObject) {
            self.webView.reload()
    }
    
    @IBAction func forward(_ sender: AnyObject) {
        if (self.webView.canGoForward) {
            self.webView.goForward()
        }
    }
    
    @IBAction func menu(_ sender: AnyObject) {
        let kInfoTitle = "Menu"
        let kSubtitle = textField.text!
        let menu = SCLAlertView()
        menu.addButton("Share", target:self, selector:Selector("firstButton"))
        menu.addButton("Set as Homepage", target:self, selector:Selector("firstButton"))
        menu.addButton("Add to Favourites", target:self, selector:Selector("firstButton"))
        menu.addButton("Settings", target:self, selector:Selector("firstButton"))
        menu.showEdit(kInfoTitle, subTitle: kSubtitle)
    }
}
