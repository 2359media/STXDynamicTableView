//
//  STXComment.h
//  STXDynamicTableView
//
//  Created by Jesse Armand on 27/1/14.
//  Copyright (c) 2014 2359 Media. All rights reserved.
//

@interface STXComment : NSObject <STXCommentItem>

/**
 *  Initialize data model from dictionary
 */

- (instancetype)initWithDictionary:(NSDictionary *)dictionary;

@end
