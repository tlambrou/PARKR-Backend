import Vapor
import HTTP
import VaporPostgreSQL

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
    var parking = parking
    parking.hourLimit = new.hourLimit
    parking.hoursBegin = new.hoursBegin
    parking.hoursEnd = new.hoursEnd
    parking.originalId = new.originalId
    
    return parking
  }
  
  func makeResource() -> Resource<Parking> {
    return Resource(
      index: index
    )
  }
  
}

extension Request {
  func parking() throws -> Parking {
    guard let json = json else { throw Abort.badRequest }
    return try Parking(node: json)
  }
}
