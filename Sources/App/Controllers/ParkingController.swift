import Vapor
import HTTP
import VaporPostgreSQL

final class ParkingController {
    
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
    func parkingSubset(request: Request) throws -> ResponseRepresentable {
        guard let ulatleft = request.parameters["ULat"]?.float, // x1
            let ulongleft = request.parameters["ULong"]?.float, // y1
            let llatright = request.parameters["LLat"]?.float, // x2
            let llongright = request.parameters["LLong"]?.float else { // y2
                throw Abort.badRequest
        }
        
        let ulatright = ulatleft + (llatright - ulatleft)
        let ulongright = ulongleft
        let llatleft = ulatleft
        let llongleft = ulongleft + (llongright - ulongleft)
        
        //        let parkings = try Parking.query().filter("bounding_x1", .greaterThanOrEquals, ulatleft)
        //        .filter("bounding_x2", .lessThanOrEquals, )
        
        var parkings: [Node]
        
        if let mysql = drop.database?.driver as? PostgreSQLDriver {
            let parkings = try mysql.raw("SELECT * FROM parkings WHERE (bounding_x1 BETWEEN \(ulatleft) AND \(llatright)) AND (bounding_y1 BETWEEN \(ulongleft) AND \(llongright))").nodeArray
            
            //        select *
            //        from parkings
            //        where
            //        bounding_x1 > ulat and bounding_x1 < llat AND bounding_y1 > ulong and bounding_y1 < llong
            //        bounding_x2 > ulat and bounding_x2 < llat AND bounding_y2 > ulong and bounding_y2 < llong
            //        calc_bounding_x3 > ulat and calc_bounding_x3 < llat AND calc_bounding_y3 > ulong and calc_bounding_y3 < llong
            //        calc_bounding_x4 > ulat and calc_bounding_x4 < llat AND calc_bounding_y4 > ulong and calc_bounding_y4 < llong
            //
            //        select *
            //        from parkings
            //        where
            //        ulat > bounding_x1 and llat < bounding_x1 AND ulong > bounding_y1 and llong < bounding_y1
            //        ulat > bounding_x2 and llat < bounding_x2 AND ulong > bounding_y2 and llong < bounding_y2
            //        ulat > calc_bounding_x3 and ulat < llat AND calc_bounding_y3 > ulong and calc_bounding_y3 < llong
            //        calc_bounding_x4 > ulat and calc_bounding_x4 < llat AND calc_bounding_y4 > ulong and calc_bounding_y4 < llong
            
            return parkings as! ResponseRepresentable
        }
        
        return "hello"
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
