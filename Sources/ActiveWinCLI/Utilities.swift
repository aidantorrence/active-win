import AppKit


@discardableResult
func runAppleScript(source: String) -> String? {
    var error: NSDictionary?
    if let output: NSAppleEventDescriptor = NSAppleScript(source: source)?.executeAndReturnError(&error) {
        return output.stringValue
    } else if let error = error {
        SentrySDK.capture(error: NSError(domain: "com.yourdomain.yourapp", code: 9999, userInfo: error as? [String: Any]))
        print("Error running AppleScript: \(error)")
    }
    return nil
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
