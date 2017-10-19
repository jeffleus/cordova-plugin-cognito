//
//  CognitoCordovaPlugin.m
//  CognitoSample
//
//  Created by Jeff Leininger on 5/31/17.
//  Copyright © 2017 Jeff Leininger. All rights reserved.
//

#import "CognitoCordovaPlugin.h"
#import "CognitoPoolIdentityProvider.h"

@implementation CognitoCordovaPlugin
//hard-coded region constant for the USWest2 region based on current project
AWSRegionType const CognitoIdentityUserPoolRegion = AWSRegionUSWest2;

//Config options for the AWS Cognito services to use my identityPool, userPool, and clientId
NSString *CognitoIdentityUserPoolId;
NSString *CognitoIdentityUserPoolAppClientId;
NSString *CognitoIdentityPoolId;
NSString *USER_POOL_NAME = @"FuelStationApp";
NSString *CognitoIdentityUserPoolRegionString = @"us-west2";

//AWS Objects to handle the service interactions
AWSCognitoIdentityUserPool *pool;
AWSCognitoIdentityUser *user;
AWSCognitoIdentityUserPoolConfiguration *configuration;
AWSServiceConfiguration *serviceConfiguration;
AWSCognitoCredentialsProvider *credentialsProvider;

AWSServiceConfiguration *serviceConfig;

- (void)readOptions:(NSDictionary *)options {

    CognitoIdentityPoolId = [options objectForKey:@"arnIdentityPoolId"];
    CognitoIdentityUserPoolId = [options objectForKey:@"CognitoIdentityUserPoolId"];
    CognitoIdentityUserPoolAppClientId = [options objectForKey:@"CognitoIdentityUserPoolAppClientId"];
    //CognitoIdentityUserPoolAppClientSecret = nil;
    //user = nil;
    
}

- (id) init {
    if ( self = [super init] ) {
        return self;
    } else
        return nil;
}

- (void)initPlugin:(NSDictionary *)options {
    NSLog(@"\n\n**********\n\nSTART - plugin init code\n\n**********\n\n");
    [self readOptions:options];
    
    // We can then set this as the default configuration for all AWS SDKs
    serviceConfiguration = [[AWSServiceConfiguration alloc] initWithRegion:CognitoIdentityUserPoolRegion credentialsProvider:nil];
    
    // Setup the pool
    configuration = [[AWSCognitoIdentityUserPoolConfiguration alloc]
                                                              initWithClientId:CognitoIdentityUserPoolAppClientId
                                                              clientSecret:nil
                                                              poolId:CognitoIdentityUserPoolId];
    //register the pool using the serviceConfig and poolConfig for the given poolName as key
    [AWSCognitoIdentityUserPool registerCognitoIdentityUserPoolWithConfiguration:serviceConfiguration
                                                           userPoolConfiguration:configuration
                                                                          forKey:USER_POOL_NAME];
    // Get the pool object now
    pool = [AWSCognitoIdentityUserPool CognitoIdentityUserPoolForKey:USER_POOL_NAME];
    
    // The Credentials Provider holds our identity pool which allows access to AWS resources
    credentialsProvider = [[AWSCognitoCredentialsProvider alloc]
                           initWithRegionType:CognitoIdentityUserPoolRegion
                           identityPoolId:CognitoIdentityPoolId
                           identityProviderManager:pool];
    
    //init a new serviceConfig this time providing the credentialsProvider
    AWSServiceConfiguration *svcConfig = [[AWSServiceConfiguration alloc]
                                          initWithRegion:CognitoIdentityUserPoolRegion
                                          credentialsProvider:credentialsProvider];
    [AWSServiceManager defaultServiceManager].defaultServiceConfiguration = svcConfig;
    
    NSLog(@"\n\n**********\n\nEND - plugin init code\n\n**********\n\n");

}

- (void)loginUser:(NSString *)username withPassword:(NSString *)password {
    // Get the user from the pool
    //    user = [pool currentUser];
    user = [pool getUser:username];
    
    // Make a call to get hold of the users session
    [[user getSession:username password:password validationData:nil]
     continueWithBlock:^id(AWSTask<AWSCognitoIdentityUserSession *> *task) {
        if (task.error) {
            NSLog(@"Could not get user session. Error: %@", task.error);
            
        } else {
            NSLog(@"Successfully retrieved user session data");
            
            // Get the session object from our result
            AWSCognitoIdentityUserSession *session = (AWSCognitoIdentityUserSession *) task.result;
            NSLog(@"TOKEN: %@", session.idToken.tokenString);
            
            // Build a token string
            NSString *key = [NSString
                             stringWithFormat:@"cognito-idp.%@.amazonaws.com/%@",
                             CognitoIdentityUserPoolRegionString,
                             CognitoIdentityUserPoolId];
            NSString *tokenStr = [session.idToken tokenString];
            NSDictionary *tokens = [[NSDictionary alloc] initWithObjectsAndKeys:tokenStr, key,  nil];
            
            CognitoPoolIdentityProvider *idProvider = [[CognitoPoolIdentityProvider alloc] init];
            [idProvider addTokens:tokens];
            
            AWSCognitoCredentialsProvider *creds = [[AWSCognitoCredentialsProvider alloc]
                                                    initWithRegionType:CognitoIdentityUserPoolRegion
                                                    identityPoolId:CognitoIdentityPoolId
                                                    identityProviderManager:idProvider];
            
            serviceConfig = [[AWSServiceConfiguration alloc]
                             initWithRegion:CognitoIdentityUserPoolRegion
                             credentialsProvider:creds];
            
            // This sets the default service configuration to allow the API gateway access to user authentication
            AWSServiceManager.defaultServiceManager.defaultServiceConfiguration = serviceConfig;
            
            // Register the pool
            [AWSCognitoIdentityUserPool
             registerCognitoIdentityUserPoolWithConfiguration:serviceConfig
             userPoolConfiguration:configuration
             forKey:USER_POOL_NAME];
        }
        return nil;
    }];
}

- (void)refreshSession {
    
    // Get the user from the pool
    user = [pool currentUser];
    // Get the session for the current user and refresh if needed...
    [[user getSession] continueWithBlock:^id _Nullable(AWSTask<AWSCognitoIdentityUserSession *> * _Nonnull t) {
        if (t.error) {
            NSLog(@"There was an error refreshing session...");
            NSLog(@"\n\n**********\nPlease Login Again\n\n**********\n");
        } else {
            NSLog(@"\n\n**********\nSession was refreshed!!! Yay!!!\n\n**********\n");
            NSLog(@"\nEXPIRES: %@", t.result.expirationTime);
            NSLog(@"\n\nTOKEN: %@\n\n", t.result.idToken.tokenString);
        }
        return nil;
    }];
    
}

- (void)logout {
    
    // Get the user from the pool
    user = [pool currentUser];
    [user globalSignOut];
    
}
@end
