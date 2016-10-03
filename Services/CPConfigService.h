//
//  CPConfigService.h
//  CityParking
//
//  Created by Igor Zubko on 17.11.15.
//  Copyright © 2015 Fastforward. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MKGeometry.h>

@class CPCurrentUserInfoModel;

@interface CPConfigService : NSObject
@property (nonatomic, assign) BOOL welcomeScreenShowed;
@property (nonatomic, assign) CPCurrentUserInfoModel *currentUser;

- (id)objectForKey:(NSString *)key;
- (void)setObject:(id)object forKey:(NSString *)key;

- (void)setMapRect:(MKMapRect)rect forKey:(NSString *)key;
- (MKMapRect)mapRectForKey:(NSString *)key;

@end
