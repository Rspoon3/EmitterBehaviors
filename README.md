# EmitterBehaviors

A friendly Swift API for `CAEmitterBehavior`, the private Core Animation class behind iMessage
confetti and other system particle effects. Behaviors are configured like a `CAEmitterCell`: create
one, set its properties, hand it to a layer.

> **Private API.** `CAEmitterBehavior` was removed from the public SDK in iOS 11 / Xcode 9 but still
> ships in the runtime. This package finds it by name at runtime (`NSClassFromString`, KVC) and never
> links a private symbol. On an OS without it, `EmitterBehavior.isSupported` is `false` and every
> property is a harmless no-op. Apple could still reject an app that uses it; consider gating it
> behind `#if DEBUG` or a remote flag.

```swift
import EmitterBehaviors

let sway = WaveBehavior()
sway.force = [100, 0, 0]
sway.frequency = 0.5

let attractor = AttractorBehavior()
attractor.stiffness = 5
attractor.radius = 300
attractor.falloff = -290          // negative repels

let drag = DragBehavior()
drag.drag = 2

layer.emitterBehaviors = [sway, attractor, drag]          // like `emitterCells`

// Behaviors are live: this takes effect even though it's already attached.
attractor.stiffness = 40

// Animate a parameter by a compiler-checked key path. No strings.
let relax = CABasicAnimation(keyPath: attractor.keyPath(for: \.stiffness))
relax.fromValue = 80; relax.toValue = 5; relax.duration = 3
layer.add(relax, forKey: "relax")

// Tumbling confetti pieces
cell.particleType = .plane
cell.orientationLongitude = .pi / 2
cell.orientationRange = .pi
```

Every property is optional: `nil` means "not set, use the system default", and assigning `nil`
clears a value. The simple kinds also have one-line shortcuts that work as implicit members:
`layer.emitterBehaviors = [.wave(force: [100, 0, 0], frequency: 0.5), .drag(1.2)]`. A
`@EmitterBehaviorBuilder` closure is available via `layer.setBehaviors { ... }`.

## Supported platforms

| Platform | Minimum | Status |
|---|---|---|
| iOS | 15 | Builds, and the confetti example was run in the iOS Simulator (iPhone 17 Pro). |
| macOS | 12 | Builds and the full test suite runs here (verified on macOS 27.2). The confetti example was also run as a Mac app. |
| tvOS | 15 | Builds (simulator SDK). Not run. |
| visionOS | 1 | Builds (simulator SDK). Not run. |
| watchOS | – | Not supported: Apple marks `CAEmitterLayer` and `CAEmitterCell` `API_UNAVAILABLE(watchos)`, so the package does not compile there. |

Requires Swift 6.0+ (swift-tools-version 6.0).

"Minimum" is the package's deployment target, not a guarantee that Apple ships `CAEmitterBehavior`
on every OS in that range. The class is private, so availability is checked at runtime:
`EmitterBehavior.isSupported` is `false` and behaviors silently do nothing where it's missing.
The test suite has only been run against macOS 27.2 so far. Run it on your oldest and newest target
OS versions, since the behavior types and parameters could differ between releases.

## Example: iMessage confetti

A full recreation of the Messages confetti burst, using plane particles, two waves, a repelling
attractor, drag, and animated parameters, is in the DocC article **Recreating iMessage Confetti**
(`Sources/EmitterBehaviors/EmitterBehaviors.docc/RecreatingIMessageConfetti.md`). In Xcode, build the
documentation and open it from the package's documentation page. The code was compiled against this
package and run in the iOS Simulator, where the burst rendered correctly. The numbers come from the
original article, so tune them on a device (the pieces fall off a phone screen in about three seconds
as written).

## Behaviors

| Class | Does |
|---|---|
| `WaveBehavior` | Time-modulated force, for flutter |
| `DragBehavior` | Force of `velocity * -drag` |
| `AlignToMotionBehavior` | Rotates the image to follow velocity |
| `ValueOverLifeBehavior` | Interpolates a particle property over its life |
| `ColorOverLifeBehavior` | Gradient over life |
| `LightBehavior` | 3D lighting; point or spot |
| `AttractorBehavior` | Radial / axial / planar force field; negative `falloff` repels |
| `SimpleAttractorBehavior` | Cheaper radial-only attractor |
| `ColorOverDistanceBehavior`, `ValueOverDistanceBehavior` | **Experimental.** Parameters from runtime introspection; semantics unverified |

All inherit from `EmitterBehavior`. Angles are radians; distances are points.

## Documentation

A DocC catalog lives in `Sources/EmitterBehaviors/EmitterBehaviors.docc` (Getting Started, Recreating
iMessage Confetti, Animating Behaviors, Private API and Safety). In Xcode choose **Product ▸ Build
Documentation**.

## How the schema was derived

The type list and every parameter come from introspecting the running OS (`+behaviorTypes`,
`-inputKeys`, `-attributesForKeyPath:`), cross-checked with the sources below. The test suite fails
if the OS's type or parameter lists ever diverge from the package's, or if any runtime parameter
lacks a Swift property, so drift is loud, not silent. Keys are only ever set if the runtime lists
them, since an unknown KVC key raises an uncatchable `NSException`.

## Naming safety

`emitterBehaviors` (on `CAEmitterLayer` and `CAEmitterCell`) and `particleType` / `orientation*` (on
`CAEmitterCell`) share names with private selectors. They are plain Swift members (no `@objc`), so
they register no selector and leave Apple's implementations intact. Tests assert the ObjC method
implementations are unchanged and that Apple's own getters see what the Swift setters wrote. No
exported type, member or module name matches anything in the iOS/macOS SDKs.

## Sources

- Bryce Bostwick, [CAEmitterBehavior](https://bryce.co/caemitterbehavior/) and [Recreating iMessage Confetti](https://bryce.co/recreating-imessage-confetti/)
- [macOS 10.9 SDK `CAEmitterBehavior.h`](https://github.com/phracker/MacOSX-SDKs/blob/master/MacOSX10.9.sdk/System/Library/Frameworks/QuartzCore.framework/Versions/A/Headers/CAEmitterBehavior.h) (when it was public)
- [iOS runtime headers](https://github.com/nst/iOS-Runtime-Headers/blob/master/Frameworks/QuartzCore.framework/CAEmitterBehavior.h)
- [QuartzCore iOS 10.3 → 11.0 API diff](http://codeworkshop.net/objc-diff/sdkdiffs/ios/11.0/QuartzCore.html) (removal from the SDK)

## License

MIT. See [LICENSE](LICENSE).
