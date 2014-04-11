MTJSONUtils
===========

An NSObject category for when you're working with it converting to/from JSON.

### Installation

In your Podfile, add this line:

    pod "MTJSONUtils"
  
### Methods

Use the following for a shortcut to generating JSON data from a dictionary (or any NSObject):

	- (NSData *)JSONData;

The requirements of NSJSONSerialization state that all objects must be instances of NSString, NSNumber, NSArray, NSDictionary, or NSNull.
The following can be called on any NSObject and will return a safe deep copy of the receiver:

	- (id)objectWithJSONSafeObjects;
 
#### This will:
* Replace NSDate objects with their ISO string representation. (e.g. `2012-08-12T04:17:30Z`)
* Replace any other non-valid objects with their string description.
* More coming...

The following methods allow you to query into an object graph that includes arrays (not just dictionaries):

	- (id)valueForComplexKeyPath:(NSString *)keyPath;
	- (NSString *)stringValueForComplexKeyPath:(NSString *)key;
 
#### Available Subscripting Values:
* 0..infinity
* first
* last

#### Example

Given this object:

	NSDictionary *dictionary = @{
		@"parent" : @{
			@"name" : @"Nathan",
			@"children" : @[ @{
				@"name" : @"adam",
				@"apple_products" : @[ @{
					@"title"		: @"macbook",
					@"price"		: @1399.99,
					@"date_bought"	: [NSDate dateWithTimeInterval:-22342 sinceDate:[NSDate date]]
				},
				@{
					@"title"		: @"mac mini",
					@"price"		: @599.99,
					@"date_bought"	: [NSDate dateWithTimeInterval:-30223 sinceDate:[NSDate date]]
				},
				@{
					@"title"		: @"iphone",
					@"price"		: @199.99,
					@"date_bought"	: [NSDate dateWithTimeInterval:-123453 sinceDate:[NSDate date]]
				}]
			},
			@{
				@"name" : @"amanda",
				@"apple_products" : @[ @{
					@"title"		: @"nano",
					@"price"		: @299.99,
					@"date_bought"	: [NSDate dateWithTimeInterval:-123453 sinceDate:[NSDate date]]
				}]
			},
			@{
				@"name" : @"andrew",
				@"apple_products" : @[ @{
					@"title"		: @"ipad",
					@"price"		: @499.99,
					@"date_bought"	: [NSDate dateWithTimeInterval:-2452342 sinceDate:[NSDate date]]
				},
				@{
					@"title"		: @"ipod touch",
					@"price"		: @399.99,
					@"date_bought"	: [NSDate dateWithTimeInterval:-430223 sinceDate:[NSDate date]]
				}]
			}]
		}
	};

You could query the values like this:

	[[dictionary valueForComplexKeyPath:@"parent.name"]											// => "Nathan"
	[[dictionary valueForComplexKeyPath:@"parent.children[0].name"]								// => "adam"
	[[dictionary valueForComplexKeyPath:@"parent.children[1].name"]								// => "amanda"
	[[dictionary valueForComplexKeyPath:@"parent.children[2].name"]								// => "andrew"
	[[dictionary valueForComplexKeyPath:@"parent.children[first].name"]							// => "adam"
	[[dictionary valueForComplexKeyPath:@"parent.children[last].name"]							// => "andrew"
	[[dictionary valueForComplexKeyPath:@"parent.children[first].apple_products[0].title"]		// => "macbook"
	[[dictionary valueForComplexKeyPath:@"parent.children[first].apple_products[1].title"]		// => "mac mini"
	[[dictionary valueForComplexKeyPath:@"parent.children[first].apple_products[2].title"]		// => "iphone"
	[[dictionary valueForComplexKeyPath:@"parent.children[first].apple_products[last].title"] 	// => "iphone"
	[[dictionary valueForComplexKeyPath:@"parent.children[last].apple_products[last].title"]	// => "ipod touch"
	[[dictionary valueForComplexKeyPath:@"parent.children[last].apple_products[last].price"]	// => 399.99


#### Misc

And some nifty macros for dealing with NSNull and nil:

	// swaps NSNull for nil
	#define NILL(a) ([a isKindOfClass:[NSNull class]] ? nil : a)
	// swaps nil for NSNull
	#define NUL(a) a ? a : [NSNull null]

