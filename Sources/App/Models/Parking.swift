import Foundation
import Vapor
import PostgreSQL

typealias DayRange = (Weekday, Weekday)


final class Parking: Model {
    var id: Node?
    var exists: Bool = false
    
    var hoursBegin: Int!
    var hoursEnd: Int!
    var hourLimit: Double!
    var originalId: Int!
    var dayRange: DayRange!
    var rppRegion: [RPPArea]?
    var ruleLine: [CGPoint]!
    var boundingBox: CGRect!
    
    init(hoursBegin: Int, hoursEnd: Int, hourLimit: Double, originalId: Int, dayRange: DayRange, rppRegion: [RPPArea], ruleLine: [CGPoint]) {
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
            let regulationType: String? = try node.extract("regulation")
            if regulationType == "RPP" {
                self.id = try node.extract("id")
                self.hoursBegin = try node.extract("hours_begin")
                self.hoursEnd = try node.extract("hours_end")
                self.hourLimit = try node.extract("hour_limit")
                self.originalId = try node.extract("object_id")
                
                let geomNode: Node = try node.extract("geom")
                
                self.ruleLine = [CGPoint]()
                
                for item in (geomNode["coordinates"]?.array!)! {
                    ruleLine.append(CGPoint(x: (item.array?[0].double)!, y: (item.array?[1].double)!))
                }
                
                self.boundingBox = try transformGeom(node: geomNode)
                
                self.rppRegion = try transformRPP(node: node)
                self.dayRange = try transformDayRange(node: node)
            }else{
                throw RuleIngestionError.notRPP
            }
        }else{
            self.id = try node.extract("id")
            self.hoursBegin = try node.extract("hours_begin")
            self.hoursEnd = try node.extract("hours_end")
            self.hourLimit = try node.extract("hour_limit")
            self.originalId = try node.extract("object_id")
            
            guard let x1: Double = try node.extract("bounding_x1") else {return}
            guard let y1: Double = try node.extract("bounding_y1") else {return}
            guard let x2: Double = try node.extract("bounding_x2") else {return}
            guard let y2: Double = try node.extract("bounding_y2") else {return}
            
            let (pointA, pointB) = (CGPoint(x: x1, y: y1), CGPoint(x: x2, y: y2))
            
            self.boundingBox = CGRect(origin: pointA, size: pointA.sizeOfBounds(point: pointB))
            
            let rppString: String = try node.extract("rpp_region")
            
            let rppChars: [String] = (rppString).components(separatedBy: ",")
            
            
            self.rppRegion = rppChars.map{RPPArea(areaChar: $0)}
            
            let dayRangeString: String = try node.extract("day_range")
            let dayRangeChars = dayRangeString.components(separatedBy: "-")
            self.dayRange = (Weekday(dayChar: dayRangeChars[0]), Weekday(dayChar: dayRangeChars[1]))
            
            let ruleLineString: String = try node.extract("rule_line")
            self.ruleLine = ruleLineString.components(separatedBy: "/").map{CGPoint(x: Double($0.components(separatedBy: ",")[0])!, y: Double($0.components(separatedBy: ",")[1])!)}
        }
    }

    func makeNode(context: Context) throws -> Node {
        let rppChars = self.rppRegion!.map{$0.areaChar}
        
        let ruleLineString = self.ruleLine.map{[$0.x.native, $0.y.native]}
        
        if type(of: context) == JSONContext.self {
            let dayRangeList = [self.dayRange.0.dayChar, self.dayRange.1.dayChar]
           
            let pointArray = try self.ruleLine.map{try [$0.x.native, $0.y.native].makeNode()}
            let pointArrayNode = try pointArray.makeNode()
            
            return try Node(node: [
                "hours_begin": self.hoursBegin,
                "hours_end": self.hoursEnd,
                "hour_limit": self.hourLimit,
                "day_range": dayRangeList.makeNode(),
                "rule_line": pointArrayNode
            ])
        }else{
            return try Node(node: [
                "id": self.id,
                "hours_begin": self.hoursBegin,
                "hours_end": self.hoursEnd,
                "hour_limit": self.hourLimit,
                "original_id": self.originalId,
                "day_range": self.dayRange.0.dayChar + "-" + self.dayRange.1.dayChar,
                
                "rpp_region": rppChars.joined(separator: ","),
                "bounding_x1": boundingBox.minX.native,
                "bounding_y1": boundingBox.minY.native,
                "bounding_x2": boundingBox.maxX.native,
                "bounding_y2": boundingBox.maxY.native,
                "rule_line": ruleLineString.map{$0.map{String($0)}.joined(separator: ",")}.joined(separator: "/") //lol k
            ])
        }
    }
  

    static func prepare(_ database: Vapor.Database) throws {
        try database.create("parkings", closure: { user in
            user.id()
            user.int("hours_begin")
            user.int("hours_end")
            user.double("hour_limit")
            user.int("original_id")
            user.string("day_range")
            user.string("rpp_region") // I'm so sorry about this
            user.double("bounding_x1")
            user.double("bounding_y1")
            user.double("bounding_x2")
            user.double("bounding_y2")
            user.custom("rule_line", type: "TEXT")
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
            let points: [[Double]] = try node.extract("coordinates").array
            let xs: [Double] = points.map{$0[0]}
            let ys: [Double] = points.map{$0[1]}
            
            let pointA = CGPoint(x: xs.max()!, y: ys.max()!)
            let pointB = CGPoint(x: xs.min()!, y: ys.min()!)
            
            return CGRect(origin: pointA, size: pointA.sizeOfBounds(point: pointB))
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
