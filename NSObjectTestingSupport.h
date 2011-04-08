/* NSObjectTestingSupport.h Copyright (c) 1998-1999 by Marcel Weiher, All Rights Reserved, created  on Thu 27-Aug-1998 */

#import <Foundation/Foundation.h>
#import "MPWTestCase.h"

@interface NSObject(TestingSupport)

+testClass;
+testFixture;
+testSelectors;
-(void)doTest:(NSString*)testName withTest:test;

@end
