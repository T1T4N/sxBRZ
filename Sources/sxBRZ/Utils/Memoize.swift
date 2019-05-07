//
//  Memoize.swift
//  sxBRZ
//
//  Created by Robert Armenski on 20.04.19.
//  Copyright © 2019 TitanTech. All rights reserved.
//

import Foundation

// swiftlint:disable identifier_name
func cache<T, U>(work: @escaping (T) -> U)
    -> (T) -> U
    where T: Hashable {
        var memo = [T: U]()

        return { x in
            if let q = memo[x] { return q }
            let r = work(x)
            memo[x] = r
            return r
        }
}
