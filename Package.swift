import PackageDescription

let package = Package(
    name: "parkr-api",
    dependencies: [
        .Package(url: "https://github.com/vapor/vapor.git", majorVersion: 1, minor: 5),
        .Package(url: "https://github.com/Hearst-DD/ObjectMapper.git", majorVersion: 2, minor: 2),
        .Package(url: "https://github.com/vapor/postgresql-provider", majorVersion: 1),
<<<<<<< HEAD
        .Package(url: "https://github.com/andreacremaschi/GEOSwift", majorVersion: 0, minor: 5),
        .Package(url: "https://github.com/Alamofire/Alamofire.git", majorVersion: 4)
=======
        .Package(url: "https://github.com/Alamofire/Alamofire.git", majorVersion: 4),
        .Package(url: "https://github.com/petrpavlik/GeoSwift.git", majorVersion: 1)
>>>>>>> 5aad70187a2656a14855b9fb1b7201bd4f98e033
    ],
    exclude: [
        "Config",
        "Database",
        "Localization",
        "Public",
        "Resources",
    ]
)

