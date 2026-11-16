import CoreGraphics
import Foundation
import QuartzCore

// MARK: - Public vocabulary

extension EmitterBehavior {
  /// Every parameter any behavior accepts. Raw values are the KVC keys the runtime uses.
  ///
  /// Also used to build animatable key paths; see ``EmitterBehavior/keyPath(for:)``.
  public enum Parameter: String, CaseIterable, Sendable {
    // wave
    case force, frequency
    // drag
    case drag
    // alignToMotion
    case rotation, preservesDepth
    // valueOverLife / valueOverDistance
    case keyPath, values, locations, function, additive
    // colorOverLife / colorOverDistance
    case colors
    // light
    case color, appliesAlpha, ambientIntensity, diffuseIntensity
    case spot, directionLatitude, directionLongitude, coneAngle, coneEdgeSoftness
    // attractors / distance behaviors
    case attractorType, stiffness, radius
    case position, zPosition, falloff, falloffDistance
    case orientationLatitude, orientationLongitude
  }

  /// The orientation of an ``AttractorBehavior``.
  public enum AttractorType: String, CaseIterable, Sendable {
    /// Pulls toward (or, with negative falloff, pushes away from) a point.
    case radial
    /// Pulls toward an axis through `position`, set by the orientation angles.
    case axial
    /// Pulls toward a plane through `position`, whose normal is set by the orientation angles.
    case planar
  }

  /// A particle property that ``ValueOverLifeBehavior``
  /// can interpolate across a particle's lifetime.
  public enum ValueProperty: String, CaseIterable, Sendable {
    case birthRate
    case positionX = "position.x"
    case positionY = "position.y"
    case positionZ = "position.z"
    case velocityX = "velocity.x"
    case velocityY = "velocity.y"
    case velocityZ = "velocity.z"
    case mass
    case rotation
    case spin
    case scale
    case scaleSpeed
    case red = "color.red"
    case green = "color.green"
    case blue = "color.blue"
    case alpha = "color.alpha"
  }

  /// Easing used between value / color stops.
  public enum TimingFunction: String, CaseIterable, Sendable {
    case linear
    case easeIn
    case easeOut
    case easeInEaseOut
    case standard = "default"
  }
}
