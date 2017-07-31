//
//  Double.swift
//  NightscoutMenuBar
//
//  Created by Michael Pangburn on 7/30/17.
//  Copyright © 2017 Michael Pangburn. All rights reserved.
//

import Foundation


extension Double {

    /// Rounds the value to the specified number of decimal places.
    func roundedTo(decimalPlaces: Int) -> Double {
        let divisor = pow(10, Double(decimalPlaces))
        return (self * divisor).rounded() / divisor
    }

    /// If the value ends in `.0`, returns the String containing the value without the decimal place or zero.
    /// Otherwise, returns the String with the value rounded to one decimal place.
    var cleanString: String {
        if self.truncatingRemainder(dividingBy: 1) == 0 {
            return String(format: "%.0f", self)
        } else {
            return String(self.roundedTo(decimalPlaces: 1))
        }
    }
}
