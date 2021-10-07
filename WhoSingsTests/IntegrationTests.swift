//
//  IntegrationTests.swift
//  WhoSingsTests
//
//  Created by Jean Raphael Bordet on 05/10/21.
//

import XCTest
@testable import WhoSings
@testable import MusixmatchClient

class IntegrationTests: XCTestCase {
	let topSongModel =
		TopSongsModel(
			message: TopSongsModel.Message(
				body: TopSongsModel.Message.Body(
					track_list: [
						TopSongsModel.Message.Body.Tracks(
							track: TopSongsModel.Message.Body.Tracks.Track(
								track_id: 42, track_name: "awesome song", artist_id: 11, artist_name: "bobby")
						)
					]
				)
			)
		)
	
	func testTopSongs() {
		let result = Track.map(with: topSongModel)
		let track = Track(id: 42, name: "awesome song", playerId: 11, artistName: "bobby", lyrics: "")
		
		XCTAssertEqual(result, [track])
	}
	
	func testLyrics() {
		let lyricsModel = GetLyricsModel(
			message: GetLyricsModel.Message(
				body: GetLyricsModel.Message.Body(
					lyrics: GetLyricsModel.Message.Body.Lyric(
						lyrics_id: 1,
						lyrics_body: "single line of lyrycs\n ends before"
					)
				)
			)
		)
		
		let result = String.map(with: lyricsModel)
		
		XCTAssertEqual(result, "single line of lyrycs")
	}
	
	
	func testArtist() {
		let artistModel = GetArtistChartModel(
			message: GetArtistChartModel.Message(
				body: GetArtistChartModel.Message.Body(
					artist_list: [.init(artist: .init(artist_id: 1, artist_name: "bobby solo"))]
				)
			)
		)
		
		let expectedResult: Artist = .init(id: 1, name: "bobby solo")
		let result = Artist.map(with: artistModel).first!
		
		XCTAssertEqual(result, expectedResult)
	}
}
