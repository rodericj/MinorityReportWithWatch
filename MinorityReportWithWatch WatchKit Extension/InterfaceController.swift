
//
//  InterfaceController.swift
//  MinorityReportWithWatch WatchKit Extension
//
//  Created by Roderic Campbell on 8/20/15.
//  Copyright © 2015 Roderic Campbell. All rights reserved.
//

import WatchKit
import Foundation

import CoreMotion
import WatchConnectivity

class InterfaceController: WKInterfaceController {

    @IBOutlet var xLabel: WKInterfaceLabel!
    @IBOutlet var yLabel: WKInterfaceLabel!
    @IBOutlet var zLabel: WKInterfaceLabel!
    
    @IBOutlet var statusLabel: WKInterfaceLabel!
    
    
    let session : WCSession?
    
    let manager : CMMotionManager
    let motionQueue : NSOperationQueue
    override init() {
        
        motionQueue = NSOperationQueue.mainQueue()

        manager = CMMotionManager()
        manager.accelerometerUpdateInterval = 0.1
        
        if(WCSession.isSupported()) {
            session =  WCSession.defaultSession()
        } else {
            session = nil
        }
        
    }
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        // Configure interface objects here.
        
        
        var status = ""
        if(manager.magnetometerActive){
            status = status.stringByAppendingString("(m)")
        } else {
            status = status.stringByAppendingString("(-m)")
        }
        if (manager.gyroAvailable){
            status = status.stringByAppendingString("(g)")
        } else {
            status = status.stringByAppendingString("(-g)")
        }
        if (manager.accelerometerAvailable){
            status = status.stringByAppendingString("(a)")
        } else {
            status = status.stringByAppendingString("(-a)")
        }
        if (manager.deviceMotionAvailable) {
            status = status.stringByAppendingString("(d)")
        } else {
            status = status.stringByAppendingString("(-d)")
        }
        
        statusLabel.setText(status)
        manager.startAccelerometerUpdatesToQueue(motionQueue) { (data:CMAccelerometerData?, error:NSError?) -> Void in
            if let accel = data {
                let a = accel.acceleration
                self.xLabel.setText("x: ".stringByAppendingString(String(a.x)))
                self.yLabel.setText("y: ".stringByAppendingString(String(a.y)))
                self.zLabel.setText("z: ".stringByAppendingString(String(a.z)))
                
                if(WCSession.isSupported()) {
                    
                    // create a message dictionary to send
                    let message = ["x" : a.x, "y" : a.y, "z" : a.z]
                    if let availableSession = self.session {
                        availableSession.sendMessage(message, replyHandler: { (content:[String : AnyObject]) -> Void in
                            print("Our counterpart sent something back. This is optional")
                            }, errorHandler: {  (error ) -> Void in
                                print("We got an error from our paired device : " + error.domain)
                        })
                    }
                }
            }
        }

        
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

}
