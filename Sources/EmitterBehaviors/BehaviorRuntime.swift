import Foundation
import QuartzCore

/// The only place that touches the private `CAEmitterBehavior` class.
///
/// Everything is resolved by name at runtime (`NSClassFromString`, selectors, KVC) so the package
/// never links against a private symbol, and degrades to "unsupported" instead of crashing if the
/// class disappears in a future OS.
enum BehaviorRuntime {
  static let behaviorClass: NSObject.Type? = NSClassFromString("CAEmitterBehavior") as? NSObject.Type

  private static let behaviorTypesSelector = NSSelectorFromString("behaviorTypes")
  private static let behaviorWithTypeSelector = NSSelectorFromString("behaviorWithType:")
  private static let inputKeysSelector = NSSelectorFromString("inputKeys")
  private static let typeSelector = NSSelectorFromString("type")

  /// Behavior type names the running OS knows about (e.g. `"wave"`, `"attractor"`).
  static var availableTypes: [String] {
    guard let cls = behaviorClass, cls.responds(to: behaviorTypesSelector) else { return [] }
    return cls.perform(behaviorTypesSelector)?.takeUnretainedValue() as? [String] ?? []
  }

  /// Creates a raw `CAEmitterBehavior`, or `nil` if the class or type is unavailable.
  static func makeBehavior(type: String) -> NSObject? {
    guard
      let cls = behaviorClass,
      cls.responds(to: behaviorWithTypeSelector),
      availableTypes.contains(type)
    else { return nil }
    return cls.perform(behaviorWithTypeSelector, with: type)?.takeUnretainedValue() as? NSObject
  }

  /// The keys a behavior accepts. `nil` if the OS doesn't tell us.
  ///
  /// Setting an unknown key through KVC raises an Objective-C exception, which Swift cannot
  /// catch, so we only ever set keys this reports.
  static func inputKeys(of behavior: NSObject) -> Set<String>? {
    guard behavior.responds(to: inputKeysSelector) else { return nil }
    guard let keys = behavior.perform(inputKeysSelector)?.takeUnretainedValue() as? [String]
    else { return nil }
    return Set(keys)
  }

  /// The type name (e.g. `"wave"`) of a raw behavior. KVC returns `nil` for `type`, so ask the selector.
  static func typeName(of behavior: NSObject) -> String? {
    guard behavior.responds(to: typeSelector) else { return nil }
    return behavior.perform(typeSelector)?.takeUnretainedValue() as? String
  }
}
