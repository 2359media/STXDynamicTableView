![UALogger](https://github.com/coneybeare/UALogger/blob/master/lumberjack.png?raw=true "Lumberjack")

UALogger is a simple and lightweight logging tool for iOS and Mac apps. It allows you to customize the log format, customize when to log to the console at runtime, and allows collection of the entire recent console log for your application. It includes the `UALogger` class and class methods, and a few handy macros.

## Why UALogger?

##### Get Context

`NSLog` is great, but it has room for improvement. You probably have some code in your project that says something like the following and ends up logging something generic and unhelpful like:
 
    NSLog(@"Error: %@", [error localizedDescription]);
    => Error: There was a problem loading resource.
   
UALogger steps in to help. By simply adding the file and line number (the basic format) to the output, you can put your generic log messages into context, allowing them to be a much more powerful method of feedback.

    UALog(@"Error: %@", [error localizedDescription]);
    => <UAViewController.m:27> Error: There was a problem loading resource.
    

##### Speed up your Production App

Calls to `NSLog` are expensive. Each write has to append a line to a file on the OS, meaning that the file has to be located, opened, appended, saved, and all synchronously. A `NSLog` call here and there won't grind your app to a halt, but if you log a lot (like you should), it can have a measurable performance hit.

So what do you do to prevent logging in production? Do you grep for `NSLog` entries and comment them out before launch? __No__. You install UALogger and don't worry about it. UALogger won't log to the console on production builds unless you override it to do so. Furthermore, logging in production can be enabled/disabled at **runtime**.

##### Protect Sensitive Information

The console log that `NSLog` writes to can be read by any app, or anyone who knows how to dig around on their device. This may not be a problem, but what if you log user details such as email or password? What if you log URL's for your private API, or details on your backend service? When you use UALogger, you won't print these logs to the system console in production, protecting yourself and your users.

##### Give Better Support

UALogger lets you get all of the logs written by your app to the system log. In our flagship app [Ambiance](http://ambianceapp.com), we use this to help debug tough customer issues. If a customer contacts us with an issue that we can't figure out, we ask them to turn on logging for Ambiance via a switch in the App settings, try to reproduce the problem, then send us the log via an in-app button.

##### Logging Severity Levels

UALogger allows you to use severity levels when logging such that only the important logs get through. This is useful for logging sever errors and critical messages in production.

## Installation

Installation is made simple with [Cocoapods](http://cocoapods.org/). If you want to do it the old fashioned way, just add `UALogger.h` and `UALogger.m` to your project.

    pod 'UALogger', '~> 0.2.3'

Then, simply place this line in your `prefix.pch` file to access the logger from all of your source files.

    #import <UALogger.h>




## Usage

#### Macros

`UALogBasic` logs just like `NSLog`, but also logs the file name and line number.

    UALogBasic(@"Foobar");
    => <UAViewController.m:27> Foobar

`UALogFull` logs the calling object (self), the file name, the line number and the method name.

    UALogFull(@"Foobar");
    => <0xb26b730 UAViewController.m:28 (viewDidLoad)> Foobar

`UALogPlain` logs to the console exactly like NSLog, with no additional information.

    UALogPlain(@"Foobar");
    => Foobar

`UALog` is shorthand for `UALogBasic`.

One easy way to use `UALogger` is to do a project-wide find and replace for `NSLog`, and change it to `UALog`.

    UALog(@"This used to be an NSLog()");
    => <UAViewController.m:27> This used to be an NSLog()


#### Customization

`UALog` is setup by default to call `UALogBasic`, but you can change that by adding this to your code immediately after the `#import <UALogger.h>` in your `prefix.pch` file:

	#import <UALogger.h>
	#undef UALog;
	#define UALog( s, ... ) UALogPlain( s, ##__VA_ARGS__ );

or
	
    #import <UALogger.h>
    #undef UALog;
	#define UALog( s, ... ) UALogFull( s, ##__VA_ARGS__ );


`UALogger` will work seamlessly alongside of `NSLog`, however, if you set a Preprocessor Macro called `UALOGGER_SWIZZLE_NSLOG`, you can use UALogger without changing any of your code.

	
	NSLog(@"This NSLog call is actually routing through UALogger.");
	=> <0xb26b730 UAViewController.m:28 (viewDidLoad)> This NSLog call is actually routing through UALogger.

Only calls made to `NSLog` from files in your app that have imported `UALogger.h` will route through UALogger. If you imported UALogger in your `prefix.pch`, then that means all of them.


#### UALogger Class Methods

Even though it makes life easier, you don't _have_ to use any of the `UALogger` macros to use `UALogger`. You can log anything with a simple call:

	[UALogger log:@"I am logging now: %@", [NSDate date]];
	=> I am logging now: 2013-09-02 12:42:31 +0000


Note that logging this way does not prepend any of the additional information. This is because there is no way to know the calling filename and log line, method name etc… from within the `UALogger` class. The macros do know this information though, and it is advised that you use them to maximize the benefit of UALogger.

If you just want to change the way the log looks, you can customize the format of the `UALogPlain`, `UALogBasic` and `UALogFull` calls simply by changing the format string at runtime:

    [UALogger setFormat:@"Foobar! %@" forVerbosity:UALoggerVerbosityPlain];
    UALogPlain(@"Barfoo%@?", @"d");
    => Foobar! Barfood?

Then all subsequent log calls for that verbosity will use that format. Take a look at the `setupDefaultFormats` method for more info on the default formats and what variables they expect in what order. If you want to reset the format, call

	[UALogger resetDefaultLogFormats];

#### Production Logging

By default UALogger will log in Debug environments and not in Production. It determines this by the presence of the Preprocessor Macro `DEBUG`, which is added to every Xcode project by default. The rules it uses to determine if it __should log__ to the console are:


- It __is not__ a production build and `shouldLogInDebug` is true __OR__
- It __is__ a production build and `shouldLogInProduction` is true __OR__
- The NSUserDefaults key for logging is true.


You can query these values and set some of them at runtime.

`[+ isProduction]` returns true if the `DEBUG` macro is __NOT__ found on compilation.

    BOOL isProduction = [UALogger isProduction];
    
`[+ shouldLogInProduction]` is set to `NO` by default, but can be set otherwise:

    BOOL shouldLogInProduction = [UALogger shouldLogInProduction];
    if (shouldLogInProduction)
        [UALogger setShouldLogInProduction:NO];

`[+ shouldLogInDebug]` is set to `YES` by default, but can be set otherwise:

    BOOL shouldLogInDebug = [UALogger shouldLogInDebug];
    if (!shouldLogInDebug)
        [UALogger setShouldLogInDebug:YES];

`[+ userDefaultsKey]` is the key used to look for manual log overrides. The most common usage of this is to hook up a toggle switch in your App's settings that turns on logging. By default, this key is set as `UALogger_LoggingEnabled`, but can be set to anything you want that returns a `BOOL`.

    NSString *userDefaultsKey = [UALogger userDefaultsKey];
    if ([userDefaultsKey isEqualToString:UALogger_LoggingEnabled])
        [UALogger setUserDefaultsKey:@"CustomizedUserDefaultsKey"];

An example of when you may want to change this value is if you want to log when a certain feature is enabled — say you have a fancy, but beta, feature X;
	
	BOOL featureXIsEnabled = [[NSUserDefaults standardDefaults] boolForKey:@"featureXIsEnabled"];
    [UALogger setUserDefaultsKey:@"featureXIsEnabled"];

Setting the logger to use the same key means that when the feature is on, logging will happen.

`[+ loggingEnabled]` is the method UALogger uses to determine whether or not it should log a line. It uses the above algorithm and methods to return a simple `BOOL`.

    BOOL loggingEnabled = [UALogger loggingEnabled];


#### Using Log Severity Levels

UALogger can also be setup to work with log severity levels. Each of the three logging macros (`UALogPlain`, `UALogBasic`, and `UALogFull`) have a variation that lets you pass in a `UALoggerSeverity`:

 - `UASLogPlain`
 - `UASLogBasic`
 - `UASLogFull`
 - `UASLog` // Defaults to UASLogBasic

The `S` stands for severity, and is the first argument in those functions. UALogger recognizes 5 severities:

 - `UALoggerSeverityDebug` // Lowest log level
 - `UALoggerSeverityInfo`
 - `UALoggerSeverityWarn`
 - `UALoggerSeverityError`
 - `UALoggerSeverityFatal` // Highest Log Level


To use the severity levels, you **MUST** set a minimumSeverity for UALogger to use:

    [UALogger setMinimumSeverity:UALoggerSeverityWarn];
    
By default, the severity is `UALoggerSeverityUnset` and thus, not used for determining when to log. When unset, the `[UALogger loggingEnabled]` method is used. Once you set the `minimumSeverity` to something else however, **ONLY** the verbosity will be used to determine when to log.

Example:

	[UALogger setMinimumSeverity:UALoggerSeverityWarn];
    UASLog(UALoggerSeverityDebug,	@" - Logged with severity => UALoggerSeverityDebug");
	UASLog(UALoggerSeverityInfo,	@" - Logged with severity => UALoggerSeverityInfo");
	UASLog(UALoggerSeverityWarn,	@" - Logged with severity => UALoggerSeverityWarn");
	UASLog(UALoggerSeverityError,	@" - Logged with severity => UALoggerSeverityError");
	UASLog(UALoggerSeverityFatal,	@" - Logged with severity => UALoggerSeverityFatal");
	UASLog(UALoggerSeverityFatal,	@" - Only 3 of the above lines are logged because they meet or exceed the minimumSeverity (UALoggerSeverityWarn)");

After setting the `minimumSeverity`, any calls made to the non-`S` functions will not log unless you unset it.

	[UALogger setMinimumSeverity:UALoggerSeverityDebug];
    UALog(@"This will not log.");
    UASLog(UALoggerSeverityDebug, @"This will log.");
    
    [UALogger setMinimumSeverity:UALoggerSeverityUnset];
    UALog(@"This will log.");
    UASLog(UALoggerSeverityDebug, @"This will log, and the severity ignored");


#### Recent Console Log Collecting

One of the more useful features of `UALogger` is to grab the recent log entries from the console. To do this, simply call:

    [UALogger applicationLog];

It can be useful to automatically append to support emails that originate from within your app.

    NSString *log = [UALogger applicationLog];
    NSData *data = [log dataUsingEncoding:NSUTF8StringEncoding];
    [mailComposeViewController addAttachmentData:data mimeType:@"text/plain" fileName:@"ApplicationLog.txt"];

The `applicationLog` method is synchronous and can take while, so there is also an asynchronous block based method with an onComplete callback:

    [UALogger getApplicationLog:^(NSArray *logs){
        for (NSString *log in logs) {
            // Do something awesome"
        }
    }];

Remember that it only finds entries that were written to the console log, so if you don't have logging enabled, it will not return any lines. It is able to check the entire console log, but is not able to look at previous logs once the file's have been turned over. For normal usage you can usually grab a day or so of log entries.


## Example Project
Check out the example project to see how to use UALogger, how to setup a toggle switch to turn on/off logging in the wild, and how to attach the application log to an email.


## What's Planned?

There are some ideas we have for future versions of UALogger. Feel free to fork/implement if you would like to expedite the process.

- Add some sort of optional log priority system like `error`, `critical`, `warning` etc… We could then set a threshold to log and everything that meets or exceeds that threshold in severity would be logged. This allows the log printing to be data driven. Something like `UALog(UALoggerSeverityCritical, @"Error: %@", [error localizedDescription]`;
-  Investigate whether or not it is worth it to [log messages using the ASL API](https://developer.apple.com/library/mac/documentation/MacOSX/Conceptual/BPSystemStartup/Chapters/LoggingErrorsAndWarnings.html#//apple_ref/doc/uid/10000172i-SW8-SW6). 
-  Implement [ASL logging](https://developer.apple.com/library/mac/documentation/MacOSX/Conceptual/BPSystemStartup/Chapters/LoggingErrorsAndWarnings.html#//apple_ref/doc/uid/10000172i-SW8-SW6) if there are clear benefits.
-  [Your idea](https://github.com/coneybeare/UALogger/issues).

## Bugs / Pull Requests
Let us know if you see ways to improve `UALogger` or see something wrong with it. We are happy to pull in pull requests that have clean code, and have features that are useful for most people.

## What's With the Lumberjack?
Screenshots are cool. Screenshots of log consoles are not cool. Pictures of lumberjacks are cool.


## What Does UA stand for?
[Urban Apps](http://urbanapps.com). We make neat stuff. Check us out.


## Open-Source Urban Apps Projects

- [UAModalPanel](https://github.com/coneybeare/UAModalPanel) - An animated modal panel alternative for iOS
- [UAAppReviewManager](https://github.com/coneybeare/UAAppReviewManager) - An app review prompting tool for iOS and Mac App Store apps.


## Feeling Generous?

If you want to thank us for open-sourcing UALogger, you can [buy one of our apps](http://itunes.com/apps/urbanapps?at=11l7j9&ct=github) or even donate something small.

<a href='http://www.pledgie.com/campaigns/21745'><img alt='Click here to lend your support to: Support UALogger Development and make a donation at www.pledgie.com !' src='http://www.pledgie.com/campaigns/21745.png?skin_name=chrome' border='0' /></a>

[![Bitdeli Badge](https://d2weczhvl823v0.cloudfront.net/coneybeare/ualogger/trend.png)](https://bitdeli.com/free "Bitdeli Badge")

