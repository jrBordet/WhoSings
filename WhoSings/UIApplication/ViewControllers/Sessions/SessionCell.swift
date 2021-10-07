//
//  SessionCell.swift
//  WhoSings
//
//  Created by Jean Raphael Bordet on 02/10/21.
//

import UIKit

class SessionCell: UITableViewCell {
	lazy var nameLabel = UILabel()
	lazy var scoreLabel = UILabel()

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
		
		nameLabel.font = UIFont.boldSystemFont(ofSize: 21)
		
		self.addSubview(nameLabel)
		self.addSubview(scoreLabel)
		
		nameLabel.snp.makeConstraints { make in
			make.top.bottom.equalToSuperview()
			make.right.equalTo(scoreLabel.snp.leftMargin).offset(15)
			make.left.equalToSuperview().offset(15)
		}
		
		scoreLabel.snp.makeConstraints {
			$0.centerY.equalTo(nameLabel.snp.centerY)
			$0.left.equalTo(nameLabel.snp.right).offset(15)
		}
    }
    
}
