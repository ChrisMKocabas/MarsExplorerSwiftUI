//
//  PhotoObject.swift
//  MarsPhotoExplorer
//
//  Created by Muhammed Kocabas on 2023-02-04.
//

import Foundation
import SwiftUI

class PhotosResponse:ObservableObject,Codable {
    enum CodingKeys: CodingKey {
        case photos
    }
    @Published var photos: [Photo] = []
    
    init(){ }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        photos = try container.decode([Photo].self, forKey: .photos)

    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(photos, forKey: .photos)
    }
}

struct Photo:Identifiable,Codable {
    var id : Int
    var sol : Int
    var camera : Camera
    var img_src : String
    var earth_date : String
    var rover : Rover
}


struct Camera:Identifiable,Codable {
    var id : Int
    var name : String
    var rover_id : Int
    var full_name : String
}

struct Rover:Identifiable,Codable {
    var id : Int
    var name : String
    var landing_date : String
    var launch_date : String
    var status : String
}
