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
    
    @IBOutlet weak var isPairedLabel: UILabel!
    @IBOutlet weak var isAppInstalledLabel: UILabel!
    @IBOutlet weak var isConnectedLabel: UILabel!
    
    @IBOutlet weak var delayLabel: UILabel!
    
    @IBOutlet weak var numeratorSelector: UISegmentedControl!
    @IBOutlet weak var denominatorSelector: UISegmentedControl!
    let session : WCSession
    
    required init?(coder aDecoder: NSCoder) {
        session = WCSession.defaultSession()
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if(WCSession.isSupported()) {
            self.session.delegate = self
            self.session.activateSession()
            
            self.isAppInstalledLabelUpdate()
            self.isConnectedLabelUpdate()
            self.isPairedLabelUpdate()
        }
    }

    func sessionReachabilityDidChange(session: WCSession) {
        // Aha, this may not be coming back on the main thread. Fix that
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.isAppInstalledLabelUpdate()
            self.isConnectedLabelUpdate()
            self.isPairedLabelUpdate()
        })
    }
    
    func sessionWatchStateDidChange(session: WCSession) {
        print("watch state changed %@", session.paired)

    }
    func session(session: WCSession, didReceiveApplicationContext applicationContext: [String : AnyObject]) {
        processMessage(applicationContext)
    }
    
    func session(session: WCSession, didReceiveMessage message: [String : AnyObject], replyHandler: ([String : AnyObject]) -> Void) {
        processMessage(message)
    }
    
    func processMessage(message : [String : AnyObject]) {
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            if let xValue = message["x"] as! Float? {
                self.xLabel.text = "x: ".stringByAppendingString(String(xValue))
            }
            if let yValue = message["y"] as! Float? {
                self.yLabel.text = "y: ".stringByAppendingString(String(yValue))
            }
            if let zValue = message["z"] as! Float? {
                self.zLabel.text = "z: ".stringByAppendingString(String(zValue))
            }
            
            let numeratorString = self.numeratorSelector.titleForSegmentAtIndex(self.numeratorSelector.selectedSegmentIndex)
            if let numeratorValue = message[numeratorString!] as! Float? {
                let denominatorString = self.denominatorSelector.titleForSegmentAtIndex(self.denominatorSelector.selectedSegmentIndex)
                
                if let denominatorValue = message[denominatorString!] as! Float? {
                    if let rate = message["rate"] as! NSTimeInterval? {
                        let shorterRate = rate - 0.1
                        UIView.animateWithDuration(shorterRate, delay: 0, options: .BeginFromCurrentState, animations: { () -> Void in
                            let rotation = atan2(Double(numeratorValue), Double(denominatorValue)) - M_PI
                            print("rotation is " + String(rotation))
                            self.emojiLabel.transform = CGAffineTransformMakeRotation(-CGFloat(rotation))
                            }, completion: nil)
                    }
                }
            }
            if let timeSent = message["time"] as! NSTimeInterval? {
                let delta = NSDate().timeIntervalSince1970 - timeSent
                self.delayLabel.text = String(delta)
            } else {
                self.delayLabel.text = String(message)
                
            }
        })
    }
    
    func isAppInstalledLabelUpdate() {
        if(self.session.watchAppInstalled) {
            self.isAppInstalledLabel.text = "app is\non ⌚️"
        } else {
            self.isAppInstalledLabel.text = "app is\nnot on ⌚️"
        }
    }
    
    func isConnectedLabelUpdate() {
        if (!NSThread.isMainThread()) {
            print("updating a label on not the main thread")
        }
        if(self.session.reachable) {
            self.isConnectedLabel.text = "⌚️ reachable"
        } else {
            self.isConnectedLabel.text = "⌚️ not \nreachable"
        }

    }
    
    func isPairedLabelUpdate() {
        if(self.session.paired) {
            self.isPairedLabel.text = "⌚️ and 📱 \nare 🍐d"
        } else {
            self.isPairedLabel.text = "🚨 ⌚️ and 📱\nare not 🍐d"
        }
    }
    
    
}

