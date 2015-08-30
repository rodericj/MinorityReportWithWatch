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
        self.isAppInstalledLabelUpdate()
        self.isConnectedLabelUpdate()
        self.isPairedLabelUpdate()
        
    }
    
    func sessionWatchStateDidChange(session: WCSession) {
        print("watch state changed %@", session.paired)

    }
    func session(session: WCSession, didReceiveMessage message: [String : AnyObject], replyHandler: ([String : AnyObject]) -> Void) {
        print(message)
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            print("We got something on the phone here")
            print(message)

            if let xValue = message["x"] as! Float? {
                self.xLabel.text = "x: ".stringByAppendingString(String(xValue))
                if (xValue > 1) {
                    self.emojiLabel.text = "UP"
                } else if (xValue < -1) {
                    self.emojiLabel.text = "DOWN"
                }
            }
            
            if let yValue = message["y"] as! Float? {
                self.yLabel.text = "y: ".stringByAppendingString(String(yValue))
            }
            if let zValue = message["z"] as! Float? {
                self.zLabel.text = "z: ".stringByAppendingString(String(zValue))
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

