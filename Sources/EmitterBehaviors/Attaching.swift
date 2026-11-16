import Foundation
import QuartzCore

// MARK: - Result builder

/// Lets you list behaviors in a closure: `layer.setBehaviors { DragBehavior(); WaveBehavior() }`.
@resultBuilder
public enum EmitterBehaviorBuilder {
  public static func buildExpression(_ behavior: EmitterBehavior) -> [EmitterBehavior] { [behavior] }
  public static func buildExpression(_ behaviors: [EmitterBehavior]) -> [EmitterBehavior] { behaviors }
  public static func buildBlock(_ components: [EmitterBehavior]...) -> [EmitterBehavior] {
    components.flatMap { $0 }
  }
  public static func buildOptional(_ component: [EmitterBehavior]?) -> [EmitterBehavior] {
    component ?? []
  }
  public static func buildEither(first component: [EmitterBehavior]) -> [EmitterBehavior] { component }
  public static func buildEither(second component: [EmitterBehavior]) -> [EmitterBehavior] { component }
  public static func buildArray(_ components: [[EmitterBehavior]]) -> [EmitterBehavior] {
    components.flatMap { $0 }
  }
}

private let emitterBehaviorsKey = "emitterBehaviors"

private func readBehaviors(from object: NSObject) -> [EmitterBehavior] {
  (object.value(forKey: emitterBehaviorsKey) as? [NSObject] ?? []).compactMap(EmitterBehavior.wrap)
}

private func writeBehaviors(_ behaviors: [EmitterBehavior], to object: NSObject) {
  object.setValue(behaviors.compactMap(\.underlyingObject), forKey: emitterBehaviorsKey)
}

// MARK: - CAEmitterLayer

// `CAEmitterLayer` already responds to a private `emitterBehaviors` selector. Reusing the name is
// safe because this is a plain Swift member (never `@objc`): it registers no selector and cannot
// replace Apple's implementation. The test suite guards this.
extension CAEmitterLayer {
  /// The behaviors acting on every particle this layer emits, like `emitterCells`.
  ///
  /// Reading returns wrappers around the layer's live behaviors, so setting a property on an
  /// element changes the layer. Wrappers are created fresh on each read; compare
  /// ``EmitterBehavior/underlyingObject`` for identity.
  public var emitterBehaviors: [EmitterBehavior] {
    get { readBehaviors(from: self) }
    set { writeBehaviors(newValue, to: self) }
  }

  /// Replaces ``emitterBehaviors`` using a result builder.
  public func setBehaviors(@EmitterBehaviorBuilder _ behaviors: () -> [EmitterBehavior]) {
    emitterBehaviors = behaviors()
  }
}

// MARK: - CAEmitterCell

extension CAEmitterCell {
  /// Behaviors scoped to this cell's particles only.
  ///
  /// Per-cell behaviors work, but their parameters can't be animated through the layer with
  /// ``EmitterBehavior/keyPath(for:)``.
  public var emitterBehaviors: [EmitterBehavior] {
    get { readBehaviors(from: self) }
    set { writeBehaviors(newValue, to: self) }
  }

  /// Replaces ``emitterBehaviors`` using a result builder.
  public func setBehaviors(@EmitterBehaviorBuilder _ behaviors: () -> [EmitterBehavior]) {
    emitterBehaviors = behaviors()
  }
}
