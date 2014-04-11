//
//  NSObject+MTJSONUtils.h
//  MTJSONUtils
//
//  Created by Adam Kirk on 8/16/12.
//  Copyright (c) 2012 Mysterious Trousers. All rights reserved.
//

// swaps NSNull for nil
#define NILL(a) ([a isKindOfClass:[NSNull class]] ? nil : a)
// swaps nil for NSNull
#define NUL(a) (a ? a : [NSNull null])
// same as NUL but swaps nil for empty string (plist safe)
#define NULS(a) (a ? a : @"")


@interface NSObject (MTJSONUtils)

- (NSData *)JSONData;
- (id)objectWithJSONSafeObjects;
- (id)valueForComplexKeyPath:(NSString *)keyPath;
- (NSString *)stringValueForComplexKeyPath:(NSString *)key;

@end

