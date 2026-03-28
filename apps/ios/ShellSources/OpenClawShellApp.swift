import SwiftUI
import UIKit

private func shellValidationStampText(_ date: Date?) -> String {
    guard let date else { return "尚未记录" }

    let absoluteFormatter = DateFormatter()
    absoluteFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"

    let relativeFormatter = RelativeDateTimeFormatter()
    relativeFormatter.unitsStyle = .short
    relativeFormatter.locale = Locale(identifier: "zh_CN")

    let relativeText = relativeFormatter.localizedString(for: date, relativeTo: Date())
    let absoluteText = absoluteFormatter.string(from: date)
    return "\(relativeText) · \(absoluteText)"
}

private func shellRecentHistoryText(_ history: [Date], limit: Int = 3) -> String {
    guard !history.isEmpty else { return "最近打点：无" }
    let recent = history.suffix(limit).reversed()
    let body = recent.map { shellValidationStampText($0) }.joined(separator: " | ")
    return "最近打点（最多\(limit)条）：\(body)"
}

private func shellValidationReport(
    source: String,
    date: Date?,
    history: [Date],
    sessionTitle: String? = nil,
    sessionId: String? = nil,
    actionSummary: String? = nil,
    actionAt: Date? = nil)
    -> String
{
    let status = (date == nil) ? "未打点" : "已打点"
    let stamp = shellValidationStampText(date)
    let historyCount = history.count

    var lines = [
        "页面来源：\(source)",
        "主路径验收状态：\(status)",
        "时间：\(stamp)",
        "累计打点次数：\(historyCount)",
        shellRecentHistoryText(history),
    ]

    if let sessionTitle {
        lines.append("会话标题：\(sessionTitle)")
    }
    if let sessionId {
        lines.append("会话ID：\(sessionId)")
    }
    if let actionSummary {
        lines.append("最近动作结果：\(actionSummary)")
    }
    if let actionAt {
        lines.append("动作时间：\(shellValidationStampText(actionAt))")
    }

    return lines.joined(separator: "\n")
}

private struct ShellValidationStampText: View {
    let date: Date?

    var body: some View {
        TimelineView(.periodic(from: .now, by: 1)) { _ in
            Text(shellValidationStampText(self.date))
                .font(.system(.caption, design: .monospaced))
                .foregroundStyle(.cyan)
        }
    }
}

private struct ShellValidationStatusPill: View {
    let date: Date?

    var body: some View {
        let isReady = (self.date != nil)
        let title = isReady ? "状态：已打点" : "状态：未打点"
        let tint: Color = isReady ? .green : .orange

        return Text(title)
            .font(.system(.caption2, design: .rounded))
            .fontWeight(.bold)
            .foregroundStyle(tint)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(tint.opacity(0.16), in: Capsule())
    }
}

@main
struct OpenClawShellApp: App {
    var body: some Scene {
        WindowGroup {
            ChatWindowView()
        }
    }
}

private struct ShellRootView: View {
    @State private var selectedTab: Int = 0
    @State private var lastValidationAt: Date? = nil
    @State private var validationHistory: [Date] = []

    var body: some View {
        TabView(selection: self.$selectedTab) {
            ShellHomeView(onPrimaryAction: {
                self.selectedTab = 1
            }, lastValidationAt: self.$lastValidationAt, validationHistory: self.$validationHistory)
                .tabItem { Label("概览", systemImage: "house.fill") }
                .tag(0)

            ShellSessionsView(lastValidationAt: self.lastValidationAt, validationHistory: self.validationHistory)
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
    let showsDisclosure: Bool
    let isRead: Bool
    let isStarred: Bool
    let isArchived: Bool

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

                if self.isRead || self.isStarred || self.isArchived {
                    HStack(spacing: 6) {
                        if self.isRead {
                            Text("已读")
                                .font(.system(.caption2, design: .rounded))
                                .foregroundStyle(.green)
                        }
                        if self.isStarred {
                            Text("星标")
                                .font(.system(.caption2, design: .rounded))
                                .foregroundStyle(.yellow)
                        }
                        if self.isArchived {
                            Text("已归档")
                                .font(.system(.caption2, design: .rounded))
                                .foregroundStyle(.orange)
                        }
                    }
                }
            }

            if self.showsDisclosure {
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(.white.opacity(0.55))
                    .padding(.top, 6)
            }
        }
        .padding(14)
        .background(.white.opacity(0.05), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
    }
}

private struct ShellSessionItem: Identifiable, Codable, Equatable {
    let id: String
    let title: String
    let subtitle: String
    let badge: String
    let symbol: String
    var isRead: Bool = false
    var isStarred: Bool = false
    var isArchived: Bool = false
    var lastActionSummary: String? = nil
    var lastActionAt: Date? = nil

    static func defaults() -> [ShellSessionItem] {
        [
            ShellSessionItem(id: "boss", title: "老板", subtitle: "主入口会话占位。下一轮可从这里往真实消息列表骨架推进。", badge: "主会话", symbol: "person.crop.circle.fill"),
            ShellSessionItem(id: "local", title: "本地会话", subtitle: "保留为安全静态样式，不发起真实连接。", badge: "静态", symbol: "desktopcomputer"),
            ShellSessionItem(id: "recent-tasks", title: "最近任务", subtitle: "后续可演化为任务 / 运行 / 工具结果入口。", badge: "预留", symbol: "hammer.fill")
        ]
    }
}

private extension Notification.Name {
    static let shellResetSessionState = Notification.Name("openclaw.shell.resetSessionState")
}

private struct ShellSessionDetailPlaceholderView: View {
    @Binding var session: ShellSessionItem
    let lastValidationAt: Date?
    let validationHistory: [Date]
    @State private var copyFeedback: String? = nil

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color.black, Color(red: 0.07, green: 0.09, blue: 0.15)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing)
                .ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 18) {
                    ShellCard {
                        ShellSectionTitle(title: session.title, detail: "只读占位")
                        Text("这是会话详情占位视图。当前版本仅验证前台导航链路与页面稳定性，不发起网络请求，不连接网关，不启用后台能力。")
                            .font(.system(.footnote, design: .rounded))
                            .foregroundStyle(.white.opacity(0.76))
                    }

                    ShellCard {
                        ShellSectionTitle(title: "会话元信息", detail: "静态")
                        VStack(alignment: .leading, spacing: 10) {
                            Label("标记：\(session.badge)", systemImage: "tag.fill")
                            Label("图标：\(session.symbol)", systemImage: "sparkles")
                            Label("说明：\(session.subtitle)", systemImage: "text.alignleft")
                        }
                        .font(.system(.footnote, design: .rounded))
                        .foregroundStyle(.white.opacity(0.82))
                    }

                    ShellCard {
                        ShellSectionTitle(title: "主路径验收链路", detail: "详情页可见")
                        VStack(alignment: .leading, spacing: 8) {
                            HStack(spacing: 12) {
                                Label("最近一次主路径点击", systemImage: "clock.badge.checkmark")
                                    .font(.system(.footnote, design: .rounded))
                                    .foregroundStyle(.white.opacity(0.88))
                                Spacer(minLength: 0)
                                ShellValidationStatusPill(date: self.lastValidationAt)
                            }
                            ShellValidationStampText(date: self.lastValidationAt)
                        }
                    }

                    ShellCard {
                        ShellSectionTitle(title: "本地动作", detail: "可执行")
                        HStack(spacing: 10) {
                            Button(self.session.isRead ? "已读" : "标记已读") {
                                self.session.isRead = true
                                self.session.lastActionSummary = "标记已读"
                                self.session.lastActionAt = Date()
                            }
                            .buttonStyle(.borderedProminent)

                            Button(self.session.isStarred ? "取消星标" : "加星") {
                                self.session.isStarred.toggle()
                                self.session.lastActionSummary = self.session.isStarred ? "加星" : "取消星标"
                                self.session.lastActionAt = Date()
                            }
                            .buttonStyle(.bordered)

                            Button(self.session.isArchived ? "取消归档" : "归档") {
                                self.session.isArchived.toggle()
                                self.session.lastActionSummary = self.session.isArchived ? "归档" : "取消归档"
                                self.session.lastActionAt = Date()
                            }
                            .buttonStyle(.bordered)
                        }

                        if let action = self.session.lastActionSummary, let at = self.session.lastActionAt {
                            Text("最近动作：\(action) · \(shellValidationStampText(at))")
                                .font(.system(.caption, design: .rounded))
                                .foregroundStyle(.white.opacity(0.78))
                        } else {
                            Text("最近动作：暂无")
                                .font(.system(.caption, design: .rounded))
                                .foregroundStyle(.white.opacity(0.6))
                        }
                    }

                    ShellCard {
                        ShellSectionTitle(title: "验收结果导出", detail: "详情页")
                        Button(action: {
                            UIPasteboard.general.string = shellValidationReport(
                                source: "会话详情",
                                date: self.lastValidationAt,
                                history: self.validationHistory,
                                sessionTitle: self.session.title,
                                sessionId: self.session.id,
                                actionSummary: self.session.lastActionSummary,
                                actionAt: self.session.lastActionAt)
                            self.copyFeedback = "已复制到剪贴板"
                        }) {
                            HStack {
                                Label("复制验收结果", systemImage: "doc.on.doc.fill")
                                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                                Spacer(minLength: 0)
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 10)
                            .foregroundStyle(.black)
                            .background(.mint, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                        }
                        .buttonStyle(.plain)

                        Text(self.copyFeedback ?? "复制内容含页面来源、状态、时间")
                            .font(.system(.caption, design: .rounded))
                            .foregroundStyle(.white.opacity(0.72))
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(20)
                .padding(.bottom, 24)
            }
        }
        .navigationTitle("会话详情")
        .navigationBarTitleDisplayMode(.inline)
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
    @Binding var lastValidationAt: Date?
    @Binding var validationHistory: [Date]
    @State private var copyFeedback: String? = nil

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
                    ShellMetricCard(value: "安全", label: "自动能力")
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
                Button(action: {
                    let now = Date()
                    self.lastValidationAt = now
                    self.validationHistory.append(now)
                    self.onPrimaryAction()
                }) {
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
                ShellSectionTitle(title: "本地验收打点", detail: "新增")
                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 12) {
                        Label("最近一次主路径点击", systemImage: "checkmark.seal.fill")
                            .font(.system(.footnote, design: .rounded))
                            .foregroundStyle(.white.opacity(0.9))
                        Spacer(minLength: 0)
                        ShellValidationStatusPill(date: self.lastValidationAt)
                    }
                    ShellValidationStampText(date: self.lastValidationAt)
                }
            }

            ShellCard {
                ShellSectionTitle(title: "验收统计", detail: "新增")
                HStack(spacing: 12) {
                    ShellMetricCard(value: "\(self.validationHistory.count)", label: "累计打点")
                    ShellMetricCard(value: (self.lastValidationAt == nil ? "未打点" : "已打点"), label: "当前状态")
                }
                if let first = self.validationHistory.first {
                    Text("首次打点：\(shellValidationStampText(first))")
                        .font(.system(.caption, design: .rounded))
                        .foregroundStyle(.white.opacity(0.72))
                }
                Text(shellRecentHistoryText(self.validationHistory))
                    .font(.system(.caption, design: .rounded))
                    .foregroundStyle(.white.opacity(0.72))
            }

            ShellCard {
                ShellSectionTitle(title: "验收结果导出", detail: "新增")
                Button(action: {
                    UIPasteboard.general.string = shellValidationReport(
                        source: "概览",
                        date: self.lastValidationAt,
                        history: self.validationHistory)
                    self.copyFeedback = "已复制到剪贴板"
                }) {
                    HStack {
                        Label("复制验收结果", systemImage: "doc.on.doc.fill")
                            .font(.system(size: 15, weight: .semibold, design: .rounded))
                        Spacer(minLength: 0)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 10)
                    .foregroundStyle(.black)
                    .background(.mint, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                }
                .buttonStyle(.plain)

                Text(self.copyFeedback ?? "用于一键回传当前“状态+时间”文本")
                    .font(.system(.caption, design: .rounded))
                    .foregroundStyle(.white.opacity(0.72))
            }

            ShellCard {
                ShellSectionTitle(title: "仍然刻意不碰的部分", detail: "为了先保稳定")
                Text("自动连接网关、推送 / APNs、实时活动、后台任务、分享 / 手表 / 小组件继续全部关闭。这一版目标不是功能全，而是先把真正的前台主界面骨架做稳。")
                    .font(.system(.footnote, design: .rounded))
                    .foregroundStyle(.white.opacity(0.76))
            }
        }
    }
}

private struct ShellSessionsView: View {
    let lastValidationAt: Date?
    let validationHistory: [Date]
    @State private var copyFeedback: String? = nil

    @State private var rows: [ShellSessionItem] = ShellSessionItem.defaults()

    private static let storageKey = "openclaw.shell.sessions.v1"

    private func loadPersistedRows() {
        guard let data = UserDefaults.standard.data(forKey: Self.storageKey),
              let decoded = try? JSONDecoder().decode([ShellSessionItem].self, from: data),
              !decoded.isEmpty
        else {
            self.rows = ShellSessionItem.defaults()
            return
        }
        self.rows = decoded
    }

    private func persistRows(_ rows: [ShellSessionItem]) {
        guard let data = try? JSONEncoder().encode(rows) else { return }
        UserDefaults.standard.set(data, forKey: Self.storageKey)
    }

    private func resetRows() {
        UserDefaults.standard.removeObject(forKey: Self.storageKey)
        self.rows = ShellSessionItem.defaults()
        self.copyFeedback = "已重置会话状态"
    }

    private func exportCurrentSessionReport() -> String {
        let target = self.rows.first ?? ShellSessionItem(
            id: "none",
            title: "会话",
            subtitle: "无数据",
            badge: "占位",
            symbol: "bubble.left")

        return shellValidationReport(
            source: "会话",
            date: self.lastValidationAt,
            history: self.validationHistory,
            sessionTitle: target.title,
            sessionId: target.id,
            actionSummary: target.lastActionSummary,
            actionAt: target.lastActionAt)
    }

    private func exportAllSessionsReport() -> String {
        let header = shellValidationReport(
            source: "会话-全量摘要",
            date: self.lastValidationAt,
            history: self.validationHistory)

        let body = self.rows.map { row in
            let statusTags = [
                row.isRead ? "已读" : nil,
                row.isStarred ? "星标" : nil,
                row.isArchived ? "归档" : nil,
            ]
            .compactMap { $0 }
            .joined(separator: ",")

            let statusText = statusTags.isEmpty ? "无" : statusTags
            let actionText = row.lastActionSummary ?? "无"
            let actionAtText = shellValidationStampText(row.lastActionAt)
            return "- \(row.title) [\(row.badge)] id=\(row.id) 状态=\(statusText) 最近动作=\(actionText) 动作时间=\(actionAtText)"
        }
        .joined(separator: "\n")

        return header + "\n\n会话列表：\n" + body
    }

    var body: some View {
        ShellScaffold(
            title: "会话",
            subtitle: "从单纯占位页升级成更像真实入口的列表骨架，但仍不接消息与网络")
        {
            ShellCard {
                ShellSectionTitle(title: "最近入口", detail: "只读")
                VStack(spacing: 12) {
                    ForEach(self.$rows) { $row in
                        NavigationLink(destination: ShellSessionDetailPlaceholderView(session: $row, lastValidationAt: self.lastValidationAt, validationHistory: self.validationHistory)) {
                            ShellSessionRow(
                                title: row.title,
                                subtitle: row.subtitle,
                                badge: row.badge,
                                symbol: row.symbol,
                                showsDisclosure: true,
                                isRead: row.isRead,
                                isStarred: row.isStarred,
                                isArchived: row.isArchived)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }

            ShellCard {
                ShellSectionTitle(title: "验收状态", detail: "跨 Tab 可见")
                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 12) {
                        Label("最近一次主路径点击", systemImage: "clock.badge.checkmark")
                            .font(.system(.footnote, design: .rounded))
                            .foregroundStyle(.white.opacity(0.88))
                        Spacer(minLength: 0)
                        ShellValidationStatusPill(date: self.lastValidationAt)
                    }
                    ShellValidationStampText(date: self.lastValidationAt)
                }
            }

            ShellCard {
                ShellSectionTitle(title: "验收结果导出", detail: "会话页")
                VStack(spacing: 10) {
                    Button(action: {
                        UIPasteboard.general.string = self.exportCurrentSessionReport()
                        self.copyFeedback = "已复制当前会话验收结果"
                    }) {
                        HStack {
                            Label("复制当前会话结果", systemImage: "doc.on.doc.fill")
                                .font(.system(size: 15, weight: .semibold, design: .rounded))
                            Spacer(minLength: 0)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 10)
                        .foregroundStyle(.black)
                        .background(.mint, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                    }
                    .buttonStyle(.plain)

                    Button(action: {
                        UIPasteboard.general.string = self.exportAllSessionsReport()
                        self.copyFeedback = "已复制全部会话摘要"
                    }) {
                        HStack {
                            Label("复制全部会话摘要", systemImage: "square.stack.3d.up.fill")
                                .font(.system(size: 15, weight: .semibold, design: .rounded))
                            Spacer(minLength: 0)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 10)
                        .foregroundStyle(.black)
                        .background(.cyan, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                    }
                    .buttonStyle(.plain)
                }

                Text(self.copyFeedback ?? "支持导出：当前会话 + 全会话摘要")
                    .font(.system(.caption, design: .rounded))
                    .foregroundStyle(.white.opacity(0.72))
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
        .onAppear {
            self.loadPersistedRows()
        }
        .onChange(of: self.rows) { newValue in
            self.persistRows(newValue)
        }
        .onReceive(NotificationCenter.default.publisher(for: .shellResetSessionState)) { _ in
            self.resetRows()
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
                ShellSectionTitle(title: "会话状态维护", detail: "可恢复")
                Button(action: {
                    NotificationCenter.default.post(name: .shellResetSessionState, object: nil)
                }) {
                    HStack {
                        Label("重置本地会话状态", systemImage: "arrow.counterclockwise.circle.fill")
                            .font(.system(size: 15, weight: .semibold, design: .rounded))
                        Spacer(minLength: 0)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 10)
                    .foregroundStyle(.black)
                    .background(.orange, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                }
                .buttonStyle(.plain)

                Text("用于清理已读/星标/归档等本地状态，恢复默认列表")
                    .font(.system(.caption, design: .rounded))
                    .foregroundStyle(.white.opacity(0.72))
            }

            ShellCard {
                ShellSectionTitle(title: "当前构建策略", detail: "安全优先")
                VStack(alignment: .leading, spacing: 10) {
                    Label("不注册推送 / APNs", systemImage: "xmark.circle")
                    Label("不启用后台任务", systemImage: "xmark.circle")
                    Label("不自动发现或连接网关", systemImage: "xmark.circle")
                    Label("不加载分享 / 手表 / 小组件扩展", systemImage: "xmark.circle")
                }
                .font(.system(.footnote, design: .rounded))
                .foregroundStyle(.white.opacity(0.8))
            }
        }
    }
}
