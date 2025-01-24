import Foundation

/// To enable logging, create an empty file under `$TMPDIR/swift_tui.log`. Logging will append to the
/// end of this file.
///
/// You can monitor the log live using:
/// ```
/// tail -f $TMPDIR/swift_tui.log
/// ```
///
/// TMPDIR falls back to TMP then TEMP, otherwise C:\Users\(UserName)\AppData\Local\Temp on Windows or /tmp on *nix
public func log(_ item: Any, terminator: String = "\n") {
    print(item, terminator: terminator, to: &logStream)
}

#if os(Windows)
    let fallback = "C:\\Users\\\(ProcessInfo.processInfo.userName)\\AppData\\Local\\Temp"
#else
    let fallback = "/tmp"
#endif
let logPath = ProcessInfo.processInfo.environment["TMPDIR"] ?? ProcessInfo.processInfo.environment["TMP"] ?? ProcessInfo.processInfo.environment["TEMP"] ?? fallback

let logURL = URL(fileURLWithPath: "\(logPath)/swift_tui\(ProcessInfo.processInfo.processIdentifier).log")

var logStream = LogStream()
struct LogStream: TextOutputStream {
    func write(_ string: String) {
        guard let data = string.data(using: .utf8) else {
            assertionFailure("Cannot write to log")
            return
        }
        if let fileHandle = try? FileHandle(forWritingTo: logURL) {
            fileHandle.seekToEndOfFile()
            fileHandle.write(data)
            fileHandle.closeFile()
        }
    }
}

