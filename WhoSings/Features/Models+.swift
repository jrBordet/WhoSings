//
//  Models+.swift
//  WhoSings
//
//  Created by Jean Raphael Bordet on 01/10/21.
//

import Foundation

struct GenericError: Error, Equatable {
	var title: String
	var message: String
	var isDismissed: Bool
}

struct Track: Equatable {
	let id: Int
	let name: String
	let playerId: Int
	let artistName: String
	let lyrics: String
}

extension Track {
	static func mock(
		id: Int = 1,
		name: String = "sunshine",
		playerId: Int = 1,
		artistName: String = "bob",
		lyrics: String = ""
	) -> Self {
		.init(
			id: id,
			name: name,
			playerId: playerId,
			artistName: artistName,
			lyrics: lyrics
		)
	}
}

struct Artist: Equatable {
	let id: Int
	let name: String
}

extension Artist {
	static func mock(
		id: Int = 1,
		name: String = "bob"
	) -> Self {
		.init(
			id: id,
			name: name
		)
	}
}
