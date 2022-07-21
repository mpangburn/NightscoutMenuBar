# Nightscout Menu Bar

A lightweight macOS menu bar application for displaying [Nightscout](https://github.com/nightscout/cgm-remote-monitor#nightscout-web-monitor-aka-cgm-remote-monitor) blood glucose data.

![Open Menu Bar](https://github.com/CodeMonkeyPrime/NightscoutMenuBar/blob/master/Screenshots/open%20menu%20bar.png?raw=true)

- [x] Displays Nightscout blood glucose data in the menu bar
- [x] Displays recent blood glucose history on click
- [x] Automatically pulls units (mg/dL or mmol/L) from Nightscout
- [x] Options to configure glucose display (optionally include delta and time)

## Installation
* Download the latest version from the [releases page](https://github.com/CodeMonkeyPrime/NightscoutMenuBar/releases) extract the .zip file.
* Move Nightscout Menu Bar.app to your Applications folder.
* Launch the application and enter your Nightscout URL when prompted.
* (Optional) Launch the application on startup by adding it to System Preferences > Users and Groups > Login Items.

## Notes
* This version doesn't require HTTPS.  This is helpful (though insecure) if your Nightscout server can't support HTTPS.
* [Submit an issue](https://github.com/CodeMonkeyPrime/NightscoutMenuBar/issues) to report a bug, suggest a new feature, or provide feedback.
* When reporting a bug, go to [yourNightscoutURL]/api/v1/entries.json and copy/paste the data you see into your issue submission.

## Credits
Forked from [mpangburn](https://github.com/mpangburn/NightscoutMenuBar).  Thank you carrying this great utility forward!
