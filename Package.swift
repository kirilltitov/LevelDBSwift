import PackageDescription

let package = Package(
    name: "LevelDB",
    dependencies: [
        .Package(url: "https://github.com/kirilltitov/CLevelDB", majorVersion: 1)
    ]
)
