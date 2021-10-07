//
//  Mockable.swift
//  WhoSingsMock
//
//  Created by Jean Raphael Bordet on 02/10/21.
//

import Foundation

func data(from file: String, type: String) -> Data? {
	Bundle
		.main
		.path(forResource: file, ofType: type)
		.map(URL.init(fileURLWithPath:))
		.flatMap { try? Data(contentsOf: $0) }
}
