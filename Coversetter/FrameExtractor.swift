import AVFoundation
import AppKit

class FrameExtractor {
  func extractFrame(from player: AVPlayer, seekTime: CMTime) async -> Data? {
    guard let asset = await player.currentItem?.asset else {
      return nil
    }

    let generator = AVAssetImageGenerator(asset: asset)
    generator.appliesPreferredTrackTransform = true

    return await withCheckedContinuation { continuation in
      generator.generateCGImageAsynchronously(for: seekTime) { cgimage, _, error in
        guard let cgimage = cgimage, error == nil else {
          continuation.resume(returning: nil)
          return
        }

        let image = NSImage(cgImage: cgimage, size: .zero)
        guard let tiffData = image.tiffRepresentation,
              let bitmap = NSBitmapImageRep(data: tiffData),
              let jpegData = bitmap.representation(using: .jpeg, properties: [:]) else {
          continuation.resume(returning: nil)
          return
        }

        continuation.resume(returning: jpegData)
      }
    }
  }
}
