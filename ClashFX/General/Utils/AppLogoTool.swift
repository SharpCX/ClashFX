//
//  AppLogoTool.swift
//  ClashFX
//

import AppKit
import CoreServices

enum AppLogoTool {
    static let customLogoPath = (NSHomeDirectory() as NSString).appendingPathComponent("/.config/clashfx/appLogo.png")
    private static let selectedLogoKey = "AppLogoTool.selectedLogo"
    private static let defaultLogoID = "default"
    private static let customLogoID = "custom"

    static let originalDefaultIcon: NSImage = {
        if let url = Bundle.main.url(forResource: "AppIcon", withExtension: "icns"),
           let image = NSImage(contentsOf: url) {
            return image
        }
        return NSApp.applicationIconImage
    }()

    struct BuiltInLogo: Equatable {
        let id: String
        let title: String
        let resourceName: String
    }

    static let builtInLogos = [
        BuiltInLogo(id: "fx-portal", title: NSLocalizedString("FX Portal", comment: ""), resourceName: "fx-portal"),
        BuiltInLogo(id: "fx-frost", title: NSLocalizedString("FX Frost", comment: ""), resourceName: "fx-frost"),
        BuiltInLogo(id: "classic-face", title: NSLocalizedString("Classic Face", comment: ""), resourceName: "classic-face"),
        BuiltInLogo(id: "classic-sitting", title: NSLocalizedString("Classic Sitting", comment: ""), resourceName: "classic-sitting"),
        BuiltInLogo(id: "flat-blue", title: NSLocalizedString("Flat Blue", comment: ""), resourceName: "flat-blue")
    ]

    static var selectedLogoID: String {
        UserDefaults.standard.string(forKey: selectedLogoKey) ?? defaultLogoID
    }

    static var isDefaultLogoSelected: Bool {
        selectedLogoID == defaultLogoID
    }

    static var canPersistBundleIcon: Bool {
        #if DEBUG
            return false
        #else
            let bundlePath = Bundle.main.bundlePath
            return !bundlePath.contains("/DerivedData/") && !bundlePath.contains("/Build/Products/")
        #endif
    }

    static var isDebugBuild: Bool {
        #if DEBUG
            return true
        #else
            return false
        #endif
    }

    static func loadCustomLogo() -> NSImage? {
        guard let image = NSImage(contentsOfFile: customLogoPath) else { return nil }
        return image
    }

    static func loadBuiltInLogo(_ logo: BuiltInLogo) -> NSImage? {
        guard let url = Bundle.main.url(forResource: logo.resourceName, withExtension: "png", subdirectory: "AppIcons") else { return nil }
        return NSImage(contentsOf: url)
    }

    static func loadSelectedLogo() -> NSImage? {
        let selectedID = selectedLogoID
        if selectedID == customLogoID {
            return loadCustomLogo()
        }
        guard let logo = builtInLogos.first(where: { $0.id == selectedID }) else { return nil }
        return loadBuiltInLogo(logo)
    }

    @discardableResult
    static func selectDefaultLogo() -> Bool {
        UserDefaults.standard.set(defaultLogoID, forKey: selectedLogoKey)
        return applyLogo()
    }

    @discardableResult
    static func selectCustomLogo() -> Bool {
        UserDefaults.standard.set(customLogoID, forKey: selectedLogoKey)
        return applyLogo()
    }

    @discardableResult
    static func selectBuiltInLogo(id: String) -> Bool {
        UserDefaults.standard.set(id, forKey: selectedLogoKey)
        return applyLogo()
    }

    /// Apply the custom logo (or restore default) to the running application.
    @discardableResult
    static func applyLogo() -> Bool {
        let bundlePath = Bundle.main.bundlePath
        let didSetIcon: Bool
        let baseIcon = loadSelectedLogo() ?? originalDefaultIcon
        let finalIcon = AutoUpgradeManager.shouldShowLabBadge ? addLabBadge(to: baseIcon) : loadSelectedLogo()

        if let finalIcon {
            NSApp.applicationIconImage = finalIcon
            didSetIcon = canPersistBundleIcon ? NSWorkspace.shared.setIcon(finalIcon, forFile: bundlePath) : true
        } else {
            NSApp.applicationIconImage = nil
            didSetIcon = canPersistBundleIcon ? NSWorkspace.shared.setIcon(nil, forFile: bundlePath) : true
        }

        if canPersistBundleIcon {
            LSRegisterURL(Bundle.main.bundleURL as CFURL, true)
        }
        NSWorkspace.shared.noteFileSystemChanged(bundlePath)
        refreshIconAppearanceCache()
        return didSetIcon
    }

    private static func addLabBadge(to icon: NSImage) -> NSImage {
        let canvas = NSSize(width: 1024, height: 1024)
        let result = NSImage(size: canvas)
        result.lockFocus()
        defer { result.unlockFocus() }

        icon.draw(in: NSRect(origin: .zero, size: canvas))

        let triSize: CGFloat = 360
        let path = NSBezierPath()
        path.move(to: NSPoint(x: canvas.width, y: canvas.height))
        path.line(to: NSPoint(x: canvas.width - triSize, y: canvas.height))
        path.line(to: NSPoint(x: canvas.width, y: canvas.height - triSize))
        path.close()
        NSColor.systemOrange.setFill()
        path.fill()
        NSColor.white.setStroke()
        path.lineWidth = 14
        path.stroke()

        let label = "Lab"
        let attrs: [NSAttributedString.Key: Any] = [
            .font: NSFont.systemFont(ofSize: 120, weight: .black),
            .foregroundColor: NSColor.white,
            .kern: 2
        ]
        let textSize = (label as NSString).size(withAttributes: attrs)
        let cx = canvas.width - triSize / 2.7
        let cy = canvas.height - triSize / 2.7

        NSGraphicsContext.current?.saveGraphicsState()
        let transform = NSAffineTransform()
        transform.translateX(by: cx, yBy: cy)
        transform.rotate(byDegrees: -45)
        transform.concat()
        let textRect = NSRect(x: -textSize.width / 2, y: -textSize.height / 2, width: textSize.width, height: textSize.height)
        (label as NSString).draw(in: textRect, withAttributes: attrs)
        NSGraphicsContext.current?.restoreGraphicsState()

        return result
    }

    private static func refreshIconAppearanceCache() {
        guard let iconAppearanceClass = NSClassFromString("SLSIconAppearanceConfiguration") as? NSObject.Type else { return }

        let fetchSelector = NSSelectorFromString("fetchCurrentIconAppearanceConfiguration")
        guard iconAppearanceClass.responds(to: fetchSelector),
              let config = iconAppearanceClass.perform(fetchSelector)?.takeUnretainedValue() as? NSObject else { return }

        let saveSelector = NSSelectorFromString("save")
        guard config.responds(to: saveSelector) else { return }
        config.perform(saveSelector)
    }
}
