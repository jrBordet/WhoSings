//
//  AppDelegate+State.swift
//  WhoSings
//
//  Created by Jean Raphael Bordet on 30/09/21.
//

import Foundation
import RxComposableArchitecture

struct AppDelegateState: Equatable { }

enum AppDelegateAction: Equatable {
	case didFinishLaunching
}

struct AppDelegateEnvironment { }

let appDelegateReducer = Reducer<
	AppDelegateState,
	AppDelegateAction,
	AppDelegateEnvironment
> { state, action, environment in
	switch action {
	case .didFinishLaunching:
		return  []
	}
}
