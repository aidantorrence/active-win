import AppKit
import Sentry

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
    var error: NSDictionary?
    var windowDetailsList = [(name: String, url: URL?)]()
    if let scriptObject = NSAppleScript(source: script) {
        if let output = scriptObject.executeAndReturnError(&error).listValue {
            for descriptor in output {
                if let recordDescriptor = descriptor.at(1),
                   let name = recordDescriptor.at(1)?.stringValue,
                   let urlString = recordDescriptor.at(2)?.stringValue {
                    windowDetailsList.append((name: name, url: URL(string: urlString)))
                }
            }
        } else if let error = error {
            print("error: \(String(describing: error))")
            SentrySDK.capture(error: NSError(domain: error.domain, code: error.code, userInfo: error as? [String: Any]))
        }
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
