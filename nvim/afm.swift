// afm.swift — Apple Foundation Models（Apple Intelligence オンデバイス LLM）の最小 CLI。
// stdin で受け取ったテキストをプロンプトとしてモデルへ渡し、結果を stdout に出す。
// Neovim の `Space ?` ガイドから呼ばれる。外部送信なし・モデルのダウンロード不要。
//
// ビルド: swiftc -O afm.swift -o ~/.local/bin/afm
// 必要環境: macOS 26 以降 + Apple Intelligence 有効 + 対応 Mac（Apple Silicon）。

import Foundation
import FoundationModels

func fail(_ message: String, _ code: Int32) -> Never {
    FileHandle.standardError.write(Data((message + "\n").utf8))
    exit(code)
}

guard #available(macOS 26.0, *) else {
    fail("macOS 26 以降が必要です。", 2)
}

let input = String(data: FileHandle.standardInput.readDataToEndOfFile(), encoding: .utf8) ?? ""
if input.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
    fail("入力が空です。", 2)
}

switch SystemLanguageModel.default.availability {
case .available:
    break
case .unavailable(.deviceNotEligible):
    fail("この Mac は Apple Intelligence に対応していません。", 3)
case .unavailable(.appleIntelligenceNotEnabled):
    fail("システム設定で Apple Intelligence を有効にしてください。", 3)
case .unavailable(.modelNotReady):
    fail("モデル準備中です。少し待って再試行してください。", 3)
case .unavailable(let reason):
    fail("利用不可: \(reason)", 3)
}

let instructions = "あなたは簡潔な操作ガイドです。指示に厳密に従い、余計な前置きをしない。"

do {
    let session = LanguageModelSession(instructions: instructions)
    let response = try await session.respond(
        to: input,
        options: GenerationOptions(sampling: .greedy)
    )
    print(response.content)
} catch let error as LanguageModelSession.GenerationError {
    fail("生成エラー: \(error)", 1)
} catch {
    fail("失敗: \(type(of: error)) \(error.localizedDescription)", 1)
}
