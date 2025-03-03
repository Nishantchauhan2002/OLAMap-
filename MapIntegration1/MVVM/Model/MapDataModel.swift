//
//  MapDataModel.swift
//  MapIntegration1
//
//  Created by Nishant Chauhan on 03/03/25.
//

import Foundation

import Foundation

// MARK: - Root Response Model
struct MapDataModel: Codable {
    let status: String
    let geocodedWaypoints: [GeocodedWaypoint]
    let routes: [Route]
    let sourceFrom: String
    let languageCode: String
    
    enum CodingKeys: String, CodingKey {
        case status
        case geocodedWaypoints = "geocoded_waypoints"
        case routes
        case sourceFrom = "source_from"
        case languageCode = "language_code"
    }
}

// MARK: - Geocoded Waypoint
struct GeocodedWaypoint: Codable {
    let geocoderStatus: String
    let placeID: String
    let types: [String]
    
    enum CodingKeys: String, CodingKey {
        case geocoderStatus = "geocoder_status"
        case placeID = "place_id"
        case types
    }
}

// MARK: - Route
struct Route: Codable {
    let summary: String
    let legs: [Leg]
    let overviewPolyline: String
    let travelAdvisory: String
    let bounds: [String: String]?
    let copyrights: String
    let warnings: [String]
    
    enum CodingKeys: String, CodingKey {
        case summary, legs
        case overviewPolyline = "overview_polyline"
        case travelAdvisory = "travel_advisory"
        case bounds, copyrights, warnings
    }
}

// MARK: - Leg
struct Leg: Codable {
    let distance: Int
    let readableDistance: String
    let duration: Int
    let readableDuration: String
    let startLocation: Coordinate
    let endLocation: Coordinate
    let startAddress: String
    let endAddress: String
    
    enum CodingKeys: String, CodingKey {
        case distance
        case readableDistance = "readable_distance"
        case duration
        case readableDuration = "readable_duration"
        case startLocation = "start_location"
        case endLocation = "end_location"
        case startAddress = "start_address"
        case endAddress = "end_address"
    }
}

// MARK: - Coordinate
struct Coordinate: Codable {
    let lat: Double
    let lng: Double
}
