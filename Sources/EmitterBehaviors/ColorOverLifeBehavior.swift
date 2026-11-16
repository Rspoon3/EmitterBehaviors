import CoreGraphics
import Foundation

/// Sets particle color from a gradient across the particle's lifetime.
public final class ColorOverLifeBehavior: EmitterBehavior, KeyPathAddressableBehavior {
  public init() { super.init(kind: .colorOverLife) }
  init(wrapping object: NSObject) { super.init(kind: .colorOverLife, wrapping: object) }

  /// Gradient stops.
  public var colors: [CGColor]? {
    get { colors(.colors) }
    set { set(.colors, newValue) }
  }

  /// Optional stop positions in `0...1`, one per color.
  public var locations: [CGFloat]? {
    get { numbers(.locations) }
    set { set(.locations, newValue) }
  }

  /// Optional easing between stops.
  public var function: TimingFunction? {
    get { timing(.function) }
    set { set(.function, newValue) }
  }

  public static var parameterKeyPaths: [PartialKeyPath<ColorOverLifeBehavior>: Parameter] {
    [\.colors: .colors, \.locations: .locations, \.function: .function]
  }
}
