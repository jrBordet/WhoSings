//
//  Parser.swift
//  WhoSings
//
//  Created by Jean Raphael Bordet on 02/10/21.
//

import Foundation
import  MusixmatchClient

extension Track {
	static func map(with topSongs: TopSongsModel) -> [Self] {
		topSongs
			.message
			.body
			.track_list
			.map {
				Track(
					id: $0.track.track_id,
					name: $0.track.track_name,
					playerId: $0.track.artist_id,
					artistName: $0.track.artist_name,
					lyrics: ""
				)
			}
	}
}

extension String {
	static func map(with lyrics: GetLyricsModel) -> Self {
		let l = lyrics
			.message
			.body
			.lyrics
			.lyrics_body
			.split(separator: "\n")
		
		return String(l.first ?? "")
	}
}

extension Artist {
	static func map(with artists: GetArtistChartModel) -> [Self] {
		artists
			.message
			.body
			.artist_list
			.map { (model: GetArtistChartModel.Message.Body.Artists) -> Artist in
				Artist(
					id: model.artist.artist_id,
					name: model.artist.artist_name
				)
			}
	}
}
