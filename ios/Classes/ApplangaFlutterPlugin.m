#import "ApplangaFlutterPlugin.h"
#import "Applanga.h"
#if __has_include(<applanga_flutter/applanga_flutter-Swift.h>)
#import <applanga_flutter/applanga_flutter-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "applanga_flutter-Swift.h"
#endif


@implementation ApplangaFlutterPlugin
static FlutterMethodChannel *channel = nil;

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  channel = [FlutterMethodChannel
      methodChannelWithName:@"applanga_flutter"
            binaryMessenger:[registrar messenger]];
  ApplangaFlutterPlugin* instance = [[ApplangaFlutterPlugin alloc] init];
  [registrar addMethodCallDelegate:instance channel:channel];

  [Applanga setScreenshotInterface:instance];
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
  if ([@"init" isEqualToString:call.method]) {
      result(nil);
  } else if ([@"setShowIdModeEnabled" isEqualToString:call.method]){
      BOOL enabled = [[call.arguments objectForKey:@"enabled"] boolValue];
      [Applanga setShowIdModeEnabled:enabled];
      result(nil);
  } else if ([@"update" isEqualToString:call.method])  {
      NSArray* groups = call.arguments[@"groups"];
      NSArray* languages = call.arguments[@"languages"];
      
      [Applanga updateGroups:groups andLanguages:languages withCompletionHandler:^(BOOL success) {
          result([NSNumber numberWithBool:success]);
      }];
  } else if ([@"takeScreenshotWithTag" isEqualToString:call.method])  {
      NSString* tag = call.arguments[@"tag"];
      NSArray* stringIds = call.arguments[@"stringIds"];
      NSString* positions = call.arguments[@"stringPos"];
      [Applanga captureScreenshotWithTag:tag ids:stringIds positions:positions withCompletionHandler:^(BOOL success) {
              result([NSNumber numberWithBool:success]);
      }];
  } else if ([@"setLanguage" isEqualToString:call.method])  {
      NSString* lang = call.arguments[@"lang"];
      [Applanga setLanguage:lang];
      result(nil);
  } else if ([@"localizeMap" isEqualToString:call.method])  {
      result([Applanga localizeMap:call.arguments andUpdateMissingStrings: FALSE]);
  } else if ([@"showDraftModeDialog" isEqualToString:call.method])  {
      [Applanga showDraftModeDialog];
      result(nil);
  } else if ([@"showScreenShotMenu" isEqualToString:call.method])  {
      [Applanga setScreenShotMenuVisible:true];
      result(nil);
  } else if ([@"hideScreenShotMenu" isEqualToString:call.method])  {
      [Applanga setScreenShotMenuVisible:false];
      result(nil);
  }  else {
      result(FlutterMethodNotImplemented);
  }
}

@end

@implementation Applanga (ApplangaFlutter)
+ (bool)isApplangaFlutter {
    return true;
}
@end

@interface ApplangaFlutterPlugin (ApplangaInterface) <ApplangaScreenshotInterface>
@end

@implementation ApplangaFlutterPlugin (ApplangaInterface)
- (void)onCaptureScreenshotFromOverlay:(NSString*)screenTag {
    [channel invokeMethod:@"captureScreenshotFromOverlay" arguments:screenTag];
}

@end
