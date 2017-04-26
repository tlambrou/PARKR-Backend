import Foundation
import Vapor
import VaporPostgreSQL
import PostgreSQL

let drop = Droplet(
    preparations: [Parking.self],
)

try drop.addProvider(VaporPostgreSQL.Provider.self)
drop.add

drop.group("api") { api in
    api.group("v1") { v1 in
        v1.group("parking") { parking in
            var parkingController = ParkingController()
            
            parking.get("subset", handler: parkingController.parkingSubset)
            //        parking.get("park", handler: parkingController.park)
            //parking.get("ingest", handler: parkingController.)
        }
    }
}

drop.run()
