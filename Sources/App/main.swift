import Foundation
import Vapor
import VaporPostgreSQL
import PostgreSQL

let drop = Droplet()

try drop.addProvider(VaporPostgreSQL.Provider.self)
drop.preparations.append(Parking.self)

drop.group("v1") { v1 in
    v1.group("parking") { parking in
        var parkingController = ParkingController()
        
        parking.get("subset", handler: parkingController.parkingSubset)
        parking.get("ingest", handler: parkingController.ingestion)
    }
}

drop.run()
