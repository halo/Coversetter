import SwiftUI
import AVKit

class CoverManager: ObservableObject {
  let processor = FFmpegProcessor()

  func saveCover(player: AVPlayer, videoURL: URL) async -> Result {

    let tempImageURL = URL(fileURLWithPath: NSTemporaryDirectory())
      .appendingPathComponent(UUID().uuidString)
      .appendingPathExtension("jpg")

    debugPrint("Extracting image of video \(videoURL) to new image file at \(tempImageURL)...")

    let time = CMTimeGetSeconds(player.currentTime())
    let extractionResult = await processor.extractCoverImage(videoURL: videoURL, atTime: time, outputURL: tempImageURL)
    guard extractionResult.isSuccess else { return extractionResult }

    let tempVideoURL = URL(fileURLWithPath: NSTemporaryDirectory())
      .appendingPathComponent(UUID().uuidString)
      .appendingPathExtension(videoURL.pathExtension)

    debugPrint("Attaching image \(tempImageURL.absoluteString) to video \(videoURL.absoluteString) to new file at \(tempVideoURL.absoluteString)")
    let result = await processor.setCoverImage(videoURL: videoURL, imageURL: tempImageURL, outputURL: tempVideoURL)
    guard result.isSuccess else { return extractionResult }

    try? FileManager.default.removeItem(at: tempImageURL)

    if result.isSuccess {
      debugPrint("Swapping video from \(tempVideoURL) to \(videoURL)...")
      do {
        try FileManager.default.removeItem(at: videoURL)
        try FileManager.default.moveItem(at: tempVideoURL, to: videoURL)
      } catch {
        try? FileManager.default.removeItem(at: tempVideoURL)
        return .failure(code: "file_move_failed", attributes: ["message": "Failed to update video: \(error.localizedDescription)"])
      }
    } else {
      try? FileManager.default.removeItem(at: tempVideoURL)
    }

    return result
  }
}
