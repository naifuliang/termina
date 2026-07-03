// Generates the Termina app icon: a dark rounded square with a shell
// prompt glyph, echoing the Windows Terminal icon but in macOS style.
// Usage: swift gen_icon.swift <output.iconset>
import AppKit

let args = CommandLine.arguments
guard args.count == 2 else {
    fputs("usage: gen_icon.swift <output.iconset>\n", stderr)
    exit(1)
}
let outDir = URL(fileURLWithPath: args[1])
try? FileManager.default.createDirectory(at: outDir, withIntermediateDirectories: true)

func draw(size: CGFloat) -> NSBitmapImageRep {
    let rep = NSBitmapImageRep(
        bitmapDataPlanes: nil, pixelsWide: Int(size), pixelsHigh: Int(size),
        bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true, isPlanar: false,
        colorSpaceName: .deviceRGB, bytesPerRow: 0, bitsPerPixel: 0)!
    NSGraphicsContext.saveGraphicsState()
    NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: rep)

    let s = size
    // macOS icon grid: content inset ~10%
    let inset = s * 0.10
    let box = NSRect(x: inset, y: inset, width: s - inset * 2, height: s - inset * 2)
    let radius = box.width * 0.225
    let squircle = NSBezierPath(roundedRect: box, xRadius: radius, yRadius: radius)

    // background: near-black vertical gradient
    let gradient = NSGradient(
        starting: NSColor(srgbRed: 0.16, green: 0.17, blue: 0.20, alpha: 1),
        ending: NSColor(srgbRed: 0.045, green: 0.047, blue: 0.055, alpha: 1))!
    gradient.draw(in: squircle, angle: -90)

    // subtle top edge highlight
    squircle.lineWidth = max(1, s * 0.008)
    NSColor(white: 1, alpha: 0.08).setStroke()
    squircle.stroke()

    // prompt glyph "❯" + cursor bar, like a shell waiting for input
    let glyphSize = box.width * 0.42
    let font = NSFont(name: "Menlo-Bold", size: glyphSize) ?? .boldSystemFont(ofSize: glyphSize)
    let prompt = NSAttributedString(string: "❯", attributes: [
        .font: font,
        .foregroundColor: NSColor(srgbRed: 0.38, green: 0.84, blue: 0.84, alpha: 1),
    ])
    let pSize = prompt.size()
    let baseX = box.minX + box.width * 0.16
    let baseY = box.midY - pSize.height / 2
    prompt.draw(at: NSPoint(x: baseX, y: baseY))

    let bar = NSRect(
        x: baseX + pSize.width + box.width * 0.10,
        y: box.midY - glyphSize * 0.32,
        width: box.width * 0.30,
        height: max(1.5, s * 0.028))
    NSColor(white: 0.95, alpha: 0.92).setFill()
    NSBezierPath(roundedRect: bar, xRadius: bar.height / 2, yRadius: bar.height / 2).fill()

    NSGraphicsContext.restoreGraphicsState()
    return rep
}

let sizes: [(Int, String)] = [
    (16, "icon_16x16"), (32, "icon_16x16@2x"),
    (32, "icon_32x32"), (64, "icon_32x32@2x"),
    (128, "icon_128x128"), (256, "icon_128x128@2x"),
    (256, "icon_256x256"), (512, "icon_256x256@2x"),
    (512, "icon_512x512"), (1024, "icon_512x512@2x"),
]
for (px, name) in sizes {
    let rep = draw(size: CGFloat(px))
    let data = rep.representation(using: .png, properties: [:])!
    try! data.write(to: outDir.appendingPathComponent("\(name).png"))
}
print("iconset written to \(outDir.path)")
