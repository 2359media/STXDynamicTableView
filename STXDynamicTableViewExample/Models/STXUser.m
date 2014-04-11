//
//  STXUser.m
//  STXDynamicTableViewExample
//
//  Created by Jesse Armand on 9/4/14.
//  Copyright (c) 2014 2359 Media Pte Ltd. All rights reserved.
//

#import "STXUser.h"

@interface STXUser ()

@property (copy, nonatomic) NSString *userID;
@property (copy, nonatomic) NSString *username;
@property (copy, nonatomic) NSString *fullname;
@property (copy, nonatomic) NSURL *profilePictureURL;

@end

@implementation STXUser

- (instancetype)initWithDictionary:(NSDictionary *)dictionary
{
    self = [super init];
    if (self) {
        NSArray *errors;
        NSDictionary *mappingDictionary = @{ @"id": KZProperty(userID),
                                             @"username": KZProperty(username),
                                             @"full_name": KZProperty(fullname),
                                             @"profile_picture": KZBox(URL, profilePictureURL) };
        
        [KZPropertyMapper mapValuesFrom:dictionary toInstance:self usingMapping:mappingDictionary errors:&errors];
    }
    
    return self;
}

@end
