import Vapor
import HTTP
import VaporPostgreSQL

final class ParkingController {
    
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
        
        guard let ulatleft = request.parameters["ULat"]?.float, // x1
        let ulong = request.parameters["ULong"]?.float, // y1
        let llat = request.parameters["LLat"]?.float, // x2
        let llong = request.parameters["LLong"]?.float else { // y2
            throw Abort.badRequest
        }
        
        let parkings = try Parking.query()
        
        select *
        from parkings
        where
        bounding_x1 > ulat and bounding_x1 < llat AND bounding_y1 > ulong and bounding_y1 < llong
        bounding_x2 > ulat and bounding_x2 < llat AND bounding_y2 > ulong and bounding_y2 < llong
        calc_bounding_x3 > ulat and calc_bounding_x3 < llat AND calc_bounding_y3 > ulong and calc_bounding_y3 < llong
        calc_bounding_x4 > ulat and calc_bounding_x4 < llat AND calc_bounding_y4 > ulong and calc_bounding_y4 < llong
        
        select *
        from parkings
        where
        ulat > bounding_x1 and llat < bounding_x1 AND ulong > bounding_y1 and llong < bounding_y1
        ulat > bounding_x2 and llat < bounding_x2 AND ulong > bounding_y2 and llong < bounding_y2
        ulat > calc_bounding_x3 and ulat < llat AND calc_bounding_y3 > ulong and calc_bounding_y3 < llong
        calc_bounding_x4 > ulat and calc_bounding_x4 < llat AND calc_bounding_y4 > ulong and calc_bounding_y4 < llong
        
        return "stuff"
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
    
    //  TODO: Make a get method route that takes in bounding rectangle coordinates and returns JSON data of all data that intersects with that view.
}

extension Request {
    func parking() throws -> Parking {
        guard let json = json else { throw Abort.badRequest }
        return try Parking(node: json)
    }
}
