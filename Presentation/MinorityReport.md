footer: @roderic 
slidenumbers: true

# [fit] Minority Report with a Watch 

---

# [fit] Minority Report with a Watch 

### or how close can we get?

---
# Agenda

- The Movie
- The Demo
- The Watch
- The Motion 
- The Networking 
- The Next Steps

^ This is what we are going to talk about





---
# The Movie
![left 100%](/Users/everest/dev/MinorityReportWithWatch/Presentation/precog.gif) 

- Precognition

^ The movie had lots of great things




---
# The Movie
![left 40%](/Users/everest/dev/MinorityReportWithWatch/Presentation/tomInACar.jpg) 

- Precognition
- Cool autonomous cars




---
# The Movie
![left 30%](/Users/everest/dev/MinorityReportWithWatch/Presentation/soundgun.jpg) 

- Precognition
- Cool autonomous cars
- Non-lethal weapons


---
# The Movie

- Precognition
- Cool autonomous cars
- Non-lethal weapons
- The multitouch, multidiminsional UI

![left fit autoplay mute loop](ui.mp4)

---

# Agenda

- The Movie ✔︎
- The Demo
- The Watch
- The Motion 
- The Networking 
- The Next Steps

^ We are not here to talk about movies

---
# The Watch :watch:

- WatchOS was a good start

^ Good start but left us wanting more. Basically just sending touch events to the phone



---
# The Watch :watch:

- WatchOS was a good start
- WatchOS 2 opens up a few new things

^ along comes watchOS 2. Now we can actually gather data, and then send it over

---
# The Watch :watch:

 - Access to the Accelerometer
 - WatchConnectivity

^ again, gather data and send it over

---
# Agenda

- The Movie ✔︎
- The Demo ✔︎
- The Watch ✔︎
- The Motion 
- The Networking 
- The Next Steps

---
# The Motion 


> *The Apple Watch accelerometer measures total body movement, counts your steps, and calculates your calories burned throughout the day*

-- Apple

---
# The Motion 

![inline 40%](/Users/everest/dev/MinorityReportWithWatch/Presentation/framedx1y0z0.png) ![inline 40%](/Users/everest/dev/MinorityReportWithWatch/Presentation/framedx0y-1z0.png) ![inline 40%](/Users/everest/dev/MinorityReportWithWatch/Presentation/framedx-1y0z0.png) 

^normal upright x0y-1z0
right side down x1y0z0
left side down x-1y0z0

---
# The Motion 

``` swift
import CoreMotion
let manager = CMMotionManager()
manager.accelerometerUpdateInterval = 0.5
...
if (manager.accelerometerAvailable) {

    manager.startAccelerometerUpdatesToQueue(motionQueue) { 
            (data:CMAccelerometerData?, error:NSError?) -> Void in
            if let accel = data {
                // process the data on the watch
            }
}

```

^ This is all new stuff in WatchOS2, we could not actually do this before. Also note that the gyro and magnetometer are not available


---
# Agenda

- The Movie ✔︎
- The Demo ✔︎
- The Watch ✔︎
- The Motion ✔︎
- The Networking 
- The Next Steps



---
# The Networking 

WatchConnectivity

---
# The Networking 

``` swift
import WatchConnectivity

if(WCSession.isSupported()) {
    WCSession.defaultSession().delegate = self
    WCSession.defaultSession().activateSession()
}

```

^ `It is this simple because the phone and the watch are paired somewhere below the application layer. No handshake, no auth, just open and go



---
# The Networking 

``` swift
public class WCSession : NSObject {
...
    public var paired: Bool { get }
    public var reachable: Bool { get }

    public func sendMessage(message: [String : AnyObject], ...
    public func updateApplicationContext(applicationContext: [String : AnyObject]) throws
}

```



---
# The Networking 

``` swift

public protocol WCSessionDelegate : NSObjectProtocol {
    // queueing mechanism
    optional public func session(session: WCSession, 
                                 didReceiveMessage message: [String : AnyObject])

    // just an update, drop everything else
    optional public func session(session: WCSession, 
                                didReceiveApplicationContext applicationContext: [String : AnyObject])
}
``` 


---
# The Networking 

``` swift

let message = ["x" : a.x, 
               "y" : a.y,
               "z" : a.z, 
               "time" : NSDate().timeIntervalSince1970, 
               "rate": self.manager.accelerometerUpdateInterval]

session.sendMessage(message, 
                    replyHandler: { (content:[String : AnyObject]) -> Void in
    // Our counterpart can send an optional response
}, 
                    errorHandler: {  (error ) -> Void in
    // do something with the error
})

```

^ build message with the motion data. Option to do something with a response. Errors on timeout, not connected, etc




---
# The Networking 

``` swift

func session(session: WCSession, 
            didReceiveMessage message: [String : AnyObject], 
            replyHandler: ([String : AnyObject]) -> Void) {

    if let xValue = message["x"] {
        self.xLabel.text = "x: ".stringByAppendingString(String(xValue))
        // you know, or something more interesting than setting a label
    }
    ...
}

```

^ Notice the replyHandler. This allows us to send that optional response



---
# The Networking 

*Demo*



---
# Agenda

- The Movie ✔︎
- The Demo ✔︎
- The Watch ✔︎
- The Motion ✔︎
- The Networking  ✔︎
- The Next Steps


---
# The Next steps

 - ⌚️ Access to the Accelerometer would be lovely
 - ⌚️ Handling the watch turning itself off when twisting
 - ⌚️ Putting together an actual UI with element selection/switching
 - 🚀 DeckRocket  (https://github.com/jpsim/DeckRocket)

---

# Special Credits


 - Philippe Dewost's video Analysis of Minority Report UI 
 --https://vimeo.com/49216050

 - Scenery 
 -- http://www.getscenery.com

