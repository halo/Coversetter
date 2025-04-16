import Foundation

class ShellExecutor {
  @discardableResult
  func execute(_ command: String, arguments: [String]) -> Result {
    let process = Process()
    process.executableURL = URL(fileURLWithPath: command)
    process.arguments = arguments

    let outputPipe = Pipe()
    let errorPipe = Pipe()
    process.standardOutput = outputPipe
    process.standardError = errorPipe

    do {
      try process.run()
    } catch {
      return .failure(code: "launch_failed", attributes: ["message": "Failed to launch \(command): \(error.localizedDescription)"])
    }

    process.waitUntilExit()

    let output = String(data: outputPipe.fileHandleForReading.readDataToEndOfFile(), encoding: .utf8) ?? ""
    let error = String(data: errorPipe.fileHandleForReading.readDataToEndOfFile(), encoding: .utf8) ?? ""

    if process.terminationStatus == 0 {
      return .success(code: "ok", attributes: ["output": output])
    } else {
      return .failure(code: "command_failed", attributes: ["status": "\(process.terminationStatus)", "message": error])
    }
  }
}
