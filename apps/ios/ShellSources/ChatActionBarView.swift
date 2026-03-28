import SwiftUI

struct ChatActionBarView: View {
    @Binding var selectedMode: String

    var body: some View {
        HStack(spacing: 8) {
            modeButton("Bypass Permissions")
            modeButton("Default Mode")
            modeButton("Accept Edits")
        }
    }

    private func modeButton(_ title: String) -> some View {
        Button(action: {
            selectedMode = title
        }) {
            Text(title)
                .font(.system(size: 12, weight: .semibold, design: .rounded))
                .lineLimit(1)
                .minimumScaleFactor(0.7)
                .padding(.horizontal, 10)
                .padding(.vertical, 8)
                .foregroundStyle(selectedMode == title ? Color.black : Color.white)
                .background(
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(selectedMode == title ? Color.cyan : Color.white.opacity(0.1))
                )
        }
        .buttonStyle(.plain)
    }
}
