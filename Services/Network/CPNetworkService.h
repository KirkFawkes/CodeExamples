//
//  CPNetworkService.h
//  CityParking
//
//  Created by Igor Zubko on 06.11.15.
//  Copyright © 2015 Fastforward. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CLLocation.h>
#import <PromiseKit/PromiseKit.h>
#import "defines.h"

@class CPUserService;
@protocol CPNetworkIndicatorServiceProtocol;

# pragma mark - HTTP Methods
extern NSString * const CPNetworkMethodGET;
extern NSString * const CPNetworkMethodPUT;
extern NSString * const CPNetworkMethodPOST;
extern NSString * const CPNetworkMethodDELETE;

#pragma mark - Error codes

typedef enum : NSUInteger {
	CPNetworkServiceErrorResponseUnexpectedError = 42,
	CPNetworkServiceErrorResponseError
} CPNetworkServiceError;

#pragma mark - Protocol

@protocol CPNetworkServiceProtocol <NSObject>
- (void)uploadImage:(UIImage *)image withCallback:(void (^)(NSDictionary *result, NSURLResponse *response, NSError *error))callback;
- (void)sendJSONRequest:(NSString *)path
			 withMethod:(NSString *)method
				 params:(NSDictionary *)params
			   callback:(void (^)(id object, NSURLResponse *response, NSError *error))callback;

- (PMKPromise *)uploadImage:(UIImage *)image;
- (PMKPromise *)sendJSONRequest:(NSString *)path withMethod:(NSString *)method params:(NSDictionary *)params;

@end

#pragma mark - Implementation

@interface CPNetworkService : NSObject<CPNetworkServiceProtocol>

@property (nonatomic, retain) CPUserService *userService;
@property (nonatomic, retain) id<CPNetworkIndicatorServiceProtocol> activityIndicatorService;
@property (nonatomic, readonly) NSURL *baseUrl;

- (instancetype)initWithBaseUrl:(NSURL *)baseUrl;

@end
