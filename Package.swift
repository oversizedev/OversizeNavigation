// swift-tools-version: 6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let commonDependencies: [PackageDescription.Package.Dependency] = [
    .package(url: "https://github.com/hmlongco/Navigator.git", .upToNextMajor(from: "1.1.1")),
]

let remoteDependencies: [PackageDescription.Package.Dependency] = commonDependencies + [
    .package(url: "https://github.com/oversizedev/OversizeUI.git", .upToNextMajor(from: "3.0.2")),
    .package(url: "https://github.com/oversizedev/OversizeCore.git", .upToNextMajor(from: "1.3.0")),
    .package(url: "https://github.com/oversizedev/OversizeModels.git", .upToNextMajor(from: "0.1.0")),
    .package(url: "https://github.com/oversizedev/OversizeResources.git", .upToNextMajor(from: "2.0.0")),
]

let localDependencies: [PackageDescription.Package.Dependency] = commonDependencies + [
    .package(name: "OversizeUI", path: "../OversizeUI"),
    .package(name: "OversizeCore", path: "../OversizeCore"),
    .package(name: "OversizeModels", path: "../OversizeModels"),
    .package(name: "OversizeResources", path: "../OversizeResources"),
]

let dependencies: [PackageDescription.Package.Dependency] = localDependencies

let package = Package(
    name: "OversizeNavigation",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v17),
        .macOS(.v14),
        .tvOS(.v17),
        .watchOS(.v10),
    ],
    products: [
        .library(
            name: "OversizeNavigation",
            targets: ["OversizeNavigation"]
        ),
    ],
    dependencies: dependencies,
    targets: [
        .target(
            name: "OversizeNavigation",
            dependencies: [
                .product(name: "OversizeUI", package: "OversizeUI"),
                .product(name: "NavigatorUI", package: "Navigator"),
                .product(name: "OversizeModels", package: "OversizeModels"),
                .product(name: "OversizeCore", package: "OversizeCore"),
                .product(name: "OversizeResources", package: "OversizeResources"),
            ]
        ),
    ]
)
