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
}

struct LoginEnvironment { }

// MARK: - business login

let loginReducer = Reducer<
	LoginState,
	LoginAction,
	LoginEnvironment
> { state, action, environment in
	switch action {
	
	case let .username(text):
		state.username = text.isEmpty ? "bob" : text
		state.loggedIn = true
		return []
		
	case .login:
		state.loggedIn.toggle()
		state.username = ""
		return []
		
	}
}
