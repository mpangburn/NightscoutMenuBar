//
//  NSMenuItem.swift
//  NightscoutMenuBar
//
//  Created by Michael Pangburn on 7/29/17.
//  Copyright © 2017 Michael Pangburn. All rights reserved.
//

import Cocoa


extension NSMenuItem {
    var isOn: Bool {
        get {
            return state == .on
        }
        set {
            state = newValue ? .on : .off
        }
    }
}
