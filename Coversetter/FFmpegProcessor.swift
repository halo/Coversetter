import Foundation

class FFmpegProcessor {
  private let executor: ShellExecutor
  private let ffmpegPath = "/opt/homebrew/bin/ffmpeg"

  init(executor: ShellExecutor = ShellExecutor()) {
    self.executor = executor
  }

  func setCoverImage(videoURL: URL, imageURL: URL, outputURL: URL) async -> Result {
    let args = [
      "-loglevel", "warning",
      "-hide_banner",
      "-i", videoURL.path,
      "-i", imageURL.path,
      "-map", "1",
      "-map", "0",
      "-codec", "copy",
      "-disposition:0", "attached_pic",
      outputURL.path,
      "-y"
    ]
    return executor.execute(ffmpegPath, arguments: args)
  }

  func extractCoverImage(videoURL: URL, atTime: Double, outputURL: URL) async -> Result {
    let args = [
//      "-loglevel", "warning",
      "-hide_banner",
      "-i", videoURL.path,
      "-ss", "\(atTime)",
      "-vframes", "1",
      outputURL.path
    ]
    return executor.execute(ffmpegPath, arguments: args)
  }
}
