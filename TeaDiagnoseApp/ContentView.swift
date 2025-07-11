import SwiftUI

struct ContentView: View {
    @State private var mood = "calm"
    @State private var time = "morning"
    @State private var temperature = 25
    @State private var caffeine = "low"

    @State private var recommendation: String?
    @State private var commentText: String?

    let moods = ["calm", "active", "tired"]
    let times = ["morning", "afternoon", "evening"]
    let caffeineLevels = ["none", "low", "medium", "high"]

    let teaNameMap: [String: String] = [
        "green_tea": "緑茶",
        "black_tea": "紅茶",
        "oolong_tea": "烏龍茶",
        "herbal_tea": "ハーブティー",
        "matcha": "抹茶",
        "chamomile": "カモミール",
        "peppermint": "ペパーミント",
        "jasmine_tea": "ジャスミン茶"
    ]

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("気分")) {
                    Picker("気分", selection: $mood) {
                        ForEach(moods, id: \.self) { Text($0) }
                    }.pickerStyle(SegmentedPickerStyle())
                }

                Section(header: Text("時間帯")) {
                    Picker("時間帯", selection: $time) {
                        ForEach(times, id: \.self) { Text($0) }
                    }.pickerStyle(SegmentedPickerStyle())
                }

                Section(header: Text("気温")) {
                    Stepper(value: $temperature, in: -10...40) {
                        Text("\(temperature)℃")
                    }
                }

                Section(header: Text("カフェイン量")) {
                    Picker("カフェイン", selection: $caffeine) {
                        ForEach(caffeineLevels, id: \.self) { Text($0) }
                    }.pickerStyle(SegmentedPickerStyle())
                }

                Button("AIにお茶を診断させる") {
                    diagnoseTea()
                }

                if let recommendation = recommendation {
                    let teaJP = teaNameMap[recommendation] ?? recommendation

                    Section(header: Text("おすすめのお茶")) {
                        Text(teaJP)
                    }
                }

                if let commentText = commentText {
                    Section(header: Text("AIコメント")) {
                        Text(commentText)
                    }
                }
            }
            .navigationTitle("お茶診断AI")
        }
    }

    func diagnoseTea() {
        let reason = determineReason(mood: mood, time: time, temperature: temperature, caffeine: caffeine)
        print("診断入力: mood=\(mood), time=\(time), temperature=\(temperature), caffeine=\(caffeine), reason=\(reason)")

        guard let result = ModelHandler.shared.predict(
            mood: mood,
            time: time,
            temperature: Int64(temperature),
            caffeine: caffeine,
            reason: reason
        ) else {
            self.recommendation = nil
            self.commentText = "診断に失敗しました。"
            return
        }

        self.recommendation = result
        let teaJP = teaNameMap[result] ?? result
        self.commentText = generateJapaneseComment(
            mood: mood,
            time: time,
            temperature: temperature,
            caffeine: caffeine,
            teaJP: teaJP,
            reason: reason
        )
    }

    func determineReason(mood: String, time: String, temperature: Int, caffeine: String) -> String {
        if mood == "tired" && time == "evening" {
            return "recover"
        } else if mood == "active" && (caffeine == "high" || caffeine == "medium") {
            return "energize"
        } else if mood == "calm" && time == "morning" {
            return "focus"
        } else if temperature > 30 {
            return "refresh"
        } else if caffeine == "none" {
            return "detox"
        } else {
            return "relax"
        }
    }

    func generateJapaneseComment(
        mood: String,
        time: String,
        temperature: Int,
        caffeine: String,
        teaJP: String,
        reason: String
    ) -> String {
        let moodPhrase: String
        switch mood {
            case "calm": moodPhrase = "落ち着いた気分のあなたに、"
            case "active": moodPhrase = "アクティブな気分のあなたに、"
            case "tired": moodPhrase = "少し疲れを感じているあなたに、"
            default: moodPhrase = ""
        }

        let timePhrase = "\(time == "morning" ? "朝" : time == "afternoon" ? "昼" : "夕方")の \(temperature)℃ という環境で、"

        let caffeinePhrase: String
        switch caffeine {
            case "none": caffeinePhrase = "ノンカフェインのお茶として、"
            case "low": caffeinePhrase = "カフェイン少なめのお茶として、"
            case "medium": caffeinePhrase = "ほどよいカフェインのお茶として、"
            case "high": caffeinePhrase = "しっかりカフェインのお茶として、"
            default: caffeinePhrase = ""
        }

        let reasonMessage: String
        switch reason {
            case "relax": reasonMessage = "気持ちをリセットして、静かな時間を過ごすのにぴったりです。"
            case "focus": reasonMessage = "集中力を高めて作業に没頭するのに適しています。"
            case "recover": reasonMessage = "一日の疲れを癒やすリラックスタイムに最適です。"
            case "refresh": reasonMessage = "さっぱりとした飲み心地で気分をリフレッシュできます。"
            case "detox": reasonMessage = "体を整えたいときにやさしく寄り添ってくれるお茶です。"
            case "energize": reasonMessage = "エネルギーをチャージして前向きな一日を支えてくれます。"
            case "stay_awake": reasonMessage = "眠気を吹き飛ばしてシャキッとしたいときに。"
            case "calm_down": reasonMessage = "心を落ち着けたいときに寄り添うお茶です。"
            default: reasonMessage = ""
        }

        return """
        \(moodPhrase)
        \(timePhrase)
        \(caffeinePhrase)\(teaJP) をおすすめします。
        理由：\(reasonMessage)
        """
    }
}
