import Foundation
import Vapor
import PostgreSQL

typealias DayRange = (Weekday, Weekday)


final class Parking: Model {
    var id: Node?
    var exists: Bool = false
    
    var hoursBegin: Int!
    var hoursEnd: Int!
    var hourLimit: Int!
    var originalId: Int!
    var dayRange: DayRange!
    var rppRegion: [RPPArea]?
    var ruleLine: [CGPoint]!
    var boundingBox: CGRect!
    
    init(hoursBegin: Int, hoursEnd: Int, hourLimit: Int, originalId: Int, dayRange: DayRange, rppRegion: [RPPArea], ruleLine: [CGPoint]) {
        self.hoursBegin = hoursBegin
        self.hoursEnd = hoursEnd
        self.hourLimit = hourLimit
        self.originalId = originalId
        self.dayRange = dayRange
        self.rppRegion = rppRegion
        self.ruleLine = ruleLine
        
        self.boundingBox = transformGeom(ruleLine: self.ruleLine)
    }

    
    init(node: Node, in context: Context) throws {
        if let context = context as? Dictionary<String, String>, let from = context["from"], from == "JSON" {
            self.hoursBegin = try node.extract("hours_begin")
            self.hoursEnd = try node.extract("hours_end")
            self.hourLimit = try node.extract("hour_limit")
            self.originalId = try node.extract("object_id")
            
            let geomNode: Node = try node.extract("geom")
            print(geomNode)
            
            self.ruleLine = [CGPoint]()
            
            for item in (geomNode["coordinates"]?.array!)! {
                ruleLine.append(CGPoint(x: (item.array?[0].double)!, y: (item.array?[1].double)!))
            }
            
            self.boundingBox = try transformGeom(node: geomNode)
            
            self.id = try node.extract("id")
            self.rppRegion = try transformRPP(node: node)
            self.dayRange = try transformDayRange(node: node)
        }else{
            self.hoursBegin = try node.extract("hours_begin")
            self.hoursEnd = try node.extract("hours_end")
            self.hourLimit = try node.extract("hour_limit")
            self.originalId = try node.extract("object_id")
            
            let geomNode: Node = try node.extract("geom")
            
            self.boundingBox = try transformGeom(node: geomNode)
            
            self.id = try node.extract("id")
            self.rppRegion = try transformRPP(node: node)
            self.dayRange = try transformDayRange(node: node)
        }
    }

    func makeNode(context: Context) throws -> Node {
        return try Node(node: [
            "id": self.id,
            "hours_begin": self.hoursBegin,
            "hours_end": self.hoursEnd,
            "hour_limit": self.hourLimit,
            "object_id": self.originalId,
            "day_range": self.dayRange.0.dayChar + "-" + self.dayRange.1.dayChar,
            "rpp_region": Node.array(self.rppRegion!.map{Node.string($0.areaChar)}),
            "bounding_box": PostgreSQL.OID.box
        ])
    }
  

    static func prepare(_ database: Vapor.Database) throws {
        try database.create("parking", closure: { user in
            user.id()
            user.int("hours_begin")
            user.int("hours_end")
            user.int("hour_limit")
            user.int("original_id")
            user.string("day_range")
            user.custom("rpp_region", type: "VARCHAR(255)[]")
            user.custom("bounding_box", type: "box")
            user.custom("rule_line", type: "line")
        })
    }
    
    static func revert(_ database: Vapor.Database) throws {
        try database.delete("parking")
    }
    
    private func transformGeom(node: Node) throws -> CGRect {
        let type: String = (node["type"]?.string!)!
        
        switch type {
        case "LineString":
            let pointAArray: [Double] = try node.extract("coordinates").array[0]
            let poingBArray: [Double] = try node.extract("coordinates").array[1]
            
            let pointA = CGPoint(x: pointAArray[0], y: pointAArray[1])
            let pointB = CGPoint(x: poingBArray[0], y: poingBArray[1])
            
            return CGRect(origin: pointA, size: pointA.sizeOfBounds(point: pointB))
        default:
            return CGRect(x: 0, y: 0, width: 100, height: 100)
        }
    }
    
    private func transformGeom(ruleLine: [CGPoint]) -> CGRect {
        return CGRect(origin: ruleLine[0], size: ruleLine[0].sizeOfBounds(point: ruleLine[1]))
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
