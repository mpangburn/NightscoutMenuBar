//
//  DeltaRecordingNightscoutEntry.swift
//  NightscoutMenuBar
//
//  Created by Michael Pangburn on 3/22/18.
//  Copyright © 2018 Michael Pangburn. All rights reserved.
//

import NightscoutKit


extension DeltaRecordingNightscoutEntry {
    func description(includingDelta: Bool, includingTimeAgo: Bool) -> String {
        var text = glucoseValue.valueString
        if includingDelta {
            text += " (\(glucoseDeltaString))"
        }
        if case .sensor(trend: let trend) = source {
            text += " \(trend.symbol)"
        }
        if includingTimeAgo {
            let minutesAgo = Int(Date().timeIntervalSince(date).minutes)
            let format = NSLocalizedString("(%d min ago)", comment: "The text describing the minutes elapsed since the entry was recorded")
            let minutesAgoString = String(format: format, minutesAgo)
            text += " \(minutesAgoString)"
        }
        return text
    }
}
