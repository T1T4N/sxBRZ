// swift-tools-version:5.0
import PackageDescription

let package = Package(
    name: "sxBRZ",
    products: [
        .executable(name: "sxBRZ", targets: ["sxBRZ"])
    ],
    targets: [
        .target(
            name: "sxBRZ",
            path: "Sources/sxBRZ"
        )
    ]
)