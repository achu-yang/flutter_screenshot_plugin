#import "FlutterScreenshotPlugin.h"
#if __has_include(<flutter_screenshot_plugin/flutter_screenshot_plugin-Swift.h>)
#import <flutter_screenshot_plugin/flutter_screenshot_plugin-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "flutter_screenshot_plugin-Swift.h"
#endif

@implementation FlutterScreenshotPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftFlutterScreenshotPlugin registerWithRegistrar:registrar];
}
@end
