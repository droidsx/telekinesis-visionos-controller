## Hand Client

You can connect to the sync server over websocket here: `URI = "wss://droid-osmosis.onrender.com"`

Suggested schema -- feel free to clarify or adjust as makes sense. Let's use JSON for now, we can change if performance warrants it.

```javascript
{
    clientId: ... // uuid to differentiate between clients
    timestamp: datetimeUTC // used for delta for time lapse between frames
    leftHand: {
      isPinchGesture: bool
      handWrist: {
        x: float,
        y: float,
        z: float
      },
      ... // other joints
    },
    rightHand: {
      // same as left
    }
}
```
