//
//  Environments+.swift
//  WhoSings
//
//  Created by Jean Raphael Bordet on 01/10/21.
//

import Foundation
import RxComposableArchitecture
import  MusixmatchClient
import RxSwift
import RxCocoa


let topSongsRequest = TopSongsRequest(
	page_size: 10,
	apikey: API_KEY
)

extension GameBootstrapEnvironment {
	static var live = Self (
		getTopSongs: { () -> Effect<Result<[Track], GenericError>> in
			topSongsRequest
				.execute(with: URLSession.shared)
				.subscribe(on: ConcurrentDispatchQueueScheduler(qos: .background))
				.map { Track.map(with: $0) }
				.map { Result<[Track], GenericError>.success($0) }
				.catch { e -> Observable<Result<[Track], GenericError>> in
					.just(.failure(GenericError(title: "TopSongsRequest", message: e.localizedDescription, isDismissed: false)))
				}
		},
		getLyrics: { track -> Effect<Result<Track, GenericError>> in
			let getLyrics: GetLyricsRequest = .init(
				track_id: track.id,
				apikey: API_KEY
			)
			
			return getLyrics
				.execute(with: URLSession.shared)
				.subscribe(on: ConcurrentDispatchQueueScheduler(qos: .background))
				.map { String.map(with: $0) }
				.map { .success(trackLyricsLens.set($0, track)) }
				.catch { e -> Observable<Result<Track, GenericError>> in
					.just(.failure(GenericError(title: "GetLyricsRequest", message: e.localizedDescription, isDismissed: false)))
				}
			
		},
		getArtists: {
			GetArtistChartRequest(apikey: API_KEY)
				.execute(with: URLSession.shared)
				.subscribe(on: ConcurrentDispatchQueueScheduler(qos: .background))
				.map { Artist.map(with: $0) }
				.map { artists -> Result<[Artist], GenericError> in
					Result<[Artist], GenericError>.success(artists)
				}
				.catch { e -> Observable<Result<[Artist], GenericError>> in
					.just(.failure(GenericError(title: "GetArtistChartRequest", message: e.localizedDescription, isDismissed: false)))
				}
		}
	)
}
