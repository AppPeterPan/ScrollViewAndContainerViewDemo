//
//  ItunesService.swift
//  Demo
//
//  Created by SHIH-YING PAN on 2020/8/24.
//  Copyright © 2020 SHIH-YING PAN. All rights reserved.
//

import Foundation

class ItunesService {
    static let shared = ItunesService()
    let baseURL = URL(string: "https://rss.itunes.apple.com/api/v1/tw/")
    
    private func processData<T: Decodable>(data: Data?, response: URLResponse?, error: Error?, dataType: T.Type) -> Result<T, ItunesError>  {
        
        if let error = error {
            return .failure(.requestFailed(error))
        }
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            return .failure(.invalidResponse)
        }
        
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        
        guard let data = data, let decodeData = try? decoder.decode(dataType, from: data)  else {
            return .failure(.invalidData)
        }
        return .success(decodeData)
    }
    
    func getTopMovies(completion: @escaping (Result<[ItunesFeed.Result], ItunesError>) -> Void ) {
        
        guard let url = baseURL?.appendingPathComponent("movies/top-movies/all/20/explicit.json") else {
            completion(.failure(.invalidUrl))
            return
        }
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            
            let result = self.processData(data: data, response: response, error: error, dataType: ItunesFeed.self)
            switch result {
            case .success(let data):
                completion(.success(data.feed.results))
            case .failure(let error):
                completion(.failure(error))
            }
            
        }.resume()
    }
    
    func getTopSongs(completion: @escaping (Result<[ItunesFeed.Result], ItunesError>) -> Void ) {
        
        guard let url = baseURL?.appendingPathComponent("apple-music/top-songs/all/20/explicit.json") else {
            completion(.failure(.invalidUrl))
            return
        }
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            
            let result = self.processData(data: data, response: response, error: error, dataType: ItunesFeed.self)
            switch result {
            case .success(let data):
                completion(.success(data.feed.results))
            case .failure(let error):
                completion(.failure(error))
            }
            
        }.resume()
    }
    
}
