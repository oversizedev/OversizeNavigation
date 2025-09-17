//
// Copyright © 2025 Alexander Romanov
// HUD.swift, created on 19.07.2025
//

import OversizeResources
import OversizeUI
import SwiftUI

public enum HUD: HUDPresentable {
    case `default`(_ text: String, duration: ContinuousClock.Duration = .seconds(4))
    case success(_ text: String? = nil)
    case destructive(_ text: String? = nil)
    case delete(_ text: String? = nil)
    case archive(_ text: String? = nil)
    case unarchive(_ text: String? = nil)
    case favorite(_ text: String? = nil)
    case edited(_ text: String? = nil)
    case unfavorite(_ text: String? = nil)
    case error(_ error: Error? = nil)

    var title: String {
        switch self {
        case let .default(text, _):
            return text
        case let .success(text):
            return text ?? "Success"
        case let .destructive(text):
            return text ?? "Error"
        case let .delete(text):
            return text ?? "Deleted"
        case let .archive(text):
            return text ?? "Archived"
        case let .unarchive(text):
            return text ?? "Unarchived"
        case let .favorite(text):
            return text ?? "Added to favorites"
        case let .unfavorite(text):
            return text ?? "Removed from favorites"
        case let .edited(text):
            return text ?? "edited"
        case let .error(error):
            return error?.localizedDescription ?? "An error occurred"
        }
    }

    var icon: Image? {
        switch self {
        case .default:
            return nil
        case .success, .edited:
            return Image.Base.Check.Circle.fill.renderingMode(.template)
        case .destructive:
            return Image.Editor.TrashWithLines.fill.renderingMode(.template)
        case .delete:
            return Image.Editor.TrashWithLines.fill.renderingMode(.template)
        case .archive:
            return Image.Delivery.Delivery.fill.renderingMode(.template)
        case .unarchive:
            return Image.Delivery.Delivery.fill.renderingMode(.template)
        case .favorite:
            return Image.Base.Star.fill.renderingMode(.template)
        case .unfavorite:
            return Image.Base.Unstar.fill.renderingMode(.template)
        case .error:
            return Image.Base.Exclamationmark.Circle.fill.renderingMode(.template)
        }
    }

    var color: Color {
        switch self {
        case .success, .edited, .error:
            return Color.success
        case .destructive, .delete:
            return Color.error
        case .archive, .unarchive, .favorite, .unfavorite:
            return Color.warning
        default:
            return Color.onSurfacePrimary
        }
    }

    var duration: ContinuousClock.Duration? {
        switch self {
        case let .default(_, duration):
            return duration
        default:
            return .seconds(4)
        }
    }

    var sensoryFeedback: SensoryFeedback {
        switch self {
        case .default, .edited:
            return .selection
        case .success:
            return .success
        case .destructive, .delete, .error:
            return .error
        case .archive, .unarchive, .favorite, .unfavorite:
            return .warning
        }
    }
}

// MARK: - Static Properties for Convenient Access

public extension HUD {
    static var success: HUD {
        return .success()
    }

    static var destructive: HUD {
        return .destructive()
    }

    static var delete: HUD {
        return .delete()
    }

    static var archive: HUD {
        return .archive()
    }

    static var unarchive: HUD {
        return .unarchive()
    }

    static var favorite: HUD {
        return .favorite()
    }

    static var unfavorite: HUD {
        return .unfavorite()
    }

    static var edited: HUD {
        return .edited()
    }
}

public extension HUD {
    var id: String {
        switch self {
        case let .default(text, duration):
            return "default_\(text)_\(duration.components.seconds)"
        case let .success(text):
            return "success_\(text ?? "Success")"
        case let .destructive(text):
            return "destructive_\(text ?? "Error")"
        case let .delete(text):
            return "delete_\(text ?? "Deleted")"
        case let .archive(text):
            return "archive_\(text ?? "Archived")"
        case let .unarchive(text):
            return "unarchive_\(text ?? "Unarchived")"
        case let .favorite(text):
            return "favorite_\(text ?? "Added to favorites")"
        case let .unfavorite(text):
            return "unfavorite_\(text ?? "Removed from favorites")"
        case let .edited(text):
            return "edited\(text ?? "Removed from favorites")"
        case let .error(error):
            return "error\(error?.localizedDescription ?? "Error")"
        }
    }
}
