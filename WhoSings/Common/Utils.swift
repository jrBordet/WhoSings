//
//  Utils.swift
//  WhoSings
//
//  Created by Jean Raphael Bordet on 01/10/21.
//

import Foundation

struct Lens<Whole, Part> {
	public let get: (Whole) -> Part
	public let set: (Part, Whole) -> Whole
	
	public init(
		get: @escaping(Whole) -> Part,
		set: @escaping(Part, Whole) -> Whole
	) {
		self.get = get
		self.set = set
	}
}

let trackLyricsLens = Lens<Track, String>(
	get: { whole in
		whole.lyrics
	},
	set: { lyrics, whole  in
		Track(
			id: whole.id,
			name: whole.name,
			playerId: whole.playerId,
			artistName: whole.artistName,
			lyrics: lyrics
		)
	}
)
