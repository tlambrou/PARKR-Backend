import Foundation
import Vapor
import VaporPostgreSQL
import Alamofire
import ObjectMapper
import GeoSwift
import MapKit

let drop = Droplet(preparations: [Acronym.self, ParkingRule.self])

try drop.addProvider(VaporPostgreSQL.Provider.self)

//Alamofire.request("https://data.sfgov.org/resource/2ehv-6arf.json", method: .get, parameters: [:], encoding: URLEncoding.default, headers: ["X-App-Token": "kvtD98auzsy6uHJqGIpB7u1tq"]).responseJSON(completionHandler: { (jsondata) in
//    print("Anything")
//    
//    let json = JSON(jsondata.result.value as! Node)
//    
//    print(json)
//})

let resp = try drop.client.get("https://data.sfgov.org/resource/2ehv-6arf.json", headers: ["X-App-Token": "kvtD98auzsy6uHJqGIpB7u1tq"], query: [:], body: "")

let j = resp.json

print((resp.json?[0])!)

if let geoJSONURL = Bundle.main.url(forResource: "TimedParkingData", withExtension: "geojson"),
    let geometries = try! Geometry.fromGeoJSON(geoJSONURL),
    let italy = geometries[0] as? MultiPolygon {
    
}

drop.get("hello") { request in
    
    
    
    return "Hello, world!"
}

drop.get("version") { request in
    if let db = drop.database?.driver as? PostgreSQLDriver {
        let version = try db.raw("SELECT version()")
        return try JSON(node: version)
    }else{
        return "No db connection"
    }
}

drop.get("model") { request in
    let acronym = Acronym(short: "AFK", long: "Away From Keyboard")
    
    return try acronym.makeJSON()
}

drop.get("test") { request in
    var acronym = Acronym(short: "AFK", long: "Away From Keyboard")
    try acronym.save()
    return try JSON(node: Acronym.query().all().makeNode())
}

drop.resource("posts", PostController())

drop.run()
