//
//  ScannedFoldersManager.swift
//  Cosmos Music Player
//
//  Persists user-selected local folders as security-scoped bookmarks so the
//  library can re-scan them for new music on every launch/manual sync. The
//  individual files discovered inside a folder still get their own per-file
//  bookmarks (stored in ExternalFileBookmarks.plist by LibraryIndexer), so
//  playback and cleanup reuse the existing external-file machinery unchanged.
//  This manager only needs to remember the folders themselves so newly-added
//  files can be picked up later and the user can stop watching a folder.
//

import Foundation

struct ScannedFolder: Identifiable, Equatable {
    /// Original path at the time it was added; stable key for de-duplication.
    let id: String
    let displayPath: String
    let bookmark: Data

    var name: String { URL(fileURLWithPath: displayPath).lastPathComponent }

    static func == (lhs: ScannedFolder, rhs: ScannedFolder) -> Bool {
        lhs.id == rhs.id
    }
}

@MainActor
final class ScannedFoldersManager: ObservableObject {
    static let shared = ScannedFoldersManager()

    @Published private(set) var folders: [ScannedFolder] = []

    private var storeURL: URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            .appendingPathComponent("ScannedFolderBookmarks.plist")
    }

    init() {
        load()
    }

    func load() {
        guard let data = try? Data(contentsOf: storeURL),
              let raw = try? PropertyListSerialization.propertyList(from: data, options: [], format: nil) as? [[String: Data]] else {
            folders = []
            return
        }

        folders = raw.compactMap { entry in
            guard let bookmark = entry["bookmark"],
                  let pathData = entry["path"],
                  let path = String(data: pathData, encoding: .utf8) else {
                return nil
            }
            return ScannedFolder(id: path, displayPath: path, bookmark: bookmark)
        }
    }

    private func persist() {
        let raw: [[String: Data]] = folders.map { folder in
            ["bookmark": folder.bookmark, "path": Data(folder.displayPath.utf8)]
        }
        do {
            let data = try PropertyListSerialization.data(fromPropertyList: raw, format: .xml, options: 0)
            try data.write(to: storeURL, options: .atomic)
        } catch {
            print("❌ Failed to persist scanned folders: \(error)")
        }
    }

    /// Store a folder as a security-scoped bookmark. Returns false if the
    /// folder is already watched or the bookmark could not be created.
    @discardableResult
    func addFolder(_ url: URL) -> Bool {
        guard !folders.contains(where: { $0.displayPath == url.path }) else {
            print("📁 Folder already watched: \(url.path)")
            return false
        }

        do {
            let bookmark = try url.bookmarkData(options: .minimalBookmark, includingResourceValuesForKeys: nil, relativeTo: nil)
            folders.append(ScannedFolder(id: url.path, displayPath: url.path, bookmark: bookmark))
            persist()
            print("✅ Now watching folder: \(url.path)")
            return true
        } catch {
            print("❌ Failed to bookmark folder \(url.path): \(error)")
            return false
        }
    }

    /// Stop watching a folder. Tracks already imported from it are left in the
    /// library; this only stops future re-scans from re-adding new files.
    func removeFolder(_ folder: ScannedFolder) {
        folders.removeAll { $0.id == folder.id }
        persist()
        print("🗑️ Stopped watching folder: \(folder.displayPath)")
    }

    /// Resolve stored bookmarks to their current URLs, refreshing any that have
    /// gone stale (e.g. the folder moved). Rejects network-scheme URLs.
    func resolvedFolderURLs() -> [URL] {
        var urls: [URL] = []
        var changed = false

        for index in folders.indices {
            var isStale = false
            guard let url = try? URL(
                resolvingBookmarkData: folders[index].bookmark,
                options: .withoutUI,
                relativeTo: nil,
                bookmarkDataIsStale: &isStale
            ) else {
                continue
            }

            if let scheme = url.scheme?.lowercased(), ["http", "https", "ftp", "sftp"].contains(scheme) {
                print("❌ Rejected network folder URL: \(url.absoluteString)")
                continue
            }

            if isStale,
               let refreshed = try? url.bookmarkData(options: .minimalBookmark, includingResourceValuesForKeys: nil, relativeTo: nil) {
                folders[index] = ScannedFolder(id: url.path, displayPath: url.path, bookmark: refreshed)
                changed = true
            }

            urls.append(url)
        }

        if changed { persist() }
        return urls
    }
}
