// swift-tools-version:3.1

import PackageDescription

let package = Package(
  name: "RxExpect",
  dependencies: [
    // temporary url for RxTest support
    .Package(url: "https://github.com/devxoul/RxSwift.git", majorVersion: 3),
  ]
)
