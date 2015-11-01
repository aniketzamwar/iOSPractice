//
//  ViewController.swift
//  Shorty - Practice
//
//  Created by Aniket Zamwar on 11/1/15.
//  Copyright © 2015 Aniket Zamwar. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIWebViewDelegate, NSURLConnectionDelegate, NSURLConnectionDataDelegate {

    @IBOutlet weak var urlField: UITextField!
    @IBOutlet weak var webView: UIWebView!
    @IBOutlet weak var shortenButton: UIBarButtonItem!
    @IBOutlet weak var shortLabel: UIBarButtonItem!
    @IBOutlet weak var clipboardButton: UIBarButtonItem!
    
    // todo -- replace api key
    let GoDaddyAccountKey = "<REPLACE WITH API KEY>"
    var shortenURLConnection: NSURLConnection?
    var shortURLData: NSMutableData?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func loadAction( _: AnyObject ) {
        
        var urlText = urlField.text
        
        if (!urlText!.hasPrefix("http:") && !urlText!.hasPrefix("htts:")) {
            if !(urlText?.hasPrefix("//") != nil) {
                urlText = "//" + urlText!
            }
            urlText = "http:" + urlText!
        }
        let url = NSURL(string: urlText!)
        webView.loadRequest(NSURLRequest(URL: url!))
        
    }
    
    @IBAction func shortenAction(sender: UIBarButtonItem) {
        
        if let toShorten = webView.request?.URL?.absoluteString {
            
            let encodedURL = toShorten.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)
            let urlString = "http://api.x.co/Squeeze.svc/text/\(GoDaddyAccountKey)?url=" + encodedURL!
            print(urlString)
            shortURLData = NSMutableData()
            let request = NSURLRequest(URL: NSURL(string : urlString)!)
            shortenURLConnection = NSURLConnection(request: request, delegate: self)
            shortenButton.enabled = false
        }
    }
    
    func webViewDidStartLoad(webView : UIWebView) {
        shortenButton.enabled = false
    }
    
    func webViewDidFinishLoad(webView : UIWebView) {
        shortenButton.enabled = true
        urlField.text = webView.request!.URL?.absoluteString
    }
    
    func webView( webView: UIWebView, didFailLoadWithError error: NSError? ) {
        
        let message = "That page could not be loaded. " + error!.localizedDescription
        let alert = UIAlertController(title: "Could not load URL", message: message, preferredStyle: .Alert )
        let okAction = UIAlertAction(title: "That's Sad", style: .Default, handler: nil)
        alert.addAction(okAction)
        presentViewController(alert, animated: true, completion: nil)
    }
    
    func connection(connection: NSURLConnection, didFailWithError error: NSError) {
        shortLabel.title = "failed"
        clipboardButton.enabled = false
        shortenButton.enabled = true
    }
    
    func connection(connection: NSURLConnection, didReceiveData data: NSData) {
        shortURLData?.appendData(data)
    }
    
    func connectionDidFinishLoading(connection: NSURLConnection) {
        if let data = shortURLData {
            let shortUrlString = NSString(data:data, encoding:NSUTF8StringEncoding)
            print(shortUrlString)
            shortLabel.title = shortUrlString as! String
            clipboardButton.enabled = true
        }
    }
    
    @IBAction func copyToClipboard(sender: UIBarButtonItem) {
        let shortURLString = shortLabel.title
        let shortURL = NSURL(string: shortURLString!)
        UIPasteboard.generalPasteboard().URL = shortURL
    }
    

}

