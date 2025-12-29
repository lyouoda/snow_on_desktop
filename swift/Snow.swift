import Cocoa
import QuartzCore

class SnowWindow: NSWindow {
    init(screen: NSScreen) {
        let frame = screen.frame
        super.init(contentRect: frame,
                   styleMask: .borderless,
                   backing: .buffered,
                   defer: false)
        self.isOpaque = false
        self.backgroundColor = .clear
        self.ignoresMouseEvents = true
        self.level = .screenSaver
    }
}

class SnowView: NSView {
    let emitter = CAEmitterLayer()
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        wantsLayer = true
        
        emitter.emitterPosition = CGPoint(x: frame.width/2, y: frame.height + 10)
        emitter.emitterSize = CGSize(width: frame.width, height: 0)
        emitter.emitterShape = .line
        
        let flake = CAEmitterCell()
        flake.birthRate = 15
        flake.lifetime = 40
        flake.velocity = 40
        flake.yAcceleration = -30
        flake.emissionLongitude = .pi
        flake.emissionRange = 0.5
        flake.scale = 0.25
        
        // 雪の文字をイメージ化
        let snowStr = "❄"
        let img = NSImage(size: NSSize(width: 24, height: 24), flipped: false) { rect in
            snowStr.draw(in: rect, withAttributes: [
                .font: NSFont.systemFont(ofSize: 20),
                .foregroundColor: NSColor.white
            ])
            return true
        }
        flake.contents = img.cgImage(forProposedRect: nil, context: nil, hints: nil)
        
        emitter.emitterCells = [flake]
        layer?.addSublayer(emitter)
    }
    
    required init?(coder: NSCoder) { fatalError() }
}

let app = NSApplication.shared
app.setActivationPolicy(.accessory)

let screen = NSScreen.main!
let window = SnowWindow(screen: screen)
window.contentView = SnowView(frame: screen.frame)
window.makeKeyAndOrderFront(nil)

app.run()
