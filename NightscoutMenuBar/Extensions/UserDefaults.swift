//
//  UserDefaults.swift
//  NightscoutMenuBar
//
//  Created by Michael Pangburn on 7/28/17.
//  Copyright © 2017 Michael Pangburn. All rights reserved.
//

import Foundation


extension UserDefaults {

    private enum Key: String {
        case baseURL = "com.pangburn.NightscoutMenuBar.baseURL"
        case showBGDeltaMenuItemState = "com.pangburn.NightscoutMenuBar.showBGDeltaMenuItemState"
        case showBGTimeMenuItemState = "com.pangburn.NightscoutMenuBar.showBGTimeMenuItemState"
    }

    var baseURL: String? {
        get {
            return string(forKey: Key.baseURL.rawValue)
        }
        set {
            set(newValue, forKey: Key.baseURL.rawValue)
        }
    }

    // In storing button states, offset by 1 to differentiate between off and no preference set.
    // See NSMenuItem.swift for information regarding NSUnsetState.
    var showBGDeltaMenuItemState: Int {
        get {
            return integer(forKey: Key.showBGDeltaMenuItemState.rawValue) - 1
        }
        set {
            set(newValue + 1, forKey: Key.showBGDeltaMenuItemState.rawValue)
        }
    }

    var showBGTimeMenuItemState: Int {
        get {
            return integer(forKey: Key.showBGTimeMenuItemState.rawValue) - 1
        }
        set {
            set(newValue + 1, forKey: Key.showBGTimeMenuItemState.rawValue)
        }
    }
}
