import SwiftUI

@main
struct OpenClawUltraliteApp: App {
    var body: some Scene {
        WindowGroup {
            UltraliteRootView()
        }
    }
}

private struct UltraliteRootView: View {
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color.black, Color(red: 0.08, green: 0.09, blue: 0.16)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing)
                .ignoresSafeArea()

            VStack(spacing: 18) {
                Image(systemName: "bolt.shield")
                    .font(.system(size: 52, weight: .semibold))
                    .foregroundStyle(.white)
                    .padding(.bottom, 4)

                Text("OpenClaw Ultralite")
                    .font(.system(.title2, design: .rounded, weight: .bold))
                    .foregroundStyle(.white)

                Text("TrollStore minimal shell build")
                    .font(.system(.subheadline, design: .rounded))
                    .foregroundStyle(.white.opacity(0.72))

                VStack(alignment: .leading, spacing: 10) {
                    Label("Launches with a minimal SwiftUI shell", systemImage: "checkmark.circle.fill")
                    Label("No gateway bootstrap or background tasks", systemImage: "checkmark.circle.fill")
                    Label("No push, live activities, location, Bonjour, or watch content", systemImage: "checkmark.circle.fill")
                }
                .font(.system(.footnote, design: .rounded))
                .foregroundStyle(.white.opacity(0.88))
                .padding(16)
                .frame(maxWidth: 320, alignment: .leading)
                .background(.white.opacity(0.08), in: RoundedRectangle(cornerRadius: 20, style: .continuous))

                Text("If this opens reliably under TrollStore, the shell path is good.")
                    .font(.system(.footnote, design: .rounded))
                    .foregroundStyle(.white.opacity(0.62))
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: 300)
            }
            .padding(28)
        }
    }
}
