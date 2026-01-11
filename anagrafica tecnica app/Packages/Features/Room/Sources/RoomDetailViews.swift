import DesignSystem
import Foundation
import SwiftUI

struct RoomItemsList: View {
    let items: [RoomItem]

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            Text("Assets & Room Notes")
                .font(AppTypography.section)
                .foregroundStyle(AppColors.textPrimary)

            if items.isEmpty {
                Text("No assets or room notes yet.")
                    .font(AppTypography.body)
                    .foregroundStyle(AppColors.textSecondary)
            } else {
                VStack(spacing: AppSpacing.sm) {
                    ForEach(items) { item in
                        NavigationLink {
                            destination(for: item)
                        } label: {
                            RoomItemRow(item: item)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }

    @ViewBuilder
    private func destination(for item: RoomItem) -> some View {
        switch item.kind {
        case .asset(let snapshot):
            AssetInstanceDetailView(snapshot: snapshot)
        case .roomNote(let snapshot):
            RoomNoteDetailView(snapshot: snapshot)
        }
    }
}

struct RoomItemRow: View {
    let item: RoomItem

    var body: some View {
        HStack(spacing: AppSpacing.md) {
            ZStack {
                RoundedRectangle(cornerRadius: AppRadius.badge)
                    .fill(AppGradients.cardAccent)
                Image(systemName: iconName)
                    .font(.system(size: AppMetrics.roomRowIconSize, weight: .semibold))
                    .foregroundStyle(.white.opacity(0.9))
            }
            .frame(width: AppMetrics.roomRowIconFrame, height: AppMetrics.roomRowIconFrame)

            VStack(alignment: .leading, spacing: AppSpacing.xs) {
                Text(item.kind.displayTitle)
                    .font(AppTypography.bodyEmphasis)
                    .foregroundStyle(AppColors.textPrimary)
                Text(item.kind.displaySubtitle)
                    .font(AppTypography.body)
                    .foregroundStyle(AppColors.textSecondary)
            }
            Spacer()
            Image(systemName: "chevron.right")
                .font(.system(size: AppMetrics.roomRowChevronSize, weight: .bold))
                .foregroundStyle(AppColors.textSecondary)
        }
        .padding(.vertical, AppSpacing.xs)
        .padding(.horizontal, AppSpacing.sm)
        .background(
            RoundedRectangle(cornerRadius: AppRadius.card)
                .fill(AppColors.cardBackground)
                .overlay(
                    RoundedRectangle(cornerRadius: AppRadius.card)
                        .stroke(AppColors.cardBorder, lineWidth: AppMetrics.cardStrokeWidth)
                )
        )
        .shadow(color: AppShadow.card.color, radius: AppShadow.card.radius, x: AppShadow.card.x, y: AppShadow.card.y)
    }

    private var iconName: String {
        switch item.kind {
        case .asset:
            return "cube.fill"
        case .roomNote:
            return "note.text"
        }
    }

}

public struct AssetInstanceDetailView: View {
    let snapshot: AssetSnapshot

    public init(snapshot: AssetSnapshot) {
        self.snapshot = snapshot
    }

    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppSpacing.lg) {
                TypeSummaryCard(snapshot: snapshot)
                ParameterSection(title: "Type parameters", rows: snapshot.typeFields)
                ParameterSection(title: "Instance parameters", rows: snapshot.instanceFields)
                PhotoSummary(title: "Instance photos", count: snapshot.instancePhotoIds.count, max: 5)
            }
            .padding(AppSpacing.xl)
            .padding(.bottom, AppSpacing.xl)
        }
        .navigationTitle(snapshot.typeName)
        .navigationBarTitleDisplayMode(.inline)
    }
}

private struct TypeSummaryCard: View {
    let snapshot: AssetSnapshot

    var body: some View {
        HStack(spacing: AppSpacing.md) {
            ZStack {
                RoundedRectangle(cornerRadius: AppRadius.thumb)
                    .fill(AppGradients.cardAccent)
                Image(systemName: snapshot.typePhotoId == nil ? "photo" : "photo.fill")
                    .font(.system(size: AppMetrics.detailPhotoIconSize, weight: .semibold))
                    .foregroundStyle(.white.opacity(0.9))
            }
            .frame(width: AppMetrics.detailPhotoSize, height: AppMetrics.detailPhotoSize)

            VStack(alignment: .leading, spacing: AppSpacing.xs) {
                Text(snapshot.typeName)
                    .font(AppTypography.section)
                    .foregroundStyle(AppColors.textPrimary)
                Text(snapshot.familyName)
                    .font(AppTypography.body)
                    .foregroundStyle(AppColors.textSecondary)
                if snapshot.typePhotoId == nil {
                    Text("No type photo")
                        .font(AppTypography.metricLabel)
                        .foregroundStyle(AppColors.textSecondary)
                }
            }
            Spacer()
        }
        .padding(AppSpacing.lg)
        .background(
            RoundedRectangle(cornerRadius: AppRadius.card)
                .fill(AppColors.cardBackground)
                .overlay(
                    RoundedRectangle(cornerRadius: AppRadius.card)
                        .stroke(AppColors.cardBorder, lineWidth: AppMetrics.cardStrokeWidth)
                )
        )
        .shadow(color: AppShadow.card.color, radius: AppShadow.card.radius, x: AppShadow.card.x, y: AppShadow.card.y)
    }
}

public struct RoomNoteDetailView: View {
    let snapshot: RoomNoteSnapshot

    public init(snapshot: RoomNoteSnapshot) {
        self.snapshot = snapshot
    }

    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppSpacing.lg) {
                VStack(alignment: .leading, spacing: AppSpacing.sm) {
                    Text("Room Note")
                    .font(AppTypography.section)
                        .foregroundStyle(AppColors.textPrimary)
                    if let createdAt = snapshot.createdAt {
                        Text(RoomFormatters.date.string(from: createdAt))
                            .font(AppTypography.metricLabel)
                            .foregroundStyle(AppColors.textSecondary)
                    }
                }

                ParameterSection(
                    title: "Flags",
                    rows: [
                        ParameterDisplayRow(
                            id: UUID(),
                            name: "Empty room",
                            value: snapshot.emptyRoom ? "Yes" : "No",
                            isMissing: false
                        ),
                        ParameterDisplayRow(
                            id: UUID(),
                            name: "Room is blocked",
                            value: snapshot.roomIsBlocked ? "Yes" : "No",
                            isMissing: false
                        )
                    ]
                )

                if let description = snapshot.noteDescription, !description.isEmpty {
                    VStack(alignment: .leading, spacing: AppSpacing.xs) {
                        Text("Description")
                            .font(AppTypography.bodyEmphasis)
                            .foregroundStyle(AppColors.textPrimary)
                        Text(description)
                            .font(AppTypography.body)
                            .foregroundStyle(AppColors.textSecondary)
                    }
                    .padding(AppSpacing.md)
                    .background(
                        RoundedRectangle(cornerRadius: AppRadius.card)
                            .fill(AppColors.cardBackground)
                            .overlay(
                                RoundedRectangle(cornerRadius: AppRadius.card)
                                    .stroke(AppColors.cardBorder, lineWidth: AppMetrics.cardStrokeWidth)
                            )
                    )
                }

                PhotoSummary(
                    title: "Room Note photos",
                    count: (snapshot.mainPhotoId == nil ? 0 : 1) + snapshot.extraPhotoIds.count,
                    max: 5
                )
            }
            .padding(AppSpacing.xl)
            .padding(.bottom, AppSpacing.xl)
        }
        .navigationTitle("Room Note")
        .navigationBarTitleDisplayMode(.inline)
    }
}

private struct ParameterSection: View {
    let title: String
    let rows: [ParameterDisplayRow]

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            Text(title)
                .font(AppTypography.bodyEmphasis)
                .foregroundStyle(AppColors.textPrimary)

            if rows.isEmpty {
                Text("No parameters available.")
                    .font(AppTypography.body)
                    .foregroundStyle(AppColors.textSecondary)
            } else {
                VStack(spacing: AppSpacing.xs) {
                    ForEach(rows) { row in
                        ParameterRow(row: row)
                    }
                }
            }
        }
        .padding(AppSpacing.md)
        .background(
            RoundedRectangle(cornerRadius: AppRadius.card)
                .fill(AppColors.cardBackground)
                .overlay(
                    RoundedRectangle(cornerRadius: AppRadius.card)
                        .stroke(AppColors.cardBorder, lineWidth: AppMetrics.cardStrokeWidth)
                )
        )
    }
}

private struct ParameterRow: View {
    let row: ParameterDisplayRow

    var body: some View {
        HStack(alignment: .firstTextBaseline) {
            Text(row.name)
                .font(AppTypography.body)
                .foregroundStyle(AppColors.textPrimary)
            Spacer()
            Text(row.value)
                .font(AppTypography.body)
                .foregroundStyle(row.isMissing ? AppColors.textSecondary : AppColors.textPrimary)
        }
    }
}

private struct PhotoSummary: View {
    let title: String
    let count: Int
    let max: Int

    var body: some View {
        HStack(spacing: AppSpacing.md) {
            Image(systemName: "photo.on.rectangle")
                .font(.system(size: AppMetrics.detailPhotoIconSize, weight: .semibold))
                .foregroundStyle(AppColors.accent)
            VStack(alignment: .leading, spacing: AppSpacing.xs) {
                Text(title)
                    .font(AppTypography.bodyEmphasis)
                    .foregroundStyle(AppColors.textPrimary)
                Text("\(count)/\(max)")
                    .font(AppTypography.body)
                    .foregroundStyle(AppColors.textSecondary)
            }
            Spacer()
        }
        .padding(AppSpacing.md)
        .background(
            RoundedRectangle(cornerRadius: AppRadius.card)
                .fill(AppColors.cardBackground)
                .overlay(
                    RoundedRectangle(cornerRadius: AppRadius.card)
                        .stroke(AppColors.cardBorder, lineWidth: AppMetrics.cardStrokeWidth)
                )
        )
    }
}

private enum RoomFormatters {
    static let date: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }()
}
