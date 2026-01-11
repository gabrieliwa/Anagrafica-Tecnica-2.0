// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "AnagraficaTecnicaModules",
    platforms: [.iOS(.v16), .macOS(.v12)],
    products: [
        .library(name: "Core", targets: ["Core"]),
        .library(name: "DesignSystem", targets: ["DesignSystem"]),
        .library(name: "Projects", targets: ["Projects"]),
        .library(name: "Floorplan", targets: ["Floorplan"]),
        .library(name: "AddAssetWizard", targets: ["AddAssetWizard"]),
        .library(name: "Room", targets: ["Room"]),
        .library(name: "SurveyReport", targets: ["SurveyReport"]),
        .library(name: "Export", targets: ["Export"])
    ],
    targets: [
        .target(
            name: "Core",
            path: "Core/Sources"
        ),
        .target(
            name: "DesignSystem",
            path: "DesignSystem/Sources"
        ),
        .target(
            name: "Projects",
            dependencies: ["Core", "DesignSystem"],
            path: "Features/Projects/Sources"
        ),
        .target(
            name: "Floorplan",
            dependencies: ["Core", "DesignSystem", "AddAssetWizard", "Room", "SurveyReport"],
            path: "Features/Floorplan/Sources"
        ),
        .target(
            name: "AddAssetWizard",
            dependencies: ["Core", "DesignSystem"],
            path: "Features/AddAssetWizard/Sources"
        ),
        .target(
            name: "Room",
            dependencies: ["Core", "DesignSystem"],
            path: "Features/Room/Sources"
        ),
        .target(
            name: "SurveyReport",
            dependencies: ["Core", "DesignSystem"],
            path: "Features/SurveyReport/Sources"
        ),
        .target(
            name: "Export",
            dependencies: ["Core", "DesignSystem"],
            path: "Features/Export/Sources"
        ),
        .testTarget(
            name: "CoreTests",
            dependencies: ["Core"],
            path: "Core/Tests"
        )
    ]
)
