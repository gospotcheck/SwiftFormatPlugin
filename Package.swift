// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SwiftFormatPlugin",
    products: [
        .plugin(
            name: "SwiftFormatLintBuildToolPlugin",
            targets: ["SwiftFormatLintBuildToolPlugin"]),
    ],
    targets: [
        .plugin(
            name: "SwiftFormatLintBuildToolPlugin",
            capability: .buildTool(),
            dependencies: [.target(name: "SwiftFormatBinary")]
        ),
        .binaryTarget(
                    name: "SwiftFormatBinary",
                        url: "https://github.com/nicklockwood/SwiftFormat/releases/download/0.55.3/swiftformat.artifactbundle.zip",
                        checksum: "5c28b67a7c64b2494324b0fe7c1a6c73bb42cc3f673f9be36fa7759cc55b34f7"
                )
    ]
)
