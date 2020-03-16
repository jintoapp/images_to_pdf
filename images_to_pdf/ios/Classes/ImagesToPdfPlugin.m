#import "ImagesToPdfPlugin.h"
#if __has_include(<images_to_pdf/images_to_pdf-Swift.h>)
#import <images_to_pdf/images_to_pdf-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "images_to_pdf-Swift.h"
#endif

@implementation ImagesToPdfPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftImagesToPdfPlugin registerWithRegistrar:registrar];
}
@end
