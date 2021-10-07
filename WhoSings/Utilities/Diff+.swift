//
//  Diff+.swift
//  WhoSings
//
//  Created by Jean Raphael Bordet on 07/10/21.
//

import Foundation
import Difference


func logDiff<State>(oldState: State, state: State) -> [String] {
	diff(oldState, state, indentationType: .tab)
		.map {
			$0.replacingOccurrences(of: "Expected", with: "-")
				.replacingOccurrences(of: "Received", with: "+")
		}
}
