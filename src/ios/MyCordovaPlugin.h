#import <Cordova/CDVPlugin.h>

@interface MyCordovaPlugin : CDVPlugin {
}

// The hooks for our plugin commands
- (void)init:(CDVInvokedUrlCommand *)command;
- (void)login:(CDVInvokedUrlCommand *)command;
- (void)echo:(CDVInvokedUrlCommand *)command;
- (void)getDate:(CDVInvokedUrlCommand *)command;

@end
