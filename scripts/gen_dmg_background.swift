// Draws the DMG window background: dark gradient, a guide arrow from
// the app icon position to the Applications folder position, and an
// install hint. Emits 1x and 2x PNGs for a Retina-capable TIFF.
// Usage: swift gen_dmg_background.swift <output-dir>
import AppKit

let args = CommandLine.arguments
guard args.count == 2 else {
    fputs("usage: gen_dmg_background.swift <output-dir>\n", stderr)
    exit(1)
}
let outDir = URL(fileURLWithPath: args[1])
try? FileManager.default.createDirectory(at: outDir, withIntermediateDirectories: true)

// Logical canvas, must match the dmgbuild window content size.
let W: CGFloat = 660
let H: CGFloat = 400

func draw(scale: CGFloat) -> Data {
    let rep = NSBitmapImageRep(
        bitmapDataPlanes: nil, pixelsWide: Int(W * scale), pixelsHigh: Int(H * scale),
        bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true, isPlanar: false,
        colorSpaceName: .deviceRGB, bytesPerRow: 0, bitsPerPixel: 0)!
    NSGraphicsContext.saveGraphicsState()
    let ctx = NSGraphicsContext(bitmapImageRep: rep)!
    NSGraphicsContext.current = ctx
    ctx.cgContext.scaleBy(x: scale, y: scale)

    // AppKit's origin is bottom-left; design in top-left coordinates.
    func fromTop(_ y: CGFloat) -> CGFloat { H - y }

    // Background gradient — near-black, matching the app's Campbell pane.
    let gradient = NSGradient(
        starting: NSColor(srgbRed: 0.106, green: 0.110, blue: 0.125, alpha: 1),
        ending: NSColor(srgbRed: 0.047, green: 0.047, blue: 0.055, alpha: 1))!
    gradient.draw(in: NSRect(x: 0, y: 0, width: W, height: H), angle: -90)

    // Faint oversized prompt glyph as a texture accent, bottom-right.
    let watermarkFont = NSFont(name: "Menlo-Bold", size: 240) ?? .boldSystemFont(ofSize: 240)
    NSAttributedString(string: "❯", attributes: [
        .font: watermarkFont,
        .foregroundColor: NSColor(white: 1, alpha: 0.030),
    ]).draw(at: NSPoint(x: W - 180, y: -40))

    // Wordmark, top-center.
    let title = NSMutableAttributedString()
    title.append(NSAttributedString(string: "❯ ", attributes: [
        .font: NSFont(name: "Menlo-Bold", size: 22) ?? .boldSystemFont(ofSize: 22),
        .foregroundColor: NSColor(srgbRed: 0.38, green: 0.84, blue: 0.84, alpha: 1),
    ]))
    title.append(NSAttributedString(string: "Termina", attributes: [
        .font: NSFont.systemFont(ofSize: 24, weight: .semibold),
        .foregroundColor: NSColor(white: 1, alpha: 0.92),
    ]))
    let tSize = title.size()
    title.draw(at: NSPoint(x: (W - tSize.width) / 2, y: fromTop(64)))

    // Guide arrow between the two icon slots (icon centers y=190 from top).
    let arrowY = fromTop(190)
    let startX: CGFloat = 165 + 84   // right edge of the app icon slot
    let endX: CGFloat = 495 - 84     // left edge of the Applications slot
    let arrow = NSBezierPath()
    arrow.lineWidth = 3
    arrow.lineCapStyle = .round
    arrow.move(to: NSPoint(x: startX, y: arrowY))
    arrow.line(to: NSPoint(x: endX - 14, y: arrowY))
    NSColor(white: 1, alpha: 0.28).setStroke()
    arrow.stroke()

    let head = NSBezierPath()
    head.move(to: NSPoint(x: endX - 26, y: arrowY + 11))
    head.line(to: NSPoint(x: endX - 12, y: arrowY))
    head.line(to: NSPoint(x: endX - 26, y: arrowY - 11))
    head.lineWidth = 3
    head.lineCapStyle = .round
    head.lineJoinStyle = .round
    head.stroke()

    // Install hint, bottom-center.
    let hint = NSAttributedString(
        string: "Drag Termina into the Applications folder to install",
        attributes: [
            .font: NSFont.systemFont(ofSize: 13, weight: .regular),
            .foregroundColor: NSColor(white: 1, alpha: 0.45),
        ])
    let hSize = hint.size()
    hint.draw(at: NSPoint(x: (W - hSize.width) / 2, y: fromTop(345)))

    NSGraphicsContext.restoreGraphicsState()
    rep.size = NSSize(width: W, height: H)
    return rep.representation(using: .png, properties: [:])!
}

try! draw(scale: 1).write(to: outDir.appendingPathComponent("dmg-background.png"))
try! draw(scale: 2).write(to: outDir.appendingPathComponent("dmg-background@2x.png"))
print("backgrounds written to \(outDir.path)")
