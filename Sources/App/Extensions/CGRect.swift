//
//  CGRect.swift
//  parkr-api
//
//  Created by fnord on 5/13/17.
//
//

import Foundation

public extension CGRect {
    var minX: Double {
        return self.origin.x.native
    }
    
    var minY: Double {
        return self.origin.y.native
    }
    
    var maxX: Double {
        return self.origin.x.native + self.size.width.native
    }
    
    var maxY: Double {
        return self.origin.y.native + self.size.height.native
    }
}
