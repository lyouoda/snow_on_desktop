#import <AppKit/AppKit.h>
#import <QuartzCore/QuartzCore.h>

// 設定管理クラス
@interface SnowSettings : NSObject
@property CGFloat birthRate;
@property CGFloat gravity;
@property (strong) CAEmitterLayer *emitterLayer;
+ (instancetype)shared;
- (void)update;
@end

@implementation SnowSettings
+ (instancetype)shared {
    static SnowSettings *s;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{ s = [SnowSettings new]; });
    return s;
}
- (void)update {
    for (CAEmitterCell *cell in self.emitterLayer.emitterCells) {
        cell.birthRate = self.birthRate;
        cell.yAcceleration = self.gravity;
    }
    NSArray *cells = self.emitterLayer.emitterCells;
    self.emitterLayer.emitterCells = nil;
    self.emitterLayer.emitterCells = cells;
}
@end

@interface SnowView : NSView
@end

@implementation SnowView
- (instancetype)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setWantsLayer:YES];
        CAEmitterLayer *emitter = [CAEmitterLayer layer];
        emitter.emitterPosition = CGPointMake(frame.size.width / 2, frame.size.height + 10);
        emitter.emitterSize = CGSizeMake(frame.size.width, 0);
        emitter.emitterShape = kCAEmitterLayerLine;
        
        CAEmitterCell *flake = [CAEmitterCell emitterCell];
        [SnowSettings shared].birthRate = 15.0;
        [SnowSettings shared].gravity = -30.0;
        
        flake.birthRate = [SnowSettings shared].birthRate;
        flake.lifetime = 40.0;
        flake.velocity = 40;
        flake.yAcceleration = [SnowSettings shared].gravity;
        flake.emissionLongitude = M_PI;
        flake.emissionRange = 0.5;
        flake.scale = 0.25;
        
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
        [SnowSettings shared].emitterLayer = emitter;
    }
    return self;
}
@end

@interface AppDelegate : NSObject <NSApplicationDelegate>
@property (strong) NSStatusItem *statusItem;
@property (strong) NSWindow *window;
@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)notification {
    self.statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
    self.statusItem.button.title = @"❄";
    
    // メニュー作成
    NSMenu *menu = [[NSMenu alloc] init];
    
    // --- カスタムビュー（スライダー）の作成 ---
    NSMenuItem *sliderItem = [[NSMenuItem alloc] init];
    NSView *customView = [[NSView alloc] initWithFrame:NSMakeRect(0, 0, 200, 80)];
    
    // 雪の量のラベルとスライダー
    NSTextField *labelRate = [[NSTextField alloc] initWithFrame:NSMakeRect(10, 50, 60, 20)];
    labelRate.stringValue = @"Amount:";
    labelRate.editable = NO; labelRate.bordered = NO; labelRate.drawsBackground = NO;
    [customView addSubview:labelRate];
    
    NSSlider *sliderRate = [NSSlider sliderWithValue:[SnowSettings shared].birthRate minValue:0 maxValue:100 target:self action:@selector(sliderRateChanged:)];
    sliderRate.frame = NSMakeRect(70, 50, 120, 20);
    [customView addSubview:sliderRate];
    
    // 速さのラベルとスライダー
    NSTextField *labelSpeed = [[NSTextField alloc] initWithFrame:NSMakeRect(10, 10, 60, 20)];
    labelSpeed.stringValue = @"Speed:";
    labelSpeed.editable = NO; labelSpeed.bordered = NO; labelSpeed.drawsBackground = NO;
    [customView addSubview:labelSpeed];
    
    NSSlider *sliderSpeed = [NSSlider sliderWithValue:-[SnowSettings shared].gravity minValue:0 maxValue:200 target:self action:@selector(sliderSpeedChanged:)];
    sliderSpeed.frame = NSMakeRect(70, 10, 120, 20);
    [customView addSubview:sliderSpeed];
    
    sliderItem.view = customView;
    [menu addItem:sliderItem];
    
    [menu addItem:[NSMenuItem separatorItem]];
    [menu addItemWithTitle:@"Quit" action:@selector(terminate:) keyEquivalent:@"q"];
    self.statusItem.menu = menu;

    // ウィンドウ設定
    NSRect screenRect = [[NSScreen mainScreen] frame];
    self.window = [[NSWindow alloc] initWithContentRect:screenRect styleMask:NSWindowStyleMaskBorderless backing:NSBackingStoreBuffered defer:NO];
    [self.window setBackgroundColor:[NSColor clearColor]];
    [self.window setOpaque:NO];
    [self.window setIgnoresMouseEvents:YES];
    [self.window setLevel:NSScreenSaverWindowLevel];
    [self.window setCollectionBehavior:NSWindowCollectionBehaviorCanJoinAllSpaces | NSWindowCollectionBehaviorFullScreenAuxiliary];
    
    SnowView *view = [[SnowView alloc] initWithFrame:screenRect];
    [self.window setContentView:view];
    [self.window makeKeyAndOrderFront:nil];
}

- (void)sliderRateChanged:(NSSlider *)sender {
    [SnowSettings shared].birthRate = sender.doubleValue;
    [[SnowSettings shared] update];
}

- (void)sliderSpeedChanged:(NSSlider *)sender {
    [SnowSettings shared].gravity = -sender.doubleValue;
    [[SnowSettings shared] update];
}
@end

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        NSApplication *app = [NSApplication sharedApplication];
        AppDelegate *delegate = [AppDelegate new];
        app.delegate = delegate;
        [app setActivationPolicy:NSApplicationActivationPolicyAccessory];
        [app run];
    }
    return 0;
}