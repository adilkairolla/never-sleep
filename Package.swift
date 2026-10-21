// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "NeverSleep",
    platforms: [.macOS(.v13)],
    products: [.executable(name: "NeverSleep", targets: ["NeverSleep"])],
    targets: [.executableTarget(name: "NeverSleep")]
)
