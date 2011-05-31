 /* MPWTestCase.h Copyright (c) 1998-1999 by Marcel Weiher, All Rights Reserved, created  on Thu 27-Aug-1998 */

#import <Foundation/Foundation.h>

@interface MPWTestCase : NSObject
{
    Class	testClass;
    id		name;
    id		arguments;
    id		fixture;
}

-(void)setup;
-(void)doTest;
-(void)cleanup;
-(void)runTest:testResults;

@end
