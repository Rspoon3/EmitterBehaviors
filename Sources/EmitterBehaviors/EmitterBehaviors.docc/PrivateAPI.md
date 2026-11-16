# Private API and Safety

What this package depends on, how it protects you, and what it can't.

## Overview

`CAEmitterBehavior` was part of the public QuartzCore headers until Apple removed it in the iOS 11 / Xcode 9 SDKs. It still ships inside the system and powers effects such as iMessage confetti, but it is undocumented and may change or disappear in any release. The `particleType` and orientation keys on `CAEmitterCell` are undocumented in the same way.

### What the package does

- **No private symbols are linked.** The class is found by name with `NSClassFromString` and configured through key-value coding.
- **Unsupported means no-op.** If the class or one behavior type is missing, ``EmitterBehavior/isSupported`` or ``EmitterBehavior/isAvailable`` is `false`, properties read as `nil`, and setting them or attaching the behavior does nothing.
- **Unknown keys are never set.** Setting an unrecognized key raises an Objective-C exception that Swift can't catch. The package only sets keys the runtime itself lists, so a future OS that renames a parameter degrades instead of crashing.
- **Drift is caught in tests.** The package's test suite compares its behavior types and parameter lists with the running OS, and checks that every parameter has a Swift property, and fails if they diverge. Run it on new OS betas.
- **Same-named members are safe.** `emitterBehaviors`, `particleType` and the `orientation*` properties share names with private Objective-C selectors on `CAEmitterLayer` and `CAEmitterCell`. They are plain Swift members, so they register no selector and leave Apple's implementations intact; a test checks the method implementations are unchanged.

### What it can't do

- **App Review.** Using undocumented API may get an app rejected. The original authors recommend against shipping it. Consider confining it to `#if DEBUG` or gating it behind a remote flag.
- **Guarantee appearance.** A behavior can exist and accept its values yet render differently, or not at all, on a future OS.
- **Verify the experimental behaviors.** ``ColorOverDistanceBehavior`` and ``ValueOverDistanceBehavior`` were found by introspection. Their parameters are real; their exact semantics are unconfirmed.

### Where the schema comes from

The behavior types and parameters come from asking the runtime (`+behaviorTypes`, `-inputKeys`, `-attributesForKeyPath:`), cross-checked with [Bryce Bostwick's write-ups](https://bryce.co/caemitterbehavior/), the pre-removal public header and runtime header dumps.
