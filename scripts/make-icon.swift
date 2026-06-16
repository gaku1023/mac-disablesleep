// Generates Resources/AppIcon.icns — a crescent moon on a purple gradient
// squircle. Run via `swift scripts/make-icon.swift` from the repo root
// (build.sh does this automatically when AppIcon.icns is missing).
import AppKit
import CoreGraphics
import Foundation

let size = 1024
let S = CGFloat(size)
let colorSpace = CGColorSpaceCreateDeviceRGB()

func makeContext() -> CGContext {
    CGContext(
        data: nil, width: size, height: size, bitsPerComponent: 8,
        bytesPerRow: 0, space: colorSpace,
        bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
    )!
}

let ctx = makeContext()
ctx.clear(CGRect(x: 0, y: 0, width: S, height: S))

// Rounded-rect (squircle-ish) background, clipped.
let margin = S * 0.08
let rect = CGRect(x: margin, y: margin, width: S - 2 * margin, height: S - 2 * margin)
let radius = rect.width * 0.225
ctx.addPath(CGPath(roundedRect: rect, cornerWidth: radius, cornerHeight: radius, transform: nil))
ctx.clip()

let gradient = CGGradient(
    colorsSpace: colorSpace,
    colors: [
        CGColor(red: 0.24, green: 0.18, blue: 0.56, alpha: 1),
        CGColor(red: 0.45, green: 0.30, blue: 0.74, alpha: 1),
    ] as CFArray,
    locations: [0, 1]
)!
ctx.drawLinearGradient(gradient, start: CGPoint(x: 0, y: S), end: CGPoint(x: 0, y: 0), options: [])

// Crescent moon: drawn on its own layer so carving reveals the gradient.
let moon = makeContext()
moon.clear(CGRect(x: 0, y: 0, width: S, height: S))
let moonColor = CGColor(red: 1.0, green: 0.91, blue: 0.66, alpha: 1.0)
let cx = S * 0.50, cy = S * 0.50, r = S * 0.27
moon.setFillColor(moonColor)
moon.fillEllipse(in: CGRect(x: cx - r, y: cy - r, width: 2 * r, height: 2 * r))
moon.setBlendMode(.clear)
let off = r * 0.62
moon.fillEllipse(in: CGRect(x: cx - r + off, y: cy - r + off * 0.65, width: 2 * r, height: 2 * r))
ctx.draw(moon.makeImage()!, in: CGRect(x: 0, y: 0, width: S, height: S))

// A few stars.
ctx.setFillColor(CGColor(red: 1, green: 1, blue: 1, alpha: 0.95))
for (sx, sy, sr) in [(0.72, 0.72, 0.018), (0.78, 0.45, 0.012), (0.66, 0.60, 0.010)] {
    let rr = S * CGFloat(sr)
    ctx.fillEllipse(in: CGRect(x: S * CGFloat(sx) - rr, y: S * CGFloat(sy) - rr, width: 2 * rr, height: 2 * rr))
}

let master = ctx.makeImage()!
let data = NSBitmapImageRep(cgImage: master).representation(using: .png, properties: [:])!
try! data.write(to: URL(fileURLWithPath: "icon_master.png"))
print("wrote icon_master.png")
