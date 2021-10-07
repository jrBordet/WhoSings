//
//  AppDelegate+mock.swift
//  WhoSingsMock
//
//  Created by Jean Raphael Bordet on 02/10/21.
//

import UIKit
import RxComposableArchitecture
import RxSwift
import RxCocoa
import SwiftPrettyPrint

var applicationStore: Store<AppState, AppAction> = Store(
	initialValue: initialAppState,
	reducer: with(
		appReducer,
		compose(
			whoSingsLogging,
			activityFeed
		)),
	environment: AppEnvironment(
		gameViewEnvironment: .mock//.error; mockEmptyArtists
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
		
		Pretty.prettyPrint(logDiff(oldState: _value, state: value))
		
		return [.fireAndForget {
			print("\n---")
			}] + effects
	}
}

func activityFeed(
	_ reducer: Reducer<AppState, AppAction, AppEnvironment>
) -> Reducer<AppState, AppAction, AppEnvironment> {
	.init { state, action, environment in
		
		//		if case AppAction.counter(CounterAction.incrTapped) = action {
		//		}
		
		return reducer(&state, action, environment)
	}
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
	var window: UIWindow?
	
	private let disposeBag = DisposeBag()
	
	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
		self.window = UIWindow(frame: UIScreen.main.bounds)
				
		// MARK: - Handle global GENERIC ERROR
		
		applicationStore
			.state
			.observe(on: MainScheduler.asyncInstance)
			.map { $0.genericError }
			.distinctUntilChanged()
			.ignoreNil()
			.subscribe { (state: GenericErrorState) in
				if let topVC = UIApplication.getTopViewController() {
					let ac = UIAlertController(
						title: state.title,
						message: state.message,
						preferredStyle: UIAlertController.Style.alert
					)
					
					ac.addAction(
						UIAlertAction(
							title: L10n.App.Session.dismiss,
							style: UIAlertAction.Style.cancel,
							handler: { (a: UIAlertAction) in
								applicationStore.send(AppAction.genericError(GenericErrorAction.dismiss))
							}
						)
					)
					
					topVC.present(ac, animated: true, completion: nil)
				}
				
			}
			.disposed(by: disposeBag)
		
		// MARK: - Sessions
		
		let sessionsStore = applicationStore.scope(
			value: { $0.sessionsView },
			action: { .sessions($0) }
		)
		
//		let testStore = Store(
//			initialValue: SessionsState(
//				sessions: [
//					UserSession(username: "bob", score: 3),
//					.init(username: "margot", score: 10),
//					.init(username: "margotma", score: 7)
//				]),
//			reducer: sessionsReducer,
//			environment: SessionEnvironment()
//		)
		
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
		
		let nav = UINavigationController(rootViewController: home)
		
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
