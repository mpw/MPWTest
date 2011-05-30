/* MPWTestSuite.h Copyright (c) 1998-1999 by Marcel Weiher, All Rights Reserved, created  on Thu 27-Aug-1998 */

#import <Foundation/Foundation.h>

@interface MPWTestSuite : NSObject
{
    id testCases;
    id name;
	id testTypes;
}

+testSuiteWithName:aName classMirrors:(NSArray*)classMirrors;

-(void)runTest:testResults;
-(int)numberOfTests;
-testTypes;
-setTestTypes:newTestTypes;


@end
