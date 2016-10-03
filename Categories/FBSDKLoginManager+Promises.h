//
//  FBSDKLoginManager+Promises.h
//  CityParking
//
//  Created by Igor Zubko on 16.02.16.
//  Copyright © 2016 Fastforward. All rights reserved.
//

#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import <PromiseKit/PromiseKit.h>

#define FBSDKCustomErrorTypeCanceledAuth 6000

@interface FBSDKLoginManager (Promises)

- (PMKPromise *)cp_closeActiveSession;
- (PMKPromise *)cp_logInWithReadPermissions:(NSArray *)permissions fromViewController:(UIViewController *)fromViewController;

@end
