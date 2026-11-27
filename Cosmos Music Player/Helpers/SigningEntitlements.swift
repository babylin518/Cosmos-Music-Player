//
//  SigningEntitlements.swift
//  Cosmos Music Player
//
//  What the signature this copy was installed with actually allows.
//

import Foundation

/// A copy re-signed with a free Apple ID (Sideloadly, AltStore) loses the
/// Siri and iCloud entitlements, and the system raises an exception - a
/// crash at launch - when INPreferences, INVocabulary or CKContainer are
/// used without them. The provisioning profile embedded in the bundle lists
/// what was granted; an App Store copy has no profile and has everything.
enum SigningEntitlements {
    static let siri: Bool = has("com.apple.developer.siri")
    static let iCloud: Bool = has("com.apple.developer.icloud-container-identifiers")

    private static func has(_ key: String) -> Bool {
        guard let url = Bundle.main.url(forResource: "embedded", withExtension: "mobileprovision"),
              let data = try? Data(contentsOf: url) else { return true }
        // The profile is a signed blob with a plain XML property list inside.
        guard let start = data.range(of: Data("<?xml".utf8)),
              let end = data.range(of: Data("</plist>".utf8), in: start.lowerBound..<data.endIndex),
              let plist = try? PropertyListSerialization.propertyList(
                  from: data.subdata(in: start.lowerBound..<end.upperBound), format: nil
              ) as? [String: Any],
              let granted = plist["Entitlements"] as? [String: Any] else { return false }
        return granted[key] != nil
    }
}
