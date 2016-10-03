//
//  CPTimeSelctionViewController.h
//  CityParking
//
//  Created by Igor Zubko on 25.11.15.
//  Copyright © 2015 Fastforward. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CPTimePickerViewController;

@protocol CPTimePickerViewControllerDelegate <NSObject>
@optional
- (void)timePicker:(CPTimePickerViewController *)timePicker viewWillDisappear:(BOOL)animated;
- (void)timePicker:(CPTimePickerViewController *)timePicker didChangedDate:(NSDate *)date;
@end
@interface CPTimePickerViewController : UIViewController
@property (nonatomic, weak) id<CPTimePickerViewControllerDelegate> delegate;
@property (nonatomic, assign) NSInteger tag;
@property (nonatomic, assign) NSDate *date;
@property (nonatomic, assign) NSDate *minDate;
@end
