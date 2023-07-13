// swift-tools-version:5.6
import PackageDescription

let package = Package(
    name: "ActiveWin",
    products: [
        .executable(
            name: "active-win",
            targets: ["ActiveWinCLI"]
        ),
    ],
    dependencies: [
        .package(
            url: "https://github.com/getsentry/sentry-cocoa.git", 
            from: "7.1.3"
        )
    ],
    targets: [
        .executableTarget(
            name: "ActiveWinCLI",
            dependencies: ["Sentry"]
        )
    ]
)
