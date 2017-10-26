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
    AWSCognitoIdentityUserSession *session;
    NSMutableDictionary* loginDetails;

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

//- (void)login:(CDVInvokedUrlCommand *)command {
//    NSMutableDictionary* options = [command.arguments objectAtIndex:0];
//
//    NSString *username = [options objectForKey:@"username"];
//    NSString *password = [options objectForKey:@"password"];
//    NSLog(@"Login as %@, %@", username, password);
//    [cognitoPlugin loginUser:username withPassword:password];
//
//    //create a pluginResult to report back the init results and return to the command delegate
//    CDVPluginResult *pluginResult = [CDVPluginResult
//                                     resultWithStatus:CDVCommandStatus_OK
//                                     messageAsString:@"Login successful"];
//    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
//
//}

- (NSDictionary*)getSessionAsDictionary:(AWSCognitoIdentityUserSession *)session {
//setup a dictioanry for the tokens (id, access, refresh) and the expiration
    NSMutableDictionary* sessionDict = [NSMutableDictionary dictionaryWithCapacity:3];
//copy the token string for each of the (3) tokens
    [sessionDict setObject:session.idToken.tokenString forKey:@"idToken"];
    [sessionDict setObject:session.idToken.tokenString forKey:@"accessToken"];
    [sessionDict setObject:session.refreshToken.tokenString forKey:@"refreshToken"];
//setup a date Formatter
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    NSLocale *enUSPOSIXLocale = [NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"];
    [dateFormatter setLocale:enUSPOSIXLocale];
    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZZZZZ"];
//use formatter to convert expiration to a String for passing back to calling js
    NSString *iso8601String = [dateFormatter stringFromDate:session.expirationTime];
    NSLog(@"%@", iso8601String);
    [sessionDict setObject:iso8601String forKey:@"expirationTime"];
//return the dictionary for marshalling back to JS side of things
    return sessionDict;
}

- (void)loginWithOptions:(NSMutableDictionary*) options forCommand:(CDVInvokedUrlCommand *) command {
    NSString *username = [options objectForKey:@"username"];
    NSString *password = [options objectForKey:@"password"];
    NSLog(@"Login as %@, %@", username, password);
    [cognitoPlugin loginUser:username withPassword:password withCompletionHandler:^(AWSCognitoIdentityUserSession *session) {
        
        //create a pluginResult to report back the login results
        CDVPluginResult *pluginResult;
        //check nil session from completionHandler for a fail condition and report error to plugin client
        if ( session == nil ) {
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Cognito login attempt failed!"];
        }
        //otherwise, convert the session to a Dictionary and return to plugin client with success
        else {
            NSDictionary *sessionDict = [self getSessionAsDictionary:session];
            pluginResult = [CDVPluginResult
                            resultWithStatus:CDVCommandStatus_OK
                            messageAsDictionary:sessionDict];
        }
        //execute the command delete to send the results (success or fail) to the plugin client
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        
    }];
}

- (void)login:(CDVInvokedUrlCommand *)command {
    NSMutableDictionary* options = [command.arguments objectAtIndex:0];
    loginDetails = options;

    [self loginWithOptions:options forCommand:command];
}

- (void)logout:(CDVInvokedUrlCommand *)command {
    [cognitoPlugin logout];
    //create a pluginResult to report back the logout results
    CDVPluginResult *pluginResult = [CDVPluginResult
                        resultWithStatus:CDVCommandStatus_OK
                        messageAsString:@"user was successfully logged out."];
    //execute the command delete to send the results (success or fail) to the plugin client
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}
    
- (void)refresh:(CDVInvokedUrlCommand *)command {
    NSMutableDictionary* options = loginDetails;
    
    [self loginWithOptions:options forCommand:command];
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
