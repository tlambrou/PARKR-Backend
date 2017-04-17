//
//  GeoTransform.swift
//  parkr-api
//
//  Created by fnord on 4/17/17.
//
//

import Foundation
import ObjectMapper

public class GeoTransform: TransformType {
    public typealias Object = CGRect
    public typealias JSON = String
    
    public func transformFromJSON(_ value: Any?) -> Object? {
        return CGRect(x: 0, y: 0, width: 100, height: 100)
    }
    
    public func transformToJSON(_ value: Object?) -> JSON? {
        return "hello"
    }
}
