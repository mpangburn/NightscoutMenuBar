//
//  URL.swift
//  NightscoutMenuBar
//
//  Created by Michael Pangburn on 7/29/17.
//  Copyright © 2017 Michael Pangburn. All rights reserved.
//

import Foundation


extension URL {

    /// Determines whether the URL is valid.
    var isValid: Bool {
        let urlRegEx = "(?i)(http|https)(:\\/\\/)([^ .]+)(\\.)([^ \n]+)"
        let predicate = NSPredicate(format:"SELF MATCHES %@", urlRegEx)
        return predicate.evaluate(with: absoluteString)
    }
}
