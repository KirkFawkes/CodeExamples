//
//  CPUserInfoModel.h
//  CityParking
//
//  Created by Igor Zubko on 17.11.15.
//  Copyright © 2015 Fastforward. All rights reserved.
//

#import <Foundation/Foundation.h>

@class STPCard;

@interface CPUserModel : NSObject
@end

@interface CPUserInfoModel : CPUserModel
@property (nonatomic, copy) id objectId;
@property (nonatomic, copy) NSString *email;
@property (nonatomic, copy) NSString *firstName;
@property (nonatomic, copy) NSString *lastName;
@property (nonatomic, copy) NSString *phone;

- (NSString *)fullName;
@end

#pragma mark - Fore registration

@interface CPRegisterUserInfoModel : CPUserInfoModel
@property (nonatomic, copy) NSString *password;
@end

#pragma mark - For authorization

@interface CPAuthUserModel : CPUserModel
@property (nonatomic, copy) NSString *email;
@property (nonatomic, copy) NSString *password;
@end

#pragma mark - Current user

@interface CPCurrentUserInfoModel : CPUserInfoModel <NSCoding>
@property (nonatomic, readonly) id accessToken;
@property (nonatomic, readonly, strong) NSString *creditCardBrand;
@property (nonatomic, readonly, strong) NSString *creditCardLast4;

- (instancetype)initWithToken:(id)token;
- (instancetype)initWithToken:(id)token andCreditCard:(STPCard *)creditCard;

- (instancetype)updateWithDictionary:(NSDictionary *)dictionary;
- (instancetype)updateWithCreditCard:(STPCard *)creditCard;

- (BOOL)isAuthorized;

- (BOOL)isCreditCardAttached;

@end