//
//  StatusMenuController.swift
//  NightscoutMenuBar
//
//  Created by Michael Pangburn on 7/28/17.
//  Copyright © 2017 Michael Pangburn. All rights reserved.
//

import Cocoa


class StatusMenuController: NSObject {

    @IBOutlet weak var statusMenu: NSMenu!
    @IBOutlet weak var lastUpdatedMenuItem: NSMenuItem!
    @IBOutlet weak var showBGDeltaMenuItem: NSMenuItem!
    @IBOutlet weak var showBGTimeMenuItem: NSMenuItem!

    let statusItem = NSStatusBar.system().statusItem(withLength: NSVariableStatusItemLength)
    let nightscout = Nightscout()

    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        formatter.dateFormat = "EE h:mm a"
        return formatter
    }()

    var lastUpdated: Date = Date() {
        didSet {
            let updatedLocalized = NSLocalizedString("Updated", comment: "The text shown before the time of the most recent update")
            lastUpdatedMenuItem.title = "\(updatedLocalized) \(dateFormatter.string(from: lastUpdated))"
        }
    }

    override func awakeFromNib() {
        statusItem.title = "Nightscout"
        statusItem.menu = statusMenu

        let defaultDeltaMenuItemState = UserDefaults.standard.showBGDeltaMenuItemState
        showBGDeltaMenuItem.state = defaultDeltaMenuItemState == NSUnsetState ? NSOnState : defaultDeltaMenuItemState
        let defaultTimeMenuItemState = UserDefaults.standard.showBGTimeMenuItemState
        showBGTimeMenuItem.state = defaultTimeMenuItemState == NSUnsetState ? NSOnState : defaultTimeMenuItemState

        if nightscout.baseURL == nil {
            setNightscoutURL()
        } else {
            nightscout.updateUnits(completion: fetchBloodGlucoseData)
        }

        let refreshInterval = 60.0
        Timer.scheduledTimer(timeInterval: refreshInterval, target: self, selector: #selector(fetchBloodGlucoseData), userInfo: nil, repeats: true)
    }

    private func setNightscoutURL() {
        let alert = NSAlert()
        alert.alertStyle = .informational
        alert.messageText = NSLocalizedString("Nightscout Configuration", comment: "The title text for the window prompting users for their Nightscout URL")
        alert.informativeText = NSLocalizedString("Enter your Nightscout URL below.", comment: "The subtitle text for the window prompting users for their Nightscout URL")
        let textField = NSTextField(frame: NSMakeRect(0, 0, 320, 22))
        textField.placeholderString = NSLocalizedString("https://MYNIGHTSCOUT.herokuapp.com", comment: "The placeholder text for the text field where users enter their Nightscout URL")
        textField.stringValue = nightscout.baseURL ?? ""
        alert.accessoryView = textField
        alert.addButton(withTitle: NSLocalizedString("OK", comment: "The text for the button confirming the user's Nightscout URL"))
        alert.addButton(withTitle: NSLocalizedString("Cancel", comment: "The text for the button canceling the user's Nightscout URL entry"))
        let response = alert.runModal() % 999
        if response == NSModalResponseOK {
            nightscout.baseURL = textField.stringValue.trimmingCharacters(in: .whitespaces)
            nightscout.bloodGlucoseEntries.removeAll()
            nightscout.updateUnits(completion: fetchBloodGlucoseData)
        }
    }

    @objc private func fetchBloodGlucoseData() {
        nightscout.fetchBloodGlucoseData() { result in
            switch result {
            case .success(let bgEntries):
                self.nightscout.bloodGlucoseEntries = bgEntries
            case .failure(let error):
                DispatchQueue.main.async {
                    let alert = NSAlert()
                    alert.alertStyle = .warning
                    alert.messageText = NSLocalizedString("Nightscout Error", comment: "The title text for the error alert")
                    alert.informativeText = error.localizedDescription
                    alert.runModal()
                }
            }

            self.lastUpdated = Date()
            self.updateUI()
        }
    }

    private func updateUI() {
        for item in statusMenu.items where item.title.contains("min") {
            statusMenu.removeItem(item)
        }

        if statusMenu.item(at: 0) == NSMenuItem.separator() {
            statusMenu.removeItem(at: 0)
        }

        if let recentEntry = nightscout.bloodGlucoseEntries.first {
            statusItem.title = recentEntry.string(includingDelta: showBGDeltaMenuItem.isOn, includingTime: showBGTimeMenuItem.isOn)

            let remainingEntries = Array(nightscout.bloodGlucoseEntries.dropFirst())
            guard !remainingEntries.isEmpty else { return }
            statusMenu.insertItem(NSMenuItem.separator(), at: 0)
            let entriesToShow = min(remainingEntries.count, 5)
            for entry in remainingEntries[0..<entriesToShow].reversed() {
                let entryMenuItem = NSMenuItem(title: entry.string(includingDelta: showBGDeltaMenuItem.isOn, includingTime: true), action: nil, keyEquivalent: "")
                entryMenuItem.isEnabled = false
                statusMenu.insertItem(entryMenuItem, at: 0)
            }
        } else {
            statusItem.title = "Nightscout"
        }
    }

    @IBAction func toggleShowBGDelta(_ sender: NSMenuItem) {
        UserDefaults.standard.showBGDeltaMenuItemState = sender.toggleState()
        updateUI()
    }

    @IBAction func toggleShowBGTime(_ sender: NSMenuItem) {
        UserDefaults.standard.showBGTimeMenuItemState = sender.toggleState()
        updateUI()
    }

    @IBAction func setNightscoutURLClicked(_ sender: NSMenuItem) {
        setNightscoutURL()
    }
    
    @IBAction func quitClicked(sender: NSMenuItem) {
        NSApplication.shared().terminate(self)
    }
}
