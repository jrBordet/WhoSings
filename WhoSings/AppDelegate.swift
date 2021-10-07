//
//  AppDelegate.swift
//  CoachTimer
//
//  Created by Jean Raphael Bordet on 17/05/2020.
//  Copyright © 2020 Jean Raphael Bordet. All rights reserved.
//

import UIKit
import RxComposableArchitecture
import RxSwift
import RxCocoa
import SwiftPrettyPrint

let API_KEY = ""

var applicationStore: Store<AppState, AppAction> = Store(
	initialValue: initialAppState,
	reducer: with(
		appReducer,
		compose(
			whoSingsLogging,
			activityFeed
		)),
	environment: AppEnvironment(
		gameViewEnvironment: .live
	)
)

let initialAppState = AppState(
	appDelegateState: AppDelegateState(),
	gameState: .empty,
	userSessions: .empty
)

func whoSingsLogging<Value, Action, Environment>(
	_ reducer: Reducer<Value, Action, Environment>
) -> Reducer<Value, Action, Environment> {
	return .init { value, action, environment in
		let _value = value

		let effects = reducer(&value, action, environment)
		
		Pretty.prettyPrint(logDiff(_value, value))
		
		return [.fireAndForget {
			print("\n---")
			}] + effects
	}
}

func activityFeed(
	_ reducer: Reducer<AppState, AppAction, AppEnvironment>
) -> Reducer<AppState, AppAction, AppEnvironment> {
	return .init { state, action, environment in
		
		if case AppAction.genericError(GenericErrorAction.dismiss) = action {
			print("generic error")
		}
		
		return reducer(&state, action, environment)
	}
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
	var window: UIWindow?
	
	private let disposeBag = DisposeBag()
	
	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
		self.window = UIWindow(frame: UIScreen.main.bounds)
		
		// MARK: - Sessions
		
		let sessionsStore = applicationStore.scope(
			value: { $0.sessionsView },
			action: { .sessions($0) }
		)
		
		let sessions = SessionsViewController()
		sessions.store = sessionsStore
		
		let navSession = UINavigationController(rootViewController: sessions)
		
		// MARK: - Home
		
		let gameStore = applicationStore.scope(
			value: { $0.gameState },
			action: { .game($0) }
		)
			
		let home = HomeViewController()
		home.store = gameStore
		
		let nav = UINavigationController.init(rootViewController: home)
		
		// Tab bar
		let tabBarController = UITabBarController()
		
		let item1 = UITabBarItem(title: "Home", image: UIImage(named: ""), tag: 0)
		let item2 = UITabBarItem(title: "Leaderboard", image:  UIImage(named: ""), tag: 1)
		
		nav.tabBarItem = item1
		navSession.tabBarItem = item2
		
		tabBarController.setViewControllers([
			nav,
			navSession
		], animated: false)
		
		self.window?.rootViewController = tabBarController
		
		self.window?.makeKeyAndVisible()
		self.window?.backgroundColor = .white
		
		applicationStore.send(.appDelegate(.didFinishLaunching))
		
		// MARK: - Handle global GENERIC ERROR
		
		applicationStore
			.state
			.observe(on: MainScheduler.asyncInstance)
			.map { $0.genericError }
			.ignoreNil()
			.distinctUntilChanged()
			.subscribe { [weak self] (state: GenericErrorState) in
				guard let self = self else {
					return
				}
				
				if let topVC = UIApplication.getTopViewController() {
					let ac = UIAlertController(
						title: state.title,
						message: state.message,
						preferredStyle: UIAlertController.Style.alert
					)
					
//					ac.addAction(
//						UIAlertAction(
//							title: L10n.App.Session.dismiss,
//							style: UIAlertAction.Style.cancel,
//							handler: { (a: UIAlertAction) in
//								s
//							}
//						)
//					)
					
					topVC.present(ac, animated: true, completion: nil)
				}
				
				self.window?.rootViewController = UIViewController()
				
			}
			.disposed(by: disposeBag)
		
		return true
	}
}

extension UIApplication {
	
	class func getTopViewController(base: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
		if let nav = base as? UINavigationController {
			return getTopViewController(base: nav.visibleViewController)
			
		} else if let tab = base as? UITabBarController, let selected = tab.selectedViewController {
			return getTopViewController(base: selected)
			
		} else if let presented = base?.presentedViewController {
			return getTopViewController(base: presented)
		}
		
		return base
	}
	
}
