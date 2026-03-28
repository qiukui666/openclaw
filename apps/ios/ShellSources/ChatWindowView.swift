import SwiftUI

struct ChatWindowView: View {
    @State private var composerText: String = ""
    @State private var selectedMode: String = "Default Mode"
    @State private var messages: [ChatMessage] = [
        ChatMessage(role: .assistant, text: "老板，我在。你说需求，我直接做。", timestamp: Date()),
        ChatMessage(role: .user, text: "这个手机网页版不方便，想做成 app。", timestamp: Date()),
        ChatMessage(role: .assistant, text: "可以做，先给你路径，再给你打包产物。", timestamp: Date())
    ]

    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(
                    colors: [Color.black, Color(red: 0.06, green: 0.08, blue: 0.14)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                VStack(spacing: 10) {
                    ScrollViewReader { proxy in
                        ScrollView(showsIndicators: false) {
                            VStack(spacing: 10) {
                                ForEach(messages) { message in
                                    ChatMessageRow(message: message)
                                        .id(message.id)
                                }
                            }
                            .padding(.horizontal, 12)
                            .padding(.top, 12)
                        }
                        .onChange(of: messages.count) { _ in
                            if let last = messages.last {
                                withAnimation(.easeOut(duration: 0.2)) {
                                    proxy.scrollTo(last.id, anchor: .bottom)
                                }
                            }
                        }
                    }

                    VStack(spacing: 8) {
                        ChatActionBarView(selectedMode: $selectedMode)
                        ChatComposerView(text: $composerText, onSend: send)
                    }
                    .padding(10)
                    .background(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .fill(Color.white.opacity(0.06))
                    )
                    .padding(.horizontal, 12)
                    .padding(.bottom, 8)
                }
            }
            .navigationTitle("聊天")
            .navigationBarTitleDisplayMode(.inline)
        }
        .navigationViewStyle(.stack)
    }

    private func send() {
        let text = composerText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }
        messages.append(ChatMessage(role: .user, text: text, timestamp: Date()))
        composerText = ""

        // Static placeholder reply to keep the prototype fully local/offline.
        messages.append(
            ChatMessage(
                role: .assistant,
                text: "收到：\(text)\n当前模式：\(selectedMode)",
                timestamp: Date()
            )
        )
    }
}
