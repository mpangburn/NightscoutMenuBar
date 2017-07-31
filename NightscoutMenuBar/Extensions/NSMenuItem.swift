//
//  NSMenuItem.swift
//  NightscoutMenuBar
//
//  Created by Michael Pangburn on 7/29/17.
//  Copyright © 2017 Michael Pangburn. All rights reserved.
//

import Cocoa


/// The menu item state representing an unspecified preference.
let NSUnsetState = -1

extension NSMenuItem {

    /// Determines whether the menu item's state is NSOnState.
    /// If a menu item's state is "on", it shows a checkmark.
    var isOn: Bool {
        get {
            return state == NSOnState
        }
        set {
            state = newValue ? NSOnState : NSOffState
        }
    }

    /**
     Toggles the state of the menu item.
     - Returns: The new state of the menu item.
     */
    @discardableResult func toggleState() -> Int {
        let newState = (state == NSOnState) ? NSOffState : NSOnState
        state = newState
        return newState
    }
}
