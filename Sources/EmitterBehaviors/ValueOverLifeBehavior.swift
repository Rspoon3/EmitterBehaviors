import CoreGraphics
import Foundation

/// Interpolates a particle property across the particle's lifetime.
///
/// ```swift
/// let grow = ValueOverLifeBehavior()
/// grow.property = .scale
/// grow.values = [0, 1, 0]        // grow then shrink
/// ```
public final class ValueOverLifeBehavior: EmitterBehavior, KeyPathAddressableBehavior {
  public init() { super.init(kind: .valueOverLife) }
  init(wrapping object: NSObject) { super.init(kind: .valueOverLife, wrapping: object) }

  /// The particle property to drive.
  public var property: ValueProperty? {
    get { valueProperty(.keyPath) }
    set { set(.keyPath, newValue) }
  }

  /// Value at each stop.
  public var values: [CGFloat]? {
    get { numbers(.values) }
    set { set(.values, newValue) }
  }

  /// Optional stop positions in `0...1`, one per value.
  public var locations: [CGFloat]? {
    get { numbers(.locations) }
    set { set(.locations, newValue) }
  }

  /// Optional easing between stops.
  public var function: TimingFunction? {
    get { timing(.function) }
    set { set(.function, newValue) }
  }

  /// Whether values add to the cell's own rather than replace it.
  public var additive: Bool? {
    get { bool(.additive) }
    set { set(.additive, newValue) }
  }

  public static var parameterKeyPaths: [PartialKeyPath<ValueOverLifeBehavior>: Parameter] {
    [
      \.property: .keyPath, \.values: .values, \.locations: .locations, \.function: .function,
      \.additive: .additive,
    ]
  }
}
