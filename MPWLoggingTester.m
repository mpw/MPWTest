/* MPWLoggingTester.m Copyright (c) 1998-1999 by Marcel Weiher, All Rights Reserved, created  on Thu 27-Aug-1998 */

#import "MPWLoggingTester.h"
#import "MPWTestCase.h"

@implementation MPWLoggingTester

-(void)setVerbose:(BOOL)n
{
    verbose=n;
}
-(BOOL)verbose
{
    return verbose;
}

-(void)addFailure:aFailure
{
    [super addFailure:aFailure];
    if ( verbose ) {
        fprintf(stderr, "\033[1;32mfailed: %s : %s\033[1;0m\n",[[self currentTestDescription] UTF8String],[[aFailure description] UTF8String]);
    }
}

-(void)addSuccess:aSuccess
{
    [super addSuccess:aSuccess];
    if ( verbose ) {
        fprintf(stderr, "success:%s : %s\n",[[self currentTestDescription] UTF8String],[[aSuccess description] UTF8String]);
    }
    //
}

-(void)beginTest:aTest
{
    if ( verbose && [aTest isKindOfClass:[MPWTestCase class]] ) {
        fprintf(stderr,"start: %s : %s\n",[[self currentTestDescription] UTF8String],[[aTest description] UTF8String]);
    }
    [super beginTest:aTest];
//    NSLog(@"Test: %@",[currentTest componentsJoinedByString:@":"]);
}

@end
