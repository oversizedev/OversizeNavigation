//
// Copyright © 2024 Alexander Romanov
// AlertRouter.swift, created on 11.04.2024
//

import OversizeLocalizable
import OversizeModels
import SwiftUI

public enum AppAlert: Alertable {
    case dismiss(_ action: () -> Void)
    case delete(_ action: () -> Void)
    case unsavedChanges(_ action: () -> Void)
    case appError(error: AppError)
    case text(_ title: String)
    case discard(_ action: () -> Void)
    case destructive(
        _ title: String,
        message: String? = nil,
        button: String = "Ok",
        _ action: () -> Void,
    )
    case `default`(
        _ title: String,
        message: String? = nil,
        button: String = "Ok",
        _ action: () -> Void,
    )
}

public extension AppAlert {
    var id: String {
        switch self {
        case .dismiss:
            "dismiss"
        case .delete:
            "delete"
        case .unsavedChanges:
            "unsavedChanges"
        case .appError:
            "appError"
        case .text:
            "textTitle"
        case .destructive:
            "destructive"
        case .discard:
            "discard"
        case .default:
            "default`"
        }
    }
}

public extension AppAlert {
    var alert: Alert {
        switch self {
        case let .dismiss(action):
            Alert(
                title: Text("Are you sure you want to dismiss?"),
                primaryButton: .destructive(Text("Dismiss"), action: action),
                secondaryButton: .cancel(),
            )
        case let .delete(action):
            Alert(
                title: Text("Are you sure you want to delete?"),
                primaryButton: .destructive(Text("\(L10n.Button.delete)"), action: action),
                secondaryButton: .cancel(),
            )
        case let .unsavedChanges(action):
            Alert(
                title: Text("You have unsaved changes"),
                message: Text("Do you want to discard?"),
                primaryButton: .destructive(Text("Discard Changes"), action: action),
                secondaryButton: .cancel(),
            )
        case let .appError(error: error):
            Alert(
                title: Text(error.title),
                message: error.subtitle.map { Text($0) },
                dismissButton: .default(Text("Close")),
            )
        case let .text(title):
            Alert(
                title: Text(title),
                dismissButton: .default(Text("Close")),
            )
        case let .destructive(title, message, button, action):
            Alert(
                title: Text(title),
                message: message.map { Text($0) },
                primaryButton: .destructive(Text(button), action: action),
                secondaryButton: .cancel(),
            )
        case let .discard(action):
            Alert(
                title: Text("Are you sure you want to discard?"),
                primaryButton: .destructive(Text("Discard"), action: action),
                secondaryButton: .cancel(),
            )
        case let .default(title, message, button, action):
            Alert(
                title: Text(title),
                message: message.map { Text($0) },
                primaryButton: .default(Text(button), action: action),
                secondaryButton: .cancel(),
            )
        }
    }
}
