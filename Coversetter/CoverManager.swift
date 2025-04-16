import SwiftUI
import AVKit

class CoverManager: ObservableObject {
  func saveCover(player: AVPlayer, videoURL: URL) async -> Result {
    debugPrint("Extracting still image...")
    let extractor = FrameExtractor()
    guard let jpegData = await extractor.extractFrame(from: player, seekTime: player.currentTime()) else {
      return .failure(code: "frame_extraction_failed", attributes: ["message": "Failed to extract frame"])
    }

    let tempImageURL = URL(fileURLWithPath: NSTemporaryDirectory())
      .appendingPathComponent(UUID().uuidString)
      .appendingPathExtension("jpg")

    let outputURL = URL(fileURLWithPath: NSTemporaryDirectory())
      .appendingPathComponent(UUID().uuidString)
      .appendingPathExtension(videoURL.pathExtension)

    do {
      try jpegData.write(to: tempImageURL)
      debugPrint("Image saved to \(tempImageURL)...")
    } catch {
      return .failure(code: "file_write_failed", attributes: ["message": "Failed to write temp image: \(error.localizedDescription)"])
    }

    let processor = FFmpegProcessor()

    debugPrint("Attaching image \(tempImageURL) to video \(videoURL) to new file at \(outputURL)...")
    let result = await processor.setCoverImage(videoURL: videoURL, imageURL: tempImageURL, outputURL: outputURL)

    try? FileManager.default.removeItem(at: tempImageURL)

    if result.isSuccess {
      debugPrint("Swapping video from \(outputURL) to \(videoURL)...")
      do {
        try FileManager.default.removeItem(at: videoURL)
        try FileManager.default.moveItem(at: outputURL, to: videoURL)
      } catch {
        try? FileManager.default.removeItem(at: outputURL)
        return .failure(code: "file_move_failed", attributes: ["message": "Failed to update video: \(error.localizedDescription)"])
      }
    } else {
      try? FileManager.default.removeItem(at: outputURL)
    }

    return result
  }
}
