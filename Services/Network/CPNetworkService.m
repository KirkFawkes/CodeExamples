//
//  CPNetworkService.m
//  CityParking
//
//  Created by Igor Zubko on 06.11.15.
//  Copyright © 2015 Fastforward. All rights reserved.
//

#import "CPNetworkService.h"
// Models
#import "CPParkingInfo.h"
// Services
#import "CPNetworkIndicatorService.h"
#import "CPUserService.h"
//
#import <Mantle/Mantle.h>
#import <AFNetworking/AFNetworking.h>
#import <AFNetworking/AFNetworkReachabilityManager.h>
// Categories
#import "NSData+NSInputStream.h"
#import "NSMutableDictionary+CPUtils.h"
#import "NSDictionary+CPUtils.h"
#import "NSArray+CPUtils.h"

#define kTimeoutInterval	15.f

NSString * const CPNetworkMethodGET = @"GET";
NSString * const CPNetworkMethodPUT = @"PUT";
NSString * const CPNetworkMethodPOST = @"POST";
NSString * const CPNetworkMethodDELETE = @"DELETE";

@interface CPNetworkService ()
{
	NSDictionary *_defaultHeaderParams;
	dispatch_once_t _defaultHeaderParamsOnce;
}

@property (nonatomic, readonly) NSURLSession *session;
@property (nonatomic, strong, readonly) AFNetworkReachabilityManager *reachabilityManager;
@end

@implementation CPNetworkService
@synthesize session = _session;

- (instancetype)initWithBaseUrl:(NSURL *)baseUrl
{
	if (self = [super init])
	{
		self->_baseUrl = baseUrl;
		
		NSString *domain = baseUrl.host;
		
		// Enshure that host setted as domain, not as ip
		DASSERT(4 != [[domain componentsSeparatedByString:@"."] cp_filter:^BOOL(NSString *item) {
			NSCharacterSet *nums = [NSCharacterSet decimalDigitCharacterSet];
			NSCharacterSet *chars = [NSCharacterSet characterSetWithCharactersInString:item];
			return [nums isSupersetOfSet:chars] && (item.length < 4);
		}].count);
		
		@weakify(self);
		self->_reachabilityManager = [AFNetworkReachabilityManager managerForDomain:domain];
		[self->_reachabilityManager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
			@strongify(self);
			
			DLOG(@"Network status did change: %@", self.reachabilityManager.localizedNetworkReachabilityStatusString);
		}];
		[self->_reachabilityManager startMonitoring];
		
		DLOG(@"--- Network initialized with '%@' as base url", baseUrl);
		DLOG(@"--- Reachability manager configured for '%@' domain", domain);
	}
	
	return self;
}

- (void)dealloc
{
	[self.reachabilityManager stopMonitoring];
}

- (NSURLSession *)session
{
	if (self->_session == nil)
	{
		NSURLSessionConfiguration *sessionConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
		self->_session = [NSURLSession sessionWithConfiguration:sessionConfig];
	}
	
	return self->_session;
}

#pragma mark - Helpers methods

- (NSDictionary *)headerParams
{
	dispatch_once(&self->_defaultHeaderParamsOnce, ^{
		NSBundle *bundle = [NSBundle mainBundle];
		
		NSMutableDictionary *d = [NSMutableDictionary dictionary];
		d[@"X-APP-ID"] = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
		d[@"X-APP-API-VERSION"] = [@(CPConfigServerApiVersion) description];
		d[@"X-APP-BUILD"] = [bundle objectForInfoDictionaryKey:@"CFBundleVersionBuild"];
#ifdef DEBUG
		d[@"X-APP-ENVIRONMENT"] = @"sandbox";
#endif
		self->_defaultHeaderParams = [NSDictionary dictionaryWithDictionary:d];
	});

	id const accessToken = self.userService.currentUser.accessToken;
	
	if (accessToken == nil) {
		return self->_defaultHeaderParams;
	}

	NSMutableDictionary *p = [NSMutableDictionary dictionaryWithDictionary:self->_defaultHeaderParams];
	p[@"X-APP-TOKEN"] = accessToken;
	return p;
}

- (NSMutableURLRequest *)createJSONRequestWithMethod:(NSString *)method URLString:(NSString *)URLString parameters:(id)parameters andError:(NSError **)error
{
	*error = nil;
	
	NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:parameters];
	[params cp_addObject:self.userService.currentUser.accessToken forKey:@"token"];
	
	NSMutableURLRequest *request = [[AFHTTPRequestSerializer serializer] requestWithMethod:method URLString:URLString parameters:params error:error];
	
	if (*error) {
		return nil;
	}
	
	[request setTimeoutInterval:kTimeoutInterval];
	[request setCachePolicy:NSURLRequestUseProtocolCachePolicy];
	
	NSDictionary *headerParams = [self headerParams];
	[headerParams enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
		[request addValue:obj forHTTPHeaderField:key];
	}];
	
	return request;
}

- (NSMutableURLRequest *)createMultipartJSONRequestWithMethod:(NSString *)method URLString:(NSString *)URLString parameters:(id)parameters andError:(NSError **)error
{
	DASSERT(parameters == nil || [parameters isKindOfClass:[NSDictionary class]]);
	
	NSDictionary *data = [[(NSDictionary *)parameters cp_filter:^BOOL(id  _Nonnull key, id  _Nonnull item) {
		return [item isKindOfClass:[NSData class]] || [item isKindOfClass:[UIImage class]];
	}] cp_map:^NSData *(NSString *key, id item) {
		if ([item isKindOfClass:[NSData class]]) {
			return item;
		}
		
		if ([item isKindOfClass:[UIImage class]]) {
			return UIImageJPEGRepresentation(item, .95f);
		}
		
		// unknown type
		DASSERT(0);
		return nil;
	}];
	
	NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:[(NSDictionary *)parameters cp_removeKeys:data.allKeys]];
	[params cp_addObject:self.userService.currentUser.accessToken forKey:@"token"];
	
	*error = nil;
	AFHTTPRequestSerializer *serializer = [AFHTTPRequestSerializer serializer];
	NSMutableURLRequest *request = [serializer multipartFormRequestWithMethod:method URLString:URLString parameters:params constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
		[data enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, NSData * _Nonnull obj, BOOL * _Nonnull stop) {
			DASSERT([obj isKindOfClass:[NSData class]]);
			[formData appendPartWithFileData:obj name:key fileName:[key stringByAppendingString:@".jpg"] mimeType:@"image/jpeg"];
		}];
	} error:error];
	
	if (*error) {
		return nil;
	}
	
	[request setTimeoutInterval:kTimeoutInterval];
	[request setCachePolicy:NSURLRequestUseProtocolCachePolicy];
	
	NSDictionary *headerParams = [self headerParams];
	[headerParams enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
		[request addValue:obj forHTTPHeaderField:key];
	}];
	
	return request;
}

- (NSError *)extractErrorFromResponse:(NSDictionary *)response
{
	if ([response isKindOfClass:[NSDictionary class]])
	{
		NSDictionary *errorValue = response[@"errors"];
		if (errorValue) {
			if ([errorValue isKindOfClass:[NSArray class]]) {
				errorValue = @{NSLocalizedDescriptionKey: [(NSArray *)errorValue componentsJoinedByString:@"; "]};
			} else if ([errorValue isKindOfClass:[NSString class]]) {
				errorValue = @{NSLocalizedDescriptionKey: errorValue};
			}
			
			NSError *err = [NSError errorWithDomain:@"com.cityparking.network" code:CPNetworkServiceErrorResponseError userInfo:errorValue];
			return err;
		}
	}

	return nil;
}

#pragma mark - Public methods

- (void)sendHttpRequest:(NSString *)path withMethod:(NSString *)method params:(NSDictionary *)params
			   callback:(void (^)(NSData *data, NSURLResponse *response, NSError *error))callback
{
	DASSERT(path.length > 0);
	DASSERT(method.length > 0);
	DASSERT(callback != nil);
	DASSERT(self.baseUrl != nil);
	
	NSError *error = nil;
	NSString *urlString = [self.baseUrl.absoluteString stringByAppendingString:path];
	NSMutableURLRequest *request = [self createJSONRequestWithMethod:method URLString:urlString parameters:params andError:&error];
	
	if (error != nil) {
		return callback(nil, nil, error);
	}
	
//	DLOG(@"[DEBUG] URL request: %@ %@ [%@]", method, urlString, self.userService.currentUser.accessToken);
	
	NSURLSessionTask *task = [self.session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
		[self.activityIndicatorService hideActivityIndicator];
		
		dispatch_sync(dispatch_get_main_queue(), ^{
			callback(data, response, error);
		});
	}];
	
	[self.activityIndicatorService showActivityIndicator];
	
	[task resume];
}

- (void)sendJSONRequest:(NSString *)path withMethod:(NSString *)method params:(NSDictionary *)params
			   callback:(void (^)(id object, NSURLResponse *response, NSError *error))callback
{
	[self sendHttpRequest:path withMethod:method params:params callback:^(NSData *data, NSURLResponse *response, NSError *error) {
		DLOG(@">>>> %@: %@", path, error);
		if (error != nil) {
			NSDictionary *userInfo = response ? [error.userInfo mtl_dictionaryByAddingEntriesFromDictionary:@{@"response": response}] : error.userInfo;
			return callback(nil, response, [NSError errorWithDomain:error.domain code:error.code userInfo:userInfo]);
		}
		
		NSError *jsonError = nil;
		NSDictionary *object = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
		
		// TODO: Handle HTTP errors
		
		if (jsonError != nil) {
			NSMutableDictionary *userInfo = [jsonError.userInfo mutableCopy];
			userInfo[@"raw_data_string"] = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
			
			NSError *e = [NSError errorWithDomain:jsonError.domain code:jsonError.code userInfo:userInfo];
			return callback(nil, response, e);
		}
		
		NSError *resultError = [self extractErrorFromResponse:object];
		callback(object, response, resultError);
	}];
}

- (PMKPromise *)sendJSONRequest:(NSString *)path withMethod:(NSString *)method params:(NSDictionary *)params
{
	return [PMKPromise promiseWithAdapter:^(PMKAdapter adapter) {
		[self sendJSONRequest:path withMethod:method params:params callback:^(id object, NSURLResponse *response, NSError *error) {
			adapter(PMKManifold(object, response), error);
		}];
	}];
}

- (void)uploadImage:(UIImage *)image withCallback:(void (^)(NSDictionary *result, NSURLResponse *response, NSError *error))callback
{
	DASSERT([image isKindOfClass:[UIImage class]]);
	
	NSError *error = nil;
	NSDictionary *params = @{@"image": image};
	NSString *urlString = [self.baseUrl.absoluteString stringByAppendingString:@"/upload/driveway"];
	NSMutableURLRequest *request = [self createMultipartJSONRequestWithMethod:CPNetworkMethodPOST URLString:urlString parameters:params andError:&error];

	if (error != nil) {
		return callback(nil, nil, error);
	}

	NSURLSessionTask *task = [self.session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
		[self.activityIndicatorService hideActivityIndicator];
		
		if (error != nil) {
			return callback(nil, response, error);
		}
		
		dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
			NSError *resultError = nil;
			NSDictionary *object = [NSJSONSerialization JSONObjectWithData:data options:0 error:&resultError];
			
			if (resultError == nil) {
				resultError = [self extractErrorFromResponse:object];
			}
			
			dispatch_sync(dispatch_get_main_queue(), ^{
				callback(object, response, resultError);
			});
		});
	}];
	
	[self.activityIndicatorService showActivityIndicator];
	
	[task resume];
}

- (PMKPromise *)uploadImage:(UIImage *)image
{
	return [PMKPromise promiseWithAdapter:^(PMKAdapter adapter) {
		[self uploadImage:image withCallback:^(id result, NSURLResponse *response, NSError *error) {
			adapter(PMKManifold(result, response), error);
		}];
	}];
}

@end
