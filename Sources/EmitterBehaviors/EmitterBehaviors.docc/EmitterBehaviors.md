# ``EmitterBehaviors``

A friendly Swift API for `CAEmitterBehavior`, the private Core Animation class behind iMessage confetti.

## Overview

`CAEmitterBehavior` lets particles react to forces, fade and scale over their lifetime, and be lit in 3D, but it has no public header and is configured through stringly-typed key-value coding. EmitterBehaviors wraps each behavior kind in a Swift class you configure the way you configure a `CAEmitterCell`, attaches it to a `CAEmitterLayer` or `CAEmitterCell`, and keeps working (as a no-op) on an OS that no longer ships the class.

```swift
let attractor = AttractorBehavior()
attractor.stiffness = 5
attractor.radius = 300
attractor.falloff = -290       // negative repels

let sway = WaveBehavior()
sway.force = [100, 0, 0]
sway.frequency = 0.5

layer.emitterBehaviors = [sway, attractor, DragBehavior()]
```

> Important: This is built on private API. Read <doc:PrivateAPI> before shipping it.

## Topics

### Essentials

- <doc:GettingStarted>
- ``EmitterBehavior``

### Guides

- <doc:RecreatingIMessageConfetti>
- <doc:AnimatingBehaviors>
- <doc:PrivateAPI>

### Forces

- ``WaveBehavior``
- ``DragBehavior``
- ``AlignToMotionBehavior``
- ``AttractorBehavior``
- ``SimpleAttractorBehavior``

### Changing particles over time

- ``ValueOverLifeBehavior``
- ``ColorOverLifeBehavior``

### Lighting

- ``LightBehavior``

### Experimental

- ``ColorOverDistanceBehavior``
- ``ValueOverDistanceBehavior``

### Vocabulary

- ``EmitterBehavior/Kind``
- ``EmitterBehavior/Parameter``
- ``EmitterBehavior/AttractorType``
- ``EmitterBehavior/ValueProperty``
- ``EmitterBehavior/TimingFunction``

### Availability

- ``EmitterBehavior/isSupported``
- ``EmitterBehavior/isAvailable``
- ``EmitterBehavior/availableKinds``

### Animating

- ``KeyPathAddressableBehavior``
- ``EmitterBehavior/keyPath(for:)``

### Attaching behaviors

- ``EmitterBehaviorBuilder``
- ``EmitterBehavior/wrap(_:)``
- ``EmitterBehavior/underlyingObject``

### One-line shortcuts

- ``EmitterBehavior/wave(force:frequency:)``
- ``EmitterBehavior/drag(_:)``
- ``EmitterBehavior/alignToMotion(rotation:preservesDepth:)``
- ``EmitterBehavior/valueOverLife(_:values:locations:function:)``
- ``EmitterBehavior/colorOverLife(colors:locations:function:)``

### Plane particles

- ``EmitterParticleType``
