//
//  BloodGlucoseUnit.swift
//  NightscoutMenuBar
//
//  Created by Michael Pangburn on 7/30/17.
//  Copyright © 2017 Michael Pangburn. All rights reserved.
//

import Foundation


/// Represents units for blood glucose values.
enum BloodGlucoseUnit: String {

    /// Milligrams per deciliter (mg/dL).
    case mgdL = "mg/dl"

    /// Millimoles per liter (mmol/L).
    case mmolL = "mmol"

    /// The factor used to convert from mg/dL.
    var conversionFactor: Double {
        switch self {
        case .mgdL:
            return 1.0
        case .mmolL:
            return 1.0 / 18.0
        }
    }
}

extension BloodGlucoseUnit: CustomStringConvertible {
    var description: String {
        switch self {
        case .mgdL:
            return "mg/dL"
        case .mmolL:
            return "mmol/L"
        }
    }
}
