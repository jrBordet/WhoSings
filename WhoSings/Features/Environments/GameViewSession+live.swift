//
//  GameViewSession+live.swift
//  WhoSings
//
//  Created by Jean Raphael Bordet on 02/10/21.
//

import Foundation

extension GameViewEnvironment {
	static var live = Self(
		bootstrap: .live,
		game: .init(),
		login: .init()
	)
}
