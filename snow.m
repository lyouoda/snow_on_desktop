#import <AppKit/AppKit.h>
#import <QuartzCore/QuartzCore.h>

@interface SnowView : NSView
@end

@implementation SnowView
- (instancetype)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setWantsLayer:YES];
        self.layer.backgroundColor = [NSColor clearColor].CGColor;
        
        CAEmitterLayer *emitter = [CAEmitterLayer layer];
        emitter.emitterPosition = CGPointMake(frame.size.width / 2, frame.size.height + 10);
        emitter.emitterSize = CGSizeMake(frame.size.width, 0);
        emitter.emitterShape = kCAEmitterLayerLine;
        
        CAEmitterCell *flake = [CAEmitterCell emitterCell];
        flake.birthRate = 10.0;
        flake.lifetime = 40.0;
        flake.velocity = 40;
        flake.velocityRange = 20;
        flake.yAcceleration = -30.0;
        flake.emissionLongitude = M_PI;
        flake.emissionRange = 0.5;
        flake.scale = 0.25;
        flake.scaleRange = 0.1;
        flake.alphaSpeed = 0.0; 
        
        NSString *snowFlakeStr = @"❄";
        NSDictionary *attributes = @{ NSFontAttributeName: [NSFont systemFontOfSize:20],
                                     NSForegroundColorAttributeName: [NSColor whiteColor] };
        NSImage *img = [NSImage imageWithSize:NSMakeSize(24, 24) flipped:NO drawingHandler:^BOOL(NSRect dstRect) {
            [snowFlakeStr drawInRect:dstRect withAttributes:attributes];
            return YES;
        }];
        flake.contents = (__bridge id)[img CGImageForProposedRect:NULL context:NULL hints:NULL];
        
        emitter.emitterCells = @[flake];
        [self.layer addSublayer:emitter];
    }
    return self;
}
@end

// メニューバーを管理するためのデリゲートクラス
@interface AppDelegate : NSObject <NSApplicationDelegate>
@property (strong) NSStatusItem *statusItem;
@property (strong) NSWindow *window;
@end

@implementation AppDelegate
- (void)applicationDidFinishLaunching:(NSNotification *)notification {
    // 1. メニューバーの設定
    self.statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
    self.statusItem.button.title = @"❄"; // メニューバーに表示されるアイコン
    
    NSMenu *menu = [[NSMenu alloc] init];
    [menu addItemWithTitle:@"Quit" action:@selector(terminate:) keyEquivalent:@"q"];
    self.statusItem.menu = menu;

    // 2. 雪を降らせるウィンドウの設定
    NSRect screenRect = [[NSScreen mainScreen] frame];
    self.window = [[NSWindow alloc] initWithContentRect:screenRect
                                              styleMask:NSWindowStyleMaskBorderless
                                                backing:NSBackingStoreBuffered
                                                  defer:NO];
    
    [self.window setBackgroundColor:[NSColor clearColor]];
    [self.window setOpaque:NO];
    [self.window setHasShadow:NO];
    [self.window setIgnoresMouseEvents:YES];
    [self.window setLevel:NSScreenSaverWindowLevel];
    [self.window setCollectionBehavior:NSWindowCollectionBehaviorCanJoinAllSpaces | NSWindowCollectionBehaviorFullScreenAuxiliary];
    
    SnowView *view = [[SnowView alloc] initWithFrame:screenRect];
    [self.window setContentView:view];
    [self.window makeKeyAndOrderFront:nil];
}
@end

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        NSApplication *app = [NSApplication sharedApplication];
        AppDelegate *delegate = [[AppDelegate alloc] init];
        app.delegate = delegate;
        [app setActivationPolicy:NSApplicationActivationPolicyAccessory];
        [app run];
    }
    return 0;
}