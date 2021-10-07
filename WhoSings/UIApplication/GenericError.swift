//
//  GenericError.swift
//  WhoSings
//
//  Created by Jean Raphael Bordet on 06/10/21.
//

import Foundation
import RxComposableArchitecture

struct GenericErrorState: Equatable {
	var title: String
	var message: String
	var isDismissed: Bool
}

enum GenericErrorAction: Equatable {
	case dismiss
}

struct GenericErrorEnvironment { }

let genericErrorReducer = Reducer<GenericErrorState, GenericErrorAction, GenericErrorEnvironment> { state, action, env in
	switch action {
	case .dismiss:
		state.title = ""
		state.message = ""
		state.isDismissed = true
		return []
	}
}
