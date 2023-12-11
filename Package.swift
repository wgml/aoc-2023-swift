// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import Foundation
import PackageDescription

var day_targets: [PackageDescription.Target] = []
for d in 1 ... 25 {
    let d_str = String(format: "%02d", arguments: [d])
    if FileManager.default.fileExists(atPath: "Sources/\(d_str)") {
        day_targets.append(.executableTarget(name: "day\(d_str)",
                                             dependencies: [.byName(name: "Common")],
                                             path: "Sources/\(d_str)")
        )
    }
}

let package = Package(
    name: "aoc",
    platforms: [.macOS(.v13)],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser", from: "1.0.0"),
    ],
    targets: [
        .target(name: "Common", path: "Sources/Common"),
    ] + day_targets
)
