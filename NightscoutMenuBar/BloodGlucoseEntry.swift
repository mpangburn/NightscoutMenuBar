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
    let rawGlucoseValue: Int

    /// The entry's blood glucose value in the entry's units.
    var glucoseValue: Double {
        return convert(glucoseValue: rawGlucoseValue, to: units)
    }

    /// The previous entry's blood glucose value in mg/dl.
    let rawPreviousGlucoseValue: Int?

    /// The entry's previous blood glucose value in the entry's units.
    var previousGlucoseValue: Double? {
        if let rawPreviousGlucoseValue = rawPreviousGlucoseValue {
            return convert(glucoseValue: rawPreviousGlucoseValue, to: units)
        } else {
            return nil
        }
    }

    /// The difference between the blood glucose value and the previous blood glucose value.
    var delta: Double? {
        if let previousGlucoseValue = previousGlucoseValue {
            return glucoseValue - previousGlucoseValue
        } else {
            return nil
        }
    }

    /// An arrow character representing the blood glucose trend.
    let direction: String

    init(date: Date, units: BloodGlucoseUnit, rawGlucoseValue: Int, rawPreviousGlucoseValue: Int?, direction: String) {
        self.date = date
        self.rawGlucoseValue = rawGlucoseValue
        self.rawPreviousGlucoseValue = rawPreviousGlucoseValue
        self.units = units
        self.direction = direction
    }
}


// MARK: - Blood glucose entry string formatting
extension BloodGlucoseEntry {

    /// A string representing the difference between the blood glucose value and the previous blood glucose value.
    /// Includes the sign of the delta.
    var deltaString: String {
        if let delta = delta {
            return delta > 0 ? "+\(delta.cleanString)" : "\(delta.cleanString)"
        } else {
            return "?"
        }
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
            if !direction.isEmpty {
                text += " "
            }
            text += "(\(Int(minutesElapsed)) \(minutesAgoLocalized))"
        }
        return text
    }
}


extension BloodGlucoseEntry: CustomStringConvertible {
    var description: String {
        return "BloodGlucoseEntry(date: \(date), units: \(units) rawGlucoseValue: \(rawGlucoseValue), rawPreviousGlucoseValue: \(String(describing: rawPreviousGlucoseValue)), direction: \(direction))"
    }
}
