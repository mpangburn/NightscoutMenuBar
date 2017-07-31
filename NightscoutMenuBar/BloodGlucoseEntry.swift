//
//  BloodGlucoseEntry.swift
//  NightscoutMenuBar
//
//  Created by Michael Pangburn on 7/28/17.
//  Copyright © 2017 Michael Pangburn. All rights reserved.
//

import Foundation


/// Represents a Nightscout blood glucose entry.
class BloodGlucoseEntry {

    /// The date the blood glucose entry was entered.
    let date: Date

    /// The units for the entry's blood glucose value.
    var units: BloodGlucoseUnit

    private func convert(glucoseValue: Int, to unit: BloodGlucoseUnit) -> Double {
        return Double(glucoseValue) * unit.conversionFactor
    }

    /// The entry's blood glucose value in mg/dl.
    private let _glucoseValue: Int

    /// The entry's blood glucose value in the entry's units.
    var glucoseValue: Double {
        return convert(glucoseValue: _glucoseValue, to: units)
    }

    /// The previous entry's blood glucose value in mg/dl.
    private let _previousGlucoseValue: Int

    /// The entry's previous blood glucose value in the entry's units.
    var previousGlucoseValue: Double {
        return convert(glucoseValue: _previousGlucoseValue, to: units)
    }

    /// The difference between the blood glucose value and the previous blood glucose value.
    var delta: Double {
        return glucoseValue - previousGlucoseValue
    }

    /// An arrow character representing the blood glucose trend.
    let direction: String

    init(date: Date, units: BloodGlucoseUnit, glucoseValue: Int, previousGlucoseValue: Int, direction: String) {
        self.date = date
        self._glucoseValue = glucoseValue
        self._previousGlucoseValue = previousGlucoseValue
        self.units = units
        self.direction = direction
    }
}


// MARK: - Blood glucose entry string formatting
extension BloodGlucoseEntry {

    /// A string representing the difference between the blood glucose value and the previous blood glucose value.
    /// Includes the sign of the delta.
    var deltaString: String {
        let delta = self.delta
        return delta > 0 ? "+\(delta.cleanString)" : "\(delta.cleanString)"
    }

    /**
     Returns a string representing the blood glucose entry with the specified options.
     The string is of form `[glucose value] [(delta)]? [direction] [(minutes ago)]?`
     - Parameters:
     - includingDelta: A boolean representing whether or not to display the blood glucose delta in the string.
     - includingTime: A boolean representing whether or not to display the number of minutes since the entry in the string.
     - Returns: A string representing the blood glucose entry.
     */
    func string(includingDelta: Bool, includingTime: Bool) -> String {
        var text = "\(glucoseValue.cleanString) "
        if includingDelta {
            text += "(\(deltaString)) "
        }
        text += "\(direction)"
        if includingTime {
            let minutesElapsed = Date().timeIntervalSince(date) / 60
            let minutesAgoLocalized = NSLocalizedString("min ago", comment: "The text describing the minutes elapsed since the blood glucose entry was entered")
            text += " (\(Int(minutesElapsed)) \(minutesAgoLocalized))"
        }
        return text
    }
}


extension BloodGlucoseEntry: CustomStringConvertible {
    var description: String {
        return "BloodGlucoseEntry(date: \(date), units: \(units) glucoseValue: \(glucoseValue), previousGlucoseValue: \(previousGlucoseValue), direction: \(direction))"
    }
}
