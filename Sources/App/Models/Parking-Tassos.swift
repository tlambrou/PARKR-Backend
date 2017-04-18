import Vapor
import VaporPostgreSQL
import FluentPostgreSQL
import Fluent
//import MapKit
//
//enum RPPArea: String {
//  case A = "A", B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q, R, S, T, U, V, W, X, Y, Z
//}

enum DOW: String {
  case mondayToFriday = "Mon-Fri"
  case mondayToSaturday = "Mon-Sat"
  case mondayToSunday = "Mon-Sun"
}

final class TassosRules: Model {
  var id: Node?
  var exists: Bool = false
  var TPHoursBegin: Int?
  var TPHoursEnd: Int?
  var TPHourLimit: Int?
  var TPOriginalId: Int?
  var TPDays: String?
  var TPDaysOfWeek: DOW?
  var hasTimedParking: Bool?
  //  var TPGeometry: [CLLocationCoordinate2D]?
  
  
  // Vars for bounding rectangle of all data in the block's geometries
  var rectLowerLongitude: Double?
  var rectUpperLongitude: Double?
  var rectLowerLatitude: Double?
  var rectUpperLatitude: Double?
  
  init(TPDaysOfWeek: DOW, TPHoursBegin: Int, TPHoursEnd: Int, TPHourLimit: Int, TPOriginalId: Int/*, TPGeometry: [CLLocationCoordinate2D]*/) {
    self.id = nil
    self.TPDays = TPDaysOfWeek.rawValue
    self.TPHoursBegin = TPHoursBegin
    self.TPHoursEnd = TPHoursEnd
    self.TPHourLimit = TPHourLimit
    self.TPOriginalId = TPOriginalId
    self.exists = true
    //    self.TPGeometry = TPGeometry
    if self.TPOriginalId != nil {
      self.hasTimedParking = true
    } else {
      self.hasTimedParking = false
      
      //Update the bounding rect values for all geometries with data on the block
      //    let line = MKPolyline(coordinates: TPGeometry, count: TPGeometry.count)
      //    let rect = line.boundingMapRect
      //    self.rectLowerLongitude = MKMapRectGetMinX(rect)
      //    self.rectUpperLongitude = MKMapRectGetMaxX(rect)
      //    self.rectLowerLatitude = MKMapRectGetMaxY(rect)
      //    self.rectUpperLatitude = MKMapRectGetMinY(rect)
    }
  }
  
    init(node: Node, in context: Context) throws {
      self.TPDays = try node.extract("TPDays")
      self.TPHoursBegin = try node.extract("TPHoursBegin")
      self.TPHoursEnd = try node.extract("TPHoursEnd")
      self.TPHourLimit = try node.extract("TPHourLimit")
      self.TPOriginalId = try node.extract("TPOriginalId")
      self.hasTimedParking = try node.extract("hasTimedParking")
      self.id = try node.extract("id")
      //    self.rectLowerLongitude = try node.extract("rectLowerLongitude")
      
    }
    
    func makeNode(context: Context) throws -> Node {
      return try Node(node: [
        "id": self.id,
        "TPDays": self.TPDays,
        "TPOriginalId": self.TPOriginalId,
        "TPHoursBegin": self.TPHoursBegin,
        "TPHoursEnd": self.TPHoursEnd,
        "TPHourLimit": self.TPHourLimit,
        //      "rectLowerLongitude": self.rectLowerLongitude
        ])
    }
    
    
    static func prepare(_ database: Database) throws {
      try database.create("parking", closure: { parking in
        parking.id()
        parking.string("TPDaysOfWeek")
        parking.int("TPHoursBegin")
        parking.int("TPHoursEnd")
        parking.int("TPHourLimit")
        parking.int("TPOriginalId", optional: true, unique: true, default: nil)
        //      parking.double("rectLowerLongitude")
      })
    }
    
    static func revert(_ database: Database) throws {
      try database.delete("parking")
    }
  }
  
  extension Model {
    
}
