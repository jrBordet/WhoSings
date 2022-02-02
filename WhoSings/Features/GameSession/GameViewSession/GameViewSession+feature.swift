//
//  GameViewSession.swift
//  WhoSings
//
//  Created by Jean Raphael Bordet on 01/10/21.
//

import Foundation
import RxComposableArchitecture
import RxSwift
import RxCocoa
import SwiftPrettyPrint

struct GameViewState: Equatable {
	// Bootstrap
	var artists: [Artist]
	var tracks: [Track]
	
	var isLoading: Bool
	var tracksCount: Int
	
	var bootstrapCompleted: Bool
	
	// Game session
	var quizCard: [QuizCard]
	var currentIndex: Int
	var points: Int
	var currentQuizCard: QuizCard?
	var playerSelection: Int
	var gameSessionCompleted: Bool
	var isPlaying: Bool
	
	// Login
	var username: String
	var loggedIn: Bool
	
	// User Sessions
	var sessions: [UserSession]
	
	// error
	var genericError: GenericErrorState?
}

extension GameViewState {
	static var empty = Self(
		artists: [],
		tracks: [],
		isLoading: false,
		tracksCount: 0,
		bootstrapCompleted: false,
		quizCard: [],
		currentIndex: 0,
		points: 0,
		currentQuizCard: nil,
		playerSelection: 0,
		gameSessionCompleted: false,
		isPlaying: false,
		username: "",
		loggedIn: false,
		sessions: [],
		genericError: nil
	)
	
	static var loggedIn = Self(
		artists: [],
		tracks: [],
		isLoading: false,
		tracksCount: 0,
		bootstrapCompleted: false,
		quizCard: [],
		currentIndex: 0,
		points: 0,
		currentQuizCard: nil,
		playerSelection: 0,
		gameSessionCompleted: false,
		isPlaying: false,
		username: "teddy",
		loggedIn: true,
		sessions: [],
		genericError: nil
	)
}

extension GameViewState {
	
	var game: GameState {
		get {
			GameState(
				tracks: self.tracks,
				artists: self.artists,
				quizCard: self.quizCard,
				currentIndex: self.currentIndex,
				points: self.points,
				playerSelection: self.playerSelection,
				currentQuizCard: self.currentQuizCard,
				gameSessionCompleted: self.gameSessionCompleted,
				isPlaying: self.isPlaying
			)
		}
		
		set {
			self.tracks = self.bootstrap.tracks
			self.artists = self.bootstrap.artists
			self.quizCard = newValue.quizCard
			self.currentIndex = newValue.currentIndex
			self.points = newValue.points
			self.playerSelection = newValue.playerSelection
			self.currentQuizCard = newValue.currentQuizCard
			self.gameSessionCompleted = newValue.gameSessionCompleted
			self.isPlaying = newValue.isPlaying
			
			if newValue.gameSessionCompleted && self.username.isEmpty == false {
				self.sessions.append(
					UserSession(
						username: self.username,
						score: self.points
					)
				)
			}
		}
	}
	
	var bootstrap: GameBootstrapState {
		get {
			GameBootstrapState(
				tracks: self.tracks,
				isLoading: self.isLoading,
				tracksCount: self.tracksCount,
				artists: self.artists,
				bootstrapCompleted: self.bootstrapCompleted,
				genericError: self.genericError
			)
		}
		
		set {
			self.tracks = newValue.tracks
			self.artists = newValue.artists
			
			self.tracksCount = newValue.tracksCount
			
			self.bootstrapCompleted = newValue.bootstrapCompleted
			
			self.isLoading = newValue.isLoading
			
			self.genericError = newValue.genericError
		}
	}
	
	var userLogin: LoginState {
		get {
			LoginState(
				username: self.username,
				loggedIn: self.loggedIn
			)
		}
		
		set {
			self.username = newValue.username
			self.loggedIn = newValue.loggedIn
		}
	}
}

enum GameViewAction: Equatable {
	case game(GameAction)
	case bootstrap(GameBootstrapAction)
	case login(LoginAction)
}

struct GameViewEnvironment {
	var bootstrap: GameBootstrapEnvironment
	var game: GameEnvironment
	var login: LoginEnvironment
}

extension GameViewEnvironment {
	
	static func mock(
		bootstrap: GameBootstrapEnvironment = .mock(),
		game: GameEnvironment = .init(),
		login: LoginEnvironment = .mock()
	) -> Self {
		.init(
			bootstrap: bootstrap,
			game: game,
			login: login
		)
	}
	
}

let gameSessionViewReducer: Reducer<GameViewState, GameViewAction, GameViewEnvironment> = .combine(
	gameBoostrapReducer.pullback(
		value: \GameViewState.bootstrap,
		action: /GameViewAction.bootstrap,
		environment: { $0.bootstrap }
	),
	gameReducer.pullback(
		value: \GameViewState.game,
		action: /GameViewAction.game,
		environment: { $0.game }
	),
	loginReducer.pullback(
		value: \GameViewState.userLogin,
		action: /GameViewAction.login,
		environment: { $0.login }
	)
)

