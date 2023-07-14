import AppKit
import Sentry

struct ScriptError: Error {
    let message: String
}

func getActiveTabDetailsFromAllWindows() -> [(name: String, url: URL?)] {
    let script = """
    tell application "Google Chrome"
        set windowList to every window
        set windowDetails to {}
        repeat with aWindow in windowList
            set windowName to name of aWindow
            set windowURL to URL of active tab of aWindow
            set end of windowDetails to {windowName:windowName, windowURL:windowURL}
        end repeat
        return windowDetails
    end tell
    """
    var windowDetailsList = [(name: String, url: URL?)]()
    
    let scriptObject = NSAppleScript(source: script)
    var error: NSDictionary? = nil
    let output = scriptObject?.executeAndReturnError(&error)
    if let error = error {
        print("Error: \(error)")
				let scriptError = ScriptError(message: "AppleScript Error: \(error)")
				SentrySDK.capture(error: scriptError)
    } else if let stringValue = output?.stringValue {
				let data = stringValue.data(using: .utf8)!
				do {
						let json = try JSONSerialization.jsonObject(with: data, options: []) as! [[String: Any]]
						for window in json {
								let name = window["windowName"] as! String
								let url = window["windowURL"] as! String
								windowDetailsList.append((name: name, url: URL(string: url)))
						}
				} catch {
						print("Error: \(error)")
						let scriptError = ScriptError(message: "AppleScript Error: \(error)")
						SentrySDK.capture(error: scriptError)
				}
    } else {
        print("Output descriptor did not contain a string.")
    }
    
    return windowDetailsList
}






func toJson<T>(_ data: T) throws -> String {
	let json = try JSONSerialization.data(withJSONObject: data)
	return String(data: json, encoding: .utf8)!
}


// Show the system prompt if there's no permission.
func hasScreenRecordingPermission() -> Bool {
	CGDisplayStream(
		dispatchQueueDisplay: CGMainDisplayID(),
		outputWidth: 1,
		outputHeight: 1,
		pixelFormat: Int32(kCVPixelFormatType_32BGRA),
		properties: nil,
		queue: DispatchQueue.global(),
		handler: { _, _, _, _ in }
	) != nil
}
