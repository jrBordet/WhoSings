//
//  UserLogin.swift
//  WhoSings
//
//  Created by Jean Raphael Bordet on 01/10/21.
//

import Foundation
import RxComposableArchitecture
import RxSwift
import RxCocoa

// MARK: - Feature domain

struct LoginState: Equatable {
	var username: String
	var loggedIn: Bool
}

enum LoginAction: Equatable {
	case username(String)
	
	case login
	case loginResponse(Result<String, GenericError>)
}

struct LoginEnvironment {
	var login: (String) -> Effect<Result<String, GenericError>>
}

extension LoginEnvironment {
	static func mock(
		login: @escaping(String) -> Effect<Result<String, GenericError>> = { _ in  fatalError("not mocked")}
	) -> Self {
		.init(
			login: login
		)
	}
	
	static var error = Self (
		login: { username in
			Effect.just(.failure(.loginError))
		}
	)
}

extension GenericError {
	static var loginError: Self = .init(
		title: "Login error",
		message: "unable to login",
		isDismissed: false
	)
}

// MARK: - business login

let loginReducer = Reducer<
	LoginState,
	LoginAction,
	LoginEnvironment
> { state, action, environment in
	switch action {
	case let .username(text):
		state.username = text.isEmpty ? "bob" : text
		
		return [
			Effect.just(LoginAction.login)
		]
		
	case .login:
		guard state.loggedIn == true else {
			return [
				environment
					.login(state.username)
					.map { LoginAction.loginResponse($0) }
			]
		}
		
		state.loggedIn.toggle()
		state.username = ""
		
		return []
				
	case let .loginResponse(.success(username)):
		state.username = username
		state.loggedIn = true
		return []
		
	case let .loginResponse(.failure(error)):
		state.username = ""
		state.loggedIn = false
		return []
	}
}
