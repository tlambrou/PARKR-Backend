import Vapor
import HTTP
import VaporPostgreSQL

final class ParkingController: ResourceRepresentable {
  
  func index(request: Request) throws -> ResourceRepresentable {
    return try JSON(node: ParkingRule.all().makeNode())
  }
  
  func makeResource() -> Resource<ParkingRule> {
    return Resource(
      index: index
    )
  }
  
}

extension Request {
  func parking(<#parameters#>) -> <#return type#> {
    <#function body#>
  }
}
