//
//  AppState.swift
//  WhoSings
//
//  Created by Jean Raphael Bordet on 30/09/21.
//

import RxComposableArchitecture
import Foundation

struct AppState: Equatable {
	var appDelegateState: AppDelegateState
	var gameState: GameViewState
	var userSessions: SessionsState
	var genericError: GenericErrorState?
}

extension AppState {
	var appDelegateView: AppDelegateState {
		get {
			self.appDelegateState
		}
		set {
			self.appDelegateState = newValue
		}
	}
	
	var gameStateView: GameViewState {
		get {
			self.gameState
		}
		
		set {
			self.gameState = newValue
			
			self.userSessions.sessions = newValue.sessions
			self.genericError = newValue.bootstrap.genericError
		}
	}
	
	var sessionsView: SessionsState {
		get {
			self.userSessions
		}
		
		set {
			self.userSessions = SessionsState(sessions: self.gameState.sessions)
		}
	}
	
	var genericErrorView: GenericErrorState? {
		get {
			self.genericError
		}
		
		set {
			if let dismissed = newValue?.isDismissed, dismissed {
				self.gameStateView.genericError = nil
			}
			
			self.genericError = newValue
		}
	}
}

enum AppAction: Equatable {
	case appDelegate(AppDelegateAction)
	case game(GameViewAction)
	case sessions(SessionAction)
	case genericError(GenericErrorAction)
}

struct AppEnvironment {
	var gameViewEnvironment: GameViewEnvironment
}

let appReducer = Reducer<AppState, AppAction, AppEnvironment>.combine(
	appDelegateReducer.pullback(
		value: \AppState.appDelegateView,
		action: /AppAction.appDelegate,
		environment: { _ in .init() }
	),
	gameSessionViewReducer.pullback(
		value: \AppState.gameStateView,
		action: /AppAction.game,
		environment: { $0.gameViewEnvironment }
	),
	genericErrorReducer.optional.pullback(
		value: \AppState.genericErrorView,
		action: /AppAction.genericError,
		environment: { _ in GenericErrorEnvironment() }
	), Reducer<AppState, AppAction, AppEnvironment> { state, action, env -> [Effect<AppAction>] in
		if case AppAction.genericError(GenericErrorAction.dismiss) = action {
			state.genericError = nil
			return []
		}
		
		return []
	}
)
