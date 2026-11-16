import CoreGraphics
import Foundation

/// Rotates each particle's image to follow its velocity.
public final class AlignToMotionBehavior: EmitterBehavior, KeyPathAddressableBehavior {
  public init() { super.init(kind: .alignToMotion) }
  init(wrapping object: NSObject) { super.init(kind: .alignToMotion, wrapping: object) }

  /// Extra rotation (radians) added to the velocity's orientation.
  public var rotation: CGFloat? {
    get { number(.rotation) }
    set { set(.rotation, newValue) }
  }

  /// `false` rotates in 2D about the z axis. `true` works in 3D, which only `plane` particles
  /// support (see ``QuartzCore/CAEmitterCell/particleType``).
  public var preservesDepth: Bool? {
    get { bool(.preservesDepth) }
    set { set(.preservesDepth, newValue) }
  }

  public static var parameterKeyPaths: [PartialKeyPath<AlignToMotionBehavior>: Parameter] {
    [\.rotation: .rotation, \.preservesDepth: .preservesDepth]
  }
}
