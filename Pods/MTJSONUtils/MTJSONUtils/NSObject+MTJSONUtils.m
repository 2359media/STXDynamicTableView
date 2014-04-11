//
//  NSObject+MTJSONUtils.m
//  MTJSONUtils
//
//  Created by Adam Kirk on 8/16/12.
//  Copyright (c) 2012 Mysterious Trousers. All rights reserved.
//

#import "NSObject+MTJSONUtils.h"





@implementation NSObject (MTJSONUtils)

- (NSData *)JSONData
{
	return [NSJSONSerialization dataWithJSONObject:[self objectWithJSONSafeObjects] options:0 error:nil];
}

- (id)objectWithJSONSafeObjects
{
	if ([self isKindOfClass:[NSDictionary class]])
		return [self safeDictionaryFromDictionary:self];

	else if ([self isKindOfClass:[NSArray class]] || [self isKindOfClass:[NSSet class]])
		return [self safeArrayFromArray:self];

	else
		return [self safeObjectFromObject:self];
}


- (id)valueForComplexKeyPath:(NSString *)keyPath {

	id currentObject = self;

	NSMutableString *path			= [NSMutableString string];
	NSMutableString *subscriptKey	= [NSMutableString string];
	NSMutableString *string			= path;

	for (int i = 0; i < keyPath.length; i++) {

		unichar c = [keyPath characterAtIndex:i];

		if (c == '[') {
			NSString *trimmedPath = [path stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@". \n"]];
			currentObject = [currentObject valueForKeyPath:trimmedPath];
			[subscriptKey setString:@""];
			string = subscriptKey;
			continue;
		}

		if (c == ']') {
			if (!currentObject) return nil;
			if (![currentObject isKindOfClass:[NSArray class]]) return nil;
			NSUInteger index = 0;
			if ([subscriptKey isEqualToString:@"first"]) {
				index = 0;
			}
			else if ([subscriptKey isEqualToString:@"last"]) {
				index = [currentObject count] - 1;
			}
			else {
				index = [subscriptKey intValue];
			}
            if ([currentObject count] == 0) return nil;
			if (index > [currentObject count] - 1) return nil;
			currentObject = [currentObject objectAtIndex:index];
			if ([currentObject isKindOfClass:[NSNull class]]) return nil;
			[path setString:@""];
			string = path;
			continue;
		}

		[string appendString:[NSString stringWithCharacters:&c length:1]];

		if (i == keyPath.length - 1) {
			NSString *trimmedPath = [path stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@". \n"]];
			currentObject = [currentObject valueForKeyPath:trimmedPath];
			break;
		}
	}

	return currentObject;
}

- (NSString *)stringValueForComplexKeyPath:(NSString *)key {
	id object = [self valueForComplexKeyPath:key];

	if ([object isKindOfClass:[NSString class]])
		return object;

	if ([object isKindOfClass:[NSNull class]])
		return @"";

	if ([object isKindOfClass:[NSNumber class]])
		return [object stringValue];

	if ([object isKindOfClass:[NSDate class]])
		return [NSString stringWithFormat:@"%@", [self safeObjectFromObject:object]];

	return [object description];
}





#pragma mark - Private Methods

- (id)safeDictionaryFromDictionary:(id)dictionary
{

	NSMutableDictionary *cleanDictionary = [NSMutableDictionary dictionary];

	for (id key in [dictionary allKeys]) {
		id object = [dictionary objectForKey:key];

		if ([object isKindOfClass:[NSDictionary class]])
			[cleanDictionary setObject:[object safeDictionaryFromDictionary:object] forKey:key];

		else if ([object isKindOfClass:[NSArray class]])
			[cleanDictionary setObject:[self safeArrayFromArray:object] forKey:key];

		else
			[cleanDictionary setObject:[self safeObjectFromObject:object] forKey:key];
	}

	return cleanDictionary;
}

- (id)safeArrayFromArray:(id)array
{

	NSMutableArray *cleanArray = [NSMutableArray array];

	for (id object in array) {
		if ([object isKindOfClass:[NSArray class]] || [object isKindOfClass:[NSSet class]])
			[cleanArray addObject:[self safeArrayFromArray:object]];

		else if ([object isKindOfClass:[NSDictionary class]])
			[cleanArray addObject:[object safeDictionaryFromDictionary:object]];

		else
			[cleanArray addObject:[self safeObjectFromObject:object]];
	}

	return cleanArray;
}

- (id)safeObjectFromObject:(id)object {

	NSArray *validClasses = @[ [NSString class], [NSNumber class], [NSNull class] ];
	for (Class c in validClasses) {
		if ([object isKindOfClass:c])
			return object;
	}

	if ([object isKindOfClass:[NSDate class]]) {
		NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
		[formatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss'Z'"];
		[formatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
		NSString *ISOString = [formatter stringFromDate:object];
		return ISOString;
	}

	return [object description];
}


@end


