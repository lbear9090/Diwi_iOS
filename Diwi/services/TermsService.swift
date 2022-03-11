//
//  TermsService.swift
//  Diwi
//
//  Created by Dominique Miller on 1/31/20.
//  Copyright © 2020 Trim Agency. All rights reserved.
//

import Foundation
import Alamofire
import RxSwift

class TermsService: MainRequestService {
    func show() -> Observable<ApiResponseData> {
        return newRequestWithoutKeyPath(route: TermsRouter.show)
    }
}
