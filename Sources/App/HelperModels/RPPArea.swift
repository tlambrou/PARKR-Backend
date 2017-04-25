//
//  RPPArea.swift
//  parkr-api
//
//  Created by fnord on 4/13/17.
//
//

//May need to add AA-ZZ later.
//TODO: Add real world descriptions of RPP. Rules surrounding them. Etc
//String because it'll be easy to add to the DB and there isn't any need to compare, though these are still comparable

public enum RPPArea: String {
    case A = "A", B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q, R, S, T, U, V, W, X, Y, Z, AA = "AA", BB = "BB", CC = "CC", DD = "DD", EE = "EE", FF = "FF", GG = "GG", HH = "HH", II = "II", JJ = "JJ", KK = "KK", LL = "LL", MM = "MM", NN = "NN", OO = "OO", PP = "PP", QQ = "QQ", RR = "RR", SS = "SS", TT = "TT", UU = "UU", VV = "VV", WW = "WW", XX = "XX", YY = "YY", ZZ = "ZZ"
    
    init(areaChar: String) {
        self = RPPArea(rawValue: areaChar)!
    }
    
    var areaChar: String {
        return self.rawValue
    }
}
