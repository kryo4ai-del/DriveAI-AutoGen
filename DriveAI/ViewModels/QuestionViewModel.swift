import AVFoundation

class QuestionViewModel: ObservableObject {
    var audioPlayer: AVAudioPlayer?
    
    func playSound(for answerFeedback: FeedbackType) {
        let soundName = answerFeedback == .correct ? "correct" : "incorrect"
        guard let url = Bundle.main.url(forResource: soundName, withExtension: "mp3") else { return }
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.play()
        } catch {
            print("Could not load sound file.")
        }
    }
    
    func submitAnswer(_ answer: String) -> Bool {
        let isCorrect = isAnswerCorrect(answer)
        playSound(for: isCorrect ? .correct : .incorrect)
        return isCorrect
    }
}