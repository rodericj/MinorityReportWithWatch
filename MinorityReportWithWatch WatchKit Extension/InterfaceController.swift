
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

class InterfaceController: WKInterfaceController, WCSessionDelegate {

    @IBOutlet var xLabel: WKInterfaceLabel!
    @IBOutlet var yLabel: WKInterfaceLabel!
    @IBOutlet var zLabel: WKInterfaceLabel!
    
    @IBOutlet var statusLabel: WKInterfaceLabel!
    @IBOutlet var reachableLabel: WKInterfaceLabel!
    
    let session : WCSession!
    
    let manager : CMMotionManager
    let motionQueue : NSOperationQueue
    override init() {
        
        motionQueue = NSOperationQueue.mainQueue()

        manager = CMMotionManager()
        manager.accelerometerUpdateInterval = 0.3
        
        if(WCSession.isSupported()) {
            session =  WCSession.defaultSession()
        } else {
            session = nil
        }

        // I need to access self after this
        super.init()

        if(WCSession.isSupported()) {
            session.delegate = self
            session.activateSession()
        }
    }
    
    func updateLabel() {
        if (self.session.reachable) {
            self.reachableLabel.setText("reach");
        } else {
            self.reachableLabel.setText("-reach")
        }
    }
    
    @IBAction func sendDummyData() {
        self.updateLabel()
        
        let message = ["x" : 1, "y" : 2, "z" : 3]
        if let availableSession = self.session {
            availableSession.sendMessage(message, replyHandler: { (content:[String : AnyObject]) -> Void in
                print("Our counterpart sent something back. This is optional")
                }, errorHandler: {  (error ) -> Void in
                    print("We got an error from our paired device : " + error.domain)
                    var errorString = " "
                    errorString = errorString.stringByAppendingFormat("%@ %d", error.domain, error.code)
                    self.statusLabel.setText(errorString)
            })
        }
    }
    
    func sendMessage(message : Dictionary<String, Double>) {
        if let availableSession = self.session {
            availableSession.sendMessage(message, replyHandler: { (content:[String : AnyObject]) -> Void in
                print("Our counterpart sent something back. This is optional")
                }, errorHandler: {  (error ) -> Void in
                    
                    var errorString = " "
                    errorString = errorString.stringByAppendingFormat("%@ %d", error.domain, error.code)
                    self.statusLabel.setText(errorString)
                    print("We got an error from our paired device : " + error.domain + String(error.code))
            })
        }
    }
    
    func session(session: WCSession, didReceiveMessage message: [String : AnyObject], replyHandler: ([String : AnyObject]) -> Void) {
        print("we got something from the iPhone" + message.description)
        self.updateLabel()

    }
    
    @IBAction func startStopButtonTapped() {
        if (manager.accelerometerActive) {
            manager.stopAccelerometerUpdates()
        } else {
            manager.startAccelerometerUpdatesToQueue(motionQueue) { (data:CMAccelerometerData?, error:NSError?) -> Void in
                if let accel = data {
                    let a = accel.acceleration
                    self.xLabel.setText("x: ".stringByAppendingString(String(a.x)))
                    self.yLabel.setText("y: ".stringByAppendingString(String(a.y)))
                    self.zLabel.setText("z: ".stringByAppendingString(String(a.z)))
                    
                    print("we got some data to send %@ %@", a, self.session)
                    // create a message dictionary to send
                    let message = ["x" : a.x, "y" : a.y, "z" : a.z]
                    self.sendMessage(message)
                }
            }
        }
        if (!manager.gyroAvailable) {
            let message = ["rotation x" : -1.0, "rotation y" : -1.0, "rotation z" : -1.0]
            self.sendMessage(message)
            manager.showsDeviceMovementDisplay = true
        } else {
            if (manager.gyroActive) {
                manager.stopGyroUpdates()
            } else {
                manager.startGyroUpdatesToQueue(motionQueue) { (data:CMGyroData?, error:NSError?) -> Void in
                    if let gyro = data {
                        let rotationRate = gyro.rotationRate
                        let message = ["rotation x" : rotationRate.x, "rotation y" : rotationRate.y, "rotation z" : rotationRate.z]
                        self.sendMessage(message)
                    }
                }
                
            }
        }
    }
    
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        
        if(WCSession.isSupported()) {
            self.session.delegate = self
            self.session.activateSession()
            self.statusLabel.setText("we are all set")
            self.updateLabel()

        } else {
            self.statusLabel.setText("something didn't get set")
        }
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

}
