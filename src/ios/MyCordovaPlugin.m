#import "MyCordovaPlugin.h"
#import "CognitoCordovaPlugin.h"

#import <Cordova/CDVAvailability.h>

@implementation MyCordovaPlugin
	//Config options for the AWS Cognito services to use my identityPool, userPool, and clientId
	NSString *CognitoIdentityPoolId;
	NSString *CognitoIdentityUserPoolId;
	NSString *CognitoIdentityUserPoolAppClientId;
	NSString *CognitoIdentityUserPoolAppClientSecret;
//	//hard-coded for now, but need to include in config args from the plugin calls
//	NSString *USER_POOL_NAME = @"FuelStationApp";
//	NSString *CognitoIdentityUserPoolRegionString = @"us-west-2";
    CognitoCordovaPlugin *cognitoPlugin;

- (void)pluginInitialize {
}

- (void)readOptions:(NSDictionary *)options {

    CognitoIdentityPoolId = [options objectForKey:@"arnIdentityPoolId"];
    CognitoIdentityUserPoolId = [options objectForKey:@"CognitoIdentityUserPoolId"];
    CognitoIdentityUserPoolAppClientId = [options objectForKey:@"CognitoIdentityUserPoolAppClientId"];
    //CognitoIdentityUserPoolAppClientSecret = nil;
    //user = nil;
    
}

- (void)init:(CDVInvokedUrlCommand *)command {
	//grab the configuration options from the plugin command args at the first index
	NSMutableDictionary* options = [command.arguments objectAtIndex:0];
	[self readOptions:options];
    cognitoPlugin = [[CognitoCordovaPlugin alloc] init];
    [cognitoPlugin initPlugin:options];

	NSLog(@"Initialization successful");
	CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"Initialization successful"];

	[self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)echo:(CDVInvokedUrlCommand *)command {
  NSString* phrase = [command.arguments objectAtIndex:0];
  NSLog(@"%@", phrase);
}

- (void)login:(CDVInvokedUrlCommand *)command {
    NSMutableDictionary* options = [command.arguments objectAtIndex:0];
    
    NSString *username = [options objectForKey:@"username"];
    NSString *password = [options objectForKey:@"password"];
    NSLog(@"Login as %@, %@", username, password);
    [cognitoPlugin loginUser:username withPassword:password];
    
    //create a pluginResult to report back the init results and return to the command delegate
    CDVPluginResult *pluginResult = [CDVPluginResult
                                     resultWithStatus:CDVCommandStatus_OK
                                     messageAsString:@"Login successful"];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];

}

- (void)getDate:(CDVInvokedUrlCommand *)command {
  NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
  NSLocale *enUSPOSIXLocale = [NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"];
  [dateFormatter setLocale:enUSPOSIXLocale];
  [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZZZZZ"];

  NSDate *now = [NSDate date];
  NSString *iso8601String = [dateFormatter stringFromDate:now];
    NSLog(@"%@", iso8601String);

  CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:iso8601String];
  [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
}

@end
