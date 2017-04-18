//
//  WeekdayRangeTransform.swift
//  parkr-api
//
//  Created by fnord on 4/13/17.
//
//
import Foundation
import ObjectMapper

public class WeekdayRangeTransform: TransformType {
    public typealias Object = (Weekday, Weekday)
    public typealias JSON = String
   
    public func transformFromJSON(_ value: Any?) -> Object? {
        let dateString = value as! String
        
        let days = dateString.components(separatedBy: "-")
        
        return (Weekday(dayChar: days[0]), Weekday(dayChar: days[1]))
    }
    
    public func transformToJSON(_ value: Object?) -> JSON? {
        if let value = value {
            return value.0.dayChar + "-" + value.1.dayChar
        }
        
        return nil
    }
}
