//
//  FBSDKLoginManager+Promises.m
//  CityParking
//
//  Created by Igor Zubko on 16.02.16.
//  Copyright © 2016 Fastforward. All rights reserved.
//

#import "FBSDKLoginManager+Promises.h"
#import <FBSDKAccessToken.h>

@implementation FBSDKLoginManager (Promises)

- (PMKPromise *)cp_closeActiveSession
{
	if ([FBSDKAccessToken currentAccessToken])
	{
		[self logOut];
	}
	
	return [PMKPromise promiseWithValue:nil];
}

- (PMKPromise *)cp_logInWithReadPermissions:(NSArray *)permissions fromViewController:(UIViewController *)fromViewController
{
	return [PMKPromise new:^(PMKFulfiller fulfill, PMKRejecter reject) {
		[self logInWithReadPermissions:permissions fromViewController:fromViewController handler:^(FBSDKLoginManagerLoginResult *result, NSError *error) {
			if (error)
			{
				return reject(error);
			}
			
			if ([result isCancelled])
			{
				NSDictionary *userInfo = @{@"silent": @1, NSLocalizedDescriptionKey: @"Canceled authorization"};
				
				NSError *error = [NSError errorWithDomain:FBSDKLoginErrorDomain code:FBSDKCustomErrorTypeCanceledAuth userInfo:userInfo];
				reject(error);
			}

			fulfill(result);
		}];
	}];
}

@end
