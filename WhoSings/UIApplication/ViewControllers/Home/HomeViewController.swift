//
//  HomeViewController.swift
//  WhoSings
//
//  Created by Jean Raphael Bordet on 29/09/21.
//

import UIKit
import SnapKit
import RxComposableArchitecture
import RxSwift
import RxCocoa

extension Reactive where Base: Store<GameViewState, GameViewAction> {
	
	var start: Binder<Bool> {
		Binder(self.base) { store, value in
			guard value else {
				return
			}
			store.send(.game(GameAction.start(true)))
		}
	}
	
	var select: Binder<Int> {
		Binder(self.base) { store, value in
			store.send(.game(.select(value)))
		}
	}
	
	var selectId: Binder<Int> {
		Binder(self.base) { store, value in
			store.send(.game(.selectId(value)))
		}
	}
	
	var next: Binder<Void> {
		Binder(self.base) { store, _ in
			store.send(.game(.next))
		}
	}
	
}

class HomeViewController: UIViewController, StoreViewController {
	public var shuffle: Bool = true
	// MARK: - Feature domain

	typealias Value = GameViewState
	typealias Action = GameViewAction
	
	var store: Store<GameViewState, GameViewAction>?

	private let disposeBag = DisposeBag()
	
	var cardTimer: CardTimer!
	
	// MARK: - UI

	lazy var headerContainer = UIView()
	lazy var timerLabel = UILabel()

	lazy var lyricsLabel = UILabel()
	
	lazy var artistsTableView = UITableView()
	
	lazy var stackView = UIStackView()
	lazy var startButton = UIButton()
	lazy var nextButton = UIButton()
	
	var mainTimer: Observable<Int>!
	var timerDisposable = DisposeBag()
	
	// MARK: - Logout
	
	@objc func logoutTapped() {
		guard let store = self.store else {
			return
		}
		
		store.send(.login(.login))
		
		store.send(.game(.reset))
		
		cardTimer.stop()
	}
	
	// MARK: - Life cycle

	override func viewDidLoad() {
		super.viewDidLoad()
		
		self.view.backgroundColor = .white
		
		// timer counter
		let resetValue = 10
		
		guard let store = self.store else {
			fatalError("store not found")
		}

		self.view.addSubview(headerContainer)
		self.headerContainer.addSubview(timerLabel)
		
		self.view.addSubview(lyricsLabel)
		
		self.view.addSubview(artistsTableView)
		self.view.addSubview(nextButton)

		self.view.addSubview(stackView)
		
		self.view.addSubview(startButton)

		// MARK: - Logout
				
		navigationItem.rightBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: self, action: #selector(logoutTapped))
		let logout = UIBarButtonItem(title: "", style: .plain, target: self, action:  #selector(logoutTapped))
		
		navigationItem.rightBarButtonItems = [logout]
		
		store
			.state
			.map { $0.loggedIn }
			.distinctUntilChanged()
			.map { $0 ? L10n.App.Home.logout : L10n.App.Home.login  }
			.bind(to: logout.rx.title)
			.disposed(by: disposeBag)
		
		// MARK: -  Header
		
		headerContainer.backgroundColor = .clear
		
		headerContainer.snp.makeConstraints { make in
			make.height.equalTo(100)
			make.right.left.equalTo(self.view)
			make.topMargin.top.equalToSuperview().offset(56)
		}
		
		// MARK: -  Timer label
		
		timerLabel.backgroundColor = .clear
		timerLabel.text = "\(resetValue)"
		timerLabel.textAlignment = .center
		
		timerLabel.snp.makeConstraints { make in
			make.right.left.equalToSuperview()
			make.bottomMargin.equalToSuperview()
		}
		
		// MARK: - Card timer
		cardTimer =  CardTimer(resetValue: resetValue)
		
		cardTimer
			.value
			.map { $0 }
			.ignoreNil()
			.map { String($0) }
			.asDriver(onErrorJustReturn: "")
			.drive(timerLabel.rx.text)
			.disposed(by: disposeBag)
		
		cardTimer
			.value
			.map { $0 == 1 ? $0 : nil }
			.ignoreNil()
			.delay(.seconds(1), scheduler: MainScheduler.asyncInstance)
			.do(afterNext: { _ in
				store.send(.game(.next))
			})
			.subscribe()
			.disposed(by: disposeBag)
		
		store
			.state
			.map { $0.isPlaying }
			.delay(.milliseconds(280), scheduler: MainScheduler.asyncInstance)
			.asDriver(onErrorJustReturn: false)
			.drive(timerLabel.rx.isVisible)
			.disposed(by: disposeBag)
		
		
		// MARK: - Lyrics
		
		lyricsLabel.snp.makeConstraints { make in
			make.top.equalTo(headerContainer.snp.bottom).offset(15)
			make.width.equalToSuperview().multipliedBy(0.85)
			make.centerX.equalToSuperview()
		}
		
		lyricsLabel.numberOfLines = 0
		lyricsLabel.textAlignment = .center
		lyricsLabel.font = .boldSystemFont(ofSize: 16)
		lyricsLabel.text = L10n.App.Home.line
		
		// MARK: - Artists
		
		artistsTableView.snp.makeConstraints { make in
			make.topMargin.top.equalTo(lyricsLabel.snp.bottom).offset(15)
			make.left.equalTo(self.view.snp.left).offset(15)
			make.right.equalTo(self.view.snp.right).offset(-30)
			make.bottom.equalTo(self.nextButton.snp.top).offset(-15)
		}
		
		artistsTableView.rowHeight = 56
		
		artistsTableView.rx
			.setDelegate(self)
			.disposed(by: disposeBag)
				
		artistsTableView.register(ArtistCell.self, forCellReuseIdentifier: "ArtistCell")
		
		store
			.state
			.map { $0.currentQuizCard }
			.ignoreNil()
			.distinctUntilChanged()
			.map { $0.artists }
			.map({ (artists: [Artist]) -> [Artist] in
				if self.shuffle {
					return artists.shuffled()
				} else {
					return artists
				}
			})
			.map { $0.map { Artist(id: $0.id, name: $0.name) } }
			.bind(to: artistsTableView.rx.items(cellIdentifier: "ArtistCell", cellType: ArtistCell.self)) { row, item, cell in
				cell.textLabel?.text = item.name
			}
			.disposed(by: disposeBag)
		
		artistsTableView.rx
			.modelSelected(Artist.self)
			.map { $0.id }
			.bind(to: store.rx.selectId)
			.disposed(by: disposeBag)

		// MARK: - Current Quiz Card
		
		store
			.state
			.map { $0.currentQuizCard }
			.distinctUntilChanged()
			.ignoreNil()
			.map { $0.track.lyrics }
			.bind(to: lyricsLabel.rx.text)
			.disposed(by: disposeBag)
		
		// MARK: - Start Button
		
		startButton.setTitle(L10n.App.Home.start, for: .normal)
		startButton.backgroundColor = UIColor.systemBlue
		startButton.layer.cornerRadius = 20
		startButton.clipsToBounds = true

		startButton.snp.makeConstraints { make in
			make.height.equalTo(56)
			make.width.equalTo(220)
			make.centerY.equalToSuperview()
			make.centerX.equalToSuperview()
		}
		
		startButton.rx
			.tap
			.map { true }
			.do(onNext: { [weak self] _ in
				self?.cardTimer.start()
			})
			.bind(to: store.rx.start)
			.disposed(by: disposeBag)

		// MARK: - Next Button
		
		nextButton.setTitle(L10n.App.Home.next, for: .normal)
		nextButton.backgroundColor = UIColor.systemBlue
		nextButton.layer.cornerRadius = 20
		nextButton.clipsToBounds = true
		
		nextButton.rx
			.tap
			.bind { [weak self] in self?.cardTimer.reset() }
			.disposed(by: disposeBag)
		
		store
			.state
			.map { $0.isPlaying }
			.distinctUntilChanged()
			.bind(to: nextButton.rx.isHidden)
			.disposed(by: disposeBag)
		
		store
			.state
			.map { ($0.currentIndex, $0.quizCard.count) }
			.map { "\(L10n.App.Home.next) \($0 + 1)/\($1)" }
			.bind(to: self.nextButton.rx.title(for: .normal))
			.disposed(by: disposeBag)
		
		nextButton.snp.makeConstraints { make in
			make.height.equalTo(56)
			make.width.equalTo(220)
			make.bottom.equalToSuperview().offset(-100)
			make.centerX.equalTo(self.view.snp.centerX)
		}
		
		// visible if is playing
		store
			.state
			.map { $0.isPlaying }
			.distinctUntilChanged()
			.bind(to: nextButton.rx.isVisible)
			.disposed(by: disposeBag)
		
		nextButton.rx
			.tap
			.throttle(.milliseconds(500), scheduler: MainScheduler.asyncInstance)
			.bind(to: store.rx.next)
			.disposed(by: disposeBag)
		
		// MARK: - Login completed enable the Start button
		
		store
			.state
			.map { $0.loggedIn && $0.isPlaying == false }
			.distinctUntilChanged()
			.bind(to: startButton.rx.isVisible)
			.disposed(by: disposeBag)
		
		// MARK: - Bootstrap
		
		store.send(.bootstrap(.bootstrap))
		
		// MARK: - Game completed and restart session
		
		let gameSessionCompleted = store
			.state
			.map { $0.gameSessionCompleted }
			.share(replay: 1, scope: .whileConnected)
		
		gameSessionCompleted
			.distinctUntilChanged()
			.filter { $0 }
			.asDriver(onErrorJustReturn: false)
			.drive(timerLabel.rx.isHidden)
			.disposed(by: disposeBag)
		
		gameSessionCompleted
			.filter { $0 }
			.flatMapLatest { _ in
				store.state.map { $0.username }
			}
			.asDriver(onErrorJustReturn: "")
			.drive(self.rx.title)
			.disposed(by: disposeBag)
		
		// MARK: - User isPlaying
		
		let isPlaying = store
			.state
			.map { $0.isPlaying }
			.distinctUntilChanged()
			.share(replay: 1, scope: .whileConnected)
		
		isPlaying
			.filter { $0 ==  false }
			.flatMapLatest { _ in
				store.state.map { $0.username }
			}
			.asDriver(onErrorJustReturn: "")
			.drive(self.rx.title)
			.disposed(by: disposeBag)
		
		isPlaying
			.asDriver(onErrorJustReturn: false)
			.drive(artistsTableView.rx.isVisible)
			.disposed(by: disposeBag)
		
		isPlaying
			.asDriver(onErrorJustReturn: false)
			.drive(lyricsLabel.rx.isVisible)
			.disposed(by: disposeBag)
		
		// MARK: - Login
		
		store
			.state
			.map { state -> Bool? in
				guard state.genericError == nil else {
					return nil
				}
				
				return state.loggedIn
			}
			.ignoreNil()
			.distinctUntilChanged()
			.delay(.milliseconds(280), scheduler: MainScheduler.asyncInstance)
			.filter { $0 == false }
			.subscribe(onNext: { v in
				guard let topVC = UIApplication.getTopViewController() else {
					return
				}

				let ac = UIAlertController(
					title: L10n.App.Alert.username,
					message: nil,
					preferredStyle: .alert
				)

				ac.addTextField()

				let submitAction = UIAlertAction(title: L10n.App.Whosings.submit, style: .default) { [unowned ac] _ in
					guard let username = ac.textFields?[0] else {
						return
					}

					// MARK: - Username
					store.send(.login(.username(username.text ?? "")))
				}

				ac.addAction(submitAction)

				topVC.present(ac, animated: true)
			})
			.disposed(by: disposeBag)
		
		// MARK: - Session completed
		
		struct ScoreCompleted: Equatable {
			var completed: Bool
			var score: Int
		}
		
		store
			.state
			.map { state -> ScoreCompleted? in
				guard state.username != "" else {
					return nil
				}
				
				return ScoreCompleted(completed: state.gameSessionCompleted, score: state.points)
			}
			.ignoreNil()
			.distinctUntilChanged()
			.filter { $0.completed  }
			.do(onNext: { [weak self] _ in
				self?.cardTimer.stop()
			})
			.delay(.milliseconds(280), scheduler: MainScheduler.asyncInstance)
			.subscribe(onNext: { v in
				guard let topVC = UIApplication.getTopViewController() else {
					return
				}
				
				let ac = UIAlertController(
					title: L10n.App.Session.completed,
					message: "\(v.score) \(L10n.App.Session.points)",
					preferredStyle: .alert
				)
				
				let submitAction = UIAlertAction(title: L10n.App.Session.dismiss, style: .default)
				
				ac.addAction(submitAction)
				
				topVC.present(ac, animated: true)
			})
			.disposed(by: disposeBag)
	}

}

// MARK: - UITableViewDelegate

extension HomeViewController: UITableViewDelegate {
	func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
		UIView()
	}
	
	func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
		1
	}
}

// MARK: - Timer

class CardTimer {
	var value = BehaviorRelay<Int?>(value: nil)
	
	private var counter: Int = 10
	private var resetValue: Int = 10
	
	var timer: Timer!
	
	init(
		resetValue: Int
	) {
		self.resetValue = resetValue
		self.counter = resetValue
	}
	
	private func fireTimer() {
		timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] timer in
			guard let self = self else {
				return
			}
			
			self.value.accept(self.counter)
			self.counter -= 1
			
			if self.counter == 0 {
				self.counter = self.resetValue
			}

		}
	}
		
	func start() {
		counter = resetValue

		fireTimer()
	}
	
	func reset() {
		counter = resetValue
		
		self.timer.invalidate()
		self.fireTimer()
	}
	
	func stop() {
		guard timer != nil else {
			return
		}
		
		timer.invalidate()
	}
	
}
