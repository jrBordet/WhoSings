//
//  GetArtistChart.swift
//  MusixmatchClient
//
//  Created by Jean Raphael Bordet on 29/09/21.
//

import Foundation

public struct GetArtistChartRequest: APIRequest, CustomDebugStringConvertible {
	public var debugDescription: String {
		request.debugDescription
	}
	
	public typealias Response = GetArtistChartModel
	
	public var endpoint: String = "chart.artists.get"
	
	private (set) var baseUrl: String
	
	private (set) var page: Int
	private (set) var page_size: Int
	private (set) var country: String
	
	private (set) var apikey: String
	
	public var request: URLRequest? {
		guard let url = URL(string: "\(baseUrl)/\(endpoint)?page=\(page)&page_size=\(page_size)&country=\(country)&apikey=\(apikey)") else {
			return nil
		}
		
		var request = URLRequest(url: url)
		request.httpMethod = "GET"
		
		return request
	}
	
	public init(
		baseUrl: String = "https://api.musixmatch.com/ws/1.1",
		page: Int = 1,
		page_size: Int = 10,
		country: String = "it",
		apikey: String
	) {
		self.baseUrl = baseUrl
		
		self.page = page
		self.page_size = page_size
		self.country = country
		
		self.apikey = apikey
	}
}

public struct GetArtistChartModel: Codable, Equatable {
	public let message: Message
	
	public struct Message: Codable, Equatable {
		public let body: Body
		
		public struct Body: Codable, Equatable {
			public let artist_list: [Artists]
			
			public struct Artists: Codable, Equatable {
				public let artist: Artist
			}
			
			public struct Artist: Codable, Equatable {
				public let artist_id: Int
				public let artist_name: String
			}
		}
	}
}
