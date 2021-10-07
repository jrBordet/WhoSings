//
//  TopSongsRequest.swift
//  MusixmatchClient
//
//  Created by Jean Raphael Bordet on 29/09/21.
//

import Foundation

/// Example:
/// [Url ecample](https://api.musixmatch.com/ws/1.1/chart.tracks.get?chart_name=top&page=1&page_size=10&country=it&f_has_lyrics=1&apikey=9876987546

public struct TopSongsRequest: APIRequest, CustomDebugStringConvertible {
	public var debugDescription: String {
		request.debugDescription
	}
	
	public typealias Response = TopSongsModel
	
	public var endpoint: String = "chart.tracks.get"
	
	private (set) var baseUrl: String
	
	private (set) var page: Int
	private (set) var page_size: Int
	private (set) var country: String
	
	private (set) var apikey: String
	
	public var request: URLRequest? {
		guard let url = URL(string: "\(baseUrl)/\(endpoint)?chart_name=top&page=\(page)&page_size=\(page_size)&country=\(country)&f_has_lyrics=1&apikey=\(apikey)") else {
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

public struct TopSongsModel: Codable, Equatable {
	public let message: Message
	
	public struct Message: Codable, Equatable {
		public let body: Body
		
		public struct Body: Codable, Equatable {
			public let track_list: [Tracks]
			
			public struct Tracks: Codable, Equatable {
				public let track: Track
				
				public struct Track: Codable, Equatable {
					public let track_id: Int
					public let track_name: String
					public let artist_id: Int
					public let artist_name: String
				}
			}
		}
	}
}
