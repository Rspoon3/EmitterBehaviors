import CoreGraphics
import Foundation

/// A force field that pulls particles toward (or, with a negative ``falloff``, pushes them away
/// from) a point, axis or plane.
public final class AttractorBehavior: EmitterBehavior, KeyPathAddressableBehavior {
  public init() { super.init(kind: .attractor) }
  init(wrapping object: NSObject) { super.init(kind: .attractor, wrapping: object) }

  /// Radial (default), axial or planar.
  public var type: AttractorType? {
    get { attractorType(.attractorType) }
    set { set(.attractorType, newValue) }
  }

  /// Strength of the pull. Animatable.
  public var stiffness: CGFloat? {
    get { number(.stiffness) }
    set { set(.stiffness, newValue) }
  }

  /// Particles inside this radius are unaffected.
  public var radius: CGFloat? {
    get { number(.radius) }
    set { set(.radius, newValue) }
  }

  /// Center of the field, in the emitter layer's coordinates.
  public var position: CGPoint? {
    get { point(.position) }
    set { set(.position, newValue) }
  }

  /// Depth of the field.
  public var zPosition: CGFloat? {
    get { number(.zPosition) }
    set { set(.zPosition, newValue) }
  }

  /// How the force decays with distance. Negative values repel.
  public var falloff: CGFloat? {
    get { number(.falloff) }
    set { set(.falloff, newValue) }
  }

  /// Distance over which ``falloff`` applies.
  public var falloffDistance: CGFloat? {
    get { number(.falloffDistance) }
    set { set(.falloffDistance, newValue) }
  }

  /// Axis (axial) or normal (planar) latitude, radians.
  public var orientationLatitude: CGFloat? {
    get { number(.orientationLatitude) }
    set { set(.orientationLatitude, newValue) }
  }

  /// Axis (axial) or normal (planar) longitude, radians.
  public var orientationLongitude: CGFloat? {
    get { number(.orientationLongitude) }
    set { set(.orientationLongitude, newValue) }
  }

  public static var parameterKeyPaths: [PartialKeyPath<AttractorBehavior>: Parameter] {
    [
      \.type: .attractorType, \.stiffness: .stiffness, \.radius: .radius, \.position: .position,
      \.zPosition: .zPosition, \.falloff: .falloff, \.falloffDistance: .falloffDistance,
      \.orientationLatitude: .orientationLatitude, \.orientationLongitude: .orientationLongitude,
    ]
  }
}
