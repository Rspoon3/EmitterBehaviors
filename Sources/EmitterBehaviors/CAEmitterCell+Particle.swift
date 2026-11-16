import Foundation
import QuartzCore

/// How a cell's particles are rendered. Backed by the undocumented `CAEmitterCell` key `particleType`.
public enum EmitterParticleType: String, Sendable {
  /// The default: a flat, camera-facing sprite.
  case sprite
  /// A flat plane in 3D that can be tilted with the cell's orientation. This is what makes
  /// iMessage confetti tumble. Required for 3D ``EmitterBehavior/alignToMotion(rotation:preservesDepth:)``
  /// and lighting.
  case plane
}

// `CAEmitterCell` already responds to the private selectors `particleType`, `orientationLatitude`,
// `orientationLongitude` and `orientationRange`. Reusing those names is safe because these members
// are plain Swift (never `@objc`), so they register no selector and cannot replace Apple's
// implementations: Swift call sites bind to these, while KVC (which the getters/setters below use)
// keeps reaching the private ObjC methods. `swiftMembersDoNotTouchPrivateSelectors` guards this.
extension CAEmitterCell {
  /// Sprite (default) or plane particles. Uses the undocumented KVC key `particleType`.
  public var particleType: EmitterParticleType {
    get { (value(forKey: "particleType") as? String).flatMap(EmitterParticleType.init) ?? .sprite }
    set { setValue(newValue.rawValue, forKey: "particleType") }
  }

  /// Latitude (radians) of a `plane` particle's initial orientation.
  public var orientationLatitude: CGFloat {
    get { cgFloat(forKey: "orientationLatitude") }
    set { setValue(Double(newValue), forKey: "orientationLatitude") }
  }

  /// Longitude (radians) of a `plane` particle's initial orientation.
  public var orientationLongitude: CGFloat {
    get { cgFloat(forKey: "orientationLongitude") }
    set { setValue(Double(newValue), forKey: "orientationLongitude") }
  }

  /// Random variation (radians) applied to a `plane` particle's orientation.
  public var orientationRange: CGFloat {
    get { cgFloat(forKey: "orientationRange") }
    set { setValue(Double(newValue), forKey: "orientationRange") }
  }

  private func cgFloat(forKey key: String) -> CGFloat {
    CGFloat((value(forKey: key) as? NSNumber)?.doubleValue ?? 0)
  }
}
