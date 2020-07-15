#import "ApplangaFlutterPlugin.h"
#import "Applanga.h"

@implementation ApplangaFlutterPlugin
static FlutterMethodChannel *channel = nil;

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  channel = [FlutterMethodChannel
      methodChannelWithName:@"applanga_flutter"
            binaryMessenger:[registrar messenger]];
  ApplangaFlutterPlugin* instance = [[ApplangaFlutterPlugin alloc] init];
  [registrar addMethodCallDelegate:instance channel:channel];

  [Applanga setScreenshotInterface:instance];
/*
  [channel invokeMethod:@"getStringPositions" arguments:nil result:^(id _Nullable result) {

      }];*/

}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
  if ([@"update" isEqualToString:call.method])  {
      [Applanga updateWithCompletionHandler:^(BOOL success) {
          result([NSNumber numberWithBool:success]);
      }];
  } else if ([@"getString" isEqualToString:call.method])  {

        NSString* key = call.arguments[@"key"];
        NSString* defaultValue = call.arguments[@"defaultValue"];

      result([Applanga localizedStringForKey:key withDefaultValue:defaultValue]);

  } else if ([@"takeScreenshotWithTag" isEqualToString:call.method])  {

      NSString* tag = call.arguments[@"tag"];

      BOOL useOcr = call.arguments[@"useOcr"];
    
      if(call.arguments[@"stringIds"] == [NSNull null])
      {
          [Applanga captureScreenshotWithTag:tag andIDs:nil useOcr:useOcr withCompletionHandler:^(BOOL success) {
              result([NSNumber numberWithBool:success]);
          }];
      }
      else
      {
          NSArray* stringIds = call.arguments[@"stringIds"];
          [Applanga captureScreenshotWithTag:tag andIDs:stringIds useOcr:useOcr withCompletionHandler:^(BOOL success) {
              result([NSNumber numberWithBool:success]);
          }];
      }

 }else if ([@"setlanguage" isEqualToString:call.method])  {

      NSString* lang = call.arguments[@"lang"];
     
      [Applanga setLanguage:lang];
      
 }  else if ([@"localizeMap" isEqualToString:call.method])  {
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

@interface ApplangaFlutterPlugin (ApplangaInterface) <ApplangaScreenshotInterface>
@end

@implementation ApplangaFlutterPlugin (ApplangaInterface)

- (void)getStringPositions:(void (^)(NSString* result))completionHandler {
    [channel invokeMethod:@"getStringPositions" arguments:nil result:^(id _Nullable result) {
        completionHandler(result);
    }];
}

@end