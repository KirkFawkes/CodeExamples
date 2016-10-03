//
//  CPTextFieldViewController.h
//  CityParking
//
//  Created by Igor Zubko on 03.12.15.
//  Copyright © 2015 Fastforward. All rights reserved.
//

#import "CPViewController.h"

@interface CPTextFieldViewController : CPViewController
@property (nonatomic, readonly, assign) BOOL success;
@property (nonatomic, copy) NSString *editibleText;
@end
