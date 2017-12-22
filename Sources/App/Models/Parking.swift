import Foundation
import FluentSQLite
import Vapor

final class Parking: Content {
    var id: UUID?
    var hoursBegin: Int
    var hoursEnd: Int
    var hourLimit: Double
    
    init(hoursBegin: Int, hoursEnd: Int, hourLimit: Double) {
        self.hoursBegin = hoursBegin
        self.hoursEnd = hoursEnd
        self.hourLimit = hourLimit
    }
}

extension Parking: Model, Migration {
    typealias Database = SQLiteDatabase
    typealias ID = UUID
    
    static var idKey: ReferenceWritableKeyPath<Parking, UUID?> {
        return \.id
    }
}
