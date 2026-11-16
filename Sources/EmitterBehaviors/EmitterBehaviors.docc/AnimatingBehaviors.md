# Animating Behaviors

Change a behavior's parameters over time with Core Animation.

## Overview

Behaviors attached to a `CAEmitterLayer` are addressable by key path, so a parameter such as an attractor's stiffness can be animated like any layer property. Every behavior has a unique ``EmitterBehavior/name`` by default, and ``KeyPathAddressableBehavior/keyPath(for:)`` turns one of its Swift properties into the key path. This is how the iMessage confetti burst relaxes after it fires.

```swift
let attractor = AttractorBehavior()
attractor.stiffness = 5          // where it should END UP
layer.emitterBehaviors = [attractor]

let relax = CAKeyframeAnimation(keyPath: attractor.keyPath(for: \.stiffness))
relax.values = [80, 5, 5]        // where it STARTS
relax.keyTimes = [0, 0.4, 1]
relax.duration = 3
layer.add(relax, forKey: "relax")
```

The key path is checked by the compiler: `\.stiffness` exists on ``AttractorBehavior`` but not on ``WaveBehavior``. If you only have an ``EmitterBehavior`` and a runtime ``EmitterBehavior/Parameter``, use ``EmitterBehavior/keyPath(for:)`` instead.

### Set the end value, animate from the start

When an animation finishes and is removed, the property snaps back to its model value. So set the model value to where the property should **end up**, then animate **from** where it starts. The attractor above is set to `5` and animated from `80`.

### Naming is optional

You don't need to name a behavior to animate it, because it gets a unique name automatically. Name it with ``EmitterBehavior/named(_:)`` when you want a readable key path (`emitterBehaviors.attractor.stiffness`) or a stable one across rebuilds.

### Rules

- Only behaviors on a **layer** can be animated this way. Per-cell behaviors can't be reached through the layer.
- Names must not contain `.`, since the name is a key path component.
- Not every parameter is guaranteed to animate. `stiffness` and `drag` are known to; check others on the OS versions you support.

### Animating cell properties

Cell properties such as `yAcceleration` have no layer-level equivalent. Name the cell and animate `emitterCells.<name>.yAcceleration` on the layer instead.
