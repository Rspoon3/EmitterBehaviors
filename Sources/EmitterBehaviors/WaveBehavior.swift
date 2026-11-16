import CoreGraphics
import Foundation

/// Adds a force vector to each particle, modulated by a time-based wave. Good for flutter.
public final class WaveBehavior: EmitterBehavior, KeyPathAddressableBehavior {
  public init() { super.init(kind: .wave) }
  init(wrapping object: NSObject) { super.init(kind: .wave, wrapping: object) }

  /// The force `[x, y, z]` at the wave's peak.
  public var force: SIMD3<Float>? {
    get { vector(.force) }
    set { set(.force, newValue) }
  }

  /// Oscillation frequency.
  public var frequency: CGFloat? {
    get { number(.frequency) }
    set { set(.frequency, newValue) }
  }

  public static var parameterKeyPaths: [PartialKeyPath<WaveBehavior>: Parameter] {
    [\.force: .force, \.frequency: .frequency]
  }
}
