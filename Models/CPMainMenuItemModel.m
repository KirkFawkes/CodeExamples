//
//  CPMainMenuItemModel.m
//  CityParking
//
//  Created by Igor on 26.08.15.
//  Copyright (c) 2015 Fastforward. All rights reserved.
//

#import "CPMainMenuItemModel.h"

@implementation CPMainMenuItemModel

+ (instancetype)menuItmeWithTitle:(NSString *)title storyboardId:(NSString *)vcId storyboardName:(NSString *)sbName isEnabled:(BOOL)enabled
{
	return [[self alloc] initWithTitle:title storyboardId:vcId storyboardName:sbName isEnabled:enabled isRestricted:NO isHiden:NO];
}

+ (instancetype)menuItmeWithTitle:(NSString *)title storyboardId:(NSString *)vcId storyboardName:(NSString *)sbName isEnabled:(BOOL)enabled isRestricted:(BOOL)restricted
{
	return [[self alloc] initWithTitle:title storyboardId:vcId storyboardName:sbName isEnabled:enabled isRestricted:YES isHiden:NO];
}

+ (instancetype)menuItmeWithTitle:(NSString *)title storyboardId:(NSString *)vcId storyboardName:(NSString *)sbName isEnabled:(BOOL)enabled isRestricted:(BOOL)restricted isHiden:(BOOL)hiden
{
	return [[self alloc] initWithTitle:title storyboardId:vcId storyboardName:sbName isEnabled:enabled isRestricted:YES isHiden:hiden];
}

- (instancetype)initWithTitle:(NSString *)title storyboardId:(NSString *)vcId storyboardName:(NSString *)sbName isEnabled:(BOOL)enabled isRestricted:(BOOL)restricted isHiden:(BOOL)hiden
{
	if (self = [super init])
	{
		self->_title = title;
		self->_storyboardId = vcId;
		self->_storyboardName = sbName;
		self->_enabled = enabled;
		self->_restricted = restricted;
		self->_hiden = hiden;
	}
	
	return self;
}

@end
