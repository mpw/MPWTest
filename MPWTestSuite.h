/* MPWTestSuite.h Copyright (c) 1998-1999 by Marcel Weiher, All Rights Reserved, created  on Thu 27-Aug-1998 */

#import <Foundation/Foundation.h>

@interface MPWTestSuite : NSObject
{
    NSArray* testCases;
    NSString* name;
	id testTypes;
}

+testSuiteWithName:aName classMirrors:(NSArray*)classMirrors testTypes:testTypeNames;
+testSuiteWithName:aName testCases:cases;
+testSuiteForLocalFramework:(NSString*)frameworkName testTypes:testTypeNames;

-(void)runTest:testResults;
-(int)numberOfTests;
//-testTypes;
//-setTestTypes:newTestTypes;
-(void)listInto:(NSMutableArray*)result;
-(NSString*)name;

@end
