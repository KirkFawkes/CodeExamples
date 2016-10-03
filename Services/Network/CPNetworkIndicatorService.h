//
//  CPNetworkIndicatorService.h
//  CityParking
//
//  Created by Igor Zubko on 15.01.16.
//  Copyright © 2016 Fastforward. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol CPNetworkIndicatorServiceProtocol <NSObject>
@property (nonatomic, readonly) BOOL isActivityIndicatorVisible;

- (void)showActivityIndicator;
- (void)hideActivityIndicator;
@end

@interface CPNetworkIndicatorService : NSObject<CPNetworkIndicatorServiceProtocol>
@end
