import CoreGraphics
import Foundation

// Experimental: this kind exists at runtime but is undocumented even by the community write-ups.
// Its parameter list comes from runtime introspection; the exact semantics (distance measured from
// `position`, shaped by the attractor type) are inferred and not verified.

/// **Experimental.** Interpolates a particle property based on distance from a point, axis or
/// plane rather than particle age.
public final class ValueOverDistanceBehavior: EmitterBehavior, KeyPathAddressableBehavior {
  public init() { super.init(kind: .valueOverDistance) }
  init(wrapping object: NSObject) { super.init(kind: .valueOverDistance, wrapping: object) }

  public var property: ValueProperty? {
    get { valueProperty(.keyPath) }
    set { set(.keyPath, newValue) }
  }
  public var values: [CGFloat]? {
    get { numbers(.values) }
    set { set(.values, newValue) }
  }
  public var locations: [CGFloat]? {
    get { numbers(.locations) }
    set { set(.locations, newValue) }
  }
  public var function: TimingFunction? {
    get { timing(.function) }
    set { set(.function, newValue) }
  }
  public var type: AttractorType? {
    get { attractorType(.attractorType) }
    set { set(.attractorType, newValue) }
  }
  public var position: CGPoint? {
    get { point(.position) }
    set { set(.position, newValue) }
  }
  public var zPosition: CGFloat? {
    get { number(.zPosition) }
    set { set(.zPosition, newValue) }
  }
  public var falloff: CGFloat? {
    get { number(.falloff) }
    set { set(.falloff, newValue) }
  }
  public var falloffDistance: CGFloat? {
    get { number(.falloffDistance) }
    set { set(.falloffDistance, newValue) }
  }
  public var orientationLatitude: CGFloat? {
    get { number(.orientationLatitude) }
    set { set(.orientationLatitude, newValue) }
  }
  public var orientationLongitude: CGFloat? {
    get { number(.orientationLongitude) }
    set { set(.orientationLongitude, newValue) }
  }
  public var additive: Bool? {
    get { bool(.additive) }
    set { set(.additive, newValue) }
  }

  public static var parameterKeyPaths: [PartialKeyPath<ValueOverDistanceBehavior>: Parameter] {
    [
      \.property: .keyPath, \.values: .values, \.locations: .locations, \.function: .function,
      \.type: .attractorType, \.position: .position, \.zPosition: .zPosition,
      \.falloff: .falloff, \.falloffDistance: .falloffDistance,
      \.orientationLatitude: .orientationLatitude, \.orientationLongitude: .orientationLongitude,
      \.additive: .additive,
    ]
  }
}
