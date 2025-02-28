//
//  Utility.swift
//  MapIntegration1
//
//  Created by Nishant Chauhan on 28/02/25.
//

import Foundation

final class Utility{
    
    class func getTileUrl() ->URL{
        return URL(string: "https://api.olamaps.io/tiles/vector/v1/styles/default-light-standard/style.json")!
    }
    class func getApiKey() -> String{
        return "3a49c1b1-c5fa-4754-b4ea-51ca77758dcc"
    }
    
    class func getProjectId() -> String{
        return "axLfy5EnHjCgtT6mayvqNUJsPemSbNdSr6LvMaGK"
    }
    
}
