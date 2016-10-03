//
//  CPParkingService.m
//  CityParking
//
//  Created by Igor Zubko on 10.11.15.
//  Copyright © 2015 Fastforward. All rights reserved.
//

#import "CPGeocoderService.h"
// System
#import <MapKit/MapKit.h>
#import <AddressBookUI/ABAddressFormatting.h>
#import <libextobjc/extobjc.h>
// categories
#import "NSData+NSInputStream.h"
#import "NSArray+CPUtils.h"
#import "NSDictionary+CPUtils.h"

@implementation CPGeocoderItem

- (instancetype)initWithPlacemark:(CLPlacemark *)placemark
{
	if (self = [super init])
	{
		self->_location = placemark.location;
		self->_address = ABCreateStringWithAddressDictionary(placemark.addressDictionary, NO);
	}
	
	return self;
}

- (NSString *)description
{
	NSString *locationDesc = [self.location description];
	
	NSRange r1 = [locationDesc rangeOfString:@"<"];
	NSRange r2 = [locationDesc rangeOfString:@">"];
	NSRange subrange = NSMakeRange(r1.location + r1.length, r2.location - r1.location - r1.length);
	NSString *locationString = [locationDesc substringWithRange:subrange];

	return [NSString stringWithFormat:@"<%@> %@ <%@>", self.class, self.address, locationString];
}

@end

@interface CPGeocoderService ()
@property (nonatomic, strong) CLGeocoder *geocoder;
@end


@implementation CPGeocoderService

- (instancetype)init
{
	if (self = [super init])
	{
		self.geocoder = [CLGeocoder new];
	}
	
	return self;
}

- (void)query:(NSString *)query doneBlock:(CPGeocoderServiceDoneBlock)doneBlock
{
	[self queryCancel];
	
	NSString *trimmedQuery = [query stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
	[self.geocoder geocodeAddressString:trimmedQuery completionHandler:^(NSArray *placemarks, NSError *error) {
		if (error == nil || error.code != kCLErrorGeocodeCanceled)
		{
			NSMutableArray *result = [[NSMutableArray alloc] initWithCapacity:placemarks.count];
			[placemarks enumerateObjectsUsingBlock:^(CLPlacemark *p, NSUInteger idx, BOOL *stop) {
				[result addObject:[[CPGeocoderItem alloc] initWithPlacemark:p]];
			}];
			
			CPSafeCallBlock(doneBlock, [NSArray arrayWithArray:result], error);
		}
	}];
}

- (void)geocodeLocation:(CLLocation *)location withSuccessBlock:(CPServiceSuccessBlock)successBlock andErrorBlock:(CPServiceErrorBlock)errorBlock
{
	[self queryCancel];
	
	[self.geocoder reverseGeocodeLocation:location completionHandler:^(NSArray<CLPlacemark *> *placemarks, NSError *error) {
		if (error) {
			CPSafeCallBlock(errorBlock, error);
			return;
		}
		
		CPSafeCallBlock(successBlock, placemarks);
	}];
}

- (void)queryCancel
{
	if ([self.geocoder isGeocoding]) {
		[self.geocoder cancelGeocode];
	}
}

#pragma mark - 

- (PMKPromise *)suggestCompletionFor:(NSString *)query
{
	NSString * const clientId = @"E5BZKWTZRKG2NN0RPC0WFFOYQRNS32PUSL0XCTUFWTCUFF4S";
	NSString * const clientSecret = @"JM1LAQRGMBBUWP00FM2YQ10WQART2OR1SEJLL1DDG1S2VFRB";
	NSString * const clientAPIVersion = @"20150813";
	
	NSString *apiParams = [NSString stringWithFormat:@"client_id=%@&client_secret=%@&v=%@", clientId, clientSecret, clientAPIVersion];
	NSString *near = @"Montreal";
	
//	220, Avenue Rachel

	query = [query stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https://api.foursquare.com/v2/venues/suggestcompletion?near=%@&query=%@&%@", near, query, apiParams]];

	return [PMKPromise new:^(PMKFulfiller fulfill, PMKRejecter reject) {
		NSURLSession *session = [NSURLSession sharedSession];
		[[session dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
			if (error) {
				return reject(error);
			}
			
			NSError *jsonError = nil;
			NSDictionary *object = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
			fulfill(jsonError ? jsonError : object);
			
		}] resume];
	}].thenInBackground(^(NSDictionary *result) {
		NSArray *venues = result[@"response"][@"minivenues"];
		
		return [venues cp_map:^id(NSDictionary *item) {
			NSString *address = item[@"name"];
			if (address == nil) {
				address = item[@"location"][@"address"];
			}
			
			NSString *lat = item[@"location"][@"lat"];
			NSString *lng = item[@"location"][@"lng"];
			
			if (address != nil && lat != nil && lng != nil) {
				return @{@"address": address, @"location": [NSString stringWithFormat:@"%@,%@", lat, lng]};
			} else {
				return  nil;
			}
		}];
	}).then(^(NSArray *result) {
		DLOG(@"%@ -> %@", url, result);
		return result;
	});
}

@end
