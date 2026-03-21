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
            ShellHomeView {
                self.selectedTab = 1
            }
                .tabItem { Label("概览", systemImage: "house.fill") }
                .tag(0)

            ShellSessionsView()
                .tabItem { Label("会话", systemImage: "bubble.left.and.text.bubble.right.fill") }
                .tag(1)

            ShellSettingsView()
                .tabItem { Label("设置", systemImage: "gearshape.fill") }
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
                    colors: [Color.black, Color(red: 0.07, green: 0.09, blue: 0.15)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing)
                    .ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 18) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text(title)
                                .font(.system(.largeTitle, design: .rounded))
                                .fontWeight(.bold)
                                .foregroundStyle(.white)
                            Text(subtitle)
                                .font(.system(.subheadline, design: .rounded))
                                .foregroundStyle(.white.opacity(0.72))
                        }

                        content
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(20)
                    .padding(.bottom, 24)
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Image(systemName: "bolt.shield")
                        .foregroundStyle(.white.opacity(0.9))
                }
            }
        }
        .navigationViewStyle(.stack)
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

private struct ShellSectionTitle: View {
    let title: String
    let detail: String?

    var body: some View {
        HStack(alignment: .firstTextBaseline) {
            Text(title)
                .font(.headline)
                .foregroundStyle(.white)
            Spacer()
            if let detail {
                Text(detail)
                    .font(.system(.caption, design: .rounded))
                    .foregroundStyle(.white.opacity(0.55))
            }
        }
    }
}

private struct ShellStatusPill: View {
    let title: String
    let value: String
    let systemImage: String
    let tint: Color

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: self.systemImage)
                .foregroundStyle(self.tint)
            VStack(alignment: .leading, spacing: 2) {
                Text(self.title)
                    .font(.system(.caption, design: .rounded))
                    .foregroundStyle(.white.opacity(0.62))
                Text(self.value)
                    .font(.system(.footnote, design: .rounded))
                    .fontWeight(.semibold)
                    .foregroundStyle(.white)
            }
            Spacer(minLength: 0)
        }
        .padding(12)
        .background(.white.opacity(0.05), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}

private struct ShellMetricCard: View {
    let value: String
    let label: String

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(self.value)
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
            Text(self.label)
                .font(.system(.caption, design: .rounded))
                .foregroundStyle(.white.opacity(0.65))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(.white.opacity(0.05), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
    }
}

private struct ShellSessionRow: View {
    let title: String
    let subtitle: String
    let badge: String
    let symbol: String

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: self.symbol)
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(.cyan)
                .frame(width: 28, height: 28)

            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(self.title)
                        .font(.system(.body, design: .rounded))
                        .fontWeight(.semibold)
                        .foregroundStyle(.white)
                    Spacer()
                    Text(self.badge)
                        .font(.system(.caption2, design: .rounded))
                        .fontWeight(.bold)
                        .foregroundStyle(.cyan)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(.cyan.opacity(0.14), in: Capsule())
                }
                Text(self.subtitle)
                    .font(.system(.footnote, design: .rounded))
                    .foregroundStyle(.white.opacity(0.7))
            }
        }
        .padding(14)
        .background(.white.opacity(0.05), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
    }
}

private struct ShellSettingRow: View {
    let title: String
    let subtitle: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(self.title)
                .font(.system(.body, design: .rounded))
                .foregroundStyle(.white)
            Text(self.subtitle)
                .font(.system(.caption, design: .rounded))
                .foregroundStyle(.white.opacity(0.6))
        }
    }
}

private struct ShellHomeView: View {
    let onPrimaryAction: () -> Void

    var body: some View {
        ShellScaffold(
            title: "OpenClaw",
            subtitle: "TrollStore 前台骨架验证版：保留真实 App 结构感，但继续避开高风险运行能力")
        {
            ShellCard {
                ShellSectionTitle(title: "当前状态", detail: "前台静态")
                HStack(spacing: 12) {
                    ShellStatusPill(title: "应用层", value: "稳定打开", systemImage: "checkmark.circle.fill", tint: .green)
                    ShellStatusPill(title: "网关层", value: "未自动连接", systemImage: "bolt.slash.fill", tint: .orange)
                }
            }

            ShellCard {
                ShellSectionTitle(title: "控制台概览", detail: "只读骨架")
                HStack(spacing: 12) {
                    ShellMetricCard(value: "3", label: "主标签页")
                    ShellMetricCard(value: "0", label: "后台任务")
                    ShellMetricCard(value: "Safe", label: "自动能力")
                }
            }

            ShellCard {
                ShellSectionTitle(title: "今天可以先验证什么", detail: "下一轮加功能前")
                VStack(alignment: .leading, spacing: 10) {
                    Label("首页层级、字体、卡片布局是否顺手", systemImage: "rectangle.grid.2x2.fill")
                    Label("会话页列表骨架是否足够像正式入口", systemImage: "list.bullet.rectangle")
                    Label("设置页交互是否稳定、切后台恢复是否正常", systemImage: "switch.2")
                }
                .font(.system(.footnote, design: .rounded))
                .foregroundStyle(.white.opacity(0.9))
            }

            ShellCard {
                ShellSectionTitle(title: "主操作", detail: "可点击")
                Button(action: self.onPrimaryAction) {
                    HStack {
                        Label("进入会话骨架", systemImage: "arrow.right.circle.fill")
                            .font(.system(size: 17, weight: .semibold, design: .rounded))
                        Spacer(minLength: 0)
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 12)
                    .foregroundStyle(.black)
                    .background(.cyan, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                }
                .buttonStyle(.plain)

                Text("点击后切换到“会话”页，验证主路径点击与标签切换交互。")
                    .font(.system(.caption, design: .rounded))
                    .foregroundStyle(.white.opacity(0.7))
            }

            ShellCard {
                ShellSectionTitle(title: "仍然刻意不碰的部分", detail: "为了先保稳定")
                Text("自动连 Gateway、Push / APNs、Live Activities、后台任务、Share / Watch / Widget 继续全部关闭。这一版目标不是功能全，而是先把真正的前台主界面骨架做稳。")
                    .font(.system(.footnote, design: .rounded))
                    .foregroundStyle(.white.opacity(0.76))
            }
        }
    }
}

private struct ShellSessionsView: View {
    private let rows: [(String, String, String, String)] = [
        ("老板", "主入口会话占位。下一轮可从这里往真实消息列表骨架推进。", "主会话", "person.crop.circle.fill"),
        ("本地会话", "保留为安全静态样式，不发起真实连接。", "静态", "desktopcomputer"),
        ("最近任务", "后续可演化为任务 / 运行 / 工具结果入口。", "预留", "hammer.fill")
    ]

    var body: some View {
        ShellScaffold(
            title: "会话",
            subtitle: "从单纯占位页升级成更像真实入口的列表骨架，但仍不接消息与网络")
        {
            ShellCard {
                ShellSectionTitle(title: "最近入口", detail: "只读")
                VStack(spacing: 12) {
                    ForEach(Array(self.rows.enumerated()), id: \.offset) { _, row in
                        ShellSessionRow(title: row.0, subtitle: row.1, badge: row.2, symbol: row.3)
                    }
                }
            }

            ShellCard {
                ShellSectionTitle(title: "下一步加回建议", detail: "仍然安全")
                VStack(alignment: .leading, spacing: 10) {
                    Label("先加消息列表样式，不加真实收发", systemImage: "text.bubble")
                    Label("再加会话详情骨架，不自动连接网关", systemImage: "rectangle.portrait.on.rectangle.portrait")
                    Label("最后再评估只读状态面板", systemImage: "gauge.with.dots.needle.33percent")
                }
                .font(.system(.footnote, design: .rounded))
                .foregroundStyle(.white.opacity(0.82))
            }
        }
    }
}

private struct ShellSettingsView: View {
    @State private var compactStatus: Bool = true
    @State private var reducedEffects: Bool = false
    @State private var keepScreenAwake: Bool = false

    var body: some View {
        ShellScaffold(
            title: "设置",
            subtitle: "保留可点击的本地静态控件，验证交互层稳定性")
        {
            ShellCard {
                ShellSectionTitle(title: "显示与交互", detail: "本地状态")
                VStack(spacing: 14) {
                    Toggle(isOn: self.$compactStatus) {
                        ShellSettingRow(title: "紧凑状态标签", subtitle: "仅影响本地静态显示，不触发网络行为")
                    }
                    Toggle(isOn: self.$reducedEffects) {
                        ShellSettingRow(title: "减少视觉效果", subtitle: "用于验证低动效下的 UI 稳定性")
                    }
                    Toggle(isOn: self.$keepScreenAwake) {
                        ShellSettingRow(title: "保持界面常亮（占位）", subtitle: "先只保留交互骨架，暂不接系统能力")
                    }
                }
                .tint(.cyan)
            }

            ShellCard {
                ShellSectionTitle(title: "当前构建策略", detail: "安全优先")
                VStack(alignment: .leading, spacing: 10) {
                    Label("不注册 Push / APNs", systemImage: "xmark.circle")
                    Label("不启用后台任务", systemImage: "xmark.circle")
                    Label("不自动发现或连接 Gateway", systemImage: "xmark.circle")
                    Label("不加载 Share / Watch / Widget 扩展", systemImage: "xmark.circle")
                }
                .font(.system(.footnote, design: .rounded))
                .foregroundStyle(.white.opacity(0.8))
            }
        }
    }
}
