import Routing
import Vapor
import Fluent

/// Register your application's routes here.
///
/// [Learn More →](https://docs.vapor.codes/3.0/getting-started/structure/#routesswift)
final class Routes: RouteCollection {
    /// Use this to create any services you may
    /// need for your routes.
    let app: Application
    /// Create a new Routes collection with
    /// the supplied application.
    init(app: Application) {
        self.app = app
    }

    /// See RouteCollection.boot
    func boot(router: Router) throws {
        let apiGroup = router.grouped("api")
        let versionOneGroup = apiGroup.grouped("v1")
        versionOneGroup.get("hello") { req in
            return Future("Hello, World!")
        }
        versionOneGroup.get("users", Int.parameter, Int.parameter) { req -> Future<String> in
            let id = try req.parameter(Int.self)
            let otherid = try req.parameter(Int.self)
            return Future("user \(id), \(otherid)")
        }
        
        versionOneGroup.get("park") { req in
            return req.withConnection(to: .sqlite, closure: { db -> Future<Parking> in
                let parking = Parking(hoursBegin: 2, hoursEnd: 5, hourLimit: 1)
                return parking.save(on: db).map(to: Parking.self) {parking}
            })
        }
        
        versionOneGroup.get("getAllPark") { (req) in
            return req.withConnection(to: .sqlite, closure: { (db) in
                return db.query(Parking.self).all()
            })
        }
        
        versionOneGroup.get("getFirstPark") { (req) in
            return req.withConnection(to: .sqlite, closure: { (db) in
                return db.query(Parking.self).first().map(to: Parking.self) {
                    guard let park = $0 else {
                        throw Abort(.notFound, reason: "Could not find parking.")
                    }
                    
                    return park
                }
            })
        }
        
        
        versionOneGroup.get("deletePark") { (req) -> Future<Parking> in
            return req.withConnection(to: .sqlite, closure: { (db) in
                 return db.query(Parking.self).first().map(to: Parking.self) {
                    guard let park = $0 else {
                        throw Abort(.notFound, reason: "Could not find parking.")
                    }
                    
                    return park
                }.flatMap(to: Parking.self, { (park) in
                    return park.delete(on: db).map(to: Parking.self) {park}
                })
            })
        }
    }
}
