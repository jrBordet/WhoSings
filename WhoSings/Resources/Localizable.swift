// swiftlint:disable all
// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

import Foundation

// swiftlint:disable superfluous_disable_command file_length implicit_return

// MARK: - Strings

// swiftlint:disable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:disable nesting type_body_length type_name vertical_whitespace_opening_braces
internal enum L10n {

  internal enum App {
    /// WhoSings
    internal static let name = L10n.tr("Localizable", "app.name")
    internal enum Alert {
      /// enter username
      internal static let username = L10n.tr("Localizable", "app.alert.username")
    }
    internal enum Home {
      /// lyrics line...
      internal static let line = L10n.tr("Localizable", "app.home.line")
      /// log in
      internal static let login = L10n.tr("Localizable", "app.home.login")
      /// log out
      internal static let logout = L10n.tr("Localizable", "app.home.logout")
      /// next
      internal static let next = L10n.tr("Localizable", "app.home.next")
      /// score
      internal static let score = L10n.tr("Localizable", "app.home.score")
      /// start
      internal static let start = L10n.tr("Localizable", "app.home.start")
    }
    internal enum Leaderboard {
      /// leaderboard
      internal static let title = L10n.tr("Localizable", "app.leaderboard.title")
    }
    internal enum Session {
      /// Session Completed
      internal static let completed = L10n.tr("Localizable", "app.session.completed")
      /// dismiss
      internal static let dismiss = L10n.tr("Localizable", "app.session.dismiss")
      /// points
      internal static let points = L10n.tr("Localizable", "app.session.points")
    }
    internal enum Whosings {
      /// not found
      internal static let notfound = L10n.tr("Localizable", "app.whosings.notfound")
      /// ok
      internal static let submit = L10n.tr("Localizable", "app.whosings.submit")
    }
  }
}
// swiftlint:enable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:enable nesting type_body_length type_name vertical_whitespace_opening_braces

// MARK: - Implementation Details

extension L10n {
  private static func tr(_ table: String, _ key: String, _ args: CVarArg...) -> String {
    let format = BundleToken.bundle.localizedString(forKey: key, value: nil, table: table)
    return String(format: format, locale: Locale.current, arguments: args)
  }
}

// swiftlint:disable convenience_type
private final class BundleToken {
  static let bundle: Bundle = {
    #if SWIFT_PACKAGE
    return Bundle.module
    #else
    return Bundle(for: BundleToken.self)
    #endif
  }()
}
// swiftlint:enable convenience_type
