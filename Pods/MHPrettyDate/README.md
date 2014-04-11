MHPrettyDate
============

An iOS framework that provides a simple mechanism to get  "Pretty Dates" ("Yesterday", "Today", etc.) from NSDate objects.

## Header File

``` objective-c

#import "MHPrettyDate.h"
```


## Enumerations

``` objective-c

typedef enum
{
    MHPrettyDateFormatWithTime,
    //
    //  EXAMPLE:  if today is September 30, 2012 and the time is 12:58 PM
    //     Today:        12:58 PM
    //     Tomorrow:     Tomorrow 12:58 PM
    //     Yesterday:    Yesterday 12:58 PM
    //     2 days ago:   Friday 12:58 PM
    //     1 week ago:   09/23/12 12:58 PM
    //     1 week later: 10/07/12 12:58 PM
    //
    MHPrettyDateFormatNoTime,
    //
    //  EXAMPLE:  if today is September 30, 2012 and the time is 12:58 PM
    //     Today:        Today
    //     Tomorrow:     Tomorrow
    //     Yesterday:    Yesterday
    //     2 days ago:   Friday
    //     1 week ago:   09/23/12
    //     1 week later: 10/07/12
    //
    MHPrettyDateFormatTodayTimeOnly,
    //
    //  EXAMPLE:  if today is September 30, 2012 and the time is 12:58 PM
    //     Today:        12:58 PM
    //     Tomorrow:     Tomorrow
    //     Yesterday:    Yesterday
    //     2 days ago:   Friday
    //     1 week ago:   09/23/12
    //     1 week later: 10/07/12
    //
    MHPrettyDateLongRelativeTime,
    //
    //  EXAMPLES:
    //     Now
    //     15 minutes ago
    //     59 minutes ago
    //     1 hour ago
    //     2 hours ago
    //     Yesterday
    //     30 days ago
    //     90 days ago
    //
    //     (future times same as MHPrettyDateFormatWithTime)
    //
   MHPrettyDateShortRelativeTime
   //
   //  EXAMPLES:
   //     Now
   //     15m
   //     59m
   //     1h
   //     23h
   //     1d
   //     30d
   //     90d
   //
   //     (future time but today same as MHPrettyDateFormatWithTime, otherwise same as MHPrettyDateFormatNoTime)
   //
} MHPrettyDateFormat;

```

## Public Class Methods

``` objective-c
@interface MHPrettyDate : NSObject

+(NSString*) prettyDateFromDate:(NSDate*) date withFormat:(MHPrettyDateFormat) dateFormat;
+(BOOL)      isToday:(NSDate*)       date;
// date
+(BOOL)      isPastDate:(NSDate*)     date;
+(BOOL)      isFutureDate:(NSDate*)   date;
+(BOOL)      isTomorrow:(NSDate*)     date;
+(BOOL)      isYesterday:(NSDate*)    date;
+(BOOL)      isWithinWeek:(NSDate*)   date;
+(BOOL)      willMakePretty:(NSDate*) date;
// time
+(BOOL)      isNow:(NSDate*)          date;
+(BOOL)      isFutureTime:(NSDate*)   date;
+(BOOL)      isPastTime:(NSDate*)     date;
+(BOOL)      isWithin24Hours:(NSDate*)date;
+(BOOL)      isWithinHour:(NSDate*)   date;

@end
```

## Requirements

- Supports iOS 5.1 and higher
- ARC enabled projects only


## Usage

Refer to example appliction MHPrettyDateExampleApp for usage strategies.


## Credits

MHPrettyDates was created by Bobby Williams (bjackw@mac.com)

## License

MHPrettyDate is available under the MIT license. See the LICENSE file for more info.

