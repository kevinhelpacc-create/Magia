import AVFoundation

/// Plays a short cue bundled with the app (add audio files to the
/// `Resources/Sounds` group in Xcode and reference their exact filename,
/// e.g. "chime.caf", from a `PLAY_SOUND` step).
final class SoundManager {
    private var player: AVAudioPlayer?

    func play(named name: String) {
        guard !name.isEmpty else { return }
        let filename = name as NSString
        let url = Bundle.main.url(forResource: name, withExtension: nil)
            ?? Bundle.main.url(
                forResource: filename.deletingPathExtension,
                withExtension: filename.pathExtension
            )
        guard let url else { return }

        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.ambient, options: [.mixWithOthers])
            try session.setActive(true)
            player = try AVAudioPlayer(contentsOf: url)
            player?.play()
        } catch {
            // Never let a missing/broken sound file interrupt a live performance.
        }
    }
}
