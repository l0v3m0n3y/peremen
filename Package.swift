// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "peremen",
    platforms: [
        .macOS(.v12), .iOS(.v15)
    ],
    products: [
        .library(name: "peremen", targets: ["peremen"]),
    ],
    targets: [
        .target(
            name: "peremen",
            path: "src"
        ),
    ]
)
