//
//  CPLocationProvider.h
//  CityParking
//
//  Created by Igor on 21.08.15.
//  Copyright (c) 2015 Fastforward. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

typedef void (^CPLocationProviderPreAuthDoneBlock)();
typedef void (^CPLocationProviderPreAuthBlock)(CPLocationProviderPreAuthDoneBlock done);
typedef void (^CPLocationProviderAuthChangedBlock)(CLAuthorizationStatus status);

@interface CPLocationProvider : NSObject
@property (nonatomic, readonly) CLAuthorizationStatus authorizationStatus;
@property (nonatomic, readonly) BOOL isNotAuthorized;
@property (nonatomic, readonly) BOOL isAuthorized;
@property (nonatomic, readonly) BOOL isDisabled;

@property (nonatomic, copy) CPLocationProviderPreAuthBlock preAuthorizationBlock;

- (void)requestAccess:(CPLocationProviderAuthChangedBlock)block;

//- (void)startUpdatingLocation;

- (void)showDisableAlert;

@end
