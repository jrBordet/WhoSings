//
//  Environments+mock.swift
//  WhoSingsMock
//
//  Created by Jean Raphael Bordet on 02/10/21.
//

import Foundation
import RxComposableArchitecture
import  MusixmatchClient
import RxSwift
import RxCocoa

let mockedError = GenericError(title: "GetTopSongs", message: "generic error", isDismissed: false)

extension GameBootstrapEnvironment {
	static var error = Self.mock(
		getTopSongs: { .just(.failure(mockedError)) },
		getLyrics: { _ in fatalError("") },
		getArtists: {  .just(.failure(mockedError)) }
	)
}

extension GameBootstrapEnvironment {
	static var mock = Self (
		getTopSongs: { () -> Effect<Result<[Track], GenericError>> in			
			.just(
				Result<[Track], GenericError>
					.success(
						Track.map(
							with: TopSongsRequest.mock(
								data(from: "top_songs_request", type: "json")!
							)
						)
					)
			)
		},
		getLyrics: { track -> Effect<Result<Track, GenericError>> in
			Observable<String>
				.just("\(track.artistName) lyrics line 🤪")
				.map { trackLyricsLens.set($0, track) }
				.map {  Result<Track, GenericError>.success($0) }
		},
		getArtists: {
			let mock = GetArtistChartRequest.mock(data(from: "artists_request", type: ".json")!)
			
			let artists = Artist.map(with: mock)
			
			return .just(Result<[Artist], GenericError>.success(artists))
		}
	)
	
	static var mockEmptyArtists = Self (
		getTopSongs: { () -> Effect<Result<[Track], GenericError>> in
			.just(
				Result<[Track], GenericError>
					.success(
						Track.map(
							with: TopSongsRequest.mock(
								data(from: "top_songs_request", type: "json")!
							)
						)
					)
			)
		},
		getLyrics: { track -> Effect<Result<Track, GenericError>> in
			Observable<String>
				.just("\(track.artistName) lyrics line 🤪")
				.map { trackLyricsLens.set($0, track) }
				.map {  Result<Track, GenericError>.success($0) }
		},
		getArtists: {
			.just(Result<[Artist], GenericError>.success([]))
		}
	)
	
}
