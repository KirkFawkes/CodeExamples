//
//  CPNetworkIndicatorService.m
//  CityParking
//
//  Created by Igor Zubko on 15.01.16.
//  Copyright © 2016 Fastforward. All rights reserved.
//

#import "CPNetworkIndicatorService.h"
#import <AFNetworking/AFNetworkActivityIndicatorManager.h>

@interface CPNetworkIndicatorService()
@property (nonatomic, strong) AFNetworkActivityIndicatorManager *manager;
@end

@implementation CPNetworkIndicatorService

- (instancetype)init
{
	if (self = [super init])
	{
		self.manager = [[AFNetworkActivityIndicatorManager alloc] init];
		self.manager.enabled = YES;
	}
	
	return self;
}

#pragma mark - CPNetworkIndicatorServiceProtocol

- (BOOL)isActivityIndicatorVisible
{
	return [self.manager isNetworkActivityIndicatorVisible];
}

- (void)showActivityIndicator
{
	[self.manager incrementActivityCount];
}

- (void)hideActivityIndicator
{
	[self.manager decrementActivityCount];
}

@end
