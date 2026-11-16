import CoreGraphics
import Foundation
import QuartzCore

/// Base class of every emitter behavior, a friendly Swift wrapper over the private
/// `CAEmitterBehavior`.
///
/// Configure a behavior the way you configure a `CAEmitterCell`: create the subclass for the kind
/// you want, set its properties, and hand it to a layer.
///
/// ```swift
/// let attractor = AttractorBehavior()
/// attractor.stiffness = 5
/// attractor.radius = 300
/// attractor.falloff = -290          // negative repels
///
/// layer.emitterBehaviors = [WaveBehavior(), attractor, DragBehavior()]
/// ```
///
/// Each instance wraps a *live* `CAEmitterBehavior`, so changing a property after the behavior is
/// attached takes effect, and animating a parameter through the layer is reflected when you read it
/// back. Every property is optional: `nil` means "not set, use the system default".
///
/// - Important: This relies on private API. Behaviors are looked up by name at runtime, so on an OS
///   that lacks them ``isSupported`` is `false` and every property is a harmless no-op. Apple may
///   still reject an app that uses it; consider gating it behind `#if DEBUG` or a remote flag.
///
/// Angles are radians. Distances are points. Subclasses are provided for each ``Kind``; don't
/// subclass this yourself.
public class EmitterBehavior {
  /// The behavior types the runtime exposes. Raw values are the runtime's type names.
  public enum Kind: String, CaseIterable, Sendable {
    case wave
    case drag
    case alignToMotion
    case valueOverLife
    case colorOverLife
    case light
    case attractor
    case simpleAttractor
    case colorOverDistance
    case valueOverDistance

    /// The parameters this kind accepts, as reported by the runtime (`inputKeys`).
    public var parameters: [Parameter] {
      switch self {
      case .wave: [.force, .frequency]
      case .drag: [.drag]
      case .alignToMotion: [.rotation, .preservesDepth]
      case .valueOverLife: [.keyPath, .values, .locations, .function, .additive]
      case .colorOverLife: [.colors, .locations, .function]
      case .light:
        [
          .color, .appliesAlpha, .ambientIntensity, .diffuseIntensity, .position, .zPosition,
          .falloff, .falloffDistance, .spot, .directionLatitude, .directionLongitude, .coneAngle,
          .coneEdgeSoftness,
        ]
      case .attractor:
        [
          .attractorType, .stiffness, .radius, .position, .zPosition, .falloff, .falloffDistance,
          .orientationLatitude, .orientationLongitude,
        ]
      case .simpleAttractor: [.stiffness, .position, .falloff]
      case .colorOverDistance:
        [
          .colors, .locations, .function, .attractorType, .position, .zPosition, .falloff,
          .falloffDistance, .orientationLatitude, .orientationLongitude, .additive,
        ]
      case .valueOverDistance:
        [
          .keyPath, .values, .locations, .function, .attractorType, .position, .zPosition,
          .falloff, .falloffDistance, .orientationLatitude, .orientationLongitude, .additive,
        ]
      }
    }
  }

  /// Which kind of behavior this is.
  public let kind: Kind

  /// The live `CAEmitterBehavior` this wraps, or `nil` if the running OS doesn't provide it.
  public let underlyingObject: NSObject?

  private let acceptedKeys: Set<String>?

  /// Wraps `object`, or creates a fresh behavior of `kind` when none is given.
  init(kind: Kind, wrapping object: NSObject? = nil) {
    self.kind = kind
    let object = object ?? BehaviorRuntime.makeBehavior(type: kind.rawValue)
    self.underlyingObject = object
    self.acceptedKeys = object.flatMap(BehaviorRuntime.inputKeys(of:))
    // A name is what makes a behavior addressable by key path, so always have one.
    if let object, object.value(forKey: "name") == nil {
      object.setValue(UUID().uuidString, forKey: "name")
    }
  }

  // MARK: Identity

  /// Identifies the behavior inside `emitterBehaviors` so its parameters can be animated by key
  /// path. Defaults to a unique string. Must not contain `.`.
  public var name: String {
    get { underlyingObject?.value(forKey: "name") as? String ?? "" }
    set { underlyingObject?.setValue(newValue, forKey: "name") }
  }

  /// A disabled behavior stays attached but has no effect.
  public var isEnabled: Bool {
    get { (underlyingObject?.value(forKey: "enabled") as? NSNumber)?.boolValue ?? true }
    set { underlyingObject?.setValue(newValue, forKey: "enabled") }
  }

  /// Sets ``name`` and returns `self`, for chaining.
  @discardableResult
  public func named(_ name: String) -> Self {
    self.name = name
    return self
  }

  // MARK: Availability

  /// Whether the running OS still ships `CAEmitterBehavior`.
  public static var isSupported: Bool { BehaviorRuntime.behaviorClass != nil }

  /// The kinds the running OS reports.
  public static var availableKinds: Set<Kind> {
    Set(BehaviorRuntime.availableTypes.compactMap(Kind.init(rawValue:)))
  }

  /// Whether this instance is backed by a real behavior on this OS.
  public var isAvailable: Bool { underlyingObject != nil }

  // MARK: Animation

  /// The key path to animate one of this behavior's parameters on the `CAEmitterLayer` it is
  /// attached to. Prefer the typed `keyPath(for: \.stiffness)` on the concrete subclass.
  ///
  /// This only works for behaviors attached to a layer, not a cell.
  public func keyPath(for parameter: Parameter) -> String {
    "emitterBehaviors.\(name).\(parameter.rawValue)"
  }

  // MARK: Wrapping

  /// Wraps an existing raw `CAEmitterBehavior` (for example one read back from a layer) in the
  /// matching subclass. Returns `nil` if it isn't one of the known kinds.
  public static func wrap(_ object: NSObject) -> EmitterBehavior? {
    guard
      let typeName = BehaviorRuntime.typeName(of: object),
      let kind = Kind(rawValue: typeName)
    else { return nil }
    switch kind {
    case .wave: return WaveBehavior(wrapping: object)
    case .drag: return DragBehavior(wrapping: object)
    case .alignToMotion: return AlignToMotionBehavior(wrapping: object)
    case .valueOverLife: return ValueOverLifeBehavior(wrapping: object)
    case .colorOverLife: return ColorOverLifeBehavior(wrapping: object)
    case .light: return LightBehavior(wrapping: object)
    case .attractor: return AttractorBehavior(wrapping: object)
    case .simpleAttractor: return SimpleAttractorBehavior(wrapping: object)
    case .colorOverDistance: return ColorOverDistanceBehavior(wrapping: object)
    case .valueOverDistance: return ValueOverDistanceBehavior(wrapping: object)
    }
  }
}

// MARK: - Typed key paths

/// A behavior whose Swift properties can be turned into animation key paths:
/// `attractor.keyPath(for: \.stiffness)`.
public protocol KeyPathAddressableBehavior: EmitterBehavior {
  /// Maps each Swift property to the runtime parameter it controls.
  static var parameterKeyPaths: [PartialKeyPath<Self>: EmitterBehavior.Parameter] { get }
}

extension KeyPathAddressableBehavior {
  /// The key path to animate `property` on the `CAEmitterLayer` this behavior is attached to.
  ///
  /// ```swift
  /// let animation = CABasicAnimation(keyPath: attractor.keyPath(for: \.stiffness))
  /// ```
  public func keyPath<Value>(for property: KeyPath<Self, Value>) -> String {
    guard let parameter = Self.parameterKeyPaths[property] else {
      preconditionFailure("\(property) is not a behavior parameter")
    }
    return keyPath(for: parameter)
  }
}

// MARK: - Raw parameter access (used by the subclasses)

extension EmitterBehavior {
  private func accepts(_ parameter: Parameter) -> Bool {
    acceptedKeys?.contains(parameter.rawValue) ?? true
  }

  // Unknown KVC keys raise an uncatchable NSException, so only ever touch keys the OS lists.
  func raw(_ parameter: Parameter) -> Any? {
    guard let underlyingObject, accepts(parameter) else { return nil }
    return underlyingObject.value(forKey: parameter.rawValue)
  }

  func setRaw(_ parameter: Parameter, _ value: Any?) {
    guard let underlyingObject, accepts(parameter) else { return }
    underlyingObject.setValue(value, forKey: parameter.rawValue)
  }

  func number(_ parameter: Parameter) -> CGFloat? {
    (raw(parameter) as? NSNumber).map { CGFloat($0.doubleValue) }
  }
  func set(_ parameter: Parameter, _ value: CGFloat?) {
    setRaw(parameter, value.map { NSNumber(value: Double($0)) })
  }

  func bool(_ parameter: Parameter) -> Bool? {
    (raw(parameter) as? NSNumber)?.boolValue
  }
  func set(_ parameter: Parameter, _ value: Bool?) {
    setRaw(parameter, value.map { NSNumber(value: $0) })
  }

  func point(_ parameter: Parameter) -> CGPoint? {
    raw(parameter) as? CGPoint
  }
  func set(_ parameter: Parameter, _ value: CGPoint?) {
    setRaw(parameter, value)  // bridges to NSValue
  }

  func vector(_ parameter: Parameter) -> SIMD3<Float>? {
    guard let numbers = raw(parameter) as? [NSNumber], numbers.count == 3 else { return nil }
    return SIMD3(numbers[0].floatValue, numbers[1].floatValue, numbers[2].floatValue)
  }
  func set(_ parameter: Parameter, _ value: SIMD3<Float>?) {
    setRaw(parameter, value.map { [$0.x, $0.y, $0.z].map { NSNumber(value: $0) } })
  }

  func numbers(_ parameter: Parameter) -> [CGFloat]? {
    (raw(parameter) as? [NSNumber])?.map { CGFloat($0.doubleValue) }
  }
  func set(_ parameter: Parameter, _ value: [CGFloat]?) {
    setRaw(parameter, value.map { $0.map { NSNumber(value: Double($0)) } })
  }

  func color(_ parameter: Parameter) -> CGColor? {
    // `as? CGColor` always "succeeds" for CF types, so check the type ID.
    guard let value = raw(parameter) as AnyObject?, CFGetTypeID(value) == CGColor.typeID
    else { return nil }
    return unsafeDowncast(value, to: CGColor.self)
  }
  func set(_ parameter: Parameter, _ value: CGColor?) {
    setRaw(parameter, value)
  }

  func colors(_ parameter: Parameter) -> [CGColor]? {
    raw(parameter) as? [CGColor]
  }
  func set(_ parameter: Parameter, _ value: [CGColor]?) {
    setRaw(parameter, value)
  }

  func attractorType(_ parameter: Parameter) -> AttractorType? {
    (raw(parameter) as? String).flatMap(AttractorType.init(rawValue:))
  }
  func set(_ parameter: Parameter, _ value: AttractorType?) {
    setRaw(parameter, value?.rawValue)
  }

  func valueProperty(_ parameter: Parameter) -> ValueProperty? {
    (raw(parameter) as? String).flatMap(ValueProperty.init(rawValue:))
  }
  func set(_ parameter: Parameter, _ value: ValueProperty?) {
    setRaw(parameter, value?.rawValue)
  }

  /// The runtime stores a `CAMediaTimingFunction` and describes it by name.
  func timing(_ parameter: Parameter) -> TimingFunction? {
    raw(parameter).flatMap { TimingFunction(rawValue: String(describing: $0)) }
  }
  func set(_ parameter: Parameter, _ value: TimingFunction?) {
    setRaw(
      parameter,
      value.map { CAMediaTimingFunction(name: CAMediaTimingFunctionName(rawValue: $0.rawValue)) })
  }
}
