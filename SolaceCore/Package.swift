// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "SolaceCore",
    platforms: [
        .iOS(.v17),
        .macOS(.v14)
    ],
    products: [
        .library(name: "SolaceCore", targets: ["SolaceCore"])
    ],
    targets: [
        .target(name: "SolaceCore"),
        .testTarget(name: "SolaceCoreTests", dependencies: ["SolaceCore"])
    ]
)
