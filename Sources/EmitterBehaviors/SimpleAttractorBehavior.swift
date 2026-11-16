import CoreGraphics
import Foundation

/// A cheaper, radial-only attractor.
public final class SimpleAttractorBehavior: EmitterBehavior, KeyPathAddressableBehavior {
  public init() { super.init(kind: .simpleAttractor) }
  init(wrapping object: NSObject) { super.init(kind: .simpleAttractor, wrapping: object) }

  /// Strength of the pull. Animatable.
  public var stiffness: CGFloat? {
    get { number(.stiffness) }
    set { set(.stiffness, newValue) }
  }

  /// Center of the field, in the emitter layer's coordinates.
  public var position: CGPoint? {
    get { point(.position) }
    set { set(.position, newValue) }
  }

  /// How the force decays with distance.
  public var falloff: CGFloat? {
    get { number(.falloff) }
    set { set(.falloff, newValue) }
  }

  public static var parameterKeyPaths: [PartialKeyPath<SimpleAttractorBehavior>: Parameter] {
    [\.stiffness: .stiffness, \.position: .position, \.falloff: .falloff]
  }
}
