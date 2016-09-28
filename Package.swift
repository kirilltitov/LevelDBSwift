import PackageDescription

let package = Package(
    name: "LevelDB",
    dependencies: [
        .Package(url: "https://github.com/jjacobson93/CLevelDB", majorVersion: 1)
    ]
)
