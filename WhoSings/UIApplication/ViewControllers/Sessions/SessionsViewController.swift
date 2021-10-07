//
//  SessionsViewController.swift
//  WhoSings
//
//  Created by Jean Raphael Bordet on 01/10/21.
//

import UIKit
import SnapKit
import RxComposableArchitecture
import RxSwift
import RxCocoa

extension Reactive where Base: SessionsViewController {
	var chart: Binder<[UserSession]> {
		Binder(base) { base, sessions in
			let bar = StackedBarChartViewController()
			bar.sessions = sessions
			
			base.navigationController?.pushViewController(bar, animated: true)
		}
	}
}

class SessionsViewController: UIViewController, StoreViewController {
	typealias Value = SessionsState
	typealias Action = SessionAction
	
	var store: Store<SessionsState, SessionAction>?
	
	lazy var tableView = UITableView()
	
	private let disposeBag = DisposeBag()
	
	@objc func chartTapped() {
		guard let store = self.store else {
			return
		}
		
		store
			.state
			.distinctUntilChanged()
			.take(1)
			.map { $0.sessions }
			.bind(to: self.rx.chart)
			.disposed(by: disposeBag)
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		guard let store = self.store else {
			fatalError()
		}
		
		self.title = NSLocalizedString("Leaderboard", comment: "")
		
		// Chart button
		navigationItem.rightBarButtonItem = UIBarButtonItem(title: "chart", style: .plain, target: self, action: #selector(chartTapped))
		let chart = UIBarButtonItem(title: "chart", style: .plain, target: self, action:  #selector(chartTapped))
		navigationItem.rightBarButtonItems = [chart]
		
		self.view.addSubview(tableView)
		
		// MARK: -  TableView
				
		tableView.snp.makeConstraints { make in
			make.left.top.right.bottom.equalToSuperview()
		}

		tableView.register(UINib(nibName: "SessionCell", bundle: Bundle.main), forCellReuseIdentifier: "SessionCell")
		tableView.rowHeight = 64
		
		store
			.state
			.map { $0.sessions.sorted { $0.score > $1.score } }
			.bind(to: tableView.rx.items(cellIdentifier: "SessionCell", cellType: SessionCell.self)) { row, item, cell in
				cell.nameLabel.text = item.username.capitalized				
				cell.scoreLabel.text = "\(item.score)"
			}
			.disposed(by: disposeBag)
	}
	
}
