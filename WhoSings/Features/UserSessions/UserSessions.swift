//
//  UserSessions.swift
//  WhoSings
//
//  Created by Jean Raphael Bordet on 02/10/21.
//

import RxComposableArchitecture
import RxSwift
import RxCocoa

// MARK: - domain

struct UserSession: Equatable {
	var username: String
	var score: Int
}

struct SessionsState: Equatable {
	var sessions: [UserSession]
}

enum SessionAction: Equatable {
	case none
}

struct SessionEnvironment { }

// MARK: - business logic

let sessionsReducer = Reducer<
	SessionsState,
	SessionAction,
	SessionEnvironment
> { state, action, environment in
	switch action {
	case .none:
		return []
	}
}

// MARK: - mocks

extension SessionsState {
	static var empty = Self(
		sessions: []
	)
}


extension UserSession {
	static func mock(
		username: String = "bob",
		score: Int = 1
	)
	-> Self {
		.init(
			username: username,
			score: score
		)
	}
}
