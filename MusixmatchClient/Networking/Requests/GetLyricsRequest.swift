//
//  GetLyricsRequest.swift
//  MusixmatchClient
//
//  Created by Jean Raphael Bordet on 29/09/21.
//

import Foundation

public struct GetLyricsRequest: APIRequest, CustomDebugStringConvertible {
	public var debugDescription: String {
		request.debugDescription
	}
	
	public typealias Response = GetLyricsModel
	
	public var endpoint: String = "track.lyrics.get"
	
	public var trackId: Int {
		track_id
	}
	
	private (set) var baseUrl: String
	
	private (set) var track_id: Int
	
	private (set) var apikey: String
	
	public var request: URLRequest? {
		guard let url = URL(string: "\(baseUrl)/\(endpoint)?track_id=\(track_id)&apikey=\(apikey)") else {
			return nil
		}
		
		var request = URLRequest(url: url)
		request.httpMethod = "GET"
		
		return request
	}
	
	public init(
		baseUrl: String = "https://api.musixmatch.com/ws/1.1",
		track_id: Int,
		apikey: String
	) {
		self.baseUrl = baseUrl
		
		self.track_id = track_id
		
		self.apikey = apikey
	}
}

public struct GetLyricsModel: Codable, Equatable {
	public let message: Message
	
	public struct Message: Codable, Equatable {
		public let body: Body
		
		public struct Body: Codable, Equatable {
			public let lyrics: Lyric
			
			public struct Lyric: Codable, Equatable {
				public let lyrics_id: Int
				public let lyrics_body: String
			}
		}
	}
}
