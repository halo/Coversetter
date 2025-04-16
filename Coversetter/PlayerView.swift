import SwiftUI
import AVKit

struct PlayerView: View {
  @State private var player: AVPlayer?
  @State private var isDraggingOver = false
  @State private var videoURL: URL?
  @EnvironmentObject private var coverManager: CoverManager

  var body: some View {
    ZStack {
      Color.black
      if let player = player {
        VideoPlayer(player: player)
      } else {
        VStack(spacing: 10) {
          Text("↓")
            .font(.system(size: 48))
            .foregroundColor(.gray)
          Text("Drop Video File Here")
            .font(.system(size: 18))
            .foregroundColor(.gray)
          Text("To Choose a Cover Image")
            .font(.system(size: 14))
            .foregroundColor(.gray)
        }
      }
      if coverManager.isProcessing {
        VStack {
          ProgressView()
            .progressViewStyle(.circular)
            .controlSize(.large)
          Text(coverManager.statusMessage)
            .foregroundColor(.white)
            .font(.system(size: 14))
            .padding(.top, 8)
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 10))
      }
    }
    .onDrop(of: [.fileURL], isTargeted: $isDraggingOver) { providers in
      coverManager.isProcessing = false
      guard let provider = providers.first else { return false }
      provider.loadItem(forTypeIdentifier: UTType.fileURL.identifier) { item, _ in
        guard let data = item as? Data,
              let url = URL(dataRepresentation: data, relativeTo: nil),
              ["mp4", "mov", "hevc"].contains(url.pathExtension.lowercased()) else {
          return
        }
        DispatchQueue.main.async {
          let playerItem = AVPlayerItem(url: url)
          player = AVPlayer(playerItem: playerItem)
          player?.isMuted = true
          videoURL = url
        }
      }
      return true
    }
    .onReceive(NotificationCenter.default.publisher(for: .saveCover)) { _ in
      guard let player = player, let videoURL = videoURL else { return }
      Task {
        let result = await coverManager.saveCover(player: player, videoURL: videoURL)
        debugPrint("Save cover result: \(result)")
      }
    }
  }
}
