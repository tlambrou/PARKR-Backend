import Foundation
import CoreLocation
import Vapor
import ObjectMapper

typealias DayRange = (Weekday, Weekday)


final class Parking: Model, Mappable {
    var id: Node?
    var exists: Bool = false
    
    var hoursBegin: Int!
    var hoursEnd: Int!
    var hourLimit: Int!
    var originalId: Int!
    var dayRange: DayRange!
    var rppRegion: [RPPArea]?
    var geometry: CGRect!
    
    required public init?(map: Map) {}
    
    public func mapping(map: Map) {
        self.dayRange <- (map["days"], WeekdayRangeTransform())
        
        self.hourLimit <- map["hour_limit"]
        self.hoursBegin <- map["hours_begin"]
        self.hoursEnd <- map["hours_end"]
        self.originalId <- map["object_id"]
        
        self.rppRegion <- (map, RPPTransform())
        
       // self.geometry <- (map["geom"], GeoTransform())
        
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
        self.hoursBegin = try node.extract("hours_begin")
        self.hoursEnd = try node.extract("hours_end")
        self.hourLimit = try node.extract("hour_limit")
        self.originalId = try node.extract("object_id")
        
        let geomNode: Node = try node.extract("geom")
        
        self.geometry = try transformGeom(node: geomNode)

        self.id = try node.extract("id")
        self.rppRegion = try transformRPP(node: node)
        self.dayRange = try transformDayRange(node: node)
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
        try database.create("parking", closure: { user in
            user.id()
            user.int("hours_begin")
            user.int("hours_end")
            user.int("hour_limit")
            user.int("original_id")
        })
    }
    
    static func revert(_ database: Database) throws {
        try database.delete("rules")
    }
    
    private func transformGeom(node: Node) throws -> CGRect {
//        let type = try node.extract("type").string
        
        let pointAArray: [Double] = try node.extract("coordinates").array[0]
        let poingBArray: [Double] = try node.extract("coordinates").array[1]
        
        let pointA = CGPoint(x: pointAArray[0], y: pointAArray[1])
        let pointB = CGPoint(x: poingBArray[0], y: poingBArray[1])
        
        return CGRect(origin: pointA, size: pointA.sizeOfBounds(point: pointB))
    }
    
    private func transformRPP(node: Node) throws -> [RPPArea] {
        
        var rppArray = [RPPArea]()
        
        if let rppArea1 = ((node["rpp_area_1"]?.string != " ") ? node["rpp_area_1"]?.string : nil) {
            rppArray.append(RPPArea(areaChar: rppArea1))
        }
        
        if let rppArea2 = ((node["rpp_area_2"]?.string != " ") ? node["rpp_area_2"]?.string : nil) {
            rppArray.append(RPPArea(areaChar: rppArea2))
        }
        
        if let rppArea3 = ((node["rpp_area_3"]?.string != " ") ? node["rpp_area_3"]?.string : nil) {
            rppArray.append(RPPArea(areaChar: rppArea3))
        }
        
        return rppArray
    }
    
    private func transformDayRange(node: Node) throws -> DayRange {
        let dateString = node["days"]?.string
        
        let days = dateString?.components(separatedBy: "-")
        
        return (Weekday(dayChar: days![0]), Weekday(dayChar: days![1]))
    }
}


extension CGPoint {
    func distanceTo(point: CGPoint) -> Double {
        let xDist = self.x - point.x
        let yDist = self.y - point.y
        
        return Double(sqrt((xDist * xDist) + (yDist * yDist)))
    }
    
    func sizeOfBounds(point: CGPoint) -> CGSize {
        let xDist = self.x - point.x
        let yDist = self.y - point.y
        
        
        return CGSize(width: xDist, height: yDist)
    }
}

extension Model {
  

  
  
  
}
