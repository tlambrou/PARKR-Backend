import Foundation
import CoreLocation
import Vapor
import ObjectMapper


final class Parking: Model, Mappable {
    var id: Node?
    var exists: Bool = false
    
    var hoursBegin: Int!
    var hoursEnd: Int!
    var hourLimit: Int!
    var originalId: Int!
    var dayRange: (Weekday, Weekday)!
    var rppRegion: [RPPArea]?
    //var geometry: [CLLocationCoordinate2D]
    
    required public init?(map: Map) {}
    
    public func mapping(map: Map) {
        self.dayRange <- (map["days"], WeekdayRangeTransform())
        
        self.hourLimit <- map["hour_limit"]
        self.hoursBegin <- map["hours_begin"]
        self.hoursEnd <- map["hours_end"]
        self.originalId <- map["object_id"]
        
        self.rppRegion <- (map, RPPTransform())
        
    }
    
//    {
//        "days": "M-F",
//        "geom": {
//            "type": "LineString",
//            "coordinates": [
//                [
//                    -122.46135273132373,
//                    37.78675307823066
//                ],
//                [
//                    -122.46054784629841,
//                    37.786789477745
//                ]
//            ]
//        },
//        "hour_limit": "2",
//        "hours": "900-1800",
//        "hours_begin": "900",
//        "hours_end": "1800",
//        "last_edited_date": "2016-10-21T00:00:00.000Z",
//        "object_id": "1",
//        "regulation": "RPP",
//        "rpp_area_1": "N",
//        "rpp_area_2": " ",
//        "rpp_area_3": " "
//    }
//    
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

extension Model {
  

  
  
  
}
