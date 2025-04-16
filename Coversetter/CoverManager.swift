import SwiftUI
import AVKit

class CoverManager: ObservableObject {
  @Published var isProcessing = false
  @Published var statusMessage = ""
  let processor = FFmpegProcessor()

  func saveCover(player: AVPlayer, videoURL: URL) async -> Result {
    await MainActor.run {
      isProcessing = true
      statusMessage = "Extracting frame..."
    }
    debugPrint("Extracting image of video \(videoURL)...")

    let tempImageURL = URL(fileURLWithPath: NSTemporaryDirectory())
      .appendingPathComponent(UUID().uuidString)
      .appendingPathExtension("jpg")

    let time = CMTimeGetSeconds(player.currentTime())
    let extractionResult = await processor.extractCoverImage(videoURL: videoURL, atTime: time, outputURL: tempImageURL)
    guard extractionResult.isSuccess else {
      await MainActor.run {
        isProcessing = false
        statusMessage = ""
      }
      return extractionResult
    }

    await MainActor.run {
      statusMessage = "Embedding cover..."
    }
    let tempVideoURL = URL(fileURLWithPath: NSTemporaryDirectory())
      .appendingPathComponent(UUID().uuidString)
      .appendingPathExtension(videoURL.pathExtension)

    debugPrint("Attaching image \(tempImageURL.absoluteString) to video \(videoURL.absoluteString) to new file at \(tempVideoURL.absoluteString)")
    let result = await processor.setCoverImage(videoURL: videoURL, imageURL: tempImageURL, outputURL: tempVideoURL)

    try? FileManager.default.removeItem(at: tempImageURL)

    if result.isSuccess {
      await MainActor.run {
        statusMessage = "Updating video..."
      }
      debugPrint("Swapping video from \(tempVideoURL) to \(videoURL)...")
      do {
        try FileManager.default.removeItem(at: videoURL)
        try FileManager.default.moveItem(at: tempVideoURL, to: videoURL)
      } catch {
        try? FileManager.default.removeItem(at: tempVideoURL)
        await MainActor.run {
          isProcessing = false
          statusMessage = ""
        }
        return .failure(code: "file_move_failed", attributes: ["message": "Failed to update video: \(error.localizedDescription)"])
      }
    } else {
      try? FileManager.default.removeItem(at: tempVideoURL)
    }

    await MainActor.run {
      isProcessing = false
      statusMessage = ""
    }
    return result
  }
}
