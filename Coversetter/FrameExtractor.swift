import AVFoundation
import AppKit

class FrameExtractor {
  func extractFrame(from player: AVPlayer, seekTime: CMTime) async -> CGImage? {
    guard let asset = await player.currentItem?.asset else {
      return nil
    }

    let generator = AVAssetImageGenerator(asset: asset)
    generator.appliesPreferredTrackTransform = true

    return await withCheckedContinuation { continuation in
      generator.generateCGImageAsynchronously(for: seekTime) { image, _, error in
        if image != nil, error == nil {
          continuation.resume(returning: image)
        } else {
          continuation.resume(returning: nil)
        }
      }
    }
  }
}
