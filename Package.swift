// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "Prism",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .library(name: "Prism", targets: ["Prism"])
    ],
    targets: [
        .target(
            name: "Prism",
            path: ".",
            exclude: ["build.yml", "Package.swift"],
            sources: [
                "PrismGalleryApp.swift",
                "PhotoAsset.swift",
                "GalleryViewModel.swift",
                "MainGalleryView.swift",
                "DetailOverlayView.swift",
                "EditorView.swift"
            ]
        )
    ]
)
