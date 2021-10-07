//
//  TopSongsRequestTests.swift
//  MusixmatchClientTests
//
//  Created by Jean Raphael Bordet on 29/09/21.
//

import XCTest
import RxBlocking

@testable import MusixmatchClient

class TopSongsRequestTests: XCTestCase {
	var urlSession: URLSession!
	
	override func setUpWithError() throws {
		let configuration = URLSessionConfiguration.ephemeral
		configuration.protocolClasses = [MockUrlProtocol.self]
		
		urlSession = URLSession(configuration: configuration)
	}
	
	override func tearDownWithError() throws {
	}
	
	func testMakeTopSongsRequest() {
		let request = TopSongsRequest(
			page: 1,
			page_size: 10,
			country: "it",
			apikey: "1234"
		)
		
		XCTAssertEqual("https://api.musixmatch.com/ws/1.1/chart.tracks.get?chart_name=top&page=1&page_size=10&country=it&f_has_lyrics=1&apikey=1234", request.request?.url?.absoluteString)
		XCTAssertEqual("GET", request.request?.httpMethod)
	}
	
	func testTopSongsRequestSuccess() throws {
		MockUrlProtocol.requestHandler = requestHandler(
			with: topSongsResponse.data(using: .utf8)!
		)
		
		let request = TopSongsRequest(
			page: 1,
			page_size: 10,
			country: "it",
			apikey: "1234"
		)
		
		let result = try request
			.execute(with: urlSession)
			.toBlocking(timeout: 10)
			.toArray()
			.first
		
		let track = result
		
		XCTAssertEqual(
			track,
			TopSongsModel(
				message: TopSongsModel.Message(
					body: TopSongsModel.Message.Body(
						track_list: [
							TopSongsModel.Message.Body.Tracks(
								track: TopSongsModel.Message.Body.Tracks.Track(
									track_id: 221037202,
									track_name: "Cold Heart - PNAU Remix",
									artist_id: 50410132,
									artist_name: "Elton John feat. Dua Lipa & PNAU"
								)
							)
						])
				)
			)
		)
		
		XCTAssertFalse(result?.message.body.track_list.isEmpty ?? true)
	}
	
	func testTopSongsRequestDecodingError() throws {
		let response = """
		empty_response
		"""
		
		MockUrlProtocol.requestHandler = requestHandler(with: response.data(using: .utf8)!)
		
		let request = TopSongsRequest(
			page: 1,
			page_size: 10,
			country: "it",
			apikey: "1234"
		)
		
		do {
			_ = try request
				.execute(with: urlSession)
				.toBlocking(timeout: 10)
				.toArray()
				.first
		} catch let error {
			XCTAssertEqual( APIError.decoding("The data couldn’t be read because it isn’t in the correct format."), error as? APIError)
		}
	}
}

let topSongsResponse =
	"""
{
  "message": {
	"header": {
	  "status_code": 200,
	  "execute_time": 0.035862922668457
	},
	"body": {
	  "track_list": [
		{
		  "track": {
			"track_id": 221037202,
			"track_name": "Cold Heart - PNAU Remix",
			"track_name_translation_list": [
			  
			],
			"track_rating": 100,
			"commontrack_id": 131326873,
			"instrumental": 0,
			"explicit": 0,
			"has_lyrics": 1,
			"has_subtitles": 1,
			"has_richsync": 1,
			"num_favourite": 126,
			"album_id": 46056969,
			"album_name": "Cold Heart (PNAU Remix)",
			"artist_id": 50410132,
			"artist_name": "Elton John feat. Dua Lipa & PNAU",
			"restricted": 0,
			"updated_time": "2021-09-24T14:15:14Z",
			"primary_genres": {
			  "music_genre_list": [
				{
				  "music_genre": {
					"music_genre_id": 34,
					"music_genre_parent_id": 0,
					"music_genre_name": "Music",
					"music_genre_name_extended": "Music",
					"music_genre_vanity": "Music"
				  }
				}
			  ]
			}
		  }
		}
	  ]
	}
  }
}
"""
