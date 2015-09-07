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

    @IBOutlet weak var howardImageView: UIImageView!
    
    @IBOutlet weak var xLabel: UILabel!
    @IBOutlet weak var yLabel: UILabel!
    @IBOutlet weak var zLabel: UILabel!
    
    @IBOutlet weak var isPairedLabel: UILabel!
    @IBOutlet weak var isAppInstalledLabel: UILabel!
    @IBOutlet weak var isConnectedLabel: UILabel!
    
    @IBOutlet weak var delayLabel: UILabel!
    
    @IBOutlet var debugElements: [UIView]!
    
    var rotationSet : Bool
    
    let session : WCSession
    
    required init?(coder aDecoder: NSCoder) {
        session = WCSession.defaultSession()
        rotationSet = true
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

    func hideLabels(shouldHide : Bool) {
    
        for view in self.debugElements {
            view.hidden = shouldHide
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

            // Determine if we are rotating or zooming
            if let stateValue = message["rotateState"] as! Float? {
                self.rotationSet = stateValue == 1.0
            }
            
            // Hide and show the appropriate things based on the state sent over
            if let stateValue = message["debugState"] as! Float? {
                self.hideLabels(stateValue != 1.0)
                print("now rotate is set to " + (stateValue != 1.0 ? "on" : "off"))
            }
            
            
            // update the appropriate x/y/z labels
            if let xValue = message["x"] {  // as! Float? {
                self.xLabel.text = "x: ".stringByAppendingString(String(xValue))
            }
            if let yValue = message["y"] { // as! Float? {
                self.yLabel.text = "y: ".stringByAppendingString(String(yValue))
            }
            if let zValue = message["z"] as! Float? {
                self.zLabel.text = "z: ".stringByAppendingString(String(zValue))
                
                // if we're in the scaling/zooming mode, lets scale
                if (!self.rotationSet) {
                    if let rate = message["rate"] as! NSTimeInterval? {
                        UIView.animateWithDuration(rate, delay: 0, options: .BeginFromCurrentState, animations: { () -> Void in
                            let scale = max(0.5, CGFloat(zValue + 1) * 3 + 0.5)
                            self.howardImageView.transform = CGAffineTransformMakeScale(scale, scale)
                            }, completion: nil)
                    }
                }
                
            }

            
            // rotation (zooming is above)
            if (self.rotationSet) {
                
                // Using X Y or Z parameters for the accelerometer based augmentation
                if let numeratorValue = message["y"] as! Float? {
                    if let denominatorValue = message["z"] as! Float? {
                        if let rate = message["rate"] as! NSTimeInterval? {
                            UIView.animateWithDuration(rate, delay: 0, options: .BeginFromCurrentState, animations: { () -> Void in
                                let rotation = atan2(Double(numeratorValue), Double(denominatorValue)) - M_PI
                                self.howardImageView.transform = CGAffineTransformMakeRotation(CGFloat(rotation))
                                }, completion: nil)
                        }
                    }
                }
            }
            
            // Show the Time delta
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
            self.isAppInstalledLabel.text = "installed ✅"
        } else {
            self.isAppInstalledLabel.text = "installed 🚨"
        }
    }
    
    func isConnectedLabelUpdate() {
        if (!NSThread.isMainThread()) {
            print("updating a label on not the main thread")
        }
        if(self.session.reachable) {
            self.isConnectedLabel.text = "reachable ✅"
        } else {
            self.isConnectedLabel.text = "reachable 🚨"
        }

    }
    
    func isPairedLabelUpdate() {
        if(self.session.paired) {
            self.isPairedLabel.text = "paired ✅"
        } else {
            self.isPairedLabel.text = "paired 🚨"
        }
    }
    
    
}

