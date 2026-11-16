import CoreGraphics
import Foundation

// One-line conveniences for the simple kinds. For anything with more than a couple of parameters,
// create the subclass and set its properties, like a `CAEmitterCell`.
extension EmitterBehavior {
  /// A ``WaveBehavior`` with the given force and frequency.
  public static func wave(force: SIMD3<Float>, frequency: CGFloat) -> WaveBehavior {
    let behavior = WaveBehavior()
    behavior.force = force
    behavior.frequency = frequency
    return behavior
  }

  /// A ``DragBehavior`` with the given coefficient.
  public static func drag(_ drag: CGFloat) -> DragBehavior {
    let behavior = DragBehavior()
    behavior.drag = drag
    return behavior
  }

  /// An ``AlignToMotionBehavior``.
  public static func alignToMotion(
    rotation: CGFloat = 0, preservesDepth: Bool = false
  ) -> AlignToMotionBehavior {
    let behavior = AlignToMotionBehavior()
    behavior.rotation = rotation
    behavior.preservesDepth = preservesDepth
    return behavior
  }

  /// A ``ValueOverLifeBehavior`` driving `property` through `values`.
  public static func valueOverLife(
    _ property: ValueProperty, values: [CGFloat], locations: [CGFloat]? = nil,
    function: TimingFunction? = nil
  ) -> ValueOverLifeBehavior {
    let behavior = ValueOverLifeBehavior()
    behavior.property = property
    behavior.values = values
    behavior.locations = locations
    behavior.function = function
    return behavior
  }

  /// A ``ColorOverLifeBehavior`` with the given gradient.
  public static func colorOverLife(
    colors: [CGColor], locations: [CGFloat]? = nil, function: TimingFunction? = nil
  ) -> ColorOverLifeBehavior {
    let behavior = ColorOverLifeBehavior()
    behavior.colors = colors
    behavior.locations = locations
    behavior.function = function
    return behavior
  }
}
