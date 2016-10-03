//
//  CPUserService.h
//  CityParking
//
//  Created by Igor Zubko on 17.11.15.
//  Copyright © 2015 Fastforward. All rights reserved.
//

#import <Foundation/Foundation.h>
// models
#import "CPObjectModel.h"
#import "CPUserInfoModel.h"

#import <PromiseKit/PromiseKit.h>

extern NSString * const kCPUserServiceAuthorizationChanged;

@protocol CPNetworkServiceProtocol;
@class CPConfigService, STPCardParams, STPBankAccountParams, CPAnalitics, CPUserService;

@protocol CPUserServiceProtocol <NSObject>
@property (nonatomic, readonly) CPCurrentUserInfoModel *currentUser;
@property (nonatomic, retain) id<CPNetworkServiceProtocol> networkService;
@property (nonatomic, retain) CPConfigService *configService;
@property (nonatomic, retain) CPAnalitics *analiticsService;

// Payments
- (void)addBankAccount:(STPBankAccountParams *)bankParams birthday:(NSDate *)birthday withSuccessBlock:(CPServiceSuccessBlock)successBlock andErrorBlock:(CPServiceErrorBlock)errorBlock;
- (void)requestPaymentsListSuccessBlock:(CPServiceSuccessBlock)successBlock andErrorBlock:(CPServiceErrorBlock)errorBlock;

- (PMKPromise *)addBankAccount:(STPBankAccountParams *)bankParams birthday:(NSDate *)birthday;

#pragma mark - Authorization

/**
 *  Authorize user with target credentials
 *
 *  <b>Side effect</b>: this request also update self.currentUser property
 *
 *  @param userInfo authorization information
 *
 *  @return CPCurrentUserInfoModel *
 */
- (PMKPromise *)authorizeUser:(CPAuthUserModel *)userInfo;

/**
 *  Authorize or register user via facebook
 *
 *  <b>Side effect</b>: this request also update self.currentUser property
 *
 *  @param facebookToken Facebook access token
 *
 *  @return CPCurrentUserInfoModel *
 */
- (PMKPromise *)authorizeWithFacebook:(NSString *)facebookToken;

/**
 *  Send pre registration request. At this step backend send sms to user phone number and wait confirmation code
 *
 *  @param userInfo registration user information
 */
- (PMKPromise *)registerUser:(CPRegisterUserInfoModel *)userInfo;

/**
 *  Send password restore email
 */
- (PMKPromise *)resetPasswordForEmail:(NSString *)email;

/**
 *  Logout user
 *
 *  <b>Side effect</b>: this request also update self.currentUser property
 */
- (PMKPromise *)logout;

#pragma mark - User

/**
 *  Request current user information.
 *
 *  <b>Side effect</b>: this request also update self.currentUser property
 *
 *  @return CPCurrentUserInfoModel *
 */
- (PMKPromise *)requestUserInformation;

/**
 *  Request user information
 *
 *  @param userId target user id
 *
 *  @return CPUserInfoModel *
 */
- (PMKPromise *)requestUserInformationById:(CPObjectModelId)userId;

/**
 *  Update curren user information
 *
 *  <b>Side effect</b>: this request also update self.currentUser property
 *
 *  @param userInformation fiedls for update (send is as)
 *
 *  @return CPCurrentUserInfoModel *
 */
- (PMKPromise *)updateUserInformation:(NSDictionary *)userInformation;

/**
 *  Change current user password
 *
 *  @param oldPassword current user password
 *  @param newPassword new user password
 */
- (PMKPromise *)changePassword:(NSString *)oldPassword toNewPassword:(NSString *)newPassword;

#pragma mark - Phone

/**
 *  Send phone verification code and finish user registration
 *
 *  <b>Side effect</b>: this request also update self.currentUser property
 *
 *  @param code verification code from sms
 *  @param phone user phone number
 *
 *  @return CPCurrentUserInfoModel *
 */
- (PMKPromise *)confirmPhoneNumberWithCode:(NSString *)code phone:(NSString *)phone;

/**
 *  Resend confirmation code to target phone
 */
- (PMKPromise *)resendConfirmationCode:(NSString *)phone;

#pragma mark - Credit cards

/**
 *  Add credit card to current user account
 *
 *  @param cardParams credit card information
 */
- (PMKPromise *)addCreditCard:(STPCardParams *)cardParams;

/**
 *  Remove credit card with target id frome current user account
 *
 *  @param cardId credit card id
 */
- (PMKPromise *)removeCreditCard:(CPObjectModelId)cardId;

@end

#pragma mark - Implementation

@interface CPUserService : NSObject<CPUserServiceProtocol>
@property (nonatomic, readonly) CPCurrentUserInfoModel *currentUser;
@property (nonatomic, retain) id<CPNetworkServiceProtocol> networkService;
@property (nonatomic, retain) CPConfigService *configService;
@property (nonatomic, retain) CPAnalitics *analiticsService;


@end
