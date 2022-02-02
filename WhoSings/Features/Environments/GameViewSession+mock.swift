//
//  GameViewSession+mock.swift
//  WhoSingsMock
//
//  Created by Jean Raphael Bordet on 02/10/21.
//

import Foundation
import RxComposableArchitecture
import RxSwift
import RxCocoa

extension GameViewEnvironment {
	static var mock = Self(
		bootstrap: .mock,
		game: .init(),
		login: .mock(
			login: { username in
				Effect.just(Result<String, GenericError>.success(username))
					.delay(.milliseconds(280), scheduler: MainScheduler.instance)
			}
		)
	)
	
	static var mockEmptyArtists = Self(
		bootstrap: .mockEmptyArtists,
		game: .init(),
		login: .mock
	)
	
	static var error = Self(
		bootstrap: .error,
		game: .init(),
		login: .mock
	)
}
