//
//  GetLyricsRequestTests.swift
//  MusixmatchClientTests
//
//  Created by Jean Raphael Bordet on 29/09/21.
//

import XCTest
import RxBlocking

@testable import MusixmatchClient

class GetLyricsRequestTests: XCTestCase {
	var urlSession: URLSession!
	
	override func setUpWithError() throws {
		let configuration = URLSessionConfiguration.ephemeral
		configuration.protocolClasses = [MockUrlProtocol.self]
		
		urlSession = URLSession(configuration: configuration)
	}
	
	override func tearDownWithError() throws {
	}
	
	func testMakeGetLyricsRequest() {
		let request = GetLyricsRequest(
			track_id: 221037202,
			apikey: "1234"
		)
		
		XCTAssertEqual("https://api.musixmatch.com/ws/1.1/track.lyrics.get?track_id=221037202&apikey=1234", request.request?.url?.absoluteString)
		XCTAssertEqual("GET", request.request?.httpMethod)
	}
	
	func testTopSongsRequestSuccess() throws {
		MockUrlProtocol.requestHandler = requestHandler(
			with: getLyricsResponse.data(using: .utf8)!
		)
		
		let request = GetLyricsRequest(
			track_id: 221037202,
			apikey: "1234"
		)
		
		let result = try request
			.execute(with: urlSession)
			.toBlocking(timeout: 10)
			.toArray()
			.first
		
		let model = GetLyricsModel(
			message: GetLyricsModel.Message(
				body: GetLyricsModel.Message.Body(
					lyrics: GetLyricsModel.Message.Body.Lyric(
						lyrics_id: 26231663,
						lyrics_body: "lyrics_body"
					)
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
		
		let request = GetLyricsRequest(
			track_id: 221037202,
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

let getLyricsResponse =
	"""
{
"message": {
	   "header": {
		   "status_code": 200,
		   "execute_time": 0.10298109054565
	   },
	   "body": {
		   "lyrics": {
			   "lyrics_id": 26231663,
			   "explicit": 0,
			   "lyrics_body": "lyrics_body",
			   "lyrics_copyright": "lyrics_body",
			   "updated_time": "2021-08-13T10:25:47Z"
		   }
	   }
   }
}
"""

