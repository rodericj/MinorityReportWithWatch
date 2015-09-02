
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
    
    
    @IBOutlet var maxXLabel: WKInterfaceLabel!
    @IBOutlet var minXLabel: WKInterfaceLabel!

    @IBOutlet var maxYLabel: WKInterfaceLabel!
    @IBOutlet var minYLabel: WKInterfaceLabel!
    
    @IBOutlet var maxZLabel: WKInterfaceLabel!
    @IBOutlet var minZLabel: WKInterfaceLabel!
    
    @IBOutlet var statusLabel: WKInterfaceLabel!
    @IBOutlet var reachableLabel: WKInterfaceLabel!
    
    @IBOutlet var rateSlider: WKInterfaceSlider!
    @IBOutlet var rateLabel: WKInterfaceLabel!
    
    var sendDataSwitchState : Bool
    var dataAsContextState : Bool
    var runningRangeTest : Bool
    
    var maxX : Double
    var minX : Double
    
    var maxY : Double
    var minY : Double
    
    var maxZ : Double
    var minZ : Double
    
    let session : WCSession!
    
    let manager : CMMotionManager
    let motionQueue : NSOperationQueue
    override init() {
        
        runningRangeTest = false
        
        motionQueue = NSOperationQueue.mainQueue()

        manager = CMMotionManager()
        manager.accelerometerUpdateInterval = 0.5
        
        if(WCSession.isSupported()) {
            session =  WCSession.defaultSession()
        } else {
            session = nil
        }
        self.maxX = -100
        self.minX = 100
        self.maxY = -100
        self.minY = 100
        self.maxZ = -100
        self.minZ = 100
        
        self.sendDataSwitchState = false
        self.dataAsContextState = false
        
        // I need to access self after this
        super.init()
 
        if(WCSession.isSupported()) {
            session.delegate = self
            session.activateSession()

        }
    }
    
    func updateLabel() {
        if (self.session.reachable) {
            self.reachableLabel.setText("reachable");
        } else {
            self.reachableLabel.setText("-reachable")
        }
    }
    
    @IBAction func reactivateSession() {
        session.activateSession()
    }
    
    @IBAction func dataAsContextSwitchChanged(value: Bool) {
        self.dataAsContextState = value;
    }
    
    @IBAction func sendDataSwitchChanged(value: Bool) {
        self.sendDataSwitchState = value
    }
    
    @IBAction func sliderChange(value: Float) {
        manager.accelerometerUpdateInterval = Double(value)
        self.rateLabel.setText(String(value))
    }
    
    @IBAction func sendDummyData() {
        self.updateLabel()
        let message = ["x" : 1, "y" : 2, "z" : 3, "time" : NSDate().timeIntervalSince1970]
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
    
    @IBAction func startStopButtonTapped() {
        if (manager.accelerometerAvailable) {
            if (manager.accelerometerActive) {
                manager.stopAccelerometerUpdates()
            } else {
                manager.startAccelerometerUpdatesToQueue(motionQueue) { (data:CMAccelerometerData?, error:NSError?) -> Void in
                    if let accel = data {
                        let a = accel.acceleration
                        self.xLabel.setText("x: ".stringByAppendingString(String(a.x)))
                        self.yLabel.setText("y: ".stringByAppendingString(String(a.y)))
                        self.zLabel.setText("z: ".stringByAppendingString(String(a.z)))
                        
                        if (self.runningRangeTest) {
                            if (a.x > self.maxX) {
                                self.maxX = a.x
                                self.maxXLabel.setText("max X: ".stringByAppendingString(String(a.x)))
                            }
                            if (a.x < self.minX) {
                                self.minX = a.x
                                self.minXLabel.setText("min X: ".stringByAppendingString(String(a.x)))
                            }
                            
                            if (a.y > self.maxY) {
                                self.maxY = a.y
                                self.maxYLabel.setText("max Y: ".stringByAppendingString(String(a.y)))
                            }
                            if (a.y < self.minY) {
                                self.minY = a.y
                                self.minYLabel.setText("min Y: ".stringByAppendingString(String(a.y)))
                            }
                            
                            if (a.z > self.maxZ) {
                                self.maxZ = a.z
                                self.maxZLabel.setText("max Z: ".stringByAppendingString(String(a.z)))
                            }
                            if (a.z < self.minZ) {
                                self.minZ = a.z
                                self.minZLabel.setText("min Z: ".stringByAppendingString(String(a.z)))
                            }
                        }
                        // create a message dictionary to send
                        
                        if (self.sendDataSwitchState) {
                            let message = ["x" : a.x, "y" : a.y, "z" : a.z, "time" : NSDate().timeIntervalSince1970, "rate": self.manager.accelerometerUpdateInterval]
                            self.sendMessage(message)
                        }
                    }
                }
            }
        }
    }
    
    // I need to determine what the range of motion looks like for given motions, standing still should be between -x and +x

    @IBAction func startStopRangeTest() {
        if (self.runningRangeTest) {
            self.runningRangeTest = false
        } else {
            self.runningRangeTest = true
            
            // also clear out measured values
            self.maxX = -100
            self.maxXLabel.setText("max X: ")

            self.minX = 100
            self.minXLabel.setText("min X:")


            self.maxY = -100
            self.maxYLabel.setText("max Y: ")

            self.minY = 100
            self.minYLabel.setText("min Y: ")

            
            self.maxZ = -100
            self.maxZLabel.setText("max Z: ")

            self.minZ = 100
            self.minZLabel.setText("min Z: ")
        }
    }
    
    func sendMessage(message : Dictionary<String, Double>) {
        if let availableSession = self.session {
            
            if (self.dataAsContextState) {
                do {
                    try availableSession.updateApplicationContext(message);
                } catch {
                    self.statusLabel.setText("error sending app state");
                }
            } else {
                
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
    }
    
    func session(session: WCSession, didReceiveMessage message: [String : AnyObject], replyHandler: ([String : AnyObject]) -> Void) {
        print("we got something from the iPhone" + message.description)
        self.updateLabel()
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
