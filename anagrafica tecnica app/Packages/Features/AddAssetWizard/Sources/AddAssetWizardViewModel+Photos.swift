import Foundation

@MainActor
extension AddAssetWizardViewModel {
    func addTypePhoto() {
        typePhotoId = UUID()
    }

    func removeTypePhoto() {
        typePhotoId = nil
    }

    func addInstancePhoto() {
        guard instancePhotoIds.count < 5 else { return }
        instancePhotoIds.append(UUID())
    }

    func removeInstancePhoto(id: UUID) {
        instancePhotoIds.removeAll { $0 == id }
    }

    func addRoomNotePhoto() {
        if roomNoteMainPhotoId == nil {
            roomNoteMainPhotoId = UUID()
        } else if roomNoteExtraPhotoIds.count < 4 {
            roomNoteExtraPhotoIds.append(UUID())
        }
    }

    func removeRoomNotePhoto(id: UUID) {
        if roomNoteMainPhotoId == id {
            roomNoteMainPhotoId = nil
        } else {
            roomNoteExtraPhotoIds.removeAll { $0 == id }
        }
    }

    func toggleRoomNoteEmpty() {
        guard !roomHasAssets else { return }
        roomNoteEmptyRoom.toggle()
        if roomNoteEmptyRoom {
            roomNoteBlocked = false
        }
    }

    func toggleRoomNoteBlocked() {
        guard !roomHasAssets else { return }
        roomNoteBlocked.toggle()
        if roomNoteBlocked {
            roomNoteEmptyRoom = false
        }
    }
}
