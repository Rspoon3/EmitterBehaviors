# Recreating iMessage Confetti

Build the confetti burst from Messages with a handful of behaviors, plane particles and a few animations.

## Overview

The confetti effect is a good tour of the package, because it uses nearly every piece of it:

- **Plane particles** (``EmitterParticleType/plane``) so the pieces tumble in 3D instead of facing the camera.
- **Two wave behaviors** (``WaveBehavior``) that add a slow sideways sway and a fast vertical flutter.
- **A repelling attractor** (``AttractorBehavior`` with a negative ``AttractorBehavior/falloff``) that blasts the pieces outward from the center.
- **Drag** (``DragBehavior``) that slows the burst down.
- **Animated parameters** (see <doc:AnimatingBehaviors>) so the blast is violent for a moment and then relaxes, and gravity takes over.
- **A second, dimmer layer** behind the first to suggest depth.

The approach and the starting numbers come from [Bryce Bostwick's write-up](https://bryce.co/recreating-imessage-confetti/). They're a close approximation, not a pixel-for-pixel copy: iMessage also blurs its background pieces, which this example doesn't.

> Important: This uses private API. Read <doc:PrivateAPI> before shipping it.

### How it works

1. **Draw the pieces.** `Confetti.image(color:shape:)` draws a 20×13 rectangle or a 10×10 circle with Core Graphics, so there are no image assets. Nine colors and two shapes make 18 cells.
2. **Emit from a small sphere at the center.** The cells have no launch velocity of their own (`velocityRange = 0`). The attractor does the launching.
3. **Make them tumble.** Each cell is a `plane` particle with a random orientation (`orientationRange = .pi`).
4. **Blast, then relax.** The attractor's `stiffness` is animated from 80 down to 5 over three seconds, easing out.
5. **Emit once.** The layer's `birthRate` animates from 1 to 0 over one second, so the effect fires a single burst.
6. **Slow down, then fall.** Drag ramps from 0 to 2 in a third of a second. Gravity (`yAcceleration`) is animated per cell, since `CAEmitterLayer` has no layer-wide gravity.

### Set the end value, animate from the start

Every animation below follows one pattern: set the property's model value to where it should **end up**, then animate **from** where it starts. When the animation is removed, the property settles on the end value instead of snapping back. That's why the attractor's `stiffness` is set to `5` and then animated from `80`, and why the layer's `birthRate` is set to `0` right before it's animated from `1`.

## The code

```swift
import CoreGraphics
import EmitterBehaviors
import QuartzCore

enum Confetti {
  enum Shape: CaseIterable { case rectangle, circle }

  static let colors: [CGColor] = [
    CGColor(red: 0.95, green: 0.26, blue: 0.33, alpha: 1),
    CGColor(red: 0.98, green: 0.55, blue: 0.20, alpha: 1),
    CGColor(red: 0.99, green: 0.80, blue: 0.20, alpha: 1),
    CGColor(red: 0.45, green: 0.80, blue: 0.35, alpha: 1),
    CGColor(red: 0.20, green: 0.75, blue: 0.70, alpha: 1),
    CGColor(red: 0.25, green: 0.55, blue: 0.95, alpha: 1),
    CGColor(red: 0.45, green: 0.35, blue: 0.90, alpha: 1),
    CGColor(red: 0.85, green: 0.35, blue: 0.80, alpha: 1),
    CGColor(red: 0.95, green: 0.45, blue: 0.60, alpha: 1),
  ]

  /// Draws one confetti piece. Pieces are tiny, so they're drawn at runtime instead of shipped as assets.
  static func image(color: CGColor, shape: Shape) -> CGImage? {
    let size = shape == .rectangle ? CGSize(width: 20, height: 13) : CGSize(width: 10, height: 10)
    guard
      let context = CGContext(
        data: nil, width: Int(size.width), height: Int(size.height), bitsPerComponent: 8,
        bytesPerRow: 0, space: CGColorSpaceCreateDeviceRGB(),
        bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)
    else { return nil }
    context.setFillColor(color)
    let rect = CGRect(origin: .zero, size: size)
    switch shape {
    case .rectangle: context.fill(rect)
    case .circle: context.fillEllipse(in: rect)
    }
    return context.makeImage()
  }

  /// One burst of confetti. Call twice: a foreground layer and a smaller, dimmer background layer
  /// that fakes depth.
  static func makeLayer(bounds: CGRect, isBackground: Bool) -> CAEmitterLayer {
    let center = CGPoint(x: bounds.midX, y: bounds.midY)

    let layer = CAEmitterLayer()
    layer.frame = bounds
    layer.emitterShape = .sphere
    layer.emitterPosition = center
    layer.emitterSize = CGSize(width: 100, height: 100)
    layer.beginTime = CACurrentMediaTime()
    if isBackground {
      layer.opacity = 0.5
      layer.speed = 0.95
    }

    // One cell per colour × shape. Cells need names so gravity can be animated per cell.
    layer.emitterCells = colors.flatMap { color in
      Shape.allCases.compactMap { shape -> CAEmitterCell? in
        guard let image = image(color: color, shape: shape) else { return nil }
        let cell = CAEmitterCell()
        cell.name = UUID().uuidString
        cell.contents = image
        cell.beginTime = 0.1
        cell.birthRate = 100
        cell.lifetime = 10
        cell.emissionRange = .pi
        cell.spin = 4
        cell.spinRange = 8
        cell.velocityRange = 0  // the attractor, not the cell, launches the pieces
        cell.yAcceleration = 0  // gravity is animated below
        cell.scale = isBackground ? 0.5 : 1

        // Flat 3D planes that tumble, instead of camera-facing sprites.
        cell.particleType = .plane
        cell.orientationRange = .pi
        cell.orientationLongitude = .pi / 2
        cell.orientationLatitude = .pi / 2
        return cell
      }
    }

    // Two waves add flutter: a slow sideways sway and a fast vertical shimmer.
    let sway = WaveBehavior()
    sway.force = [100, 0, 0]
    sway.frequency = 0.5

    let shimmer = WaveBehavior()
    shimmer.force = [0, 500, 0]
    shimmer.frequency = 3

    // A repelling attractor makes the burst.
    let attractor = AttractorBehavior()
    attractor.stiffness = 5
    attractor.radius = 300
    attractor.position = CGPoint(x: center.x, y: center.y + 20)
    attractor.zPosition = -70
    attractor.falloff = -290  // negative falloff repels

    // Drag slows the burst down.
    let drag = DragBehavior()
    drag.drag = 2

    layer.emitterBehaviors = [sway, shimmer, attractor, drag]

    // Pattern for everything below: set the model value to where it should END UP, then animate
    // from where it STARTS. When the animation is removed, the property settles on the end value.

    // 1. Blast outward hard, then relax.
    let blast = CAKeyframeAnimation(keyPath: attractor.keyPath(for: \.stiffness))
    blast.values = [80, 5, 5]
    blast.keyTimes = [0, 0.4, 1]
    blast.duration = 3
    blast.timingFunction = CAMediaTimingFunction(name: .easeOut)
    layer.add(blast, forKey: "blast")

    // 2. Emit for one second only.
    layer.birthRate = 0
    let burst = CABasicAnimation(keyPath: "birthRate")
    burst.fromValue = 1
    burst.toValue = 0
    burst.duration = 1
    layer.add(burst, forKey: "burst")

    // 3. Ramp drag up quickly so pieces slow after the initial launch.
    let slow = CABasicAnimation(keyPath: drag.keyPath(for: \.drag))
    slow.fromValue = 0
    slow.toValue = 2
    slow.duration = 0.35
    layer.add(slow, forKey: "slow")

    // 4. Let gravity take over. CAEmitterLayer has no layer-wide gravity, so animate each cell.
    for name in layer.emitterCells?.compactMap(\.name) ?? [] {
      let gravity = CAKeyframeAnimation(keyPath: "emitterCells.\(name).yAcceleration")
      gravity.values = [0, 0, 100, 2000, 4000]
      gravity.keyTimes = [0, 0.05, 0.1, 0.5, 1]
      gravity.duration = 6
      gravity.fillMode = .forwards
      gravity.isRemovedOnCompletion = false
      layer.add(gravity, forKey: "gravity-\(name)")
    }

    return layer
  }

  /// The two layers to add to your view, background first.
  static func makeLayers(bounds: CGRect) -> [CAEmitterLayer] {
    [makeLayer(bounds: bounds, isBackground: true), makeLayer(bounds: bounds, isBackground: false)]
  }
}
```

## Using it

Add the layers to a view when it appears, and remove them once the particles have died. `Confetti.makeLayers` returns plain `CAEmitterLayer`s, so this works the same in UIKit, or in SwiftUI through a `UIViewRepresentable`.

```swift
override func viewDidAppear(_ animated: Bool) {
  super.viewDidAppear(animated)

  let layers = Confetti.makeLayers(bounds: view.bounds)
  layers.forEach { view.layer.addSublayer($0) }

  // Particles live for 10 seconds.
  DispatchQueue.main.asyncAfter(deadline: .now() + 11) {
    layers.forEach { $0.removeFromSuperlayer() }
  }
}
```

Fire it again by creating fresh layers. Each layer's `beginTime` is set when it's created, so reusing an old layer won't replay the burst.

On macOS, AppKit layers are bottom-up, so set `isGeometryFlipped = true` on the host layer or gravity will pull the pieces upward.

## Tuning

- **Bigger or smaller burst:** change the attractor's starting `stiffness` (80) and its `radius`.
- **Floatier or heavier:** change the drag target (2) and the gravity values. The pieces fall off a phone screen within about three seconds as written, so lower the gravity values for a slower fall.
- **More pieces:** raise `cell.birthRate`.
- **More flutter:** raise the wave `force` or `frequency`.
- **Different look:** replace `colors`, or draw other shapes in `Confetti.image`.

This code was compiled against the package and run in the iOS Simulator, where the burst rendered as expected: tumbling plane pieces spread across the screen. The numbers come from the original article, so tune them to taste on a device.
