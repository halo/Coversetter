import XCTest
@testable import Coversetter

final class FFmpegProcessorTests: XCTestCase {
  var executor: MockShellExecutor!
  var processor: FFmpegProcessor!

  override func setUp() {
    super.setUp()
    executor = MockShellExecutor()
    processor = FFmpegProcessor(executor: executor)
  }

  func testSetCoverImageSuccess() async {
    executor.result = .success(code: "ok", attributes: ["output": ""])
    let videoURL = URL(fileURLWithPath: "/test/video.mp4")
    let imageURL = URL(fileURLWithPath: "/test/cover.jpg")
    let outputURL = URL(fileURLWithPath: "/test/output.mp4")

    let result = await processor.setCoverImage(videoURL: videoURL, imageURL: imageURL, outputURL: outputURL)

    XCTAssertTrue(result.isSuccess)
    XCTAssertEqual(executor.command, "/opt/homebrew/bin/ffmpeg")
    XCTAssertEqual(executor.arguments, [
      "--input", "/test/video.mp4",
      "--input", "/test/cover.jpg",
      "--map", "0",
      "--map", "1",
      "--codec", "copy",
      "--disposition:v:1", "attached_pic",
      "/test/output.mp4",
      "--yes"
    ])
  }

  func testSetCoverImageFailure() async {
    executor.result = .failure(code: "command_failed", attributes: ["status": "1", "message": "ffmpeg failed"])
    let videoURL = URL(fileURLWithPath: "/test/video.mp4")
    let imageURL = URL(fileURLWithPath: "/test/cover.jpg")
    let outputURL = URL(fileURLWithPath: "/test/output.mp4")

    let result = await processor.setCoverImage(videoURL: videoURL, imageURL: imageURL, outputURL: outputURL)

    XCTAssertTrue(result.isFailure)
    XCTAssertEqual(result.failure, "command_failed")
    XCTAssertEqual(result.attributes("status"), "1")
    XCTAssertEqual(result.attributes("message"), "ffmpeg failed")
  }
}

class MockShellExecutor: ShellExecutor {
  var command: String?
  var arguments: [String]?
  var result: Result?

  override func execute(_ command: String, arguments: [String]) -> Result {
    self.command = command
    self.arguments = arguments
    return result ?? .success(code: "ok", attributes: [:])
  }
}
