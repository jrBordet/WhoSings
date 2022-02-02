//
//  Bootstrap.swift
//  WhoSings
//
//  Created by Jean Raphael Bordet on 01/10/21.
//

import Foundation
import RxComposableArchitecture
import RxSwift
import RxCocoa

struct GameBootstrapState: Equatable {
	var tracks: [Track]
	var isLoading: Bool
	
	var tracksCount: Int
	
	var artists: [Artist]
	
	var bootstrapCompleted: Bool
	
	// error
	var genericError: GenericErrorState?
}

extension GameBootstrapState {
	static var empty = Self(
		tracks: [],
		isLoading: false,
		tracksCount: 0,
		artists: [],
		bootstrapCompleted: false,
		genericError: nil
	)
}

enum GameBootstrapAction: Equatable {
	/// Download from the API Top 10 songs tracks and a bunch of artists
	case bootstrap
	
	/// For every tracks download one lyrics and feel the original track
	/// wiht the result
	case getTracksResponse(Result<[Track], GenericError>), getLyricsResponse(Result<Track, GenericError>)
	
	case getArtistsResponse(Result<[Artist], GenericError>)
}

struct GameBootstrapEnvironment {
	var getTopSongs: () -> Effect<Result<[Track], GenericError>>
	var getLyrics: (Track) -> Effect<Result<Track, GenericError>>
	var getArtists: () -> Effect<Result<[Artist], GenericError>>
}

extension GameBootstrapEnvironment {
	static func mock(
		getTopSongs: @escaping() -> Effect<Result<[Track], GenericError>> = { fatalError("not mocked") },
		getLyrics: @escaping(Track) -> Effect<Result<Track, GenericError>> = { _ in fatalError("not mocked") },
		getArtists: @escaping() -> Effect<Result<[Artist], GenericError>> = { fatalError("not mocked") }
	) -> Self {
		.init(
			getTopSongs: getTopSongs,
			getLyrics: getLyrics,
			getArtists: getArtists
		)
	}
}

// MARK: - Feature business logic

let gameBoostrapReducer = Reducer<
	GameBootstrapState,
	GameBootstrapAction,
	GameBootstrapEnvironment
> { state, action, environment in
	switch action {
	
	case .bootstrap:
		state.isLoading = true
		
		return [
			environment
				.getTopSongs()
				.map(GameBootstrapAction.getTracksResponse),
			environment
				.getArtists()
				.map(GameBootstrapAction.getArtistsResponse)
		]
		
	case let .getTracksResponse(.success(tracks)):
		state.tracksCount = tracks.count
		
		return tracks.map { track in
			environment
				.getLyrics(track)
				.map(GameBootstrapAction.getLyricsResponse)
		}
		
	case let .getLyricsResponse(.success(track)):
		state.tracks.append(track)
		
		state.isLoading = (state.tracksCount == state.tracks.count) == false
		
		state.bootstrapCompleted = state.tracksCount == state.tracks.count
		
		return []
		
	case let .getArtistsResponse(.success(artists)):
		state.artists = artists
		
		return []
		
	case
		.getTracksResponse(.failure(let error)),
		.getLyricsResponse(.failure(let error)),
		.getArtistsResponse(.failure(let error)):
				
		state.genericError = GenericErrorState(
			title: error.title,
			message: error.message,
			isDismissed: false
		)
		
		return []
		
	}
	
}
