import SwiftUI

@main
struct OpenClawShellApp: App {
    var body: some Scene {
        WindowGroup {
            ShellRootView()
        }
    }
}

private struct ShellRootView: View {
    @State private var selectedTab: Int = 0

    var body: some View {
        TabView(selection: self.$selectedTab) {
            ShellHomeView()
                .tabItem { Label("Home", systemImage: "house") }
                .tag(0)

            ShellSessionsView()
                .tabItem { Label("Sessions", systemImage: "message") }
                .tag(1)

            ShellSettingsView()
                .tabItem { Label("Settings", systemImage: "gearshape") }
                .tag(2)
        }
        .tint(.cyan)
    }
}

private struct ShellScaffold<Content: View>: View {
    let title: String
    let subtitle: String
    @ViewBuilder var content: Content

    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(
                    colors: [Color.black, Color(red: 0.08, green: 0.09, blue: 0.16)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing)
                    .ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: 18) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text(title)
                                .font(.system(.largeTitle, design: .rounded, weight: .bold))
                                .foregroundStyle(.white)
                            Text(subtitle)
                                .font(.system(.subheadline, design: .rounded))
                                .foregroundStyle(.white.opacity(0.72))
                        }

                        content
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(20)
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Image(systemName: "bolt.shield")
                        .foregroundStyle(.white.opacity(0.9))
                }
            }
        }
    }
}

private struct ShellCard<Content: View>: View {
    @ViewBuilder var content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            content
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.white.opacity(0.08), in: RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(.white.opacity(0.08), lineWidth: 1)
        )
    }
}

private struct ShellHomeView: View {
    var body: some View {
        ShellScaffold(
            title: "OpenClaw Shell",
            subtitle: "A stepped-up TrollStore build with basic app structure restored")
        {
            ShellCard {
                Label("App launches into a real TabView shell", systemImage: "checkmark.circle.fill")
                Label("Three base pages with navigation chrome", systemImage: "checkmark.circle.fill")
                Label("Static settings surface for smoke testing", systemImage: "checkmark.circle.fill")
            }
            .foregroundStyle(.white.opacity(0.92))
            .font(.system(.footnote, design: .rounded))

            ShellCard {
                Text("Current scope")
                    .font(.headline)
                    .foregroundStyle(.white)
                Text("This layer intentionally avoids gateway auto-bootstrap, push, live activities, watch/share/widget payloads, and background task flows. It focuses on UI survivability under TrollStore first.")
                    .font(.system(.footnote, design: .rounded))
                    .foregroundStyle(.white.opacity(0.78))
            }

            ShellCard {
                Text("Next validation")
                    .font(.headline)
                    .foregroundStyle(.white)
                Text("Please verify launch stability, tab switching, navigation bar rendering, scroll behavior, and whether reopening from app switcher stays healthy.")
                    .font(.system(.footnote, design: .rounded))
                    .foregroundStyle(.white.opacity(0.78))
            }
        }
    }
}

private struct ShellSessionsView: View {
    private let rows: [(String, String, String)] = [
        ("Local session", "Static placeholder conversation surface", "bubble.left.and.text.bubble.right"),
        ("Gateway status", "Disconnected by design in this shell layer", "bolt.horizontal.circle"),
        ("Future step", "Incrementally reintroduce safe read-only surfaces", "arrow.triangle.branch")
    ]

    var body: some View {
        ShellScaffold(
            title: "Sessions",
            subtitle: "Minimal static page to test tab switching and list rendering")
        {
            ForEach(Array(self.rows.enumerated()), id: \.offset) { _, row in
                ShellCard {
                    Label(row.0, systemImage: row.2)
                        .font(.headline)
                        .foregroundStyle(.white)
                    Text(row.1)
                        .font(.system(.footnote, design: .rounded))
                        .foregroundStyle(.white.opacity(0.76))
                }
            }
        }
    }
}

private struct ShellSettingsView: View {
    @State private var launchOnBoot: Bool = false
    @State private var compactStatus: Bool = true
    @State private var reducedEffects: Bool = false

    var body: some View {
        ShellScaffold(
            title: "Settings",
            subtitle: "Static controls only — safe UI smoke coverage without runtime services")
        {
            ShellCard {
                Toggle("Compact status pill", isOn: self.$compactStatus)
                Toggle("Reduced visual effects", isOn: self.$reducedEffects)
                Toggle("Launch on boot (placeholder)", isOn: self.$launchOnBoot)
            }
            .tint(.cyan)
            .foregroundStyle(.white)

            ShellCard {
                Text("Disabled in this build")
                    .font(.headline)
                    .foregroundStyle(.white)
                VStack(alignment: .leading, spacing: 10) {
                    Label("Push transport & APNs registration", systemImage: "xmark.circle")
                    Label("ActivityKit / Live Activities", systemImage: "xmark.circle")
                    Label("Background task scheduling", systemImage: "xmark.circle")
                    Label("Gateway auto-connect / discovery", systemImage: "xmark.circle")
                    Label("Share extension, watch app, widgets", systemImage: "xmark.circle")
                }
                .font(.system(.footnote, design: .rounded))
                .foregroundStyle(.white.opacity(0.8))
            }
        }
    }
}
