import Foundation

class FFmpegProcessor {
  private let executor: ShellExecutor
  private let ffmpegPath = "/opt/homebrew/bin/ffmpeg"

  init(executor: ShellExecutor = ShellExecutor()) {
    self.executor = executor
  }

  func setCoverImage(videoURL: URL, imageURL: URL, outputURL: URL) async -> Result {
    let args = [
      "--input", videoURL.path,
      "--input", imageURL.path,
      "--map", "0",
      "--map", "1",
      "--codec", "copy",
      "--disposition:v:1", "attached_pic",
      outputURL.path,
      "--yes"
    ]
    return executor.execute(ffmpegPath, arguments: args)
  }
}
