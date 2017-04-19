import Foundation
import Vapor
import VaporPostgreSQL

let drop = Droplet(preparations: [Parking.self])

try drop.addProvider(VaporPostgreSQL.Provider.self)

let resp = try drop.client.get("https://data.sfgov.org/resource/2ehv-6arf.json", headers: ["X-App-Token": "kvtD98auzsy6uHJqGIpB7u1tq"], query: [:], body: "")

let j = resp.json

print(resp.json?[0]! as Any)
var park = try Parking(node:(resp.json?[0])!, in: ["from" : "JSON"])

print(try park.makeNode(context: ["":""]))
print()
print(try Parking.all().makeNode(context: ["to":"JSON"]))


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
//    let resp = try drop.client.get("https://data.sfgov.org/resource/2ehv-6arf.json", headers: ["X-App-Token": "kvtD98auzsy6uHJqGIpB7u1tq"], query: [:], body: "")
//    
//    let j = resp.json
//    
//    
//    for park in (resp.json?.array)! {
//        let newParking = try Parking(node:(resp.json?[0])!)
//        
//    }
   
    

    
    var acronym = Acronym(short: "AFK", long: "Away From Keyboard")
    try acronym.save()
    return try JSON(node: Acronym.query().all().makeNode())
}

drop.resource("posts", PostController())
drop.resource("parking", ParkingController())

drop.run()
