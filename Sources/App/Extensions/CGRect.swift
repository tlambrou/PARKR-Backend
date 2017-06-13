//
//  CGRect.swift
//  parkr-api
//
//  Created by fnord on 5/13/17.
//
//

import Foundation

public extension CGRect {
    var minX: CGFloat {
        return self.origin.x
    }
    
    var minY: CGFloat {
        return self.origin.y
    }
    
    var maxX: CGFloat {
        return self.origin.x + self.size.width
    }
    
    var maxY: CGFloat {
        return self.origin.y + self.size.height
    }
}
