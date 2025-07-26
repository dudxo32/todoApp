//
//  StringEX.swift
//  Shared
//
//  Created by 조영태 on 7/18/25.
//

import Foundation

extension String {
    var localized: String {
        NSLocalizedString(self, comment: "")
    }
}
