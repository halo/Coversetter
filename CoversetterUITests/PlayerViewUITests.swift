//import XCTest
//
//final class PlayerViewUITests: XCTestCase {
//  var app: XCUIApplication!
//
//  override func setUp() {
//    super.setUp()
//    app = XCUIApplication()
//    app.launch()
//  }
//
//  func testDropVideoDisplaysPlayer() {
//    let window = app.windows.firstMatch
//    XCTAssertTrue(window.staticTexts["Drop Video Here"].exists)
//
//    let videoURL = Bundle(for: Self.self).url(forResource: "test", withExtension: "mp4")!
//    window.performDragAndDrop(fileURL: videoURL)
//
//    XCTAssertFalse(window.staticTexts["Drop Video Here"].exists)
//    XCTAssertTrue(window.otherElements["AVPlayerView"].exists)
//  }
//}
//
//extension XCUIElement {
//  func performDragAndDrop(fileURL: URL) {
//    // Stub; needs real drag-and-drop implementation
//  }
//}
