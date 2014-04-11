//
//  STXUser.h
//  STXDynamicTableViewExample
//
//  Created by Jesse Armand on 9/4/14.
//  Copyright (c) 2014 2359 Media Pte Ltd. All rights reserved.
//

@import Foundation;

#import "STXUserItem.h"

@interface STXUser : NSObject <STXUserItem>

- (instancetype)initWithDictionary:(NSDictionary *)dictionary;

@end
