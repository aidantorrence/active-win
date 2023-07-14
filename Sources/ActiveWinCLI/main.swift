import AppKit
import Sentry

func exitWithoutResult() -> Never {
	print("null")
	exit(0)
}

func printOutput(_ output: Any) -> Never {
	guard let string = try? toJson(output) else {
		exitWithoutResult()
	}

	print(string)
	exit(0)
}

func getWindowInformation(window: [String: Any], windowOwnerPID: pid_t) -> [String: Any]? {
	// Skip transparent windows, like with Chrome.
	if (window[kCGWindowAlpha as String] as! Double) == 0 { // Documented to always exist.
		return nil
	}

	let bounds = CGRect(dictionaryRepresentation: window[kCGWindowBounds as String] as! CFDictionary)! // Documented to always exist.

	// Skip tiny windows, like the Chrome link hover statusbar.
	let minWinSize: CGFloat = 50
	if bounds.width < minWinSize || bounds.height < minWinSize {
		return nil
	}

	// This should not fail as we're only dealing with apps, but we guard it just to be safe.
	guard let app = NSRunningApplication(processIdentifier: windowOwnerPID) else {
		return nil
	}

	let appName = window[kCGWindowOwnerName as String] as? String ?? app.bundleIdentifier ?? "<Unknown>"

	let windowName = window[kCGWindowName as String] ?? ""
	SentrySDK.capture(message: "Window name: \(windowName)")

	let windowId = window[kCGWindowNumber as String] as! Int

	if app.bundleIdentifier == "com.apple.dock" {
		return nil
	}

	var output: [String: Any] = [
		"platform": "macos",
		"title": windowName,
		"id": windowId,
		"bounds": [
			"x": bounds.origin.x,
			"y": bounds.origin.y,
			"width": bounds.width,
			"height": bounds.height
		],
		"owner": [
			"name": appName,
			"processId": windowOwnerPID,
			"bundleId": app.bundleIdentifier ?? "", // I don't think this could happen, but we also don't want to crash.
			"path": app.bundleURL?.path ?? "" // I don't think this could happen, but we also don't want to crash.
		],
		"memoryUsage": window[kCGWindowMemoryUsage as String] as? Int ?? 0
	]

	// Only run the AppleScript if active window is a compatible browser.
	if let bundleIdentifier = app.bundleIdentifier, bundleIdentifier == "com.google.Chrome" {
		SentrySDK.capture(message: "Chrome detected")
			let url = getActiveTabUrl() ?? ""
			SentrySDK.capture(message: "Chrome details: \(url)")
					output["url"] = url
	}


	return output
}

SentrySDK.start { options in
		options.dsn = "https://b681c9619d704f729239969759700ae9@o1411142.ingest.sentry.io/4505524188807168"
		options.debug = true // Enabled debug when first installing is always helpful
}

let enableOpenWindowsList = CommandLine.arguments.contains("--open-windows-list")



guard
	let frontmostAppPID = NSWorkspace.shared.frontmostApplication?.processIdentifier,
	let windows = CGWindowListCopyWindowInfo([.optionOnScreenOnly, .excludeDesktopElements], kCGNullWindowID) as? [[String: Any]]
else {
	exitWithoutResult()
}

var openWindows = [[String: Any]]();

for window in windows {
	let windowOwnerPID = window[kCGWindowOwnerPID as String] as! pid_t // Documented to always exist.
	if !enableOpenWindowsList && windowOwnerPID != frontmostAppPID {
		continue
	}

	guard let windowInformation = getWindowInformation(window: window, windowOwnerPID: windowOwnerPID) else {
		continue
	}

	if !enableOpenWindowsList {
		printOutput(windowInformation)
	} else {
		openWindows.append(windowInformation)
	}
}

if !openWindows.isEmpty {
	printOutput(openWindows)
}

exitWithoutResult()
