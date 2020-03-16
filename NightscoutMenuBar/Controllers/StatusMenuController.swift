//
//  StatusMenuController.swift
//  NightscoutMenuBar
//
//  Created by Michael Pangburn on 7/28/17.
//  Copyright © 2017 Michael Pangburn. All rights reserved.
//

import Cocoa
import NightscoutKit


class StatusMenuController: NSObject {
    @IBOutlet private weak var statusMenu: NSMenu!
    @IBOutlet private weak var lastUpdatedMenuItem: NSMenuItem!
    @IBOutlet private weak var showBGDeltaMenuItem: NSMenuItem!
    @IBOutlet private weak var showBGTimeAgoMenuItem: NSMenuItem!

    private let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    private var entryMenuItems: [NSMenuItem] = []

    private var nightscout: NightscoutDownloader? {
        didSet {
            dataStore.clearFetchedEntriesCache()
            nightscout?.addObservers(dataStore, self)
            UserDefaults.standard.nightscoutURL = nightscout?.credentials.url
        }
    }

    private let dataStore = NightscoutDataStore(options: .storeFetchedEntries, cachingReceivedData: false)

    private var shouldFetchEntries = true

    private var lastUpdated = Date() {
        didSet {
            let format = NSLocalizedString("Updated %@", comment: "The text shown before the time of the most recent update")
            lastUpdatedMenuItem.title = String(format: format, lastUpdatedDateFormatter.string(from: lastUpdated))
        }
    }

    private let lastUpdatedDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "EE h:mm a"
        return formatter
    }()

    private let defaultStatusItemTitle = "Nightscout"

    // MARK: - Lifecycle

    override func awakeFromNib() {
        statusItem.title = defaultStatusItemTitle
        statusItem.menu = statusMenu
        showBGDeltaMenuItem.state = UserDefaults.standard.showBGDeltaMenuItemState ?? .on
        showBGTimeAgoMenuItem.state = UserDefaults.standard.showBGTimeMenuItemState ?? .on

        if let url = UserDefaults.standard.nightscoutURL {
            updateDownloader(forURL: url)
        } else {
            setNightscoutURL()
        }

        setupRefreshTimer()
        setupRefreshOnWakeNotification()
    }

    private func setupRefreshTimer() {
        let refreshInterval: TimeInterval = .minutes(1)
        Timer.scheduledTimer(withTimeInterval: refreshInterval, repeats: true) { [weak self] _ in
            self?.fetchEntries()
        }
    }

    private func setupRefreshOnWakeNotification() {
        let notificationCenter = NSWorkspace.shared.notificationCenter
        notificationCenter.addObserver(forName: NSWorkspace.willSleepNotification, object: nil, queue: nil) { [weak self] _ in
            self?.shouldFetchEntries = false
        }
        notificationCenter.addObserver(forName: NSWorkspace.didWakeNotification, object: nil, queue: nil) { [weak self] _ in
            self?.shouldFetchEntries = true
            self?.fetchEntries()
        }
    }
    
    deinit {
        NSWorkspace.shared.notificationCenter.removeObserver(self)
    }

    // MARK: - Nightscout Configuration

    private func setNightscoutURL() {
        let alert = NSAlert()
        alert.alertStyle = .informational
        alert.messageText = NSLocalizedString("Nightscout Configuration", comment: "The title text for the window prompting users for their Nightscout URL")
        alert.informativeText = NSLocalizedString("Enter your Nightscout URL below.", comment: "The subtitle text for the window prompting users for their Nightscout URL")
        let textField = NSTextField(frame: NSRect(x: 0, y: 0, width: 320, height: 22))
        textField.placeholderString = NSLocalizedString("https://YOUR-NIGHTSCOUT-SITE.herokuapp.com", comment: "The placeholder text for the text field where users enter their Nightscout URL")
        textField.stringValue = nightscout?.credentials.url.relativeString ?? ""
        alert.accessoryView = textField
        alert.addButton(withTitle: NSLocalizedString("OK", comment: "The text for the button confirming the user's Nightscout URL"))
        alert.addButton(withTitle: NSLocalizedString("Cancel", comment: "The text for the button canceling the user's Nightscout URL entry"))

        let response = alert.runModal()
        guard response == .alertFirstButtonReturn else {
            return
        }

        let trimmedURLString = textField.stringValue.trimmingCharacters(in: .whitespaces)
        guard let url = URL(string: trimmedURLString) else {
            presentError(.invalidURL)
            return
        }

        updateDownloader(forURL: url)
    }

    private func updateDownloader(forURL url: URL) {
        NightscoutDownloaderCredentials.validate(url: url) { result in
            switch result {
            case .success(let credentials):
                self.nightscout = NightscoutDownloader(credentials: credentials)
                self.nightscout?.fetchStatus { _ in
                    self.fetchEntries()
                }
            case .failure(let error):
                self.presentError(error)
            }
        }
    }

    // MARK: - Fetching

    private func fetchEntries() {
        guard shouldFetchEntries else { return }
        nightscout?.fetchMostRecentEntries() { _ in
            DispatchQueue.main.async {
                self.updateUI()
            }
        }
    }

    // MARK: - UI Configuration

    private func updateUI() {
        entryMenuItems.forEach(statusMenu.removeItem)
        entryMenuItems.removeAll()

        let preferredUnits = dataStore.fetchedStatus?.settings.bloodGlucoseUnits ?? .milligramsPerDeciliter
        let entries = dataStore.fetchedEntries
            .map { $0.converted(to: preferredUnits) }
            .recordingDeltas()
        guard let mostRecentEntry = entries.first else {
            statusItem.title = defaultStatusItemTitle
            return
        }

        statusItem.title = mostRecentEntry.description(includingDelta: showBGDeltaMenuItem.isOn, includingTimeAgo: showBGTimeAgoMenuItem.isOn)
        let remainingEntries = entries.dropFirst()
        guard !remainingEntries.isEmpty else { return }
        statusMenu.insertItem(.separator(), at: 0)
        let entriesToShow = min(remainingEntries.count, 5)
        for entry in remainingEntries.prefix(entriesToShow).reversed() {
            let entryMenuTitle = entry.description(includingDelta: showBGDeltaMenuItem.isOn, includingTimeAgo: true)
            let entryMenuItem = NSMenuItem(title: entryMenuTitle, action: nil, keyEquivalent: "")
            entryMenuItem.isEnabled = false
            statusMenu.insertItem(entryMenuItem, at: 0)
            entryMenuItems.append(entryMenuItem)
        }
    }

    private func presentError(_ error: NightscoutError) {
        let alert = NSAlert()
        alert.alertStyle = .warning
        alert.messageText = NSLocalizedString("Nightscout Error", comment: "The title text for a Nightscout error alert")
        alert.informativeText = error.elaborateLocalizedDescription
        alert.runModal()

        switch error {
        case .invalidURL,
             .fetchError(URLError.unsupportedURL),
             .fetchError(URLError.cannotFindHost):
            setNightscoutURL() // "invalid URL" error family
        default:
            break
        }
    }

    @IBAction private func toggleShowBGDelta(_ sender: NSMenuItem) {
        sender.isOn.toggle()
        UserDefaults.standard.showBGDeltaMenuItemState = sender.state
        updateUI()
    }

    @IBAction private func toggleShowBGTimeAgo(_ sender: NSMenuItem) {
        sender.isOn.toggle()
        UserDefaults.standard.showBGTimeMenuItemState = sender.state
        updateUI()
    }

    @IBAction private func setNightscoutURLClicked(_ sender: NSMenuItem) {
        setNightscoutURL()
    }

    @IBAction private func quitClicked(sender: NSMenuItem) {
        NSApplication.shared.terminate(self)
    }
}

// MARK: - NightscoutObserver

extension StatusMenuController: NightscoutObserver {
    func downloader(_ nightscout: NightscoutDownloader, didFetchEntries entries: [NightscoutEntry]) {
        DispatchQueue.main.async {
            self.lastUpdated = Date()
        }
    }

    func downloader(_ nightscout: NightscoutDownloader, didErrorWith error: NightscoutError) {
        switch error {
        case .fetchError(URLError.notConnectedToInternet),
             .fetchError(URLError.networkConnectionLost):
            break // ignore these errors
        default:
            DispatchQueue.main.async {
                self.presentError(error)
            }
        }
    }
}
