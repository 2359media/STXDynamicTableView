//
//  UALogger.h
//
//  Created by Matt Coneybeare on 09/1/13.
//  Copyright (c) 2013 Urban Apps, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
	UALoggerVerbosityNone = 0,
	UALoggerVerbosityPlain,
	UALoggerVerbosityBasic,
	UALoggerVerbosityFull
} UALoggerVerbosity;

typedef enum {
	UALoggerSeverityUnset = 0,		// Unset means it is not factored in on the decision to log, defaulting to the production vs debug and user overrides.
	UALoggerSeverityDebug,			// Lowest log level
	UALoggerSeverityInfo,
	UALoggerSeverityWarn,
	UALoggerSeverityError,
	UALoggerSeverityFatal			// Highest log level
} UALoggerSeverity;


#define UASLogFull( s, f, ... )	[UALogger logWithVerbosity:UALoggerVerbosityFull\
												  severity:s\
												formatArgs:@[\
															self,\
															[[NSString stringWithUTF8String:__FILE__] lastPathComponent],\
															[NSNumber numberWithInt:__LINE__],\
															NSStringFromSelector(_cmd),\
															[NSString stringWithFormat:(f), ##__VA_ARGS__]\
															]\
								]

#define UASLogBasic( s, f, ... ) [UALogger logWithVerbosity:UALoggerVerbosityBasic\
												   severity:s\
												 formatArgs:@[\
															 [[NSString stringWithUTF8String:__FILE__] lastPathComponent],\
															 [NSNumber numberWithInt:__LINE__],\
															 [NSString stringWithFormat:(f), ##__VA_ARGS__]\
															 ]\
								 ]

#define UASLogPlain( s, f, ... ) [UALogger logWithVerbosity:UALoggerVerbosityPlain\
												   severity:s\
												 formatArgs:@[\
															 [NSString stringWithFormat:(f), ##__VA_ARGS__]\
															]\
								 ]

#define UALogFull( format, ... )			UASLogFull( UALoggerSeverityUnset, format, ##__VA_ARGS__ )
#define UALogBasic( format, ... )			UASLogBasic( UALoggerSeverityUnset, format, ##__VA_ARGS__ )
#define UALogPlain( format, ... )			UASLogPlain( UALoggerSeverityUnset, format, ##__VA_ARGS__ )

#define UALog( format, ... )				UALogBasic( format, ##__VA_ARGS__ )
#define UASLog( severity, format, ... )		UASLogBasic( severity, format, ##__VA_ARGS__ )

#ifdef UALOGGER_SWIZZLE_NSLOG
#define NSLog( s, ... )		UALog( s, ##__VA_ARGS__ )
#endif

// This is just convenience
#define NSStringFromBool(b) (b ? @"YES" : @"NO")

static NSString * const UALogger_LoggingEnabled = @"UALogger_LoggingEnabled";	// This is the default NSUserDefaults key

@interface UALogger : NSObject
	
	
+ (NSString *)formatForVerbosity:(UALoggerVerbosity)verbosity;	// Returns the format string for the verbosity. See [+ initialize] for defaults
+ (void)setFormat:(NSString *)format							// Overrides the default formats for verbosities.
	 forVerbosity:(UALoggerVerbosity)verbosity;
+ (void)resetDefaultLogFormats;									// Resets the formats back to UALogger defaults
	
+ (void)setMinimumSeverity:(UALoggerSeverity)severity;
+ (UALoggerSeverity)minimumSeverity;							// Defaults to UALoggerSeverityUnset (not used in determining whether or not to log)
+ (BOOL)usingSeverityFiltering;									// Yes if minimumSeverity has been set.
+ (BOOL)meetsMinimumSeverity:(UALoggerSeverity)severity;		// Yes if severity is greater than or equal to minimumSeverity
	
+ (BOOL)isProduction;											// Returns YES when DEBUG is not present in the Preprocessor Macros
+ (BOOL)shouldLogInProduction;									// Default is NO.
+ (BOOL)shouldLogInDebug;										// Default is YES.
+ (BOOL)userDefaultsOverride;									// Default is NO. Cached BOOL of the userDefaultsKey
+ (void)setShouldLogInProduction:(BOOL)shouldLogInProduction;
+ (void)setShouldLogInDebug:(BOOL)shouldLogInDebug;
+ (void)setUserDefaultsOverride:(BOOL)userDefaultsOverride;
+ (BOOL)loggingEnabled;											// returns true if (not production and shouldLogInDebug) OR (production build and shouldLogInProduction) or (userDefaultsOverride == YES)
	
+ (NSString *)userDefaultsKey;									// Default key is UALogger_LoggingEnabled
+ (void)setUserDefaultsKey:(NSString *)userDefaultsKey;
	
+ (void)log:(NSString *)format, ...;							// Logs a format, and variables for the format.
	
+ (void)logWithVerbosity:(UALoggerVerbosity)verbosity			// Logs a preset format based on the vspecified verbosity, and variables for the format.
				severity:(UALoggerSeverity)severity
			  formatArgs:(NSArray *)args;
	
+ (NSString *)bundleName;										// Default is CFBundleName
+ (void)setBundleName:(NSString *)bundleName;
+ (void)getApplicationLog:(void (^)(NSArray *logs))onComplete;	// Gets the recent log entries written to the console on a background thread, then calls the completion block
+ (NSString *)applicationLog;									// Gets the recent log entries written to the console, may take a long time.
	
	
	@end
