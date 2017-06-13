//
//  Weekday.swift
//  parkr-api
//
//  Created by fnord on 4/13/17.
//
//

//This is an int becuase it will make checking if we are before, after, or inbetween two days easier
public enum Weekday: Int {
    case Monday = 0, Tuesday, Wednesday, Thursday, Friday, Saturday, Sunday
    
    init(dayChar: String) {
        switch dayChar {
        case "M":
            self = .Monday
        case "Tu":
            self = .Tuesday
        case "W":
            self = .Wednesday
        case "Th":
            self = .Thursday
        case "F":
            self = .Friday
        case "Sa":
            self = .Saturday
        case "Su":
            self = .Sunday
        case "S": //government software is literally the worst
            self = .Saturday
        default:
            self = .Monday
        }
    }
    
    var dayChar: String {
        switch self {
        case .Monday:
            return "M"
        case .Tuesday:
            return "Tu"
        case .Wednesday:
            return "W"
        case .Thursday:
            return "Th"
        case .Friday:
            return "F"
        case .Saturday:
            return "Sa"
        case .Sunday:
            return "Su"
        }
    }
}
