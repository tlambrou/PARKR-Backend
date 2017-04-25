import Vapor
import HTTP
import VaporPostgreSQL
import CoreData


final class ParkingController: ResourceRepresentable {
    
    func parkingSubset(request: Request) throws -> ResponseRepresentable {
        /*
         API call for getting all blocks intersecting with the view's bounding rectangle.
         http://parkr-api.herokuapp.com/parking/subset?ULat=37.766952&ULong=-122.412581&LLat=37.765095&LLong=-122.413949
         
         Base URL: http://parkr-api.herokuapp.com/parking/subset
         
         Parameters
         ULat: Represents upper left latitude coordinate of current bounding box
         ULong: Represents upper left longitude coordinate of current bounding box
         LLat: Represents lower right latitude coordinate of current bounding box
         LLong: Represents lower right longitude coordinate of current bounding box
         */
        
        let resp = try drop.client.get("https://data.sfgov.org/resource/2ehv-6arf.json", headers: ["X-App-Token": "kvtD98auzsy6uHJqGIpB7u1tq"], query: [:], body: "")
        
        var park = try Parking(node:(resp.json?[0])!, in: ["from" : "JSON"])
        
        do {
            try park.save()
        } catch {
            print(error.localizedDescription)
            print(error)
        }
        
        
        return try Parking.all().makeJSON()
    }
    
    func test(request: Request) throws -> ResponseRepresentable {
        let resp = try drop.client.get("https://data.sfgov.org/resource/2ehv-6arf.json", headers: ["X-App-Token": "kvtD98auzsy6uHJqGIpB7u1tq"], query: [:], body: "")
        
        var park = try Parking(node:(resp.json?[0])!, in: ["from" : "JSON"])
        
        do {
            try park.save()
        } catch {
            print(error.localizedDescription)
            print(error)
        }
        
        
        return try Parking.all().makeJSON()
    }
}
