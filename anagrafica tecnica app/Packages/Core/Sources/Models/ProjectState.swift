public enum ProjectLifecycleState: String, Codable, CaseIterable {
    case draft = "DRAFT"
    case ready = "READY"
    case active = "ACTIVE"
    case completed = "COMPLETED"
    case approved = "APPROVED"
}

public enum ProjectUIState: String, Codable, CaseIterable {
    case online = "Online"
    case open = "Open"
    case completed = "Completed"
}

public extension ProjectLifecycleState {
    var uiState: ProjectUIState? {
        switch self {
        case .ready:
            return .online
        case .active:
            return .open
        case .completed:
            return .completed
        case .draft, .approved:
            return nil
        }
    }
}
