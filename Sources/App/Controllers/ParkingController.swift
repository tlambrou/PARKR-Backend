import Vapor
import HTTP
import VaporPostgreSQL

final class ParkingController: ResourceRepresentable {
    
    
    func parkingSubset(request: Request) throws -> ResponseRepresentable {
        return "hello world"
    }
    
    /*
     Exists to ingest data from the dataset we're dealing with and transform it into a format that's usable in our DB
     Once in the DB, we're free to query for a square of data that would intersect the viewfinder on the ios app, and turn things into objects which would allow us to do analysis.
     This will eventually be used to ingest multiple data sets and normalize the data.
     */
    func ingestion(request: Request) throws -> ResponseRepresentable {
        let resp = try drop.client.get("https://data.sfgov.org/resource/2ehv-6arf.json", headers: ["X-App-Token": "kvtD98auzsy6uHJqGIpB7u1tq"], query: [:], body: "").json!
        
        for i in 0...resp.array!.count {
            do {
                var newPark = try Parking(node: resp[i], in: ["from" : "JSON"])
                
                do {
                    try newPark.save()
                } catch {
                    print(error.localizedDescription)
                    print(error)
                }
            } catch {
                print(error)
            }
        }
        return try Parking.all().makeJSON()
    }
    
    func makeResource() -> Resource<Parking> {
        return Resource()
    }
}
