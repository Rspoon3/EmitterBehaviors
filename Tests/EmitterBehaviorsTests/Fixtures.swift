import CoreGraphics
import Testing

@testable import EmitterBehaviors

// MARK: - Sendable test cases
//
// Behaviors are classes (like CAEmitterCell), so they aren't `Sendable` and can't be passed as
// `@Test(arguments:)`. Cases are instead small `Sendable` descriptions that build and exercise the
// behavior inside `run`.

/// Key paths are immutable, but the compiler can't see that for a key path rooted in a
/// non-`Sendable` class.
struct UncheckedSendable<Value>: @unchecked Sendable { let value: Value }

/// A behavior class that can be created with no arguments.
protocol Creatable: KeyPathAddressableBehavior { init() }

extension WaveBehavior: Creatable {}
extension DragBehavior: Creatable {}
extension AlignToMotionBehavior: Creatable {}
extension AttractorBehavior: Creatable {}
extension SimpleAttractorBehavior: Creatable {}
extension ValueOverLifeBehavior: Creatable {}
extension ColorOverLifeBehavior: Creatable {}
extension ColorOverDistanceBehavior: Creatable {}
extension ValueOverDistanceBehavior: Creatable {}
extension LightBehavior: Creatable {}

/// What happened when one Swift property was set on a fresh behavior.
struct PropertyOutcome: Sendable {
  /// Reading the property returns what was written.
  var getterReturnsSetValue: Bool
  /// The live `CAEmitterBehavior` actually holds a value under the runtime's key.
  var rawValueIsSet: Bool
  /// `keyPath(for: \.property)` maps to the runtime's key.
  var keyPathMatches: Bool
  /// Assigning `nil` clears it, on both the Swift and runtime sides.
  var clearsToNil: Bool
}

struct PropertyCase: Sendable, CustomTestStringConvertible {
  let kind: EmitterBehavior.Kind
  let parameter: EmitterBehavior.Parameter
  let valueDescription: String
  let run: @Sendable () -> PropertyOutcome

  var testDescription: String { "\(kind).\(parameter.rawValue) = \(valueDescription)" }
}

func property<B: Creatable, V: Equatable & Sendable>(
  _ keyPath: ReferenceWritableKeyPath<B, V?>,
  _ parameter: EmitterBehavior.Parameter,
  _ value: V
) -> PropertyCase {
  let keyPath = UncheckedSendable(value: keyPath)
  return PropertyCase(kind: B().kind, parameter: parameter, valueDescription: "\(value)") {
    let keyPath = keyPath.value
    let behavior = B()
    behavior[keyPath: keyPath] = value
    let getter = behavior[keyPath: keyPath] == value
    let raw = behavior.underlyingObject?.value(forKey: parameter.rawValue) != nil
    let keyPathMatches =
      behavior.keyPath(for: keyPath) == "emitterBehaviors.\(behavior.name).\(parameter.rawValue)"
    behavior[keyPath: keyPath] = nil
    let cleared =
      behavior[keyPath: keyPath] == nil
      && behavior.underlyingObject?.value(forKey: parameter.rawValue) == nil
    return PropertyOutcome(
      getterReturnsSetValue: getter, rawValueIsSet: raw, keyPathMatches: keyPathMatches,
      clearsToNil: cleared)
  }
}

// MARK: - Fixtures

let white = CGColor(red: 1, green: 1, blue: 1, alpha: 1)
let red = CGColor(red: 1, green: 0, blue: 0, alpha: 1)
let point = CGPoint(x: 3, y: 4)

/// One case for every property of every behavior class.
let propertyCases: [PropertyCase] = [
  // wave
  property(\WaveBehavior.force, .force, SIMD3<Float>(100, 0, 5)),
  property(\WaveBehavior.frequency, .frequency, 0.5),
  // drag
  property(\DragBehavior.drag, .drag, 1.2),
  // alignToMotion
  property(\AlignToMotionBehavior.rotation, .rotation, .pi),
  property(\AlignToMotionBehavior.preservesDepth, .preservesDepth, true),
  // attractor
  property(\AttractorBehavior.type, .attractorType, .axial),
  property(\AttractorBehavior.stiffness, .stiffness, 20),
  property(\AttractorBehavior.radius, .radius, 300),
  property(\AttractorBehavior.position, .position, point),
  property(\AttractorBehavior.zPosition, .zPosition, 70),
  property(\AttractorBehavior.falloff, .falloff, -280),
  property(\AttractorBehavior.falloffDistance, .falloffDistance, 50),
  property(\AttractorBehavior.orientationLatitude, .orientationLatitude, 1),
  property(\AttractorBehavior.orientationLongitude, .orientationLongitude, 2),
  // simpleAttractor
  property(\SimpleAttractorBehavior.stiffness, .stiffness, 15),
  property(\SimpleAttractorBehavior.position, .position, point),
  property(\SimpleAttractorBehavior.falloff, .falloff, 500),
  // valueOverLife
  property(\ValueOverLifeBehavior.property, .keyPath, .scale),
  property(\ValueOverLifeBehavior.values, .values, [0, 1, 0]),
  property(\ValueOverLifeBehavior.locations, .locations, [0, 0.3, 1]),
  property(\ValueOverLifeBehavior.function, .function, .easeOut),
  property(\ValueOverLifeBehavior.additive, .additive, true),
  // colorOverLife
  property(\ColorOverLifeBehavior.colors, .colors, [white, red]),
  property(\ColorOverLifeBehavior.locations, .locations, [0, 1]),
  property(\ColorOverLifeBehavior.function, .function, .easeIn),
  // light
  property(\LightBehavior.color, .color, red),
  property(\LightBehavior.appliesAlpha, .appliesAlpha, false),
  property(\LightBehavior.ambientIntensity, .ambientIntensity, 0.3),
  property(\LightBehavior.diffuseIntensity, .diffuseIntensity, 0.6),
  property(\LightBehavior.position, .position, point),
  property(\LightBehavior.zPosition, .zPosition, 5),
  property(\LightBehavior.falloff, .falloff, 3),
  property(\LightBehavior.falloffDistance, .falloffDistance, 4),
  property(\LightBehavior.spot, .spot, true),
  property(\LightBehavior.directionLatitude, .directionLatitude, 1),
  property(\LightBehavior.directionLongitude, .directionLongitude, 2),
  property(\LightBehavior.coneAngle, .coneAngle, 0.5),
  property(\LightBehavior.coneEdgeSoftness, .coneEdgeSoftness, 0.2),
  // colorOverDistance
  property(\ColorOverDistanceBehavior.colors, .colors, [white, red]),
  property(\ColorOverDistanceBehavior.locations, .locations, [0, 1]),
  property(\ColorOverDistanceBehavior.function, .function, .linear),
  property(\ColorOverDistanceBehavior.type, .attractorType, .planar),
  property(\ColorOverDistanceBehavior.position, .position, point),
  property(\ColorOverDistanceBehavior.zPosition, .zPosition, 1),
  property(\ColorOverDistanceBehavior.falloff, .falloff, 2),
  property(\ColorOverDistanceBehavior.falloffDistance, .falloffDistance, 3),
  property(\ColorOverDistanceBehavior.orientationLatitude, .orientationLatitude, 1),
  property(\ColorOverDistanceBehavior.orientationLongitude, .orientationLongitude, 2),
  property(\ColorOverDistanceBehavior.additive, .additive, false),
  // valueOverDistance
  property(\ValueOverDistanceBehavior.property, .keyPath, .alpha),
  property(\ValueOverDistanceBehavior.values, .values, [0, 1]),
  property(\ValueOverDistanceBehavior.locations, .locations, [0, 1]),
  property(\ValueOverDistanceBehavior.function, .function, .easeInEaseOut),
  property(\ValueOverDistanceBehavior.type, .attractorType, .radial),
  property(\ValueOverDistanceBehavior.position, .position, point),
  property(\ValueOverDistanceBehavior.zPosition, .zPosition, 1),
  property(\ValueOverDistanceBehavior.falloff, .falloff, 2),
  property(\ValueOverDistanceBehavior.falloffDistance, .falloffDistance, 3),
  property(\ValueOverDistanceBehavior.orientationLatitude, .orientationLatitude, 1),
  property(\ValueOverDistanceBehavior.orientationLongitude, .orientationLongitude, 2),
  property(\ValueOverDistanceBehavior.additive, .additive, true),
]

/// For each kind, the parameters its Swift class exposes as properties.
struct KindCoverage: Sendable, CustomTestStringConvertible {
  let kind: EmitterBehavior.Kind
  let swiftParameters: Set<EmitterBehavior.Parameter>
  var testDescription: String { "\(kind)" }

  init<B: Creatable>(_ type: B.Type) {
    kind = B().kind
    swiftParameters = Set(B.parameterKeyPaths.values)
  }
}

let kindCoverage: [KindCoverage] = [
  KindCoverage(WaveBehavior.self), KindCoverage(DragBehavior.self),
  KindCoverage(AlignToMotionBehavior.self), KindCoverage(ValueOverLifeBehavior.self),
  KindCoverage(ColorOverLifeBehavior.self), KindCoverage(LightBehavior.self),
  KindCoverage(AttractorBehavior.self), KindCoverage(SimpleAttractorBehavior.self),
  KindCoverage(ColorOverDistanceBehavior.self), KindCoverage(ValueOverDistanceBehavior.self),
]
