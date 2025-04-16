import XCTest
@testable import Coversetter
import AVFoundation

final class FrameExtractorTests: XCTestCase {
  var extractor: FrameExtractor!

  override func setUp() {
    super.setUp()
    extractor = FrameExtractor()
  }

  func testExtractFrameNoPlayer() async {
    let player = AVPlayer()
    let image = await extractor.extractFrame(from: player, seekTime: .zero)
    XCTAssertNil(image)
  }

  func testExtractFrameWithPlayer() async throws {
    let url = Bundle(for: Self.self).url(forResource: "test", withExtension: "mp4")!
    let playerItem = AVPlayerItem(url: url)
    let player = AVPlayer(playerItem: playerItem)

    let expectation = XCTestExpectation(description: "Player ready")
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
      expectation.fulfill()
    }
    await fulfillment(of: [expectation], timeout: 1.0)

    let image = await extractor.extractFrame(from: player, seekTime: .zero)
    XCTAssertNotNil(image)
  }
}
