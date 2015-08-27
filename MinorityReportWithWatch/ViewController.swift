//
//  ViewController.swift
//  MinorityReportWithWatch
//
//  Created by Roderic Campbell on 8/20/15.
//  Copyright © 2015 Roderic Campbell. All rights reserved.
//

import UIKit
import WatchConnectivity

class ViewController: UIViewController, WCSessionDelegate {

    @IBOutlet weak var emojiLabel: UILabel!
    
    @IBOutlet weak var xLabel: UILabel!
    @IBOutlet weak var yLabel: UILabel!
    @IBOutlet weak var zLabel: UILabel!
    
    @IBOutlet weak var rotationXLabel: UILabel!
    @IBOutlet weak var rotationYLabel: UILabel!
    @IBOutlet weak var rotationZLabel: UILabel!
    
    @IBOutlet weak var isPairedLabel: UILabel!
    @IBOutlet weak var isAppInstalledLabel: UILabel!
    @IBOutlet weak var isConnectedLabel: UILabel!
    
    let session : WCSession
    
    required init?(coder aDecoder: NSCoder) {
        session = WCSession.defaultSession()
        print("init")
        super.init(coder: aDecoder)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
//        UIView.animateWithDuration(1) { () -> Void in
//            self.emojiLabel.transform = CGAffineTransformScale(self.emojiLabel.transform, 0.3, 0.3)
//        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("view did load")
        if(WCSession.isSupported()) {
            print("wcsession is supported")
            self.session.delegate = self
            self.session.activateSession()
            
            self.isAppInstalledButtonTapped(self)
            self.isConnectedButtonTapped(self)
            self.isPairedButtonTapped(self)
        
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func sessionReachabilityDidChange(session: WCSession) {
        print("session reachability changed")
    }
    func sessionWatchStateDidChange(session: WCSession) {
        print("watch state changed %@", session.paired)

    }
    func session(session: WCSession, didReceiveMessage message: [String : AnyObject], replyHandler: ([String : AnyObject]) -> Void) {
        print("We got something on the phone here")
        print(message)
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            
            if let xText = message["x"] as! Float? {
                
                // Change the title on the main thread
                self.xLabel.text = String(xText)
            }
            
            if let yText = message["y"] as! Float? {
                
                // Change the title on the main thread
                self.yLabel.text = String(yText)
            }
            if let zText = message["z"] as! Float? {
                
                // Change the title on the main thread
                self.zLabel.text = String(zText)
            }
            
            if let xText = message["rotation x"] as! Float? {
                
                // Change the title on the main thread
                self.rotationXLabel.text = String(xText)
            }
            
            if let yText = message["rotation y"] as! Float? {
                
                // Change the title on the main thread
                self.rotationYLabel.text = String(yText)
            }
            if let zText = message["rotation z"] as! Float? {
                
                // Change the title on the main thread
                self.rotationZLabel.text = String(zText)
            }
            
        })
        
        
    }
    
    @IBAction func isAppInstalledButtonTapped(sender: AnyObject) {
        if(self.session.watchAppInstalled) {
            self.isAppInstalledLabel.text = "installed\non watch"
        } else {
            self.isAppInstalledLabel.text = "not installed\non watch"
        }
    }
    @IBAction func isConnectedButtonTapped(sender: AnyObject) {
        if(self.session.reachable) {
            self.isConnectedLabel.text = "watch is\nreachable"
        } else {
            self.isConnectedLabel.text = "watch is\nnot reachable"
        }

    }
    @IBAction func isPairedButtonTapped(sender: AnyObject) {
        if(self.session.paired) {
            self.isPairedLabel.text = "paired"
        } else {
            self.isPairedLabel.text = "not paired"
        }
    }
    
    
}

