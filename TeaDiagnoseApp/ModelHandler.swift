import CoreML

class ModelHandler {
    static let shared = ModelHandler()

    private var model: RecommendTea?

    private init() {
        do {
            let config = MLModelConfiguration()
            model = try RecommendTea(configuration: config)
        } catch {
            print("モデルの読み込みに失敗しました: \(error)")
            model = nil
        }
    }

    func predict(mood: String, time: String, temperature: Int64, caffeine: String, reason: String) -> String? {
        guard let model = model else {
            print("モデルが未ロード")
            return nil
        }

        do {
            let input = RecommendTeaInput(
                mood: mood,
                time: time,
                temperature: temperature,
                caffeine: caffeine,
                reason: reason // ← 必ずカテゴリ単語にする（relax, focusなど）
            )
            let output = try model.prediction(input: input)
            return output.recommendation
        } catch {
            print("予測に失敗しました（recommendation）: \(error)")
            return nil
        }
    }
}
