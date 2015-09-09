footer: @roderic 
slidenumbers: true

# [fit] Minority Report with a Watch 
![inline fit autoplay mute loop](trailer.mp4)

^ introduction. co-founder thumbworks. Focusing on iOS development

^ eye contact
^ hand position
^ do not be apologetic about delays. "Here are the issues identified, here is how we can resolve it etc"
^ Stay positive. This is a glimpse of what we can do 

---


### or how close can we get?

---
# Agenda

- The Movie
- The Demo
- The Watch
- The Motion 
- The Network 
- The Next Steps

^ This is what we are going to talk about


---
# The Movie
![left 100%](/Users/everest/dev/MinorityReportWithWatch/Presentation/precog.gif) 

- Precognition


^ The movie had lots of great things
90% on RT
2002




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

^ sick sticks, sound guns

---
# The Movie

- Precognition
- Cool autonomous cars
- Non-lethal weapons
- The multitouch, multidiminsional UI

![left fit autoplay mute loop](ui.mp4)

^ Aaron says that I need to be more concise with the explanation of the movie

---

# Agenda

- The Movie ✔︎
- The Demo
- The Watch
- The Motion 
- The Network 
- The Next Steps

^ We are not here to talk about movies

---
# The Watch :watch:

- WatchOS was a good start

^ Good start but left us wanting more. Basically just sending touch events to the phone

^ along comes watchOS 2. Now we can actually gather data, and then send it over


---
# The Watch :watch:

- WatchOS was a good start
- WatchOS 2 opens up a few new things

^ along comes watchOS 2. Now we can actually gather data, and then send it over

---
# The Watch :watch:

- WatchOS was a good start
- WatchOS 2 opens up a few new things
- WatchOS 2 developing for the watch should be very familiar

^ along comes watchOS 2. Now we can actually gather data, and then send it over

---

![fill](/Users/everest/dev/MinorityReportWithWatch/Presentation/storyboard.jpg) 

^ for watch development you must implement your UI in storyboards. interesting

---

![100%](/Users/everest/dev/MinorityReportWithWatch/Presentation/watchcontrolpanel.gif) 


^ a control panel on the watch

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
- The Network 
- The Next Steps

---
# The Motion (CoreMotion)

![inline 40%](/Users/everest/dev/MinorityReportWithWatch/Presentation/framedx1y0z0.png) ![inline 40%](/Users/everest/dev/MinorityReportWithWatch/Presentation/framedx0y-1z0.png) ![inline 40%](/Users/everest/dev/MinorityReportWithWatch/Presentation/framedx-1y0z0.png) 

^normal upright x0y-1z0
right side down x1y0z0
left side down x-1y0z0

---
# The Motion (CoreMotion)

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

^ Digging into the code


---
# Agenda

- The Movie ✔︎
- The Demo ✔︎
- The Watch ✔︎
- The Motion ✔︎
- The Network 
- The Next Steps



---
# The Network (WatchConnectivity)

``` swift
import WatchConnectivity

if(WCSession.isSupported()) {
    WCSession.defaultSession().delegate = self
    WCSession.defaultSession().activateSession()
}

```

^ -Talked about this in my blog

^ -Simple, no handshake



---
# The Network (WatchConnectivity)

``` swift
public class WCSession : NSObject {
...
    public var paired: Bool { get }
    public var reachable: Bool { get }

    public func sendMessage(message: [String : AnyObject], 
                            replyHandler: (([String : AnyObject]) -> Void)?, 
                            errorHandler: ((NSError) -> Void)?)

    public func updateApplicationContext(applicationContext: [String : AnyObject]) throws
}

```



---
# The Network (WatchConnectivity)

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
# The Network (WatchConnectivity)

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

^ - build message with the data. 
  - Option to do something with a response. 
  - Errors on timeout, not connected, etc




---
# The Network (WatchConnectivity)

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
# Agenda

- The Movie ✔︎
- The Demo ✔︎
- The Watch ✔︎
- The Motion ✔︎
- The Network ✔︎
- The Next Steps


---
# The Next steps

 - 📲 Testing shows .2s lag time to send and update the UI 
 - ⌚️ Access to the gyroscope would be lovely
 - ⌚️ Handling the watch reachability when the screen turns off
 - ⌚️ Putting together an actual UI with element selection/switching
 - ⌚️ 📱 Putting the watch together with the phone gyro to make entirely new gesture language
 - 🚀 DeckRocket  (https://github.com/jpsim/DeckRocket)

^ - I can send faster than .2s

---

# Special Credits


 - Philippe Dewost's video Analysis of Minority Report UI 
 --https://vimeo.com/49216050

 - Scenery 
 -- http://www.getscenery.com


# Code Available
https://github.com/rodericj/MinorityReportWithWatch


^ Can I get crown position

