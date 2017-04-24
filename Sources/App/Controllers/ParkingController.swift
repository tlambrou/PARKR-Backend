import Vapor
import HTTP
import VaporPostgreSQL
import CoreData


final class ParkingController: ResourceRepresentable {
    
    func parkingSubset(request: Request) throws -> ResponseRepresentable {
        /*
         API call for getting all blocks intersecting with the view's bounding rectangle.
         http://parkr-api.herokuapp.com/parking/subset?ULat= 37.766952&ULong=-122.412581&LLat=37.765095&LLong=-122.413949
         
         Base URL: http://parkr-api.herokuapp.com/parking/subset
         
         Parameters
         ULat: Represents upper left latitude coordinate of current bounding box
         ULong: Represents upper left longitude coordinate of current bounding box
         LLat: Represents lower right latitude coordinate of current bounding box
         LLong: Represents lower right longitude coordinate of current bounding box
         */
        
        let resp = try drop.client.get("https://data.sfgov.org/resource/2ehv-6arf.json", headers: ["X-App-Token": "kvtD98auzsy6uHJqGIpB7u1tq"], query: [:], body: "")
        
        let j = resp.json
        
        var park = try Parking(node:(resp.json?[0])!, in: ["from" : "JSON"])
        
        do {
            try park.save()
        } catch {
            print(error.localizedDescription)
            print(error)
        }
        
        print(try park.makeNode(context: ["":""]))
        print()
        let parkings = try Parking.all()
        print()
        
        
        return "Hello, world!"
    }
    
    
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
