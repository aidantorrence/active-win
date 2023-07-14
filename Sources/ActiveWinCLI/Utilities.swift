import AppKit
import Sentry
import Foundation

struct ScriptError: Error {
    let message: String
}

func getActiveTabUrl(windowId: Int) -> String? {
		SentrySDK.capture(message: "Input window id: \(windowId)")
    let scriptSource = """
    tell application "Google Chrome"
        set windowIds to {}
        set allWindows to every window
        repeat with aWindow in allWindows
            set end of windowIds to id of aWindow
            if id of aWindow is "\(windowId)" then
                return URL of active tab of aWindow
            end if
        end repeat
        return windowIds
    end tell
    """

    var error: NSDictionary?
    let script = NSAppleScript(source: scriptSource)
    let output = script?.executeAndReturnError(&error)
    
    if let error = error {
        print("Error: \(error)")
        let scriptError = ScriptError(message: "AppleScript Error: \(error)")
        SentrySDK.capture(error: scriptError)
        return nil
    } else {
        let result = output?.stringValue
        SentrySDK.capture(message: "Result: \(result ?? "null")")
        return result
    }
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
