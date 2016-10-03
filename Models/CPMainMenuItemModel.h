//
//  CPMainMenuItemModel.h
//  CityParking
//
//  Created by Igor on 26.08.15.
//  Copyright (c) 2015 Fastforward. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CPMainMenuItemModel : NSObject
@property (nonatomic, readonly, copy) NSString *title;				// Localized title for main menu
@property (nonatomic, readonly, copy) NSString *storyboardId;		// View controller Id in storyboard
@property (nonatomic, readonly, copy) NSString *storyboardName;		// Storyboard name
@property (nonatomic, readonly, assign) BOOL enabled;
@property (nonatomic, readonly, assign) BOOL restricted;
@property (nonatomic, readonly, assign) BOOL hiden;

+ (instancetype)menuItmeWithTitle:(NSString *)title storyboardId:(NSString *)vcId storyboardName:(NSString *)sbName isEnabled:(BOOL)enabled;
+ (instancetype)menuItmeWithTitle:(NSString *)title storyboardId:(NSString *)vcId storyboardName:(NSString *)sbName isEnabled:(BOOL)enabled isRestricted:(BOOL)restricted;
+ (instancetype)menuItmeWithTitle:(NSString *)title storyboardId:(NSString *)vcId storyboardName:(NSString *)sbName isEnabled:(BOOL)enabled isRestricted:(BOOL)restricted isHiden:(BOOL)hiden;

@end
