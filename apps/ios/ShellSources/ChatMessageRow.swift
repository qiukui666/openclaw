import SwiftUI

struct ChatMessage: Identifiable, Equatable {
    let id: UUID = UUID()
    let role: ChatRole
    let text: String
    let timestamp: Date
}

enum ChatRole {
    case user
    case assistant
}

struct ChatMessageRow: View {
    let message: ChatMessage

    var body: some View {
        HStack(alignment: .bottom, spacing: 8) {
            if message.role == .assistant {
                Circle()
                    .fill(Color.cyan.opacity(0.85))
                    .frame(width: 24, height: 24)
                bubble
                Spacer(minLength: 32)
            } else {
                Spacer(minLength: 32)
                bubble
            }
        }
    }

    private var bubble: some View {
        Text(message.text)
            .font(.system(size: 15, weight: .regular, design: .rounded))
            .foregroundStyle(message.role == .assistant ? .white : .black)
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(message.role == .assistant ? Color.white.opacity(0.12) : Color.cyan)
            )
    }
}
