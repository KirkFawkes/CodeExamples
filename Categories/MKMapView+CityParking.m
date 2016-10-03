//
//  MKMapView+CityParking.m
//  CityParking
//
//  Created by Igor on 26.08.15.
//  Copyright (c) 2015 Fastforward. All rights reserved.
//

#import "MKMapView+CityParking.h"

@implementation MKMapView (CityParking)

- (CLCircularRegion *)cp_visibleCircleRegion
{
	MKMapRect mRect = self.visibleMapRect;
	
	MKMapPoint neMapPoint = MKMapPointMake(MKMapRectGetMaxX(mRect), mRect.origin.y);
	MKMapPoint swMapPoint = MKMapPointMake(mRect.origin.x, MKMapRectGetMaxY(mRect));
	
	CLLocationCoordinate2D neCoord = MKCoordinateForMapPoint(neMapPoint);
	CLLocationCoordinate2D swCoord = MKCoordinateForMapPoint(swMapPoint);
	
	CLLocation *startLoc = [[CLLocation alloc] initWithLatitude:neCoord.latitude longitude:neCoord.longitude];
	CLLocation *endLoc   = [[CLLocation alloc] initWithLatitude:swCoord.latitude longitude:swCoord.longitude];
	
	CLLocationDistance diameter = [startLoc distanceFromLocation:endLoc];
	
//	DLOG(@"Center: %@, radius: %lf", NSStringFromCLLocationCoordinate2D(self.centerCoordinate), diameter/2.f);
	
	return [[CLCircularRegion alloc] initWithCenter:self.centerCoordinate radius:(diameter/2) identifier:@"VisibleCircleRegion"];
}

@end
