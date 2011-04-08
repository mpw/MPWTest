/* MPWTestCase.m Copyright (c) 1998-1999 by Marcel Weiher, All Rights Reserved, created  on Thu 27-Aug-1998 */

#import "MPWTestCase.h"
#import "MPWTestResults.h"
#import "NSObjectTestingSupport.h"
#import "MPWTestAssertionHandler.h"
@implementation MPWTestCase

-initWithClass:(Class)classToTest testName:testName arguments:args
{
	NSString *msg = @"Couldn't get test case for %@/%@:%@";
    self = [super init];
    NS_DURING
        testClass = classToTest;
        name = [testName retain];
        arguments=[args retain];
        fixture = [[classToTest testFixture] retain];
    NS_HANDLER
//        NSLog(msg,NSStringFromClass( classToTest ),name,[localException reason]);
        [self release];
        return nil;
    NS_ENDHANDLER
    return self;
}

-initWithClass:(Class)classToTest testName:testName
{
    return [self initWithClass:classToTest testName:testName arguments:nil];

}

-(void)setup
{
    ;
}
-(void)doTest
{
    [fixture doTest:name withTest:self];
}

-(void)cleanup
{
    
}

-(void)reportFailure:aFailure inResults:testResults
{
	[testResults addFailure:aFailure];
}

-(void)runTest:testResults
{
    id pool=[[NSAutoreleasePool alloc] init];
    id oldAssertionhandler=[[[[NSThread currentThread] threadDictionary] objectForKey:@"NSAssertionHandler"] retain];
    [testResults beginTest:self];
    [testResults noteTest];
    
    [[[NSThread currentThread] threadDictionary] setObject:[MPWTestAssertionHandler assertionHandlerWithTester:testResults] forKey:@"NSAssertionHandler"];
    NS_DURING
        [self setup];
        [self doTest];
        [testResults addSuccess:self];
    NS_HANDLER
		[self reportFailure:localException inResults:testResults];
    NS_ENDHANDLER
//	NSLog(@"start handler");
	if ( oldAssertionhandler ) {
		[[[NSThread currentThread] threadDictionary] setObject:oldAssertionhandler forKey:@"NSAssertionHandler"];
	} else {
		[[[NSThread currentThread] threadDictionary] removeObjectForKey:@"NSAssertionHandler"];
	}
    [oldAssertionhandler release];
    [self cleanup];
    [testResults endTest:self];
    [pool release];
}

-name
{
    return name;
}

-description
{
    return [self name];
}

-(int)numberOfTests
{
    return 1;
}

-(void)dealloc
{
    [name release];
    [arguments release];
    [fixture release];
    [super dealloc];
}

@end
