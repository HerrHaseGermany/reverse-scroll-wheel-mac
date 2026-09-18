import Cocoa
import CoreGraphics

var eventTap: CFMachPort?

func eventTapCallback(
    proxy: CGEventTapProxy,
    type: CGEventType,
    event: CGEvent,
    refcon: UnsafeMutableRawPointer?
) -> Unmanaged<CGEvent>? {

    // macOS kann einen Event Tap temporär deaktivieren.
    // In diesem Fall aktivieren wir ihn wieder.
    if type == .tapDisabledByTimeout ||
       type == .tapDisabledByUserInput {

        if let tap = eventTap {
            CGEvent.tapEnable(tap: tap, enable: true)
        }

        return Unmanaged.passUnretained(event)
    }

    guard type == .scrollWheel else {
        return Unmanaged.passUnretained(event)
    }

    // 0 = line-based scrolling (typisches Mausrad)
    // 1 = continuous scrolling (typisches Trackpad)
    let continuous = event.getIntegerValueField(
        .scrollWheelEventIsContinuous
    )

    guard continuous == 0 else {
        return Unmanaged.passUnretained(event)
    }

    let vertical = event.getIntegerValueField(
        .scrollWheelEventDeltaAxis1
    )

    let horizontal = event.getIntegerValueField(
        .scrollWheelEventDeltaAxis2
    )

    event.setIntegerValueField(
        .scrollWheelEventDeltaAxis1,
        value: -vertical
    )

    event.setIntegerValueField(
        .scrollWheelEventDeltaAxis2,
        value: -horizontal
    )

    return Unmanaged.passUnretained(event)
}

let eventMask = CGEventMask(
    1 << CGEventType.scrollWheel.rawValue
)

eventTap = CGEvent.tapCreate(
    tap: .cgSessionEventTap,
    place: .headInsertEventTap,
    options: .defaultTap,
    eventsOfInterest: eventMask,
    callback: eventTapCallback,
    userInfo: nil
)

guard let tap = eventTap else {
    fputs(
        "Reverse Scroll Wheel: Event Tap konnte nicht erstellt werden.\n",
        stderr
    )

    exit(1)
}

guard let runLoopSource = CFMachPortCreateRunLoopSource(
    kCFAllocatorDefault,
    tap,
    0
) else {
    fputs(
        "Reverse Scroll Wheel: RunLoop Source konnte nicht erstellt werden.\n",
        stderr
    )

    exit(1)
}

CFRunLoopAddSource(
    CFRunLoopGetCurrent(),
    runLoopSource,
    .commonModes
)

CGEvent.tapEnable(
    tap: tap,
    enable: true
)

CFRunLoopRun()