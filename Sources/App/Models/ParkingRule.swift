import Foundation
import CoreLocation
import Vapor

final class ParkingRule: Model {
    //var DoW: daysOfTheWeek?
    var id: Node?
    var exists: Bool = false
    
    var hoursBegin: Int
    var hoursEnd: Int
    var hourLimit: Int
    var originalId: Int
    //var geometry: [CLLocationCoordinate2D]
    
    init(hoursBegin: Int, hoursEnd: Int, hourLimit: Int, originalId: Int, geometry: [CLLocationCoordinate2D]) {
        self.hoursBegin = hoursBegin
        self.hoursEnd = hoursEnd
        self.hourLimit = hourLimit
        self.originalId = originalId
        //self.geometry = geometry
    }
    
    init(node: Node, in context: Context) throws {
        self.hoursBegin = try node.extract("hoursBegin")
        self.hoursEnd = try node.extract("hoursEnd")
        self.hourLimit = try node.extract("hourLimit")
        self.originalId = try node.extract("originalId")
        //self.geometry = try node.extract("geometry")
        self.id = try node.extract("id")
    }

    func makeNode(context: Context) throws -> Node {
        return try Node(node: [
            "id": self.id,
            "originalId": self.originalId,
            "hoursBegin": self.hoursBegin,
            "hoursEnd": self.hoursEnd,
            "hourLimit": self.hourLimit
        ])
    }

    static func prepare(_ database: Database) throws {
        try database.create("rules", closure: { user in
            user.id()
            //user.
        })
    }
    
    static func revert(_ database: Database) throws {
        try database.delete("rules")
    }
}
