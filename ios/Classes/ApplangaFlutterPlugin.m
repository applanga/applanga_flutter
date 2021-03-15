#import "ApplangaFlutterPlugin.h"
#if __has_include(<applanga_flutter/applanga_flutter-Swift.h>)
#import <applanga_flutter/applanga_flutter-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "applanga_flutter-Swift.h"
#endif

@implementation ApplangaFlutterPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftApplangaFlutterPlugin registerWithRegistrar:registrar];
}
@end
