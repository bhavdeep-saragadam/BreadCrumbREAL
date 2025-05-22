// swift-tools-version:5.7
import PackageDescription

let package = Package(
    name: "BreadCrumb",
    platforms: [
        .iOS(.v15)
    ],
    products: [
        .library(
            name: "BreadCrumb",
            targets: ["BreadCrumb"]),
    ],
    dependencies: [
        .package(url: "https://github.com/supabase-community/supabase-swift.git", from: "0.3.0"),
        .package(url: "https://github.com/google/GoogleSignIn-iOS.git", from: "7.0.0")
    ],
    targets: [
        .target(
            name: "BreadCrumb",
            dependencies: [
                .product(name: "Supabase", package: "supabase-swift"),
                .product(name: "GoogleSignIn", package: "GoogleSignIn-iOS")
            ]),
        .testTarget(
            name: "BreadCrumbTests",
            dependencies: ["BreadCrumb"]),
    ]
) 