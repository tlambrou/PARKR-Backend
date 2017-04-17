import PackageDescription

let package = Package(
    name: "parkr-api",
    dependencies: [
        .Package(url: "https://github.com/vapor/vapor.git", majorVersion: 1, minor: 5),
        .Package(url: "https://github.com/Hearst-DD/ObjectMapper.git", majorVersion: 2, minor: 2),
        .Package(url: "https://github.com/vapor/postgresql-provider", majorVersion: 1),
        .Package(url: "https://github.com/Alamofire/Alamofire.git", majorVersion: 4)
    ],
    exclude: [
        "Config",
        "Database",
        "Localization",
        "Public",
        "Resources",
    ]
)

