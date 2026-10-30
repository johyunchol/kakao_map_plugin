// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "kakao_map_plugin",
    platforms: [
        .iOS("13.0")
    ],
    products: [
        .library(name: "kakao-map-plugin", targets: ["kakao_map_plugin"])
    ],
    dependencies: [
        .package(name: "FlutterFramework", path: "../FlutterFramework")
    ],
    targets: [
        .target(
            name: "kakao_map_plugin",
            dependencies: [
                .product(name: "FlutterFramework", package: "FlutterFramework")
            ]
        )
    ]
)
