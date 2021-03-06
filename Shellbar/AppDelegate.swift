//
//  Created by Patrick Hart on 11/17/15.
//  Copyright © 2015-2016 Patrick Hart. All rights reserved.
//

// SwiftLint
// swiftlint:disable trailing_whitespace
// swiftlint:disable line_length

import Foundation
import Cocoa
import AppleScriptKit
import AppleScriptObjC
import SwiftShell

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    @IBOutlet weak var window: NSWindow!
    @IBOutlet weak var view: NSView!

    let statusItem = NSStatusBar.systemStatusBar().statusItemWithLength(NSVariableStatusItemLength)

    // SHOW / HIDE HIDDEN FILES
    func ShowHideFiles(sender: AnyObject) {
        run("if [[ \"$(defaults read com.apple.Finder AppleShowAllFiles)\" = FALSE ]]; then defaults write com.apple.Finder AppleShowAllFiles TRUE && killall Finder; else defaults write com.apple.Finder AppleShowAllFiles FALSE && killall Finder; fi")
    }
    // CLEAR LOGS
    func ClearLogs(sender: AnyObject) {
        NSAppleScript(source: "do shell script \"sudo rm -fdrv /tmp/*; sudo rm -fdrv /var/tmp/*; sudo rm -fdrv /var/log/*; sudo rm -fdrv /private/tmp/*; sudo rm -fdrv /private/var/log/*\" with administrator " +
            "privileges")!.executeAndReturnError(nil)
    }
    // EMPTY TRASH
    func EmptyTrash(sender: AnyObject) {
        run("rm -fdrv ~/.Trash/*")
        // Old way, needs admin privileges. Emptying the trash shouldn't need that.
        //NSAppleScript(source: "do shell script \"sudo rm -fdrv ~/.Trash/*\" with administrator " +
        //    "privileges")!.executeAndReturnError(nil)
    }
    // Lock Screen
    func LockScreen(sender: AnyObject) {
        let IOReg = IORegistryEntryFromPath(kIOMasterPortDefault, "IOService:/IOResources/IODisplayWrangler")
        if (IOReg > 0) {
            IORegistryEntrySetCFProperty(IOReg, "IORequestIdle", kCFBooleanTrue)
            IOObjectRelease(IOReg)
        }
    }
    // ABOUT SHELLBAR
    func AboutShellbar(sender: AnyObject) {
        let AboutAlert: NSAlert = NSAlert()
        AboutAlert.messageText = "Created by Patrick Hart\nhttp://thrifus.co/"
        AboutAlert.informativeText = "If you find a bug in Shellbar, please, contact me. Make sure you use lots of details in your report, too.\nI can't help if you just complain."
        AboutAlert.addButtonWithTitle("Close")
        AboutAlert.addButtonWithTitle("Contact Me")
        if AboutAlert.runModal() == NSAlertSecondButtonReturn {
            let os = NSProcessInfo().operatingSystemVersion
            let OSTYPE = String("OS X \(os.majorVersion).\(os.minorVersion).\(os.patchVersion)")
            print(OSTYPE)

            let body = "NOTE: IF YOU ARE SUBMITTING ONE OR THE OTHER, JUST TYPE \"NONE\" IN THE ONE YOU DON'T WANT TO SUBMIT.\nYOU CAN DELETE THIS PART NOW.\n\nBUG REPORT:\n<REPLACE WITH THE BUG YOU FOUND>\n\n\nFEATURE REQUEST:\n<REPLACE WITH YOUR FEATURE REQUEST>"
            let shareItems = [body] as NSArray
            let service = NSSharingService(named: NSSharingServiceNameComposeEmail)
            service?.recipients = ["thrifus@gmail.com"]
            let subject = "<CHANGE THIS TO YOUR OWN SUBJECT DEPENDING ON WHAT YOU ARE SUBMITTING>"
            service?.subject = subject
            service?.performWithItems(shareItems as [AnyObject])
        }
    }
    func GetExternalIP(sender: AnyObject) {
        run("dig +short myip.opendns.com @resolver1.opendns.com | pbcopy")
    }
    func GetInternalIP(sender: AnyObject) {
        run("ipconfig getifaddr en0 | pbcopy")
    }
    func ScreenSaver(sender: AnyObject) {
        run("open /System/Library/Frameworks/ScreenSaver.framework/Versions/A/Resources/ScreenSaverEngine.app")
    }

    // NOTE: notification
    func applicationDidFinishLaunching(aNotification: NSNotification) {
        if let button = statusItem.button {
            button.image = NSImage(named: "StatusBarIcon")
        }

        let menu = NSMenu()
        // MENU ITEMS
        menu.addItem(NSMenuItem(title: "About Shellbar", action: Selector("AboutShellbar:"), keyEquivalent: ""))
            menu.addItem(NSMenuItem.separatorItem())
        menu.addItem(NSMenuItem(title: "Show / Hide Hidden Files", action: Selector("ShowHideFiles:"), keyEquivalent: ""))
            menu.addItem(NSMenuItem.separatorItem())
        menu.addItem(NSMenuItem(title: "Clear Logs", action: Selector("ClearLogs:"), keyEquivalent: ""))
        menu.addItem(NSMenuItem(title: "Empty Trash", action: Selector("EmptyTrash:"), keyEquivalent: ""))
            menu.addItem(NSMenuItem.separatorItem())
        menu.addItem(NSMenuItem(title: "Lock Screen", action: Selector("LockScreen:"), keyEquivalent: ""))
        menu.addItem(NSMenuItem(title: "Start Screensaver", action: Selector("ScreenSaver:"), keyEquivalent: ""))
        // Get ready for when I figure out how to copy text to the clipboard. Feel free to help with that by the way.
            menu.addItem(NSMenuItem.separatorItem())
        menu.addItem(NSMenuItem(title: "External IP:", action: Selector(""), keyEquivalent: ""))
        menu.addItem(NSMenuItem(title: "\(run("dig +short myip.opendns.com @resolver1.opendns.com").read())", action: Selector("GetExternalIP:"), keyEquivalent: ""))
        menu.addItem(NSMenuItem(title: "Internal IP:", action: Selector(""), keyEquivalent: ""))
        menu.addItem(NSMenuItem(title: "\(run("ipconfig getifaddr en0").read())", action: Selector("GetInternalIP:"), keyEquivalent: ""))
            menu.addItem(NSMenuItem.separatorItem())
        menu.addItem(NSMenuItem(title: "Quit Shellbar", action: Selector("terminate:"), keyEquivalent: ""))
        statusItem.menu = menu
    }
    // NOTE: notification
    func applicationWillTerminate(aNotification: NSNotification) {}
}
