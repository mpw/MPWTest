/* MPWTestResults.m Copyright (c) 1998-1999 by Marcel Weiher, All Rights Reserved, created  on Thu 27-Aug-1998 */

#import "MPWTestResults.h"
//#import <ExceptionHandling/ExceptionHandling.h>

@implementation MPWTestResults

-init
{
    self = [super init];
    failures=[[NSMutableArray alloc] init];
    errors=[[NSMutableArray alloc] init];
    successes=[[NSMutableArray alloc] init];
    currentTest=[[NSMutableArray alloc] init];
    return self;
}

-(void)addError:aFailure
{
	[self printStackTrace:aFailure];
    [failures addObject:[NSString stringWithFormat:@"tests:1: %@ in %@",aFailure,[self currentTestDescription]]];
}


-(void)addFailure:aFailure
{
	if ( [[aFailure name] isEqual:@"MPWTestFailedException"]) {
		
		[failures addObject:[NSString stringWithFormat:@"%@ : %@",aFailure,[self currentTestDescription]]];
	} else {
		[self addError:aFailure];
	}
}

//extern NSString *NSStackTraceKey;

- (void)printStackTrace:(NSException *)e
{
    NSString *stack = nil; // [[e userInfo] objectForKey:NSStackTraceKey];
//    NSString *stack =[[e userInfo] objectForKey:NSStackTraceKey];
    if (stack) {
        NSTask *ls = [[NSTask alloc] init];
        NSString *pid = [[NSNumber numberWithInt:[[NSProcessInfo processInfo] processIdentifier]] stringValue];
        NSMutableArray *args = [NSMutableArray arrayWithCapacity:20];
		
        [args addObject:@"-p"];
        [args addObject:pid];
        [args addObjectsFromArray:[stack componentsSeparatedByString:@"  "]];
        // Note: function addresses are separated by double spaces, not a single space.
		
        [ls setLaunchPath:@"/usr/bin/atos"];
        [ls setArguments:args];
        [ls launch];
        [ls release];
		
    } else {
        NSLog(@"No stack trace available.");
    }
}

-(void)addSuccess:aSuccess
{
    [successes addObject:[NSString stringWithFormat:@"%@ : %@",[self currentTestDescription],aSuccess]];
}
-(void)beginTest:aTest
{
    [currentTest addObject:aTest];
}

-(void)addToTotalTests:(int)numberOfTests
{
	totalTestsToRun+=numberOfTests;
}

-(void)noteTest
{
    totalExecutedTests++;
}

-(void)endTest:aTest
{
    [currentTest removeLastObject];
}

-(int)successCount 
{
	return [successes count];
}

-(int)failureCount
{
    return [failures count];
}

-(float)percentSucces
{
    if ( totalTestsToRun > 0 ) {
        return (float)([successes count])*100.0/totalTestsToRun;
    } else {
        return 0.0;
    }
}

-(BOOL)allOk
{
    return [failures count]==0;
}

-(void)printResults
{
	if ( [self allOk] ) {
		fprintf(stderr, "\033[91;32m" );
	} else {
		fprintf(stderr, "\033[91;31m" );
	}
    fprintf(stderr,"tests:1:%s %d tests (of %d) executed, %d failures (%g %% success rate)\n",([self failureCount]==0 ? " warning: " :" error:"),[self successCount], totalTestsToRun,[self failureCount],[self percentSucces]);
    if ( ![self allOk] ) {
        int i;
        fprintf(stderr,"failures:\n");
        for (i=0;i<[self failureCount];i++) {
            fprintf(stderr,"%s\n",[[failures objectAtIndex:i] UTF8String]);
        }
    }
	fprintf(stderr, "\033[0m" );
}

-(void)printAllResults
{
    [self printResults];
    NSLog(@"successes: %@",successes);
}

-(NSString*)currentTestDescription
{
    return [currentTest componentsJoinedByString:@":"];
}

@end
