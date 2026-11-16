import CoreGraphics
import ObjectiveC
import QuartzCore
import Testing

@testable import EmitterBehaviors

// MARK: - Runtime contract

@Suite struct RuntimeContractTests {
  @Test func isSupportedOnThisOS() {
    #expect(EmitterBehavior.isSupported)
  }

  /// If Apple renames or removes a type, this fails loudly instead of the behavior silently no-oping.
  @Test(arguments: EmitterBehavior.Kind.allCases)
  func kindExistsAtRuntime(kind: EmitterBehavior.Kind) {
    #expect(BehaviorRuntime.availableTypes.contains(kind.rawValue))
    #expect(EmitterBehavior.availableKinds.contains(kind))
  }

  /// Our per-kind parameter lists must match the runtime's `inputKeys` exactly, so we never set an
  /// unknown KVC key (an uncatchable crash) and never silently miss a new one.
  @Test(arguments: EmitterBehavior.Kind.allCases)
  func parametersMatchRuntimeInputKeys(kind: EmitterBehavior.Kind) throws {
    let object = try #require(BehaviorRuntime.makeBehavior(type: kind.rawValue))
    let runtimeKeys = try #require(BehaviorRuntime.inputKeys(of: object))
    #expect(Set(kind.parameters.map(\.rawValue)) == runtimeKeys)
  }

  @Test(arguments: EmitterBehavior.ValueProperty.allCases)
  func runtimeAcceptsValueProperty(property: EmitterBehavior.ValueProperty) throws {
    let object = try #require(BehaviorRuntime.makeBehavior(type: "valueOverLife"))
    object.setValue(property.rawValue, forKey: "keyPath")
    #expect(object.value(forKey: "keyPath") as? String == property.rawValue)
  }
}

// MARK: - Swift classes cover the runtime

@Suite struct CoverageTests {
  /// Every runtime parameter of a kind must have a Swift property on that kind's class.
  @Test(arguments: kindCoverage)
  func classExposesEveryRuntimeParameter(coverage: KindCoverage) {
    #expect(coverage.swiftParameters == Set(coverage.kind.parameters))
  }

  @Test func everyKindHasAClass() {
    #expect(Set(kindCoverage.map(\.kind)) == Set(EmitterBehavior.Kind.allCases))
  }

  /// And every one of those properties has a test case below.
  @Test func everyPropertyHasATestCase() {
    let covered = Set(propertyCases.map { "\($0.kind).\($0.parameter.rawValue)" })
    let expected = Set(
      EmitterBehavior.Kind.allCases.flatMap { kind in
        kind.parameters.map { "\(kind).\($0.rawValue)" }
      })
    #expect(covered == expected)
  }

  @Test(arguments: EmitterBehavior.Kind.allCases)
  func wrapPicksTheMatchingSubclass(kind: EmitterBehavior.Kind) throws {
    let raw = try #require(BehaviorRuntime.makeBehavior(type: kind.rawValue))
    let wrapped = try #require(EmitterBehavior.wrap(raw))
    #expect(wrapped.kind == kind)
    #expect(wrapped.underlyingObject === raw)
    let className = kind.rawValue.prefix(1).uppercased() + kind.rawValue.dropFirst() + "Behavior"
    #expect(String(describing: type(of: wrapped)) == className)
  }
}

// MARK: - Properties

@Suite struct PropertyTests {
  @Test(arguments: propertyCases)
  func propertyRoundTrips(_ test: PropertyCase) {
    let outcome = test.run()
    #expect(outcome.getterReturnsSetValue, "getter returns the value that was set")
    #expect(outcome.rawValueIsSet, "the live CAEmitterBehavior holds the value")
    #expect(outcome.keyPathMatches, "keyPath(for:) maps to the runtime key")
    #expect(outcome.clearsToNil, "nil clears it")
  }

  /// A new behavior must not pre-set anything: `nil` means "use the system default".
  @Test(arguments: EmitterBehavior.Kind.allCases)
  func freshBehaviorHasNothingSet(kind: EmitterBehavior.Kind) throws {
    let raw = try #require(BehaviorRuntime.makeBehavior(type: kind.rawValue))
    let behavior = try #require(EmitterBehavior.wrap(raw))
    for parameter in kind.parameters {
      #expect(behavior.raw(parameter) == nil, "\(kind).\(parameter.rawValue)")
    }
  }

  @Test func settingOnePropertyLeavesOthersAlone() {
    let attractor = AttractorBehavior()
    attractor.stiffness = 20
    #expect(attractor.radius == nil)
    #expect(attractor.zPosition == nil)
  }

  @Test(arguments: EmitterBehavior.AttractorType.allCases)
  func attractorTypeValues(type: EmitterBehavior.AttractorType) {
    let attractor = AttractorBehavior()
    attractor.type = type
    #expect(attractor.type == type)
    #expect(attractor.underlyingObject?.value(forKey: "attractorType") as? String == type.rawValue)

    let colorDistance = ColorOverDistanceBehavior()
    colorDistance.type = type
    #expect(colorDistance.type == type)

    let valueDistance = ValueOverDistanceBehavior()
    valueDistance.type = type
    #expect(valueDistance.type == type)
  }

  @Test(arguments: EmitterBehavior.ValueProperty.allCases)
  func valueProperties(property: EmitterBehavior.ValueProperty) {
    let life = ValueOverLifeBehavior()
    life.property = property
    #expect(life.property == property)
    #expect(life.underlyingObject?.value(forKey: "keyPath") as? String == property.rawValue)

    let distance = ValueOverDistanceBehavior()
    distance.property = property
    #expect(distance.property == property)
  }

  /// The runtime stores a CAMediaTimingFunction and describes it by name.
  @Test(arguments: EmitterBehavior.TimingFunction.allCases)
  func timingFunctions(function: EmitterBehavior.TimingFunction) {
    let life = ValueOverLifeBehavior()
    life.function = function
    #expect(life.function == function)
    #expect(String(describing: life.underlyingObject?.value(forKey: "function") ?? "") == function.rawValue)

    let color = ColorOverLifeBehavior()
    color.function = function
    #expect(color.function == function)
  }

  @Test(arguments: [true, false])
  func isEnabledRoundTrips(isEnabled: Bool) {
    let drag = DragBehavior()
    drag.isEnabled = isEnabled
    #expect(drag.isEnabled == isEnabled)
    #expect((drag.underlyingObject?.value(forKey: "enabled") as? NSNumber)?.boolValue == isEnabled)
  }

  @Test func isEnabledDefaultsToTrue() {
    #expect(DragBehavior().isEnabled)
  }

  @Test func nameRoundTripsAndChains() {
    let drag = DragBehavior()
    let returned = drag.named("slow")
    #expect(returned === drag)
    #expect(drag.name == "slow")
    #expect(drag.underlyingObject?.value(forKey: "name") as? String == "slow")
  }

  @Test func defaultNamesAreUniqueAndKeyPathSafe() {
    let a = DragBehavior(), b = DragBehavior()
    #expect(a.name != b.name)
    #expect(!a.name.isEmpty)
    #expect(!a.name.contains("."))
  }

  @Test func availabilityFlags() {
    #expect(DragBehavior().isAvailable)
    #expect(DragBehavior().kind == .drag)
  }
}

// MARK: - Shortcuts

@Suite struct ShortcutTests {
  @Test func simpleShortcuts() {
    let wave = EmitterBehavior.wave(force: [1, 2, 3], frequency: 4)
    #expect(wave.force == [1, 2, 3])
    #expect(wave.frequency == 4)

    #expect(EmitterBehavior.drag(1.2).drag == 1.2)

    let align = EmitterBehavior.alignToMotion(rotation: .pi, preservesDepth: true)
    #expect(align.rotation == .pi)
    #expect(align.preservesDepth == true)
  }

  @Test func overLifeShortcuts() {
    let value = EmitterBehavior.valueOverLife(
      .scale, values: [0, 1, 0], locations: [0, 0.3, 1], function: .easeOut)
    #expect(value.property == .scale)
    #expect(value.values == [0, 1, 0])
    #expect(value.locations == [0, 0.3, 1])
    #expect(value.function == .easeOut)

    let color = EmitterBehavior.colorOverLife(colors: [white, red])
    #expect(color.colors?.count == 2)
    #expect(color.locations == nil)
  }

  @Test func shortcutsWorkAsImplicitMembers() {
    let behaviors: [EmitterBehavior] = [.drag(1), .wave(force: [1, 0, 0], frequency: 1)]
    #expect(behaviors.map(\.kind) == [.drag, .wave])
  }
}

// MARK: - Attaching

@Suite struct AttachmentTests {
  private func drags(_ count: Int) -> [EmitterBehavior] { (0..<count).map { _ in DragBehavior() } }

  @Test(arguments: [0, 1, 3, 10])
  func layerAssignmentReplaces(count: Int) {
    let layer = CAEmitterLayer()
    layer.emitterBehaviors = [SimpleAttractorBehavior()]  // must be replaced, not appended to
    layer.emitterBehaviors = drags(count)
    #expect(layer.emitterBehaviors.count == count)
  }

  @Test(arguments: [0, 1, 3])
  func layerAppends(existing: Int) {
    let layer = CAEmitterLayer()
    layer.emitterBehaviors = drags(existing)
    layer.emitterBehaviors.append(WaveBehavior())
    layer.emitterBehaviors += drags(1)
    #expect(layer.emitterBehaviors.count == existing + 2)
  }

  @Test func layerEmptiesAndHasNoBehaviorsByDefault() {
    let layer = CAEmitterLayer()
    #expect(layer.emitterBehaviors.isEmpty)
    layer.emitterBehaviors = drags(2)
    layer.emitterBehaviors = []
    #expect(layer.emitterBehaviors.isEmpty)
  }

  @Test(arguments: [0, 1, 3])
  func cellAssignmentReplaces(count: Int) {
    let cell = CAEmitterCell()
    #expect(cell.emitterBehaviors.isEmpty)
    cell.emitterBehaviors = drags(count)
    #expect(cell.emitterBehaviors.count == count)
  }

  /// Reading back returns the right subclass, in order.
  @Test func readBackPreservesKindsAndOrder() {
    let layer = CAEmitterLayer()
    layer.emitterBehaviors = [WaveBehavior(), AttractorBehavior(), DragBehavior(), LightBehavior()]
    #expect(layer.emitterBehaviors.map(\.kind) == [.wave, .attractor, .drag, .light])
    #expect(layer.emitterBehaviors[1] is AttractorBehavior)
  }

  @Test func readBackWrapsTheSameLiveObjects() {
    let attractor = AttractorBehavior()
    let layer = CAEmitterLayer()
    layer.emitterBehaviors = [attractor]
    #expect(layer.emitterBehaviors[0].underlyingObject === attractor.underlyingObject)
  }

  @Test func resultBuilderSupportsConditionalsAndLoops() {
    let layer = CAEmitterLayer()
    layer.setBehaviors {
      DragBehavior()
      if true { WaveBehavior() }
      for _ in 0..<2 { SimpleAttractorBehavior() }
      EmitterBehavior.drag(2)
    }
    #expect(layer.emitterBehaviors.map(\.kind) == [.drag, .wave, .simpleAttractor, .simpleAttractor, .drag])

    let cell = CAEmitterCell()
    cell.setBehaviors { DragBehavior() }
    #expect(cell.emitterBehaviors.count == 1)
  }

  /// Behaviors are live: changing one after attaching changes what the layer holds.
  @Test func mutatingAfterAttachingIsVisibleToTheLayer() {
    let attractor = AttractorBehavior()
    attractor.stiffness = 10
    let layer = CAEmitterLayer()
    layer.emitterBehaviors = [attractor]

    attractor.stiffness = 42
    #expect((layer.emitterBehaviors[0] as? AttractorBehavior)?.stiffness == 42)
    #expect((layer.value(forKeyPath: attractor.keyPath(for: \.stiffness)) as? NSNumber)?.doubleValue == 42)

    // ...and the other direction.
    (layer.emitterBehaviors[0] as? AttractorBehavior)?.radius = 99
    #expect(attractor.radius == 99)
  }

  /// A custom name is optional: the auto-generated one must also work in a key path, for every
  /// numeric attractor parameter, via both the typed and the `Parameter` key path APIs.
  @Test(
    arguments: [true, false],
    [(EmitterBehavior.Parameter.stiffness, 80.0), (.radius, 300), (.falloff, -290), (.zPosition, 70)]
  )
  func keyPathResolvesThroughTheLayer(named: Bool, parameter: (EmitterBehavior.Parameter, Double)) {
    let (parameter, value) = parameter
    let attractor = AttractorBehavior()
    attractor.stiffness = 80
    attractor.radius = 300
    attractor.zPosition = 70
    attractor.falloff = -290
    if named { attractor.name = "attractor" }

    let layer = CAEmitterLayer()
    layer.emitterBehaviors = [attractor]

    let keyPath = attractor.keyPath(for: parameter)
    #expect(keyPath == "emitterBehaviors.\(attractor.name).\(parameter.rawValue)")
    #expect((layer.value(forKeyPath: keyPath) as? NSNumber)?.doubleValue == value)

    layer.setValue(5, forKeyPath: keyPath)
    #expect((layer.value(forKeyPath: keyPath) as? NSNumber)?.doubleValue == 5)
  }

  @Test func typedKeyPathMatchesParameterKeyPath() {
    let attractor = AttractorBehavior().named("attractor")
    #expect(attractor.keyPath(for: \.stiffness) == "emitterBehaviors.attractor.stiffness")
    #expect(attractor.keyPath(for: \.stiffness) == attractor.keyPath(for: .stiffness))
    #expect(DragBehavior().named("d").keyPath(for: \.drag) == "emitterBehaviors.d.drag")
  }
}

// MARK: - Plane particles & private selector safety

@Suite struct PlaneParticleTests {
  @Test(arguments: [EmitterParticleType.sprite, .plane])
  func particleTypeRoundTrips(type: EmitterParticleType) {
    let cell = CAEmitterCell()
    cell.particleType = type
    #expect(cell.particleType == type)
    #expect(cell.value(forKey: "particleType") as? String == type.rawValue)
  }

  @Test func defaultsToSprite() {
    #expect(CAEmitterCell().particleType == .sprite)
  }

  @Test(arguments: [0, .pi / 2, .pi, -1.25])
  func orientationRoundTrips(angle: CGFloat) {
    // `angle` is CGFloat, not Double: `#expect` can't apply the implicit Double -> CGFloat
    // conversion, so comparing mixed types would fail even for equal values.
    let cell = CAEmitterCell()
    cell.orientationLatitude = angle
    cell.orientationLongitude = angle
    cell.orientationRange = angle
    #expect(cell.orientationLatitude == angle)
    #expect(cell.orientationLongitude == angle)
    #expect(cell.orientationRange == angle)
  }
}

/// Our Swift members share names with private Objective-C selectors on CAEmitterCell and
/// CAEmitterLayer. Prove they don't register selectors, replace Apple's methods, or desync from the
/// ObjC side.
@Suite struct PrivateSelectorSafetyTests {
  private func implementations(of cls: AnyClass, _ selectors: [String]) -> [IMP?] {
    selectors.map { class_getMethodImplementation(cls, NSSelectorFromString($0)) }
  }

  @Test func cellParticleSelectors() throws {
    let selectors = [
      "particleType", "setParticleType:", "orientationLatitude", "setOrientationLatitude:",
      "orientationLongitude", "orientationRange",
    ]
    let before = implementations(of: CAEmitterCell.self, selectors)
    #expect(before.allSatisfy { $0 != nil }, "these private selectors exist")

    let cell = CAEmitterCell()
    cell.particleType = .plane
    cell.orientationLatitude = 1.25

    // Apple's own ObjC getters, called directly, see what the Swift setters wrote.
    #expect(cell.perform(NSSelectorFromString("particleType"))?.takeUnretainedValue() as? String == "plane")
    #expect((cell.value(forKey: "orientationLatitude") as? NSNumber)?.doubleValue == 1.25)
    #expect(implementations(of: CAEmitterCell.self, selectors) == before)
  }

  @Test(arguments: [CAEmitterLayer.self, CAEmitterCell.self] as [AnyClass])
  func emitterBehaviorsSelectors(cls: AnyClass) throws {
    let selectors = ["emitterBehaviors", "setEmitterBehaviors:"]
    let before = implementations(of: cls, selectors)
    #expect(before.allSatisfy { $0 != nil }, "these private selectors exist")

    let object = try #require((cls as? NSObject.Type)?.init())
    let drag = DragBehavior()
    if let layer = object as? CAEmitterLayer { layer.emitterBehaviors = [drag] }
    if let cell = object as? CAEmitterCell { cell.emitterBehaviors = [drag] }

    // Apple's own ObjC getter, called directly, returns the very object we attached.
    let raw = object.perform(NSSelectorFromString("emitterBehaviors"))?.takeUnretainedValue() as? [NSObject]
    #expect(raw?.count == 1)
    #expect(raw?.first === drag.underlyingObject)
    #expect(implementations(of: cls, selectors) == before)
  }
}
