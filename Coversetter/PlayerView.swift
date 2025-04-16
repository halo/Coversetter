import SwiftUI
import AVKit

struct PlayerView: View {
  @State private var player: AVPlayer?
  @State private var isDraggingOver = false

  var body: some View {
    ZStack {
      if let player = player {
        VideoPlayer(player: player)
      } else {
        Text("Drop Video Here")
          .foregroundColor(.gray)
      }
    }
    .background(.black)
    .onDrop(of: [.fileURL], isTargeted: $isDraggingOver) { providers in
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
        }
      }
      return true
    }
  }
}
