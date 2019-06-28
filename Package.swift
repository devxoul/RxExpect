// swift-tools-version:5.0

import PackageDescription

let package = Package(
  name: "RxExpect",
  platforms: [
    .iOS(.v8), .macOS(.v10_10), .tvOS(.v9)
  ],
  products: [
    .library(name: "RxExpect", targets: ["RxExpect"]),
  ],
  dependencies: [
    .package(url: "https://github.com/ReactiveX/RxSwift.git", .upToNextMajor(from: "5.0.0")),
  ],
  targets: [
    .target(name: "RxExpect", dependencies: ["RxSwift", "RxTest", "RxRelay"]),
    .testTarget(name: "RxExpectTests", dependencies: ["RxExpect"])
  ],
  swiftLanguageVersions: [.v5]
)
