# Never Sleep

A tiny SwiftUI menu bar app for macOS 13 or later. Click the coffee cup in the menu bar and turn **Keep Mac awake** on or off. A filled cup means it's on; an outlined cup means it's off. The app starts off each time you launch it.

While enabled, it moves the pointer one pixel every 10 seconds, alternating direction, and holds a macOS power assertion to prevent idle display and system sleep. Mouse movement is skipped while a mouse button is held, to avoid interfering with dragging. Turning it off or quitting releases sleep prevention. Closing the lid or choosing Sleep can still put your Mac to sleep.

## Build and open

Requires Apple's Command Line Tools (`xcode-select --install`) or Xcode.

```sh
./build.sh
open "dist/Never Sleep.app"
```

You can drag the built app to Applications. It has no Dock icon; use the menu bar's **Quit Never Sleep** command to exit. The bundle is locally ad-hoc signed, for use on your own Mac.

To edit in Xcode, open `Package.swift`. Run the build script to produce the menu-bar-only app bundle with its Info.plist.

Uses Apple's [MenuBarExtra](https://developer.apple.com/documentation/swiftui/menubarextra), [CGWarpMouseCursorPosition](https://developer.apple.com/documentation/coregraphics/1456387-cgwarpmousecursorposition), and [idle display sleep assertion](https://developer.apple.com/documentation/iokit/kiopmassertiontypepreventuseridledisplaysleep).
