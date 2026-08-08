//
//  AetherHomeView.swift
//  Cosmos Music Player
//
//  Aether "Shelves" Home — the artwork-first landing screen that replaces the
//  old category-list Library. See docs/design/aether/AETHER_OPTION3_SHELVES.md.
//
//  This is presentation only: it projects the existing library (`tracks`) and
//  player state (`PlayerEngine`) into shelves and reuses the existing detail
//  screens as navigation destinations. No playback or persistence behavior is
//  changed. Derived groupings are computed in `AetherHomeModel` off the render
//  loop, not in `body`. The persistent mini player is provided by ContentView's
//  `.safeAreaInset`, so it is not rebuilt here.
//

import SwiftUI

// MARK: - Home

struct AetherHomeView: View {
    let tracks: [Track]
    @Binding var showTutorial: Bool
    @Binding var showPlaylistManagement: Bool
    @Binding var showSettings: Bool
    let onRefresh: (() async -> (before: Int, after: Int))?
    let onManualSync: (() async -> (before: Int, after: Int))?

    @EnvironmentObject private var appCoordinator: AppCoordinator
    @StateObject private var model = AetherHomeModel()

    @State private var showFilePicker = false
    @State private var showFolderPicker = false
    @State private var isSyncing = false

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(alignment: .leading, spacing: Aether.Spacing.shelfGap) {
                    header

                    if tracks.isEmpty {
                        emptyState
                    } else {
                        ContinueListeningSection(
                            playerEngine: appCoordinator.playerEngine,
                            artistNameById: model.artistNameById,
                            albumTitleById: model.albumTitleById
                        )

                        if !model.recentlyAdded.isEmpty {
                            albumShelf(title: NSLocalizedString("recently_added", value: "Recently Added", comment: ""),
                                       albums: model.recentlyAdded,
                                       destination: { RecentlyAddedScreen(tracks: tracks) })
                        }
                        if !model.albums.isEmpty {
                            albumShelf(title: Localized.albums,
                                       albums: model.albums,
                                       destination: { AlbumsScreen(allTracks: tracks) })
                        }
                        if !model.artists.isEmpty {
                            artistShelf
                        }
                        if !model.playlists.isEmpty {
                            playlistShelf
                        }

                        collectionLinks
                    }
                }
                .padding(.top, Aether.Spacing.md)
                .padding(.bottom, Aether.Spacing.xl)
            }
            .aetherBackground()
            .navigationBarHidden(true)
        }
        // Aether is dark by default; force dark for Home and every screen pushed
        // from it so pushed destinations don't flash the light system appearance.
        .preferredColorScheme(.dark)
        .task { reload() }
        .onChange(of: tracks.count) { _, _ in reload() }
        .sheet(isPresented: $showFilePicker) {
            MusicFilePicker { urls in importFiles(urls) }
        }
        .sheet(isPresented: $showFolderPicker) {
            MusicFolderPicker { urls in importFolders(urls) }
        }
    }

    // MARK: Header

    private var header: some View {
        HStack(alignment: .center) {
            Aether.wordmark()
            Spacer()
            HStack(spacing: Aether.Spacing.lg) {
                if let onManualSync {
                    Button {
                        guard !isSyncing else { return }
                        isSyncing = true
                        Task {
                            _ = await onManualSync()
                            isSyncing = false
                        }
                    } label: {
                        if isSyncing {
                            ProgressView()
                                .controlSize(.small)
                                .tint(Aether.Color.primary)
                        } else {
                            Image(systemName: "arrow.triangle.2.circlepath")
                                .font(.system(size: 18, weight: .regular))
                                .foregroundStyle(Aether.Color.primary)
                        }
                    }
                    .accessibilityLabel(Text(NSLocalizedString("sync", value: "Sync", comment: "")))
                }
                Button {
                    showSettings = true
                } label: {
                    Image(systemName: "gearshape")
                        .font(.system(size: 18, weight: .regular))
                        .foregroundStyle(Aether.Color.textSecondary)
                }
                .accessibilityLabel(Text(Localized.settings))
            }
        }
        .padding(.horizontal, Aether.Spacing.screenMargin)
        .padding(.top, Aether.Spacing.sm)
    }

    // MARK: Shelves

    private func albumShelf<Destination: View>(
        title: String,
        albums: [Album],
        @ViewBuilder destination: @escaping () -> Destination
    ) -> some View {
        AetherShelf {
            AetherShelfHeader(title: title, destination: destination)
        } content: {
            ForEach(albums, id: \.id) { album in
                AlbumShelfItem(
                    album: album,
                    repTrack: album.id.flatMap { model.repTrackByAlbumId[$0] },
                    artistName: album.id.flatMap { model.artistNameForAlbum($0) } ?? "",
                    allTracks: tracks
                )
            }
        }
    }

    private var artistShelf: some View {
        AetherShelf {
            AetherShelfHeader(title: Localized.artists) { ArtistsScreen(allTracks: tracks) }
        } content: {
            ForEach(model.artists, id: \.id) { artist in
                ArtistShelfItem(
                    artist: artist,
                    repTrack: artist.id.flatMap { model.repTrackByArtistId[$0] },
                    allTracks: tracks
                )
            }
        }
    }

    private var playlistShelf: some View {
        AetherShelf {
            AetherShelfHeader(title: Localized.playlists) { PlaylistsScreen() }
        } content: {
            ForEach(model.playlists, id: \.id) { playlist in
                PlaylistShelfItem(playlist: playlist)
            }
        }
    }

    // MARK: Collection links

    private var collectionLinks: some View {
        VStack(alignment: .leading, spacing: Aether.Spacing.sm) {
            Text(NSLocalizedString("collection", value: "Collection", comment: ""))
                .aetherSectionHeader()
                .padding(.horizontal, Aether.Spacing.screenMargin)

            VStack(spacing: 0) {
                NavigationLink {
                    LikedSongsScreen(allTracks: tracks)
                } label: {
                    AetherCollectionRow(icon: "heart", title: NSLocalizedString("favorites", value: "Favorites", comment: ""),
                                        detail: model.favoritesCount > 0 ? "\(model.favoritesCount)" : nil)
                }
                .buttonStyle(.plain)

                Divider().overlay(Aether.Color.separator).padding(.leading, 52)

                NavigationLink {
                    AllSongsScreen(tracks: tracks)
                } label: {
                    AetherCollectionRow(icon: "music.note", title: NSLocalizedString("songs", value: "Songs", comment: ""),
                                        detail: "\(tracks.count)")
                }
                .buttonStyle(.plain)

                Divider().overlay(Aether.Color.separator).padding(.leading, 52)

                Menu {
                    Button {
                        showFilePicker = true
                    } label: {
                        Label(NSLocalizedString("add_music_choose_files", value: "Choose Files", comment: ""), systemImage: "doc.badge.plus")
                    }
                    Button {
                        showFolderPicker = true
                    } label: {
                        Label(NSLocalizedString("add_music_scan_folder", value: "Scan Folder", comment: ""), systemImage: "folder.badge.plus")
                    }
                } label: {
                    AetherCollectionRow(icon: "square.and.arrow.down", title: NSLocalizedString("import_music", value: "Import Music", comment: ""), detail: nil)
                }
            }
            .background(Aether.Color.surface, in: RoundedRectangle(cornerRadius: Aether.Radius.miniPlayer, style: .continuous))
            .padding(.horizontal, Aether.Spacing.screenMargin)
        }
    }

    // MARK: Empty state

    private var emptyState: some View {
        VStack(spacing: Aether.Spacing.md) {
            Spacer(minLength: Aether.Spacing.xl * 2)
            Image(systemName: "square.stack.3d.up.slash")
                .font(.system(size: 48, weight: .thin))
                .foregroundStyle(Aether.Color.textTertiary)
            Text(NSLocalizedString("empty_library_title", value: "Your music lives here", comment: ""))
                .font(.title3.weight(.semibold))
                .foregroundStyle(Aether.Color.textPrimary)
            Text(NSLocalizedString("empty_library_subtitle", value: "Import audio files to begin building your Aether library.", comment: ""))
                .font(.subheadline)
                .foregroundStyle(Aether.Color.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, Aether.Spacing.xl)

            Menu {
                Button {
                    showFilePicker = true
                } label: {
                    Label(NSLocalizedString("add_music_choose_files", value: "Choose Files", comment: ""), systemImage: "doc.badge.plus")
                }
                Button {
                    showFolderPicker = true
                } label: {
                    Label(NSLocalizedString("add_music_scan_folder", value: "Scan Folder", comment: ""), systemImage: "folder.badge.plus")
                }
            } label: {
                Text(NSLocalizedString("import_music", value: "Import Music", comment: ""))
                    .font(.headline)
                    .foregroundStyle(Aether.Color.background)
                    .padding(.horizontal, Aether.Spacing.lg)
                    .padding(.vertical, Aether.Spacing.sm)
                    .background(Aether.Color.primary, in: Capsule())
            }
            .padding(.top, Aether.Spacing.sm)
            Spacer()
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: Actions

    private func reload() {
        let favorites = (try? appCoordinator.getFavorites().count) ?? 0
        model.reload(tracks: tracks, favoritesCount: favorites)
    }

    private func importFiles(_ urls: [URL]) {
        Task {
            let imported = await LibraryIndexer.shared.importExternalFiles(urls)
            if imported > 0, let onManualSync { _ = await onManualSync() }
        }
    }

    private func importFolders(_ urls: [URL]) {
        Task {
            var imported = 0
            for url in urls {
                if let scheme = url.scheme?.lowercased(), ["http", "https", "ftp", "sftp"].contains(scheme) { continue }
                guard url.startAccessingSecurityScopedResource() else { continue }
                _ = ScannedFoldersManager.shared.addFolder(url)
                imported += await LibraryIndexer.shared.importMusicFromFolder(url, allowExcludedReimport: true)
                url.stopAccessingSecurityScopedResource()
            }
            if imported > 0, let onManualSync { _ = await onManualSync() }
        }
    }
}

// MARK: - Derived-data model

@MainActor
final class AetherHomeModel: ObservableObject {
    @Published var recentlyAdded: [Album] = []
    @Published var albums: [Album] = []
    @Published var artists: [Artist] = []
    @Published var playlists: [Playlist] = []
    @Published var repTrackByAlbumId: [Int64: Track] = [:]
    @Published var repTrackByArtistId: [Int64: Track] = [:]
    @Published var artistNameById: [Int64: String] = [:]
    @Published var albumTitleById: [Int64: String] = [:]
    @Published var albumArtistIdById: [Int64: Int64] = [:]
    @Published var favoritesCount: Int = 0

    private let previewCount = 12

    /// Album artist display name, resolved through the album's artistId.
    func artistNameForAlbum(_ albumId: Int64) -> String? {
        guard let artistId = albumArtistIdById[albumId] else { return nil }
        return artistNameById[artistId]
    }

    func reload(tracks: [Track], favoritesCount: Int) {
        let previewCount = self.previewCount
        // Grouping + DB reads run off the main actor; only the assignment hops
        // back. GRDB reads are already used off-main elsewhere (ContentView).
        Task.detached(priority: .userInitiated) {
            let db = DatabaseManager.shared
            let allAlbums = (try? db.getAllAlbums()) ?? []
            let allArtists = (try? db.getAllArtists()) ?? []
            let allPlaylists = (try? db.getAllPlaylists()) ?? []

            // `tracks` arrives newest-first (id desc). First occurrence of an
            // album/artist is therefore its most recent track — good artwork.
            var repAlbum: [Int64: Track] = [:]
            var repArtist: [Int64: Track] = [:]
            var recentAlbumIds: [Int64] = []
            var seenAlbum = Set<Int64>()
            for track in tracks {
                if let albumId = track.albumId {
                    if repAlbum[albumId] == nil { repAlbum[albumId] = track }
                    if seenAlbum.insert(albumId).inserted { recentAlbumIds.append(albumId) }
                }
                if let artistId = track.artistId, repArtist[artistId] == nil {
                    repArtist[artistId] = track
                }
            }

            var albumById: [Int64: Album] = [:]
            var albumTitleById: [Int64: String] = [:]
            var albumArtistIdById: [Int64: Int64] = [:]
            for album in allAlbums {
                guard let id = album.id else { continue }
                albumById[id] = album
                albumTitleById[id] = album.title
                if let artistId = album.artistId { albumArtistIdById[id] = artistId }
            }
            var artistNameById: [Int64: String] = [:]
            for artist in allArtists {
                if let id = artist.id { artistNameById[id] = artist.name }
            }

            let recently = recentAlbumIds.prefix(previewCount).compactMap { albumById[$0] }
            let albumsPreview = Array(allAlbums.prefix(previewCount))
            let artistsPreview = Array(allArtists.prefix(previewCount))
            let playlistsPreview = Array(allPlaylists.prefix(previewCount))

            await MainActor.run {
                self.repTrackByAlbumId = repAlbum
                self.repTrackByArtistId = repArtist
                self.artistNameById = artistNameById
                self.albumTitleById = albumTitleById
                self.albumArtistIdById = albumArtistIdById
                self.recentlyAdded = Array(recently)
                self.albums = albumsPreview
                self.artists = artistsPreview
                self.playlists = playlistsPreview
                self.favoritesCount = favoritesCount
            }
        }
    }
}

// MARK: - Continue Listening

struct ContinueListeningSection: View {
    @ObservedObject var playerEngine: PlayerEngine
    let artistNameById: [Int64: String]
    let albumTitleById: [Int64: String]

    var body: some View {
        if let track = playerEngine.currentTrack {
            VStack(alignment: .leading, spacing: Aether.Spacing.sm) {
                Text(NSLocalizedString("continue_listening", value: "Continue Listening", comment: ""))
                    .aetherSectionHeader()
                card(track)
            }
            .padding(.horizontal, Aether.Spacing.screenMargin)
        }
    }

    private func card(_ track: Track) -> some View {
        let artist = track.artistId.flatMap { artistNameById[$0] } ?? ""
        let album = track.albumId.flatMap { albumTitleById[$0] } ?? ""
        let progress = playerEngine.duration > 0 ? playerEngine.playbackTime / playerEngine.duration : 0

        return HStack(spacing: Aether.Spacing.md) {
            AetherArtwork(track: track)
                .frame(width: 84, height: 84)

            VStack(alignment: .leading, spacing: 3) {
                Text(track.title)
                    .font(.headline)
                    .foregroundStyle(Aether.Color.textPrimary)
                    .lineLimit(1)
                if !artist.isEmpty {
                    Text(artist).font(.subheadline).foregroundStyle(Aether.Color.textSecondary).lineLimit(1)
                }
                if !album.isEmpty {
                    Text(album).font(.caption).foregroundStyle(Aether.Color.textTertiary).lineLimit(1)
                }
            }

            Spacer(minLength: Aether.Spacing.sm)

            Button {
                if playerEngine.isPlaying { playerEngine.pause() } else { playerEngine.play() }
            } label: {
                Image(systemName: playerEngine.isPlaying ? "pause.fill" : "play.fill")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(Aether.Color.textPrimary)
                    .frame(width: 44, height: 44)
                    .background(Aether.Color.primary.opacity(0.22), in: Circle())
            }
            .accessibilityLabel(Text(playerEngine.isPlaying ? NSLocalizedString("pause", value: "Pause", comment: "") : NSLocalizedString("play", value: "Play", comment: "")))
        }
        .padding(Aether.Spacing.md)
        .frame(height: Aether.Metrics.continueCardHeight)
        .background(Aether.Color.surfaceElevated, in: RoundedRectangle(cornerRadius: Aether.Radius.featureCard, style: .continuous))
        .overlay(alignment: .bottom) {
            GeometryReader { geo in
                Capsule()
                    .fill(Aether.Color.primary)
                    .frame(width: max(0, geo.size.width * progress), height: 2)
            }
            .frame(height: 2)
            .padding(.horizontal, Aether.Spacing.md)
            .padding(.bottom, 6)
        }
    }
}

// MARK: - Reusable shelf building blocks

struct AetherShelf<Header: View, Content: View>: View {
    @ViewBuilder let header: () -> Header
    @ViewBuilder let content: () -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: Aether.Spacing.sm) {
            header()
                .padding(.horizontal, Aether.Spacing.screenMargin)
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(alignment: .top, spacing: Aether.Spacing.md) {
                    content()
                }
                .padding(.horizontal, Aether.Spacing.screenMargin)
            }
        }
    }
}

struct AetherShelfHeader<Destination: View>: View {
    let title: String
    @ViewBuilder let destination: () -> Destination

    var body: some View {
        NavigationLink {
            destination()
        } label: {
            HStack {
                Text(title).aetherSectionHeader()
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Aether.Color.textSecondary)
            }
        }
        .buttonStyle(.plain)
    }
}

struct AlbumShelfItem: View {
    let album: Album
    let repTrack: Track?
    let artistName: String
    let allTracks: [Track]

    var body: some View {
        NavigationLink {
            AlbumDetailScreen(album: album, allTracks: allTracks)
        } label: {
            VStack(alignment: .leading, spacing: 6) {
                AetherArtwork(track: repTrack)
                    .frame(width: Aether.Metrics.shelfItemArtwork, height: Aether.Metrics.shelfItemArtwork)
                Text(album.title)
                    .font(.subheadline)
                    .foregroundStyle(Aether.Color.textPrimary)
                    .lineLimit(1)
                Text(artistName.isEmpty ? " " : artistName)
                    .font(.caption)
                    .foregroundStyle(Aether.Color.textSecondary)
                    .lineLimit(1)
            }
            .frame(width: Aether.Metrics.shelfItemWidth, alignment: .leading)
        }
        .buttonStyle(.plain)
    }
}

struct ArtistShelfItem: View {
    let artist: Artist
    let repTrack: Track?
    let allTracks: [Track]

    var body: some View {
        NavigationLink {
            ArtistDetailScreen(artist: artist, allTracks: allTracks)
        } label: {
            VStack(spacing: 6) {
                AetherArtwork(track: repTrack, circular: true)
                    .frame(width: Aether.Metrics.shelfItemArtwork, height: Aether.Metrics.shelfItemArtwork)
                Text(artist.name)
                    .font(.subheadline)
                    .foregroundStyle(Aether.Color.textPrimary)
                    .lineLimit(1)
                    .multilineTextAlignment(.center)
            }
            .frame(width: Aether.Metrics.shelfItemWidth)
        }
        .buttonStyle(.plain)
    }
}

struct PlaylistShelfItem: View {
    let playlist: Playlist

    var body: some View {
        NavigationLink {
            PlaylistDetailScreen(playlist: playlist)
        } label: {
            VStack(alignment: .leading, spacing: 6) {
                ZStack {
                    if let path = playlist.customCoverImagePath, let image = UIImage(contentsOfFile: path) {
                        Image(uiImage: image).resizable().scaledToFill()
                    } else {
                        Aether.Color.surfaceElevated
                        Image(systemName: "music.note.list")
                            .font(.system(size: 28, weight: .light))
                            .foregroundStyle(Aether.Color.textTertiary)
                    }
                }
                .frame(width: Aether.Metrics.shelfItemArtwork, height: Aether.Metrics.shelfItemArtwork)
                .clipShape(RoundedRectangle(cornerRadius: Aether.Radius.artwork, style: .continuous))
                Text(playlist.title)
                    .font(.subheadline)
                    .foregroundStyle(Aether.Color.textPrimary)
                    .lineLimit(1)
                Text(Localized.playlist)
                    .font(.caption)
                    .foregroundStyle(Aether.Color.textSecondary)
                    .lineLimit(1)
            }
            .frame(width: Aether.Metrics.shelfItemWidth, alignment: .leading)
        }
        .buttonStyle(.plain)
    }
}

struct AetherCollectionRow: View {
    let icon: String
    let title: String
    let detail: String?

    var body: some View {
        HStack(spacing: Aether.Spacing.md) {
            Image(systemName: icon)
                .font(.system(size: 17))
                .foregroundStyle(Aether.Color.primary)
                .frame(width: 24)
            Text(title)
                .font(.body)
                .foregroundStyle(Aether.Color.textPrimary)
            Spacer()
            if let detail {
                Text(detail)
                    .font(.subheadline)
                    .foregroundStyle(Aether.Color.textTertiary)
            }
            Image(systemName: "chevron.right")
                .font(.caption.weight(.semibold))
                .foregroundStyle(Aether.Color.textTertiary)
        }
        .padding(.horizontal, Aether.Spacing.md)
        .padding(.vertical, Aether.Spacing.sm + 2)
        .contentShape(Rectangle())
    }
}

// MARK: - Artwork

/// Loads and displays a track's thumbnail via the existing ArtworkManager cache,
/// with a restrained placeholder. Reused across every shelf item.
struct AetherArtwork: View {
    let track: Track?
    var circular: Bool = false
    var maxPixelSize: CGFloat = 160
    @State private var image: UIImage?

    var body: some View {
        ZStack {
            if let image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
            } else {
                Aether.Color.surfaceElevated
                Image(systemName: "music.note")
                    .font(.system(size: 24, weight: .light))
                    .foregroundStyle(Aether.Color.textTertiary)
            }
        }
        .clipShape(circular
                   ? AnyShape(Circle())
                   : AnyShape(RoundedRectangle(cornerRadius: Aether.Radius.artwork, style: .continuous)))
        .task(id: track?.stableId) {
            guard let track else { image = nil; return }
            image = await ArtworkManager.shared.getThumbnail(for: track, maxPixelSize: maxPixelSize)
        }
    }
}
