//
//  LocalizedError.swift
//  NightscoutMenuBar
//
//  Created by Michael Pangburn on 3/26/18.
//  Copyright © 2018 Michael Pangburn. All rights reserved.
//

import Foundation


extension LocalizedError {
    var elaborateLocalizedDescription: String {
        return [errorDescription, failureReason, recoverySuggestion].compactMap({ $0 }).joined(separator: " ")
    }
}
