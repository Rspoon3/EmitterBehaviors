# Getting Started

Create your first behaviors and attach them to an emitter layer.

## Overview

Each kind of behavior is its own class. Create one, set the properties you care about, and assign it to a `CAEmitterLayer`'s `emitterBehaviors`, the same way you assign cells to `emitterCells`. Angles are radians; distances are points.

```swift
import EmitterBehaviors

let layer = CAEmitterLayer()
layer.emitterShape = .sphere
layer.emitterPosition = CGPoint(x: 200, y: 400)

let sway = WaveBehavior()
sway.force = [100, 0, 0]
sway.frequency = 0.5

let attractor = AttractorBehavior()
attractor.stiffness = 10
attractor.radius = 300
attractor.falloff = -290

let drag = DragBehavior()
drag.drag = 1.2

layer.emitterBehaviors = [sway, attractor, drag]
```

Every property is optional. `nil` means "not set, use the system default", and assigning `nil` clears a value you set earlier.

### Editing after you attach

A behavior wraps a *live* `CAEmitterBehavior`, so changing it after attaching takes effect, and the layer's array reads back the same behaviors:

```swift
attractor.stiffness = 40                       // the layer sees this
layer.emitterBehaviors.append(WaveBehavior())  // get, modify, set
layer.emitterBehaviors = []                    // remove everything
```

Reading `layer.emitterBehaviors` returns fresh wrapper objects each time. They share the same ``EmitterBehavior/underlyingObject``, so compare that if you need identity.

### One-line shortcuts

For the simple kinds there are shortcuts, which also work as implicit members:

```swift
layer.emitterBehaviors = [.wave(force: [100, 0, 0], frequency: 0.5), .drag(1.2)]
```

For anything with more than a couple of parameters, create the class and set its properties.

### A result builder

If you prefer a declarative list:

```swift
layer.setBehaviors {
  WaveBehavior()
  if usesDrag { EmitterBehavior.drag(1.2) }
}
```

### Fade particles out over their life

```swift
let fade = ValueOverLifeBehavior()
fade.property = .alpha
fade.values = [1, 1, 0]
fade.locations = [0, 0.7, 1]

cell.emitterBehaviors = [fade]
```

Behaviors on a cell affect only that cell's particles; behaviors on the layer affect all of them.

### Tumbling, 3D pieces

Set a cell's `particleType` to ``EmitterParticleType/plane`` and give it an orientation to make flat pieces tumble the way iMessage confetti does. 3D ``AlignToMotionBehavior/preservesDepth`` and lighting also require plane particles.

```swift
cell.particleType = .plane
cell.orientationLongitude = .pi / 2
cell.orientationLatitude = .pi / 2
cell.orientationRange = .pi
```

### Check availability

```swift
guard EmitterBehavior.isSupported else { /* fall back to plain emitter cells */ return }
```

On an OS without the class, creating a behavior and setting its properties is a safe no-op, so this check is only needed if you want a different fallback.
