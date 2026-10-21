import AppKit
import SwiftUI
import IOKit.pwr_mgt

@main
struct NeverSleepApp: App {
    @StateObject private var controller = AwakeController()

    var body: some Scene {
        MenuBarExtra {
            Text("Never Sleep")
            Toggle("Keep Mac awake", isOn: Binding(
                get: { controller.isEnabled },
                set: { controller.setEnabled($0) }
            ))
            Divider()
            Text(controller.isEnabled ? "Mouse moves every 10 seconds" : "Sleep prevention is off")
            if let error = controller.error {
                Text(error)
            }
            Divider()
            Button("Quit Never Sleep") {
                controller.setEnabled(false)
                NSApplication.shared.terminate(nil)
            }
            .keyboardShortcut("q")
        } label: {
            Label("Never Sleep: \(controller.isEnabled ? "On" : "Off")",
                  systemImage: controller.isEnabled ? "cup.and.saucer.fill" : "cup.and.saucer")
        }
        .menuBarExtraStyle(.menu)
    }
}

@MainActor
final class AwakeController: ObservableObject {
    @Published private(set) var isEnabled = false
    @Published private(set) var error: String?
    private var assertion: IOPMAssertionID?
    private var timer: Timer?
    private var activity: NSObjectProtocol?
    private var direction: CGFloat = 1

    func setEnabled(_ enabled: Bool) {
        guard enabled != isEnabled else { return }
        error = nil
        if enabled {
            var identifier = IOPMAssertionID(0)
            let result = IOPMAssertionCreateWithName(
                kIOPMAssertionTypePreventUserIdleDisplaySleep as CFString,
                IOPMAssertionLevel(kIOPMAssertionLevelOn),
                "Never Sleep is enabled" as CFString,
                &identifier
            )
            guard result == kIOReturnSuccess else {
                error = "Could not prevent sleep. Try turning it on again."
                return
            }
            assertion = identifier
            activity = ProcessInfo.processInfo.beginActivity(
                options: [.userInitiated, .idleSystemSleepDisabled],
                reason: "Move the pointer every 10 seconds while enabled"
            )
            isEnabled = true
            let tick = Timer(timeInterval: 10, repeats: true) { [weak self] _ in
                MainActor.assumeIsolated { self?.movePointer() }
            }
            RunLoop.main.add(tick, forMode: .common)
            timer = tick
        } else {
            timer?.invalidate()
            timer = nil
            if let assertion { IOPMAssertionRelease(assertion) }
            assertion = nil
            if let activity { ProcessInfo.processInfo.endActivity(activity) }
            activity = nil
            isEnabled = false
        }
    }

    private func movePointer() {
        guard isEnabled else { return }
        // Avoid nudging while the user is dragging or holding a mouse button.
        guard NSEvent.pressedMouseButtons == 0 else { return }
        guard let point = CGEvent(source: nil)?.location else { return }
        var display = CGDirectDisplayID(0)
        var count: UInt32 = 0
        guard CGGetDisplaysWithPoint(point, 1, &display, &count) == .success,
              count > 0 else { return }
        let bounds = CGDisplayBounds(display)
        var next = CGPoint(x: point.x + direction, y: point.y)
        if next.x < bounds.minX || next.x >= bounds.maxX {
            direction *= -1
            next.x = point.x + direction
        }
        let result = CGWarpMouseCursorPosition(next)
        direction *= -1
        error = result == .success ? nil : "Mouse could not move. Sleep prevention is still on."
    }
}
