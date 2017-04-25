import Foundation
import Vapor
import VaporPostgreSQL
import PostgreSQL

let drop = Droplet(
    preparations: [Parking.self],
    providers: [VaporPostgreSQL.Provider.self]
)

drop.group("api") { api in
    api.group("v1") { v1 in
        v1.group("parking") { parking in
            var parkingController = ParkingController()
            
            parking.get("subset", handler: parkingController.parkingSubset)
            //        parking.get("park", handler: parkingController.park)
        }
    }
}

drop.run()
