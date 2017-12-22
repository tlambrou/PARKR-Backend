import Vapor
import FluentSQLite
import Foundation

/// Called before your application initializes.
///
/// [Learn More →](https://docs.vapor.codes/3.0/getting-started/structure/#configureswift)
public func configure(
    _ config: inout Config,
    _ env: inout Environment,
    _ services: inout Services
) throws {
    // configure your application here
    let directoryConfig = DirectoryConfig.default()
    services.instance(directoryConfig)

    try services.provider(FluentProvider())
    try services.provider(SQLiteProvider())

    var databaseConfig = DatabaseConfig()
    let db = SQLiteDatabase(storage: .file(path: "/Users/fnord/Documents/sqlite/test.db"))
    databaseConfig.add(database: db, as: .sqlite)
    services.instance(databaseConfig)

    var migrationConfig = MigrationConfig()
    migrationConfig.add(model: Parking.self, database: .sqlite)
    services.instance(migrationConfig)
}

extension DatabaseIdentifier {
    static var sqlite: DatabaseIdentifier<SQLiteDatabase> {
        return .init("sqlite")
    }
}
