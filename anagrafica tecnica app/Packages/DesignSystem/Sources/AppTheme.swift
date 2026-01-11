import SwiftUI

public enum AppColors {
    public static let backgroundTop = Color(red: 0.96, green: 0.94, blue: 0.90)
    public static let backgroundBottom = Color(red: 0.88, green: 0.93, blue: 0.92)
    public static let cardBackground = Color(red: 0.99, green: 0.98, blue: 0.96)
    public static let cardBorder = Color(red: 0.86, green: 0.84, blue: 0.80)
    public static let textPrimary = Color(red: 0.13, green: 0.12, blue: 0.12)
    public static let textSecondary = Color(red: 0.40, green: 0.38, blue: 0.36)
    public static let accent = Color(red: 0.12, green: 0.52, blue: 0.50)

    public static let onlineBadgeBackground = Color(red: 0.79, green: 0.92, blue: 0.84)
    public static let onlineBadgeText = Color(red: 0.14, green: 0.44, blue: 0.28)
    public static let openBadgeBackground = Color(red: 0.98, green: 0.87, blue: 0.64)
    public static let openBadgeText = Color(red: 0.58, green: 0.36, blue: 0.10)
    public static let completedBadgeBackground = Color(red: 0.86, green: 0.86, blue: 0.88)
    public static let completedBadgeText = Color(red: 0.35, green: 0.35, blue: 0.38)
    public static let unknownBadgeBackground = Color(red: 0.90, green: 0.90, blue: 0.90)
    public static let unknownBadgeText = Color(red: 0.38, green: 0.38, blue: 0.42)

    public static let planLinework = Color.black.opacity(0.18)
    public static let roomEmptyFill = Color(red: 0.93, green: 0.93, blue: 0.93)
    public static let roomEmptyStroke = Color(red: 0.76, green: 0.76, blue: 0.76)
    public static let roomEmptyIcon = Color(red: 0.42, green: 0.42, blue: 0.44)
    public static let roomOccupiedFill = Color(red: 0.75, green: 0.88, blue: 0.94)
    public static let roomSelectedStroke = Color(red: 0.12, green: 0.52, blue: 0.50)
}

public enum AppGradients {
    public static let page = LinearGradient(
        colors: [AppColors.backgroundTop, AppColors.backgroundBottom],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    public static let cardAccent = LinearGradient(
        colors: [Color(red: 0.14, green: 0.54, blue: 0.52), Color(red: 0.12, green: 0.34, blue: 0.42)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}

public enum AppTypography {
    public static let title = Font.custom("AvenirNext-DemiBold", size: 28)
    public static let section = Font.custom("AvenirNext-DemiBold", size: 18)
    public static let body = Font.custom("AvenirNext-Regular", size: 15)
    public static let bodyEmphasis = Font.custom("AvenirNext-Medium", size: 15)
    public static let badge = Font.custom("AvenirNext-DemiBold", size: 12)
    public static let metric = Font.custom("AvenirNext-Bold", size: 16)
    public static let metricLabel = Font.custom("AvenirNext-Regular", size: 12)
}

public enum AppSpacing {
    public static let xs: CGFloat = 4
    public static let sm: CGFloat = 8
    public static let md: CGFloat = 12
    public static let lg: CGFloat = 16
    public static let xl: CGFloat = 24
    public static let xxl: CGFloat = 32
}

public enum AppRadius {
    public static let card: CGFloat = 18
    public static let thumb: CGFloat = 14
    public static let badge: CGFloat = 10
    public static let field: CGFloat = 12
}

public enum AppMetrics {
    public static let cardStrokeWidth: CGFloat = 1
    public static let projectCardImageSize: CGFloat = 64
    public static let projectCardIconSize: CGFloat = 24
    public static let readOnlyBadgeIconSize: CGFloat = 12
    public static let levelPickerChevronSize: CGFloat = 10

    public static let wizardCloseIconSize: CGFloat = 14
    public static let wizardHeaderPlaceholderSize: CGFloat = 28
    public static let wizardChevronSize: CGFloat = 12
    public static let wizardStepDotSize: CGFloat = 10
    public static let wizardStepLineWidth: CGFloat = 26
    public static let wizardStepLineHeight: CGFloat = 2
    public static let wizardTextAreaMinHeight: CGFloat = 80

    public static let floorplanLineWidth: CGFloat = 1
    public static let floorplanRoomStrokeWidth: CGFloat = 1.5
    public static let floorplanBadgeSize: CGFloat = 24
    public static let floorplanBadgeStrokeWidth: CGFloat = 1.5
    public static let floorplanBadgePlusSize: CGFloat = 14
    public static let floorplanBadgeTextSize: CGFloat = 12
    public static let floorplanFitScale: CGFloat = 0.92
    public static let floorplanTapThreshold: CGFloat = 4
    public static let floorplanMinZoom: CGFloat = 1.0
    public static let floorplanDefaultMaxZoom: CGFloat = 5.0
    public static let floorplanZoomEpsilon: CGFloat = 0.0001
    public static let floorplanRoomFillOpacity: Double = 0.5
    public static let floorplanSelectedRoomFillOpacity: Double = 1.0
    public static let floorplanSelectedRoomStrokeWidth: CGFloat = 3
    public static let roomOverlayTopBarHeight: CGFloat = 44
    public static let roomSheetMaxHeightFraction: CGFloat = 0.40
    public static let roomSheetRowHeight: CGFloat = 56
    public static let roomSheetHeaderHeight: CGFloat = 34
    public static let roomSheetActionsHeight: CGFloat = 56
    public static let roomBottomBarHeight: CGFloat = 56
    public static let roomBottomBarWidthRatio: CGFloat = 0.72
    public static let roomFocusAnimationDuration: Double = 0.4
    public static let roomFocusPaddingScale: CGFloat = 0.9

    public static let roomPlanHeight: CGFloat = 220
    public static let roomRowIconSize: CGFloat = 18
    public static let roomRowIconFrame: CGFloat = 36
    public static let roomRowChevronSize: CGFloat = 10
    public static let detailPhotoSize: CGFloat = 56
    public static let detailPhotoIconSize: CGFloat = 22
}

public enum AppShadow {
    public static let card = (color: Color.black.opacity(0.08), radius: CGFloat(10), x: CGFloat(0), y: CGFloat(6))
}
