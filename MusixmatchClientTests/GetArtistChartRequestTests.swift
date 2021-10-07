//
//  GetArtistChartRequestTests.swift
//  MusixmatchClientTests
//
//  Created by Jean Raphael Bordet on 29/09/21.
//

import XCTest
import RxBlocking

@testable import MusixmatchClient

class GetArtistChartRequestTests: XCTestCase {
	var urlSession: URLSession!
	
	override func setUpWithError() throws {
		let configuration = URLSessionConfiguration.ephemeral
		configuration.protocolClasses = [MockUrlProtocol.self]
		
		urlSession = URLSession(configuration: configuration)
	}
	
	override func tearDownWithError() throws {
	}
	
	func testMakeGetLyricsRequest() {
		let request = GetArtistChartRequest(
			page: 1,
			page_size: 3,
			country: "it",
			apikey: "1234"
		)
		
		XCTAssertEqual("https://api.musixmatch.com/ws/1.1/chart.artists.get?page=1&page_size=3&country=it&apikey=1234", request.request?.url?.absoluteString)
		XCTAssertEqual("GET", request.request?.httpMethod)
	}
	
	func testGetArtistChartRequestSuccess() throws {
		MockUrlProtocol.requestHandler = requestHandler(
			with: getArtistsResponse.data(using: .utf8)!
		)
		
		let request = GetArtistChartRequest(
			page: 1,
			page_size: 3,
			country: "it",
			apikey: "1234"
		)
		
		let result = try request
			.execute(with: urlSession)
			.toBlocking(timeout: 10)
			.toArray()
			.first
		
		let model = GetArtistChartModel(
			message: GetArtistChartModel.Message(
				body: GetArtistChartModel.Message.Body(
					artist_list: [
						GetArtistChartModel.Message.Body.Artists(
							artist: GetArtistChartModel.Message.Body.Artist(
								artist_id: 1039,
								artist_name: "Coldplay"
							)
						)
					]
				)
			)
		)

		XCTAssertEqual(result, model)
	}
	
	func testUserRequestDecodingError() throws {
		let response = """
		empty_response
		"""
		
		MockUrlProtocol.requestHandler = requestHandler(with: response.data(using: .utf8)!)
		
		let request = GetArtistChartRequest(
			page: 1,
			page_size: 3,
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

let getArtistsResponse =
	"""
{
	"message": {
		"header": {
			"status_code": 200,
			"execute_time": 0.013553857803345
		},
		"body": {
			"artist_list": [{
				"artist": {
					"artist_id": 1039,
					"artist_name": "Coldplay",
					"artist_name_translation_list": [{
						"artist_name_translation": {
							"language": "JA",
							"translation": ""
						}
					}],
					"artist_comment": "",
					"artist_country": "GB",
					"artist_alias_list": [{
						"artist_alias": ""
					}, {
						"artist_alias": "ku wan yue dui"
					}, {
						"artist_alias": "The Coldplay"
					}, {
						"artist_alias": "Cold Play"
					}],
					"artist_rating": 97,
					"artist_twitter_url": "",
					"artist_credits": {
						"artist_list": []
					},
					"restricted": 0,
					"updated_time": "2013-11-05T11:24:57Z",
					"begin_date_year": "1996",
					"begin_date": "1996-09-00",
					"end_date_year": "",
					"end_date": "0000-00-00"
				}
			}]
		}
	}
}
"""


