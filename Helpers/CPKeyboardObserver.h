//
//  CPKeyboardObserver.h
//  CityParking
//
//  Created by Igor on 21.08.15.
//  Copyright (c) 2015 Fastforward. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef struct {
	CGRect               beginRect;
	CGRect               endRect;
	NSTimeInterval       duration;
	UIViewAnimationCurve animationCurve;
	UIViewAnimationOptions animationOptions;
} CPKeyboardChange;

@class CPKeyboardObserver;
@protocol CPKeyboardObserverDelegate <NSObject>
@optional
- (void)keyboardObserver:(CPKeyboardObserver *)keyboardObserver willChange:(CPKeyboardChange)changeInfo;
- (void)keyboardObserver:(CPKeyboardObserver *)keyboardObserver didChange:(CPKeyboardChange)changeInfo;
@end

@interface CPKeyboardObserver : NSObject
@property (nonatomic, readonly) BOOL isOpened;
@property (nonatomic, weak, readonly) id<CPKeyboardObserverDelegate> delegate;
@property (nonatomic, assign, readonly) CPKeyboardChange lastChange;

- (instancetype)initWithDelegate:(id<CPKeyboardObserverDelegate>)delegate;

- (void)start;
- (void)stop;

@end
