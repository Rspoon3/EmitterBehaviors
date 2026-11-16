// swift-tools-version: 6.0
import PackageDescription

let package = Package(
  name: "EmitterBehaviors",
  platforms: [
    .iOS(.v15),
    .macOS(.v12),
    .tvOS(.v15),
    .visionOS(.v1),
  ],
  products: [
    .library(name: "EmitterBehaviors", targets: ["EmitterBehaviors"])
  ],
  targets: [
    .target(name: "EmitterBehaviors"),
    .testTarget(
      name: "EmitterBehaviorsTests",
      dependencies: ["EmitterBehaviors"]
    ),
  ]
)
