import Core
import CoreData
import DesignSystem
import SwiftUI

public struct ProjectsListView: View {
    @FetchRequest(fetchRequest: ProjectFetchRequest.make())
    private var projects: FetchedResults<NSManagedObject>

    @State private var searchText = ""

    public init() {}

    public var body: some View {
        ZStack {
            AppGradients.page
                .ignoresSafeArea()

            VStack(alignment: .leading, spacing: AppSpacing.lg) {
                header
                searchField

                if filteredProjects.isEmpty {
                    emptyState
                } else {
                    ScrollView {
                        LazyVStack(spacing: AppSpacing.md) {
                            ForEach(filteredProjects, id: \.objectID) { project in
                                let snapshot = makeSnapshot(from: project)
                                NavigationLink(value: ProjectRoute(id: snapshot.id, name: snapshot.name, uiState: snapshot.uiState)) {
                                    ProjectCardView(snapshot: snapshot)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.bottom, AppSpacing.xl)
                    }
                }
            }
            .padding(AppSpacing.xl)
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: AppSpacing.xs) {
            Text("Projects")
                .font(AppTypography.title)
                .foregroundStyle(AppColors.textPrimary)
            Text("Demo data is loaded locally")
                .font(AppTypography.body)
                .foregroundStyle(AppColors.textSecondary)
        }
    }

    private var searchField: some View {
        HStack(spacing: AppSpacing.sm) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(AppColors.textSecondary)
            TextField("Search projects", text: $searchText)
                .textInputAutocapitalization(.words)
                .disableAutocorrection(true)
        }
        .padding(AppSpacing.md)
        .background(
            RoundedRectangle(cornerRadius: AppRadius.field)
                .fill(Color.white.opacity(0.75))
        )
        .overlay(
            RoundedRectangle(cornerRadius: AppRadius.field)
                .stroke(AppColors.cardBorder, lineWidth: AppMetrics.cardStrokeWidth)
        )
    }

    private var emptyState: some View {
        VStack(spacing: AppSpacing.sm) {
            Text("No project assigned")
                .font(AppTypography.section)
                .foregroundStyle(AppColors.textPrimary)
            Text("Ask your supervisor to assign a project.")
                .font(AppTypography.body)
                .foregroundStyle(AppColors.textSecondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
    }

    private var filteredProjects: [NSManagedObject] {
        guard !searchText.isEmpty else {
            return Array(projects)
        }
        return projects.filter { object in
            let name = (object.value(forKey: "name") as? String) ?? ""
            return name.localizedCaseInsensitiveContains(searchText)
        }
    }

    private func makeSnapshot(from object: NSManagedObject) -> ProjectSnapshot {
        let id = (object.value(forKey: "id") as? UUID) ?? UUID()
        let name = (object.value(forKey: "name") as? String) ?? "Untitled"
        let location = object.value(forKey: "location") as? String
        let roomCount = (object.value(forKey: "roomCount") as? Int64).map(Int.init)
        let assetCount = (object.value(forKey: "assetCount") as? Int64).map(Int.init)
        let stateRaw = object.value(forKey: "stateRaw") as? String
        let lifecycleState = stateRaw.flatMap(ProjectLifecycleState.init(rawValue:))
        return ProjectSnapshot(
            id: id,
            name: name,
            location: location,
            roomCount: roomCount,
            assetCount: assetCount,
            uiState: lifecycleState?.uiState
        )
    }
}

private enum ProjectFetchRequest {
    static func make() -> NSFetchRequest<NSManagedObject> {
        let request = NSFetchRequest<NSManagedObject>(entityName: "Project")
        request.sortDescriptors = [
            NSSortDescriptor(key: "name", ascending: true)
        ]
        request.fetchBatchSize = 20
        return request
    }
}

private struct ProjectSnapshot: Identifiable {
    let id: UUID
    let name: String
    let location: String?
    let roomCount: Int?
    let assetCount: Int?
    let uiState: ProjectUIState?
}

public struct ProjectRoute: Hashable, Identifiable {
    public let id: UUID
    public let name: String
    public let uiState: ProjectUIState?

    public init(id: UUID, name: String, uiState: ProjectUIState?) {
        self.id = id
        self.name = name
        self.uiState = uiState
    }
}

private struct ProjectCardView: View {
    let snapshot: ProjectSnapshot

    var body: some View {
        HStack(alignment: .top, spacing: AppSpacing.md) {
            ZStack {
                RoundedRectangle(cornerRadius: AppRadius.thumb)
                    .fill(AppGradients.cardAccent)
                Image(systemName: "building.2.fill")
                    .font(.system(size: AppMetrics.projectCardIconSize, weight: .bold))
                    .foregroundStyle(.white.opacity(0.9))
            }
            .frame(width: AppMetrics.projectCardImageSize, height: AppMetrics.projectCardImageSize)

            VStack(alignment: .leading, spacing: AppSpacing.sm) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: AppSpacing.xs) {
                        Text(snapshot.name)
                            .font(AppTypography.section)
                            .foregroundStyle(AppColors.textPrimary)
                        Text(snapshot.location?.isEmpty == false ? snapshot.location! : "Location TBD")
                            .font(AppTypography.body)
                            .foregroundStyle(AppColors.textSecondary)
                    }
                    Spacer()
                    ProjectStateBadge(state: snapshot.uiState)
                }

                HStack(spacing: AppSpacing.lg) {
                    MetricView(label: "Rooms", value: snapshot.roomCount)
                    MetricView(label: "Assets", value: snapshot.assetCount)
                }
            }
        }
        .padding(AppSpacing.lg)
        .background(
            RoundedRectangle(cornerRadius: AppRadius.card)
                .fill(AppColors.cardBackground)
                .overlay(
                    RoundedRectangle(cornerRadius: AppRadius.card)
                        .stroke(AppColors.cardBorder.opacity(0.6), lineWidth: AppMetrics.cardStrokeWidth)
                )
        )
        .shadow(color: AppShadow.card.color, radius: AppShadow.card.radius, x: AppShadow.card.x, y: AppShadow.card.y)
    }
}

private struct MetricView: View {
    let label: String
    let value: Int?

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(value.map(String.init) ?? "—")
                .font(AppTypography.metric)
                .foregroundStyle(AppColors.textPrimary)
            Text(label)
                .font(AppTypography.metricLabel)
                .foregroundStyle(AppColors.textSecondary)
        }
    }
}

private struct ProjectStateBadge: View {
    let state: ProjectUIState?

    var body: some View {
        let style = ProjectStateStyle(state: state)
        Text(style.title)
            .font(AppTypography.badge)
            .padding(.horizontal, AppSpacing.sm)
            .padding(.vertical, AppSpacing.xs)
            .background(
                Capsule().fill(style.background)
            )
            .foregroundStyle(style.text)
    }
}

private struct ProjectStateStyle {
    let title: String
    let background: Color
    let text: Color

    init(state: ProjectUIState?) {
        switch state {
        case .online:
            title = ProjectUIState.online.rawValue
            background = AppColors.onlineBadgeBackground
            text = AppColors.onlineBadgeText
        case .open:
            title = ProjectUIState.open.rawValue
            background = AppColors.openBadgeBackground
            text = AppColors.openBadgeText
        case .completed:
            title = ProjectUIState.completed.rawValue
            background = AppColors.completedBadgeBackground
            text = AppColors.completedBadgeText
        case .none:
            title = "Unknown"
            background = AppColors.unknownBadgeBackground
            text = AppColors.unknownBadgeText
        }
    }
}
