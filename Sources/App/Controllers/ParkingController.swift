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
    parking.TPDaysOfWeek = new.TPDaysOfWeek
    parking.TPHourLimit = new.TPHourLimit
    parking.TPHoursBegin = new.TPHoursBegin
    parking.TPHoursEnd = new.TPHoursEnd
    parking.TPOriginalId = new.TPOriginalId
    
    return parking
  }
  
  func delete(request: Request, parking: Parking) throws -> ResponseRepresentable {
    try parking.delete()
    return JSON([:])
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
