# Aether — Option 3 “Shelves”
## Product / UX / Implementation Brief

**Purpose:** This document is the handoff spec for redesigning the existing Cosmos iOS music player into **Aether**, using the “Shelves” direction.

**Reference images**
- `00_Aether_Option3_Concept_Board.png` — overall visual direction
- `01_Aether_Home_Shelves.png` — primary Home / Library experience
- `02_Aether_Albums.png` — album browsing reference
- `03_Aether_Now_Playing.png` — Now Playing reference

---

# 1. Product idea

> **Aether should feel like a place where music lives, not a file browser for music.**

The current Cosmos library UI is useful but utilitarian: it exposes navigation categories as a vertical list of equally weighted cards. Aether should instead make the **music itself** the primary visual material.

Album art, recently played music, collections, and listening continuity should define the interface. Navigation remains easy, but it becomes secondary to browsing and listening.

The app should feel:

- personal
- calm
- tactile
- cinematic
- artwork-first
- lightweight
- native to iOS
- built around a local music library rather than around a streaming storefront

This is **not** a Spotify/Apple Music clone. There is no recommendation feed, merchandising layer, social feed, or content store. The user is opening *their own collection*.

---

# 2. Core UX principles

## 2.1 Music before navigation

Do not make the first screen a menu.

The first screen should immediately show recognizable music: current/last playback, recent albums, album art, playlists, and artists.

Navigation controls exist to support the collection, not to dominate it.

## 2.2 Artwork is the visual system

Use real album artwork wherever possible instead of decorative category icons.

The existing Cosmos design uses large icon tiles for Songs, Artists, Albums, etc. Aether should reduce that visual weight dramatically.

Artwork creates variation naturally and makes the library feel alive without requiring excessive visual effects.

## 2.3 Progressive disclosure

The Home screen is an overview, not a complete library listing.

A shelf displays enough items to create recognition and invite browsing. A section header / chevron opens the full category.

Example:

`Albums  >`

followed by 4–5 horizontally scrolling album covers.

## 2.4 Continuity matters

The first useful action after opening the app should often be **continue listening**.

If playback state exists, place a prominent Continue Listening card near the top.

If no playback history exists, omit the card cleanly rather than showing an empty placeholder.

## 2.5 Calm density

Aether should contain more useful information per screen than the current large-card layout while *feeling* less busy.

Achieve this through:

- small number of visual hierarchy levels
- generous section spacing
- restrained text
- consistent artwork sizing
- dark negative space
- subtle separators rather than boxed containers everywhere

## 2.6 Native behavior first

Prefer standard iOS interaction patterns and smooth SwiftUI behavior over custom visual gimmicks.

The aesthetic should come from composition, artwork, materials, typography, and motion—not complicated bespoke controls.

---

# 3. Home screen information architecture

The Home screen replaces the current “Library” list.

Recommended order:

1. **AETHER header**
2. **Continue Listening**
3. **Recently Added**
4. **Albums**
5. **Artists**
6. **Playlists**
7. Optional compact **Collections / Library** section
8. Persistent **Mini Player** when something is loaded

Do not render empty sections.

The screen should remain useful for a tiny library as well as a very large one.

---

# 4. Home screen specification

## 4.1 Header

Use a compact Aether wordmark instead of `Library`.

Preferred appearance:

`A E T H E R`

with slightly expanded letter spacing.

Right-side controls can include:

- Search
- Settings
- Refresh / rescan only if it is genuinely needed often enough to deserve top-level placement

Avoid a large app icon next to the title.

The title is branding, not a navigation label.

### Behavior

The header may begin visually spacious at the top and become slightly more compact while scrolling.

Do not make it excessively animated.

---

## 4.2 Continue Listening

This is the visual anchor.

Recommended content:

- album artwork
- song title
- artist
- album
- play/pause button
- subtle progress indicator

The card should use artwork-derived atmosphere if practical, but avoid expensive real-time blur effects if they hurt scrolling performance.

### Suggested geometry

- horizontal card
- artwork approximately square
- artwork occupying ~35–40% of card width
- rounded corners
- dark translucent surface
- play/pause control aligned toward the trailing edge

### Empty state

If the user has never played anything, do not show the module.

---

## 4.3 Recently Added shelf

A horizontally scrolling shelf.

Each item:

- square artwork
- title
- secondary artist text

The shelf should expose roughly 3.5–4.5 items at once so that the clipped trailing item communicates horizontal scrolling.

Tapping an item opens the album.

Tapping the section title / chevron opens the complete recently-added view.

---

## 4.4 Albums shelf

Same basic shelf interaction as Recently Added.

Use consistent cover dimensions unless there is a strong reason otherwise.

Prefer showing title + artist below the cover rather than placing text over artwork.

---

## 4.5 Artists shelf

Artist presentation may use circular artwork/avatars if usable artist imagery already exists.

If Cosmos has no artist images, do **not** invent network-dependent artist imagery.

Fallback options in order:

1. album artwork mosaic associated with the artist
2. dominant album cover
3. tasteful generated local placeholder using initials / typography

The app should remain fully useful offline.

---

## 4.6 Playlists shelf

Use square cards.

If playlist artwork exists, show it.

If it does not, create a local collage from representative album artwork when feasible.

Do not use giant generic playlist icons unless no artwork can be derived.

---

## 4.7 Collections / utility library access

The current functionality still needs to be reachable:

- All Songs
- Favorites / Liked
- Files / Import
- possibly Lossless / Hi-Res filters if supported or added later

These are useful but should not carry the same visual weight as Albums / Artists / Playlists.

A compact section near the bottom can expose them as rows or small chips/cards.

Example:

```
Collection
♡ Favorites        >
♫ All Songs        >
folder Files       >
```

If `Open Files` is an important import action rather than a browsing destination, consider placing import inside an overflow menu or Files screen instead of permanently treating it as a top-level content category.

Preserve the underlying feature either way.

---

# 5. Persistent mini player

Once a playable item exists, display a compact player at the bottom of the browsing interface.

Contents:

- artwork thumbnail
- track title
- artist
- play / pause
- optional next-track control

Tap anywhere on the primary body to open Now Playing.

The mini player should sit above the safe area and should not obscure the last shelf.

Use appropriate bottom content inset.

The mini player should persist across primary library destinations.

---

# 6. Album browsing

The full Albums screen should be artwork-dense.

Recommended default:

- two-column adaptive grid on iPhone
- cover
- album title
- artist
- search
- sort/filter

Do not put every album inside a large card.

Artwork itself is the card.

### Sort options

Preserve existing Cosmos behavior where applicable.

Potential options:

- Album title
- Artist
- Recently added
- Year

Do not add metadata-driven features unless the library parser already supports the required metadata reliably.

---

# 7. Artist browsing

Prefer a visually recognizable grid/list hybrid.

Possible iPhone presentation:

- 2–3 column artist tiles
- circular or softly rounded artwork
- artist name below

If artist artwork is not available, use album-derived local imagery.

Full artist screen should prioritize:

1. artist
2. albums
3. songs

Avoid unnecessary biography / internet metadata dependencies.

---

# 8. Playlist browsing

Playlist view should visually resemble a collection of records rather than a settings list.

Show artwork/collage, title, track count where useful.

Playlist detail should retain familiar song list behavior.

---

# 9. Now Playing

Now Playing should be the most immersive screen in Aether.

Hierarchy:

1. minimal navigation controls
2. large album artwork
3. song title
4. artist
5. album
6. favorite
7. progress / time
8. optional audio quality metadata
9. playback controls
10. secondary controls such as queue / output / repeat / shuffle

Keep the artwork large.

Do not surround the artwork in several nested cards.

### Background

Use a deep near-black base.

Optionally derive a *very subtle* background glow from album artwork.

The background should never become brighter than the artwork or compromise text legibility.

---

# 10. Visual language

## 10.1 General

Aether is dark by default.

Reference mood:

- deep navy / near-black
- muted violet
- occasional blue/pink light
- soft glow
- glass only where it communicates layering
- no “RGB gamer” rainbow treatment

The generated concept art exaggerates the cosmic atmosphere slightly. The implementation should be **more restrained**.

Think “dark room with a little reflected color,” not “space-themed skin.”

---

# 11. Color tokens

Treat these as starting points, not immutable hex requirements.

```swift
AetherBackground      // near black with very slight cool/navy bias
AetherSurface         // lifted dark surface
AetherSurfaceElevated // mini-player / cards
AetherPrimary         // restrained lavender / violet
AetherTextPrimary     // near-white
AetherTextSecondary   // cool gray
AetherTextTertiary    // dim gray
```

Recommended visual relationship:

- background ≈ `#080B10`
- surface ≈ `#12121A`
- elevated surface ≈ `#181825`
- primary violet ≈ `#A386FF`
- text primary ≈ `#ECECF2`
- text secondary ≈ `#A1A1B3`

Avoid hardcoding colors throughout views. Define semantic tokens once.

Support accessibility contrast.

---

# 12. Typography

Use Apple system typography / SF Pro.

Do not bundle a custom font merely to create branding.

Suggested hierarchy:

- AETHER wordmark: medium/light system font + tracking
- large screen title: `.largeTitle` or close equivalent
- section header: `.headline`
- album title: `.subheadline` / medium
- secondary metadata: `.caption` / secondary color

The visual identity should come partly from spacing and tracking rather than from a novelty typeface.

---

# 13. Shape language

Use rounded corners consistently.

Suggested starting points:

- large feature card: 16–20 pt
- mini player: 14–18 pt
- artwork: 8–12 pt
- small buttons: circular or capsule where appropriate

Do not wrap every shelf item in another rounded rectangle.

Artwork should often sit directly on the background.

---

# 14. Icons

Use SF Symbols wherever possible.

Preferred style:

- thin / regular weight
- monochrome
- tint only for emphasis
- no separate rainbow color per library category

The old category colors should not be carried forward as a primary organizing device.

---

# 15. Motion

Motion should communicate continuity.

Useful transitions:

- album cover → album detail
- mini player → full Now Playing
- subtle shelf item press scale
- play/pause state transition
- gentle header collapse while scrolling

Avoid:

- looping decorative animations
- moving starfields
- aggressive glow pulses
- animation that delays interaction

Honor **Reduce Motion**.

---

# 16. Haptics

Use sparingly.

Reasonable places:

- favorite toggle
- play/pause
- successful import completion
- reorder/drop completion if applicable

Do not add haptics to every navigation tap.

---

# 17. Accessibility

Required:

- Dynamic Type should not make core actions unusable
- VoiceOver labels for all icon-only controls
- minimum practical 44x44 touch targets
- sufficient text contrast
- Reduce Motion support
- do not convey library state by color alone

Album artwork can be decorative to VoiceOver when adjacent text already identifies the album.

---

# 18. Performance constraints

This is a local-library player. Large libraries are expected.

The Home screen must remain fluid with hundreds or thousands of albums/songs.

Important:

- lazy stacks / lazy grids
- thumbnail-size image decoding/caching where possible
- avoid repeatedly decoding full-resolution cover art
- avoid expensive blur chains in scrolling cells
- stable IDs
- avoid recomputing library grouping in `body`
- build view-model / derived state outside rendering loops
- preserve offline operation

If the existing project already has an artwork cache, reuse it before inventing another one.

---

# 19. Architecture guidance for the coding agent

**First inspect the repository. Do not begin by replacing the app architecture.**

Determine:

- SwiftUI vs UIKit boundaries
- current library model
- playback state / audio engine ownership
- current navigation structure
- artwork loading/cache
- persistence
- file importer
- favorites model
- playlist implementation
- search
- refresh / scan behavior

Then map Aether onto the current architecture with the smallest clean structural change.

Prefer **presentation refactoring over playback refactoring**.

Playback already works; the first goal is to change how the library is experienced without destabilizing audio behavior.

---

# 20. Suggested SwiftUI component decomposition

Names are illustrative and should be adapted to the existing project conventions.

```text
AetherHomeView
├── AetherHeader
├── ContinueListeningCard
├── ShelfSection<Content>
│   ├── ShelfHeader
│   └── horizontal LazyHStack
├── AlbumShelfItem
├── ArtistShelfItem
├── PlaylistShelfItem
├── CollectionLinks
└── MiniPlayer

AlbumsView
├── LibraryScreenHeader
└── AlbumGrid

NowPlayingView
├── NowPlayingArtwork
├── TrackMetadata
├── PlaybackProgress
├── PrimaryPlaybackControls
└── SecondaryPlaybackControls
```

Avoid creating a bespoke abstract framework just for the redesign.

Extract components when repetition or state boundaries justify them.

---

# 21. Data required by Home

The Home presentation layer needs derived values approximately equivalent to:

```text
currentPlayback
recentlyAddedAlbums
albumsPreview
artistsPreview
playlistsPreview
favoritesCount / destination
```

Do not create duplicate authoritative music-library state.

These should be projections of the existing library/player state.

---

# 22. Navigation

The Home screen becomes the default library landing screen.

Section behavior:

- Continue Listening → Now Playing / resume
- Recently Added item → Album Detail
- Recently Added header → Recently Added list
- Albums item → Album Detail
- Albums header → Albums
- Artists item → Artist Detail
- Artists header → Artists
- Playlists item → Playlist Detail
- Playlists header → Playlists
- Mini Player → Now Playing
- Search → global library search
- Settings → existing settings

Maintain predictable iOS back navigation.

---

# 23. Empty states

Aether should degrade elegantly.

## Empty library

Do not show six empty shelves.

Instead show a single focused invitation:

**Your music lives here**

Import audio files to begin building your Aether library.

`[ Import Music ]`

Optionally show one short note about supported sources/formats if known.

## Partially populated library

Only render sections that have content.

If albums exist but playlists do not, simply omit Playlists.

---

# 24. Naming / copy changes

Rename visible Cosmos branding to **Aether**.

Prefer concise copy.

Examples:

- `Library` landing title → `AETHER`
- `Liked Songs` → `Favorites` unless changing terminology would break user expectations
- `Open Files` → `Import Music` when used as an action
- `All Songs` → `Songs`

Do not rename internal model types purely for branding unless there is a strong maintenance reason.

---

# 25. What NOT to do

Do not:

- rebuild the audio engine for this redesign
- introduce a streaming service dependency
- fetch artist art from the network by default
- create a recommendation engine
- add fake “AI” features
- turn the screen into a dashboard of metrics
- make every container translucent glass
- use a different accent color for every category
- add decorative stars everywhere
- sacrifice scrolling performance for live blur
- hide basic library navigation behind clever gestures
- remove existing functionality simply because it is visually secondary

---

# 26. Implementation stages

## Stage 0 — Repository reconnaissance

Before edits, identify the relevant files and produce a short mapping:

```text
Current Home / Library:
Navigation:
Player state:
Artwork:
Library model:
Search:
Import:
Favorites:
Playlists:
```

Call out uncertainty before changing architectural behavior.

## Stage 1 — Aether visual tokens

Add semantic color/spacing/corner tokens.

Do not spread magic values through feature views.

## Stage 2 — New Home shell

Create Aether Home with:

- branded header
- scroll structure
- shelf component
- existing data wired in

No risky player changes.

## Stage 3 — Continue Listening + mini player

Wire existing playback state.

Keep current playback semantics.

## Stage 4 — Shelves

Add:

- Recently Added
- Albums
- Artists
- Playlists

Use existing models.

## Stage 5 — Category screens

Restyle Albums / Artists / Playlists incrementally.

Preserve behavior.

## Stage 6 — Now Playing

Apply the immersive Aether treatment to the existing player UI.

## Stage 7 — polish

Accessibility, empty states, animation, haptics, performance.

---

# 27. Acceptance criteria

The redesign is successful when:

- Opening Aether shows the user's **music**, not a menu of categories.
- Album art is the dominant visual material.
- Resume/continue playback is available immediately when applicable.
- Albums, artists, playlists, songs, favorites, search, import, and settings remain reachable.
- Home has no large stack of six equal utility cards.
- A small library does not produce awkward empty shelves.
- A large library scrolls smoothly.
- The interface works offline.
- Playback behavior is not regressed.
- VoiceOver and Dynamic Type remain usable.
- The visual treatment is restrained enough to feel native rather than themed.
- The generated images are treated as **directional references**, not pixel-perfect requirements.

---

# 28. First implementation target

The first PR / coding pass should focus on **Home only**.

Deliver:

1. new Aether home screen
2. Aether header
3. Continue Listening
4. Recently Added shelf
5. Albums shelf
6. Artists shelf
7. Playlists shelf
8. compact utility collection links
9. mini player using existing playback state
10. existing destinations wired to the new UI

Do **not** redesign every downstream screen in the same pass.

Once the Home experience feels right, use it to establish the design system for the rest of the application.

---

# 29. Instruction block for Codex / Claude

Use the following as the execution prompt together with this document and the reference images:

> Redesign the existing Cosmos iOS application into the Aether “Shelves” experience described in `AETHER_OPTION3_SHELVES.md`. Begin by inspecting the repository and mapping the existing library, navigation, playback, artwork, search, import, favorites, and playlist architecture. Preserve working playback and library behavior. Implement the redesign incrementally, starting with the Home screen only. Treat the supplied mockups as visual direction rather than pixel-perfect specifications. Prefer native SwiftUI/iOS behavior, semantic reusable design tokens, existing models/services, smooth large-library performance, offline operation, and accessibility. Do not introduce unnecessary architecture or network dependencies. Before making broad changes, state which existing files/components you intend to modify and why. After implementation, summarize changed files, behavior preserved, any assumptions, and remaining follow-up work.

---

# 30. Design north star

If there is ambiguity during implementation, use this test:

> **Does this make Aether feel more like opening my record collection, or more like opening a settings/file browser?**

Choose the former while preserving clarity and speed.
