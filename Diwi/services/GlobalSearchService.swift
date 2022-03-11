//
//  GlobalSearchService.swift
//  Diwi
//
//  Created by Dominique Miller on 4/16/20.
//  Copyright © 2020 Trim Agency. All rights reserved.
//

import Foundation
import RxSwift

class GlobalSearchService: MainRequestService {
    func search(for term: String) -> Observable<SearchResult> {
        return newRequestWithKeyPath(route: GlobalSearchRouter.search(term),
                                     keypath: "results")
    }
}
