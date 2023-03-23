// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "BrandPay",
    platforms: [
        .iOS(.v11)
    ],
    products: [
        .library(
            name: "BrandPayBiometric",
            targets: [
                "BrandPayBase",
                "BiometricInterface",
            ]),
        .library(
            name: "BrandPayOCR",
            targets: [
                "BrandPayBase",
                "OCRInterface",
                "FinCubeOcrSDK"
            ]),
        .library(
            name: "BrandPayWeb",
            targets: [
                "BrandPayBase",
                "OCRInterface",
                "FinCubeOcrSDK",
                "BiometricInterface"
            ])
    ],
    targets: [
        .binaryTarget(name: "BrandPayBase", path: "Library/BrandPayBase.xcframework"),
        .binaryTarget(name: "OCRInterface", path: "Library/OCRInterface.xcframework"),
        .binaryTarget(name: "BiometricInterface", path: "Library/BiometricInterface.xcframework"),
        .binaryTarget(name: "FinCubeOcrSDK", path: "Library/FinCubeOcrSDK.xcframework")
    ],
    swiftLanguageVersions: [
        .v5
    ]
)
