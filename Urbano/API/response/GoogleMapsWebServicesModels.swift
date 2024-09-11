//
//  GoogleModels.swift
//  Urbano
//
//  Created by Mick VE on 7/05/18.
//  Copyright © 2018 Urbano. All rights reserved.
//

import Foundation

struct GoogleMapsWebServices {
    struct Directions {
        struct Request {
            var origin: String
            var destination: String
        }
        
        struct Response: Decodable {
            var routes: [Routes]
            var status: String
            
            struct Routes: Decodable {
                var bounds: Bounds
                var legs: [Legs]
                var overview_polyline: OverviewPolyline
                
                struct Bounds: Decodable {
                    var northeast: Northeast
                    var southwest: Southwest
                    
                    struct Northeast: Decodable {
                        var lat: Double
                        var lng: Double
                    }
                    
                    struct Southwest: Decodable {
                        var lat: Double
                        var lng: Double
                    }
                }
                
                struct Legs: Decodable {
                    var distance: Distance
                    var duration: Duration
                    
                    struct Distance: Decodable {
                        var text: String
                        var value: Int
                    }
                    
                    struct Duration: Decodable {
                        var text: String
                        var value: Int
                    }
                }
                
                struct OverviewPolyline: Decodable {
                    var points: String
                }
            }
        }
    }
}

typealias GoogleDirectionsRequest = GoogleMapsWebServices.Directions.Request
typealias GoogleDirectionsResponse = GoogleMapsWebServices.Directions.Response
