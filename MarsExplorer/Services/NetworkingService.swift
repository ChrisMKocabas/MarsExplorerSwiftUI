////
////  NetworkingService.swift
////  MarsPhotoExplorer
////
////  Created by Muhammed Kocabas on 2023-02-04.
////
//
//import Foundation
//
////struct Constants {
////    static let API_KEY = "hUM97gPW2TL8pkFJ3GLrVVcWZouB4fgfooQcIy9N"
////    static let baseURL = "https://api.nasa.gov/mars-photos/api/v1/rovers"
////}
//
//protocol NetworkingDelegate {
//    func networkingDidFinishWithError()
//    func networkingDidFinishWithResult(allCities: [String])
//}
//
//
//class NetworkingService {
//
//    var delegate: NetworkingDelegate?
//    static var shared = NetworkingService()
//    
//    // var urlString = "http://gd.geobytes.com/AutoCompleteCity?&q="
//
//
//
//
//    func loadData(rover : String = "curiosity",date: String = "2015-06-03", completionHandler: @escaping (Result<Data,Error>)->Void) async {
//        print(rover)
//       guard let urlObj = URL(string: "\(Constants.baseURL)/\(rover)/photos?api_key=\(Constants.API_KEY)&earth_date=\(date)")
//        else {return}
//
//
//        let task = URLSession.shared.dataTask(with: URLRequest(url:urlObj)) { data, response, error in
//
//                if let error = error {
//                    completionHandler(.failure(error))
//                }
//                else {
//                    completionHandler(.success(data!))
//                }
//            }
//
//        task.resume()
//        }
//
//    func loadImage(url:String, completionHandler: @escaping(Result<Data,Error>) -> Void) async {
//
//        guard let imageURL = URL(string: url) else { return}
//
//        let task = URLSession.shared.dataTask(with: imageURL) { data, response, error in
//
//                if let error = error {
//                    completionHandler(.failure(error))
//                }else {
//                    completionHandler(.success(data!))
//                }
//
//        }
//
//        task.resume()
//
//    }
//
//}
