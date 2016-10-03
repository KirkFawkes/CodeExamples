//
//  CPNotificaitonService.h
//  CityParking
//
//  Created by Igor Zubko on 07.12.15.
//  Copyright © 2015 Fastforward. All rights reserved.
//

#import <Foundation/Foundation.h>
// servicese
#import "CPUserService.h"
#import "CPNetworkService.h"
#import "CPParkingService.h"
#import "CPAnalitics.h"

@protocol CPNotificaitonServiceProtocol <NSObject>
@property (nonatomic, strong) id<CPNetworkServiceProtocol> __nonnull networkService;
@property (nonatomic, strong) id<CPAnaliticsServiceProtocol> __nonnull analiticsService;

- (void)registerForNotifications;
- (void)didRegisterWithDeviceToken:(nonnull NSData *)deviceToken;
- (void)didReceiveRemoteNotification:(nonnull NSDictionary *)userInfo;

- (void)handleActionWithIdentifier:(nullable NSString *)identifier forRemoteNotification:(nonnull NSDictionary *)userInfo completionHandler:(nonnull void (^)())completionHandler;

@end

@interface CPNotificaitonService : NSObject<CPNotificaitonServiceProtocol>
@property (nonatomic, strong) id<CPUserServiceProtocol> __nonnull userService;
@property (nonatomic, strong) id<CPParkingService> __nonnull parkingService;
@property (nonatomic, strong) id<CPNetworkServiceProtocol> __nonnull networkService;
@property (nonatomic, strong) id<CPAnaliticsServiceProtocol> __nonnull analiticsService;

@end
