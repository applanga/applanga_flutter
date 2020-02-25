#import "ApplangaFlutterPlugin.h"
#import "Applanga.h"

@implementation ApplangaFlutterPlugin

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  FlutterMethodChannel* channel = [FlutterMethodChannel
      methodChannelWithName:@"applanga_flutter"
            binaryMessenger:[registrar messenger]];
  ApplangaFlutterPlugin* instance = [[ApplangaFlutterPlugin alloc] init];
  [registrar addMethodCallDelegate:instance channel:channel];
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
  if ([@"update" isEqualToString:call.method])  {
      [Applanga updateWithCompletionHandler:^(BOOL success) {
          result([NSNumber numberWithBool:success]);
      }];
  } else if ([@"getString" isEqualToString:call.method])  {
      result([Applanga localizedStringForKey:call.arguments withDefaultValue:nil]);
  } else if ([@"localizeMap" isEqualToString:call.method])  {
      result([Applanga localizeMap:call.arguments]);
  } else if ([@"showDraftModeDialog" isEqualToString:call.method])  {
      [Applanga showDraftModeDialog];
  } else if ([@"showScreenShotMenu" isEqualToString:call.method])  {
         [Applanga setScreenShotMenuVisible:true];
  } else if ([@"hideScreenShotMenu" isEqualToString:call.method])  {
             [Applanga setScreenShotMenuVisible:false];
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

