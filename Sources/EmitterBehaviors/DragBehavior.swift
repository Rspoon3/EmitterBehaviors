import CoreGraphics
import Foundation

/// Applies a drag force of `velocity * -drag` to each particle.
public final class DragBehavior: EmitterBehavior, KeyPathAddressableBehavior {
  public init() { super.init(kind: .drag) }
  init(wrapping object: NSObject) { super.init(kind: .drag, wrapping: object) }

  /// The drag coefficient. Animatable.
  public var drag: CGFloat? {
    get { number(.drag) }
    set { set(.drag, newValue) }
  }

  public static var parameterKeyPaths: [PartialKeyPath<DragBehavior>: Parameter] {
    [\.drag: .drag]
  }
}
