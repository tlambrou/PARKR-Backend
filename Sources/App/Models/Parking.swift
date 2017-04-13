import Foundation
import CoreLocation
import Vapor

enum RPPArea: String {
    case A = "A"
    case B
    case C
    case D
    case E
    case F
    case G
    case H
    case I
    case J
    case K
    case L
    case M
    case N
    case O
    case P
    case Q
    case R
    case S
    case T
    case U
    case V
    case W
    case X
    case Y
    case Z
}

enum Weekdays {
    case Monday
    case Tuesday
    case Wednesday
    case Thursday
    case Friday
    case Saturday
    case Sunday
}

final class Parking: Model {
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
