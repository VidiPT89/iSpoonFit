#!/usr/bin/env swift

// Renders the 1024×1024 app icon: a spoon mark in the ividi.dev orange
// gradient on the app's near-black background. Run from the repo root:
//
//     swift scripts/make-app-icon.swift
//
// The output overwrites SpoonFit/Assets.xcassets/AppIcon.appiconset/icon-1024.png.

import AppKit
import CoreGraphics
import Foundation

let side = 1024
let colorSpace = CGColorSpaceCreateDeviceRGB()

guard let context = CGContext(
    data: nil,
    width: side,
    height: side,
    bitsPerComponent: 8,
    bytesPerRow: 0,
    space: colorSpace,
    bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
) else {
    fatalError("Could not create the drawing context")
}

func color(_ hex: UInt32) -> CGColor {
    CGColor(
        srgbRed: CGFloat((hex >> 16) & 0xff) / 255,
        green: CGFloat((hex >> 8) & 0xff) / 255,
        blue: CGFloat(hex & 0xff) / 255,
        alpha: 1
    )
}

let background = color(0x0A0A0F)
let accentLight = color(0xFCBB00)
let accent = color(0xF99C00)
let accentDark = color(0xDD7400)

// Background
context.setFillColor(background)
context.fill(CGRect(x: 0, y: 0, width: side, height: side))

// Warm halo behind the mark
if let halo = CGGradient(
    colorsSpace: colorSpace,
    colors: [color(0xF99C00).copy(alpha: 0.22)!, color(0xF99C00).copy(alpha: 0)!] as CFArray,
    locations: [0, 1]
) {
    context.drawRadialGradient(
        halo,
        startCenter: CGPoint(x: 512, y: 512), startRadius: 0,
        endCenter: CGPoint(x: 512, y: 512), endRadius: 470,
        options: []
    )
}

// The spoon: a solid oval bowl above a slim handle that tapers to a rounded
// tip. Drawn as one filled silhouette so it stays legible at 40 points.
// The rotation pushes the bowl to the right, so the mark is nudged back to
// keep its visual mass centred in the tile.
let tilt = CGAffineTransform(translationX: 512 - 30, y: 512)
    .rotated(by: -14 * .pi / 180)
    .translatedBy(x: -512, y: -512)

let mark = CGMutablePath()
mark.addEllipse(in: CGRect(x: 512 - 152, y: 472, width: 304, height: 396), transform: tilt)

let handle = CGMutablePath()
let tipY: CGFloat = 176
let tipRadius: CGFloat = 40
handle.move(to: CGPoint(x: 512 - 62, y: 640))
handle.addCurve(
    to: CGPoint(x: 512 - tipRadius, y: tipY),
    control1: CGPoint(x: 512 - 70, y: 470),
    control2: CGPoint(x: 512 - 46, y: 300)
)
handle.addArc(
    center: CGPoint(x: 512, y: tipY),
    radius: tipRadius,
    startAngle: .pi,
    endAngle: 2 * .pi,
    clockwise: false
)
handle.addCurve(
    to: CGPoint(x: 512 + 62, y: 640),
    control1: CGPoint(x: 512 + 46, y: 300),
    control2: CGPoint(x: 512 + 70, y: 470)
)
handle.closeSubpath()
mark.addPath(handle, transform: tilt)

// Clip to the mark and paint the brand gradient through it.
context.saveGState()
context.addPath(mark)
context.clip()

if let gradient = CGGradient(
    colorsSpace: colorSpace,
    colors: [accentLight, accent, accentDark] as CFArray,
    locations: [0, 0.55, 1]
) {
    context.drawLinearGradient(
        gradient,
        start: CGPoint(x: 220, y: 900),
        end: CGPoint(x: 820, y: 130),
        options: []
    )
}
context.restoreGState()

// A soft highlight inside the bowl gives the silhouette some depth.
context.saveGState()
context.addPath(mark)
context.clip()
context.setFillColor(color(0xFFFFFF).copy(alpha: 0.18)!)
context.fillEllipse(in: CGRect(x: 512 - 96, y: 660, width: 150, height: 168).applying(tilt))
context.restoreGState()

guard let image = context.makeImage() else { fatalError("Could not render the icon") }

let outputURL = URL(fileURLWithPath: "SpoonFit/Assets.xcassets/AppIcon.appiconset/icon-1024.png")
let bitmap = NSBitmapImageRep(cgImage: image)
guard let data = bitmap.representation(using: .png, properties: [:]) else {
    fatalError("Could not encode the PNG")
}
try data.write(to: outputURL)
print("Wrote \(outputURL.path)")
