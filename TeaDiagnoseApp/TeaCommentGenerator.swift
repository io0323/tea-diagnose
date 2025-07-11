import Foundation

class TeaCommentGenerator {
    static let shared = TeaCommentGenerator()

    private let commentDict: [String: String] = [
        "sencha": "爽やかな香りとほどよい渋みで、リラックスしながら集中力を高めたい時におすすめです。",
        "hojicha": "香ばしくカフェインが少ないため、夜のひとときや寝る前に最適なお茶です。",
        "matcha": "鮮やかな緑とコクのある味わいで、アクティブな気分をさらに引き立てます。",
        "genmaicha": "香ばしい玄米の香りが落ち着きを与え、午後のひと休みにぴったりです。",
        "kamairicha": "独特の香りと柔らかな甘みで、穏やかな時間をサポートしてくれます。"
    ]

    func generateComment(for teaName: String) -> String {
        return commentDict[teaName.lowercased()] ?? "心を整える一杯のお茶で、あなたの時間が豊かになりますように。"
    }
}
