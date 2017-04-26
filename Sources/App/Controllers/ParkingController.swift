import Vapor
import HTTP
import VaporPostgreSQL

final class ParkingController {
    
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
        
        guard let x1 = request.data["ULat"]?.float,         // TOP LEFT
        let y1 = request.data["ULong"]?.float,              // TOP LEFT
        let x2 = request.data["LLat"]?.float,               // BOTTOM RIGHT
        let y2 = request.data["LLong"]?.float else {        // BOTTOM RIGHT
            throw Abort.badRequest
        }
        
        let x3 = x1 + (x2 - x1) // TOP RIGHT
        let y3 = y1             // TOP RIGHT
        let x4 = x1             // BOTTOM LEFT
        let y4 = y1 + (y2 - y1) // BOTTOM LEFT
        
        if let mysql = drop.database?.driver as? PostgreSQLDriver {
            let parkings = try mysql
                .raw("SELECT * FROM parkings WHERE ((bounding_x1 BETWEEN \(x1) AND \(x2)) AND (bounding_y1 BETWEEN \(y1) AND \(y2))) OR ((bounding_x2 BETWEEN \(x1) AND \(x2)) AND (bounding_y2 BETWEEN \(y1) AND \(y2))) OR (((bounding_x1 + (bounding_x2 - bounding_x1)) BETWEEN \(x1) AND \(x2)) AND (bounding_y1 BETWEEN \(y1) AND \(y2))) OR ((bounding_x1 BETWEEN \(x1) AND \(x2)) AND ((bounding_y1 - (bounding_y2 - bounding_y1)) BETWEEN \(y1) AND \(y2)))")
            print("Break Point")
        }
        
//        let parkings = try Parking
//            .query()
//            .makeQuery()
//            .or { orGroup in
//                // MARK: Bounding Boxes within Frame
//                
//                // Checking if TOP LEFT corner is within Frame
//                try orGroup.and { andGroup in
//                    try andGroup.filter("bounding_x1", .greaterThanOrEquals, x1)
//                    try andGroup.filter("bounding_x1", .lessThanOrEquals, x2)
//                    try andGroup.filter("bounding_y1", .greaterThanOrEquals, y1)
//                    try andGroup.filter("bounding_y1", .lessThanOrEquals, y2)
//                }
//                
//                // Checking if BOTTOM RIGHT corner is within Frame
//                try orGroup.and { andGroup in
//                    try andGroup.filter("bounding_x2", .greaterThanOrEquals, x1)
//                    try andGroup.filter("bounding_x2", .lessThanOrEquals, x2)
//                    try andGroup.filter("bounding_y2", .greaterThanOrEquals, y1)
//                    try andGroup.filter("bounding_y2", .lessThanOrEquals, y2)
//                }
//            }
//            .all()
        
        
        
//        select *
//        from parkings
//        where
//        bounding_x1 > ulat and bounding_x1 < llat AND bounding_y1 > ulong and bounding_y1 < llong
//        OR
//        bounding_x2 > ulat and bounding_x2 < llat AND bounding_y2 > ulong and bounding_y2 < llong
//        OR
//        calc_bounding_x3 > ulat and calc_bounding_x3 < llat AND calc_bounding_y3 > ulong and calc_bounding_y3 < llong
//        OR
//        calc_bounding_x4 > ulat and calc_bounding_x4 < llat AND calc_bounding_y4 > ulong and calc_bounding_y4 < llong
//        
//        select *
//        from parkings
//        where
//        ulat > bounding_x1 and llat < bounding_x1 AND ulong > bounding_y1 and llong < bounding_y1
//        ulat > bounding_x2 and llat < bounding_x2 AND ulong > bounding_y2 and llong < bounding_y2
//        ulat > calc_bounding_x3 and ulat < llat AND calc_bounding_y3 > ulong and calc_bounding_y3 < llong
//        calc_bounding_x4 > ulat and calc_bounding_x4 < llat AND calc_bounding_y4 > ulong and calc_bounding_y4 < llong
        
//        return parkings as! ResponseRepresentable
        return "Hello"
    }
    
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
    
    func create(request: Request) throws -> ResponseRepresentable {
        var parking = try request.parking()
        try parking.save()
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
    
    //  TODO: Make a get method route that takes in bounding rectangle coordinates and returns JSON data of all data that intersects with that view.
}

extension Request {
    func parking() throws -> Parking {
        guard let json = json else { throw Abort.badRequest }
        return try Parking(node: json)
    }
}
