import CoreGraphics
import Foundation

/// Applies 3D lighting to particles (pair with `plane` particles for the best effect).
public final class LightBehavior: EmitterBehavior, KeyPathAddressableBehavior {
  public init() { super.init(kind: .light) }
  init(wrapping object: NSObject) { super.init(kind: .light, wrapping: object) }

  /// Light color. Alpha is ignored.
  public var color: CGColor? {
    get { color(.color) }
    set { set(.color, newValue) }
  }

  /// Whether the light affects particle alpha. Defaults to `true` at runtime.
  public var appliesAlpha: Bool? {
    get { bool(.appliesAlpha) }
    set { set(.appliesAlpha, newValue) }
  }

  /// `0...1`.
  public var ambientIntensity: CGFloat? {
    get { number(.ambientIntensity) }
    set { set(.ambientIntensity, newValue) }
  }

  /// `0...1`.
  public var diffuseIntensity: CGFloat? {
    get { number(.diffuseIntensity) }
    set { set(.diffuseIntensity, newValue) }
  }

  /// Light position.
  public var position: CGPoint? {
    get { point(.position) }
    set { set(.position, newValue) }
  }

  /// Light depth.
  public var zPosition: CGFloat? {
    get { number(.zPosition) }
    set { set(.zPosition, newValue) }
  }

  /// How intensity decays with distance.
  public var falloff: CGFloat? {
    get { number(.falloff) }
    set { set(.falloff, newValue) }
  }

  /// Distance over which ``falloff`` applies.
  public var falloffDistance: CGFloat? {
    get { number(.falloffDistance) }
    set { set(.falloffDistance, newValue) }
  }

  /// `true` makes a spot light (uses the direction and cone properties).
  public var spot: Bool? {
    get { bool(.spot) }
    set { set(.spot, newValue) }
  }

  /// Spot direction latitude, radians.
  public var directionLatitude: CGFloat? {
    get { number(.directionLatitude) }
    set { set(.directionLatitude, newValue) }
  }

  /// Spot direction longitude, radians.
  public var directionLongitude: CGFloat? {
    get { number(.directionLongitude) }
    set { set(.directionLongitude, newValue) }
  }

  /// Spot cone angle, `0...π/2`.
  public var coneAngle: CGFloat? {
    get { number(.coneAngle) }
    set { set(.coneAngle, newValue) }
  }

  /// Spot cone edge softness, `0...π/2`.
  public var coneEdgeSoftness: CGFloat? {
    get { number(.coneEdgeSoftness) }
    set { set(.coneEdgeSoftness, newValue) }
  }

  public static var parameterKeyPaths: [PartialKeyPath<LightBehavior>: Parameter] {
    [
      \.color: .color, \.appliesAlpha: .appliesAlpha, \.ambientIntensity: .ambientIntensity,
      \.diffuseIntensity: .diffuseIntensity, \.position: .position, \.zPosition: .zPosition,
      \.falloff: .falloff, \.falloffDistance: .falloffDistance, \.spot: .spot,
      \.directionLatitude: .directionLatitude, \.directionLongitude: .directionLongitude,
      \.coneAngle: .coneAngle, \.coneEdgeSoftness: .coneEdgeSoftness,
    ]
  }
}
