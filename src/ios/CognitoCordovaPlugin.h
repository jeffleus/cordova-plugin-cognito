//
//  CognitoCordovaPlugin.h
//  CognitoSample
//
//  Created by Jeff Leininger on 5/31/17.
//  Copyright © 2017 Jeff Leininger. All rights reserved.
//
#import <Cordova/CDVPlugin.h>

#import <Foundation/Foundation.h>
#import <AWSCognitoIdentityProvider/AWSCognitoIdentityProvider.h>
#import <AWSCore/AWSCore.h>

@interface CognitoCordovaPlugin : CDVPlugin {    
}

    - (void)initPlugin:(NSDictionary *)options;
	- (void)loginUser:(NSString *)username withPassword:(NSString *)password;

 	- (void)init:(CDVInvokedUrlCommand*)command;
    - (void)login:(CDVInvokedUrlCommand*)command;
    - (void)loginUser:(NSString *)username withPassword:(NSString *)password withCompletionHandler:(void(^)(AWSCognitoIdentityUserSession *session)) completion;
    - (void)getToken:(CDVInvokedUrlCommand*)command;
	- (void)logout:(CDVInvokedUrlCommand*)command;

@end
