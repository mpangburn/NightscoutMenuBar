//
//  TimeInterval.swift
//  NightscoutMenuBar
//
//  Created by Michael Pangburn on 3/22/18.
//  Copyright © 2018 Michael Pangburn. All rights reserved.
//

import Foundation


extension TimeInterval {
    static func minutes(_ minutes: Double) -> TimeInterval {
        return minutes * 60
    }

    var minutes: Double {
        return self / 60
    }
}
