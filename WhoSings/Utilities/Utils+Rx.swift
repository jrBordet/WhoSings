//
//  Utils+Rx.swift
//  ViaggioTreno
//
//  Created by Jean Raphael Bordet on 22/12/2020.
//

import Foundation
import RxSwift
import RxComposableArchitecture

extension Observable where Element: OptionalType {
	func ignoreNil() -> Observable<Element.Wrapped> {
		flatMap { value -> Observable<Element.Wrapped> in
			guard let value = value.value else {
				return Observable<Element.Wrapped>.empty()
			}
			
			return Observable<Element.Wrapped>.just(value)
		}
	}
}

public protocol OptionalType {
	associatedtype Wrapped
	var value: Wrapped? { get }
}

extension Optional: OptionalType {
	/// Cast `Optional<Wrapped>` to `Wrapped?`
	public var value: Wrapped? {
		return self
	}
}
