//
//  MKMapView+CityParking.h
//  CityParking
//
//  Created by Igor on 26.08.15.
//  Copyright (c) 2015 Fastforward. All rights reserved.
//

#import <MapKit/MapKit.h>

@interface MKMapView (CityParking)

- (CLCircularRegion *)cp_visibleCircleRegion;

@end
