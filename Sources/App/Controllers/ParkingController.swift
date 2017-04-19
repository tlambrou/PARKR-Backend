import Vapor
import HTTP
import VaporPostgreSQL
import CoreData


final class ParkingController: ResourceRepresentable {
  
  func index(request: Request) throws -> ResponseRepresentable {
    return try JSON(node: Parking.all().makeNode())
  }
  
  func create(request: Request) throws -> ResponseRepresentable {
    var parking = try request.parking()
    try parking.save()
    return parking
  }
  
  func show(request: Request, parking: Parking) throws -> ResponseRepresentable {
    return parking
  }
  
  func update(request: Request, parking: Parking) throws -> ResponseRepresentable {
    let new = try request.parking()
    let parking = parking
    
    parking.dayRange = new.dayRange
    parking.hourLimit = new.hourLimit
    parking.hoursBegin = new.hoursBegin
    parking.hoursEnd = new.hoursEnd
    return parking
  }
  
  func delete(request: Request, parking: Parking) throws -> ResponseRepresentable {
    try parking.delete()
    return JSON([:])
  }
  
  func dataImport(request: Request, parking: Parking) throws -> ResponseRepresentable {
    let file = "/Data/SampleTimedParking.json"
    let fileComponents = file.components(separatedBy: ".")
    let path = Bundle.main.path(forResource: fileComponents[0], ofType: fileComponents[1])
    let text = try! String(contentsOfFile: path!) // read as string
    
    guard let json = try! JSONSerialization.jsonObject(with: text.data(using: .utf8)!, options: []) as? [String: Any] else {
        throw JSONError.self as! Error
    }
   
    let allData = json["features"]
   
    let allTimedParkingData = try allData.map({ (entry) -> Context in
      return try parking.makeNode(context: entry as! Context)
    })
    return allTimedParkingData as! ResponseRepresentable
  }
  
  func makeResource() -> Resource<Parking> {
    return Resource(
      index: index,
      store: create,
      show: show,
      modify: update,
      destroy: delete
    )
  }
  
//  TODO: Make a get method route that takes in bounding rectangle coordinates and returns JSON data of all data that intersects with that view.
  
  
  
}

extension Request {
  func parking() throws -> Parking {
    guard let json = json else { throw Abort.badRequest }
    return try Parking(node: json)
  }
}
