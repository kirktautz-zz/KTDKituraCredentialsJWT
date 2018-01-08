// swift-tools-version:4.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "KTDKituraCredentialsJWT",
    products: [
        .library(
            name: "KTDKituraCredentialsJWT",
            targets: ["KTDKituraCredentialsJWT"]),
    ],
    dependencies: [
        .package(url: "https://github.com/IBM-Swift/Kitura-Credentials.git", .upToNextMinor(from: "2.0.0")),
        .package(url: "https://github.com/vapor/jwt.git", .upToNextMinor(from: "2.3.0ls "))
    ],
    targets: [
        .target(
            name: "KTDKituraCredentialsJWT",
            dependencies: ["Credentials", "JWT"]
        )
    ]
)
