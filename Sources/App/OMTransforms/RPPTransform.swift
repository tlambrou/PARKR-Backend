//
//  RPPTransform.swift
//  parkr-api
//
//  Created by fnord on 4/14/17.
//
//

import Foundation
import ObjectMapper

public class RPPTransform: TransformType {
    public typealias Object = [RPPArea]
    public typealias JSON = String
    
    public func transformFromJSON(_ value: Any?) -> Object? {
        if let vMap = value as? Map {
            var rppArray = [RPPArea]()
            
            if let rppArea1 = vMap["rpp_area_1"].currentValue as? String {
                rppArray.append(RPPArea(areaChar: rppArea1))
            }
            
            if let rppArea2 = vMap["rpp_area_2"].currentValue as? String {
                rppArray.append(RPPArea(areaChar: rppArea2))
            }
            
            if let rppArea3 = vMap["rpp_area_3"].currentValue as? String {
                rppArray.append(RPPArea(areaChar: rppArea3))
            }
            
            return rppArray
        }else{
            print("map didn't work out in RPPTransform")
            return nil
        }
    }
    
    public func transformToJSON(_ value: Object?) -> JSON? {
        var retString = ""
        
        for rpp in value! {
            retString.append(rpp.areaChar)
        }
        
        return retString
    }
}
