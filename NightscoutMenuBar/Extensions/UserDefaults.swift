//
//  UserDefaults.swift
//  NightscoutMenuBar
//
//  Created by Michael Pangburn on 7/28/17.
//  Copyright © 2017 Michael Pangburn. All rights reserved.
//

import Cocoa
import NightscoutKit


extension UserDefaults {
    private enum Key {
        static let baseURL = "com.pangburn.NightscoutMenuBar.baseURL"
        static let showBGDeltaMenuItemState = "com.pangburn.NightscoutMenuBar.showBGDeltaMenuItemState"
        static let showBGTimeMenuItemState = "com.pangburn.NightscoutMenuBar.showBGTimeMenuItemState"
    }

    var nightscout: Nightscout? {
        get {
            return url(forKey: Key.baseURL).map { Nightscout(baseURL: $0) }
        }
        set {
            set(newValue?.baseURL, forKey: Key.baseURL)
        }
    }

    var showBGDeltaMenuItemState: NSControl.StateValue? {
        get {
            guard let rawValue = object(forKey: Key.showBGDeltaMenuItemState) as? NSControl.StateValue.RawValue else {
                return nil
            }
            return .init(rawValue: rawValue)
        }
        set {
            set(newValue?.rawValue, forKey: Key.showBGDeltaMenuItemState)
        }
    }

    var showBGTimeMenuItemState: NSControl.StateValue? {
        get {
            guard let rawValue = object(forKey: Key.showBGTimeMenuItemState) as? NSControl.StateValue.RawValue else {
                return nil
            }
            return .init(rawValue: rawValue)
        }
        set {
            set(newValue?.rawValue, forKey: Key.showBGTimeMenuItemState)
        }
    }
}
