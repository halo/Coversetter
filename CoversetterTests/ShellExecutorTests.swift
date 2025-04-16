import XCTest
@testable import Coversetter

final class ShellExecutorTests: XCTestCase {
  var executor: ShellExecutor!

  override func setUp() {
    super.setUp()
    executor = ShellExecutor()
  }

  func testExecuteSuccess() {
    let result = executor.execute("/bin/echo", arguments: ["hello"])
    XCTAssertTrue(result.isSuccess)
    XCTAssertEqual(result.success, "ok")
    XCTAssertEqual(result.attributes("output")?.trimmingCharacters(in: .newlines), "hello")
  }

  func testExecuteMissingExecutable() {
    let result = executor.execute("/nonexistent", arguments: [])
    XCTAssertTrue(result.isFailure)
    XCTAssertEqual(result.failure, "launch_failed")
    XCTAssertFalse(result.attributes("message")?.isEmpty ?? true)
  }

  func testExecuteFailure() {
    let result = executor.execute("/bin/ls", arguments: ["/nonexistent"])
    XCTAssertTrue(result.isFailure)
    XCTAssertEqual(result.failure, "command_failed")
    XCTAssertEqual(result.attributes("status"), "1")
    XCTAssertFalse(result.attributes("message")?.isEmpty ?? true)
  }
}
