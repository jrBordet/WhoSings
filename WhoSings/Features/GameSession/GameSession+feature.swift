//
//  GameSession+feature.swift
//  WhoSings
//
//  Created by Jean Raphael Bordet on 30/09/21.
//

import Foundation
import RxComposableArchitecture
import RxSwift
import RxCocoa

struct QuizCard: Equatable {
	var track: Track
	var artists: [Artist]
}

struct GameState: Equatable {
	var tracks: [Track]
	var artists: [Artist]
	
	var quizCard: [QuizCard]
	var currentIndex: Int
	var points: Int
	var playerSelection: Int // artistId inferred from the user selection
	
	var currentQuizCard: QuizCard?
	var gameSessionCompleted: Bool
	var isPlaying: Bool
}

extension GameState {
	static var empty = Self(
		tracks: [],
		artists: [],
		quizCard: [],
		currentIndex: 0,
		points: 0,
		playerSelection: 0,
		gameSessionCompleted: false,
		isPlaying: false
	)
}

enum GameAction: Equatable {
	/// Start the game creating quiz cards
	///
	/// - Parameter param: shuffle. `true` : shuffle the players inside tre track `false`: for UnitTests
	case start(Bool)
	case select(Int)
	
	/// Select the artist identifier.
	/// Is the user artist choice.
	///
	/// - Parameter param: id
	case selectId(Int)
	case next
	
	case reset
}

struct GameEnvironment {
}

extension GameEnvironment {
	static func mock() -> Self {
		.init()
	}
}

// MARK: - Feature business logic

let gameReducer = Reducer<
	GameState,
	GameAction,
	GameEnvironment
> { state, action, environment in
	switch action {
	case let .start(shuffle):
		
		state.gameSessionCompleted = false
		state.points = 0
		state.currentIndex = 0
		state.isPlaying = true
		
		state.quizCard = state
			.tracks
			.map { track -> QuizCard in
				let artists: [Artist]

				if shuffle {
					artists = state
						.artists
						.filter { $0.id != track.playerId }
						.shuffled()
				} else {
					artists = state
						.artists
						.filter { $0.id != track.playerId }
				}
				
				let artistTrack = Artist(
					id: track.playerId,
					name: track.artistName
				)
				
				return QuizCard(
					track: track,
					artists: [
						artistTrack,
						artists.first ?? .mock(id: 1, name: "ted"),
						artists.last ?? .mock(id: 2, name: "alex")
					]
				)
			}
		
		state.currentQuizCard = state.quizCard.first
		
		return []
		
	case let .select(index):
		guard let currentQuizCard = state.currentQuizCard else {
			return []
		}
		
		state.playerSelection = currentQuizCard.artists[index].id
		
		return []
		
	case .next:
		guard let currentQuizCard = state.currentQuizCard else {
			return []
		}
		
		// Update the current QuizCard with the next one
		state.currentIndex = state.currentIndex + 1
		
		// Game Session completed
		if state.currentIndex == state.quizCard.count {
			state.quizCard = []
			state.currentQuizCard = nil
			state.currentIndex = 0
			state.gameSessionCompleted = true
			state.isPlaying = false
		} else {
			state.currentQuizCard = state.quizCard[state.currentIndex]
		}
		
		// Check the artist selection by Id
		guard let artist = currentQuizCard.artists.filter({ $0.id == state.playerSelection }).first else {
			state.playerSelection = 0
			return []
		}
		
		// Update players points
		if artist.id == currentQuizCard.track.playerId {
			state.points = state.points + 10
		}
		
		state.playerSelection = 0
		
		return []
		
	case let .selectId(artistId):
		guard
			let currentQuizCard = state.currentQuizCard,
			let artist = currentQuizCard.artists.filter({ $0.id == artistId }).first else {
			return []
		}
		
		state.playerSelection = artistId
		
		return []
		
	case .reset:
		state.gameSessionCompleted = false
		state.isPlaying = false
				
		return []
		
	}
}
