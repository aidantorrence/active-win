import AppKit
import Sentry
import Foundation

struct ScriptError: Error {
    let message: String
}

func getActiveTabUrl() -> String? {
    let scriptSource = """
        tell application "Google Chrome"
            return URL of active tab of front window
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
        // SentrySDK.capture(message: "Result: \(result ?? "null")")
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
