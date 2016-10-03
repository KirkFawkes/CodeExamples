//
//  CPObjectModel.h
//  CityParking
//
//  Created by Igor Zubko on 20.11.15.
//  Copyright © 2015 Fastforward. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Mantle/Mantle.h>

typedef id CPObjectModelId;

@interface CPObjectModel : MTLModel<MTLJSONSerializing>
@property (nonatomic, readonly, copy) CPObjectModelId objectId;

+ (instancetype)objectFromDictionary:(NSDictionary *)dictionary error:(NSError **)error;
+ (NSArray *)objectsFromArray:(NSArray<NSDictionary *> *)array error:(NSError **)error;

@end
