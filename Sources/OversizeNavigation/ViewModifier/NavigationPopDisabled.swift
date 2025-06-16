//
// Copyright © 2025 Alexander Romanov
// NavigationPopGestureDisabler.swift, created on 06.06.2025
//

import SwiftUI

#if os(iOS)
    extension UIView {
        var parentViewController: UIViewController? {
            sequence(first: self) {
                $0.next
            }.first { $0 is UIViewController } as? UIViewController
        }
    }

    private struct NavigationPopGestureDisabler: UIViewRepresentable {
        let disabled: Bool

        func makeUIView(context _: Context) -> some UIView { UIView() }

        func updateUIView(_ uiView: UIViewType, context _: Context) {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.02) {
                uiView.parentViewController?.navigationController?.interactivePopGestureRecognizer?.isEnabled = !disabled
            }
        }
    }
#endif

public extension View {
    @ViewBuilder
    func interactivePopGestureDisabled(_ disabled: Bool) -> some View {
        #if os(iOS)
            background {
                NavigationPopGestureDisabler(disabled: disabled)
            }
        #endif
    }
}
