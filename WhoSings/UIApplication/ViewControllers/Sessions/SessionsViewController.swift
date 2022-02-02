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

class SessionsViewController: UIViewController, StoreViewController {
	typealias Value = SessionsState
	typealias Action = SessionAction
	
	var store: Store<SessionsState, SessionAction>?
	
	lazy var tableView = UITableView()
	
	private let disposeBag = DisposeBag()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		guard let store = self.store else {
			fatalError()
		}
		
		self.title = NSLocalizedString("Leaderboard", comment: "")
		
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
