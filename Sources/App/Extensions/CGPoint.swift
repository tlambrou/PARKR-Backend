import CoreGraphics

public extension CGPoint {
    func distanceTo(point: CGPoint) -> Double {
        let xDist = self.x - point.x
        let yDist = self.y - point.y
        
        return Double(sqrt((xDist * xDist) + (yDist * yDist)))
    }
    
    func sizeOfBounds(point: CGPoint) -> CGSize {
        let xDist = self.x - point.x
        let yDist = self.y - point.y
        
        
        return CGSize(width: xDist, height: yDist)
    }
}

