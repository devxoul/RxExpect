// swift-tools-version:5.1

import PackageDescription

let package = Package(
  name: "RxExpect",
  platforms: [
    .iOS(.v9), .macOS(.v10_10), .tvOS(.v9)
  ],
  products: [
    .library(name: "RxExpect", targets: ["RxExpect"]),
  ],
  dependencies: [
    .package(url: "https://github.com/ReactiveX/RxSwift.git", .upToNextMajor(from: "6.0.0")),
  ],
  targets: [
    .target(name: "RxExpect", dependencies: ["RxRelay", "RxSwift", "RxTest"]),
    .testTarget(name: "RxExpectTests", dependencies: ["RxExpect"])
  ],
  swiftLanguageVersions: [.v5]
)
