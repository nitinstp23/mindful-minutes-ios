import SwiftUI

extension Color {
    static let mindfulPrimary = Color(red: 0.063, green: 0.725, blue: 0.506)
    static let mindfulSecondary = Color(red: 0.078, green: 0.722, blue: 0.651)
    static let mindfulBackground = Color.white
    static let mindfulBackgroundSecondary = Color(red: 0.95, green: 0.95, blue: 0.95)
    static let mindfulTextPrimary = Color.black
    static let mindfulTextSecondary = Color.black.opacity(0.6)
}

struct MindfulCard<Content: View>: View {
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        content
            .padding()
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
}

struct MindfulButton: View {
    let title: String
    let action: () -> Void
    let style: ButtonStyle

    enum ButtonStyle {
        case primary
        case secondary
    }

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.headline)
                .foregroundColor(style == .primary ? .white : .mindfulPrimary)
                .frame(maxWidth: .infinity)
                .padding()
                .background(style == .primary ? Color.mindfulPrimary : Color.clear)
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.mindfulPrimary, lineWidth: style == .secondary ? 1 : 0)
                )
        }
    }
}

struct MindfulSpacing {
    static let standard: CGFloat = 16
    static let section: CGFloat = 24
    static let small: CGFloat = 8
    static let large: CGFloat = 32
}

#Preview {
    VStack(spacing: MindfulSpacing.section) {
        MindfulCard {
            VStack {
                Text("Sample Card")
                    .font(.headline)
                Text("This is a sample card with the design system")
                    .font(.subheadline)
                    .foregroundColor(.mindfulTextSecondary)
            }
        }

        MindfulButton(title: "Primary Button", action: {}, style: .primary)
        MindfulButton(title: "Secondary Button", action: {}, style: .secondary)
    }
    .padding()
    .background(Color.mindfulBackground)
}
