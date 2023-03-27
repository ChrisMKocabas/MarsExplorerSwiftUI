//
//  APIManager.swift
//  MarsExplorer
//
//  Created by Muhammed Kocabas on 2023-02-23.
//

import Foundation
import SwiftUI

class APIManager: ObservableObject {
    
    struct Constants {
        static let API_KEY = "hUM97gPW2TL8pkFJ3GLrVVcWZouB4fgfooQcIy9N"
        static let baseURL = "https://api.nasa.gov/mars-photos/api/v1/rovers"
    }
    

    @Published var photosResponse = PhotosResponse()
    @Published var roverList = ["spirit", "curiosity", "opportunity"]
    @Published var selectedRover: String = "curiosity"
    @Published var selectedDate: Date = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
    
    
    func fetchPhotos() async throws {
        let formattedDate =  formatDate(selectedDate)
        let url = URL(string: "\(Constants.baseURL)/\(selectedRover)/photos?api_key=\(Constants.API_KEY)&earth_date=\(formattedDate)")!
        print(url)
        let (data, _) = try await URLSession.shared.data(from: url)
        let response = try JSONDecoder().decode(PhotosResponse.self, from: data)
        DispatchQueue.main.async {
            self.photosResponse = response
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
}
