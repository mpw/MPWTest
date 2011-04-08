/* MPWTestResults.h Copyright (c) 1998-1999 by Marcel Weiher, All Rights Reserved, created  on Thu 27-Aug-1998 */

#import <Foundation/Foundation.h>

@interface MPWTestResults : NSObject
{
    id	failures;
    int	totalExecutedTests;
	int	totalTestsToRun;
    id	successes;
    id	errors;
    id  currentTest;
}

-(void)addFailure:aFailure;
-(void)addSuccess:aSuccess;
-(void)beginTest:aTest;
-(void)endTest:aTest;
-(void)noteTest;
-(void)printResults;
-(void)printAllResults;
-(int)numFailures;


@end
