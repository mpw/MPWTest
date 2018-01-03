/* NSObjectTestingSupport.m Copyright (c) 1998-1999 by Marcel Weiher, All Rights Reserved, created  on Thu 27-Aug-1998 */

#import "NSObjectTestingSupport.h"

@implementation NSObject(TestingSupport)

+testClass
{
    return [MPWTestCase class];
}

+testFixture
{
    return self;
}

+testSelectors
{
    return [NSArray array];
}

-(void)doTest:(NSString*)testName withTest:test
{
    SEL testMethod=NSSelectorFromString(testName);

    if ( testMethod &&  [self respondsToSelector:testMethod] ) {
        [self performSelector:testMethod];
    } else {
        [NSException raise:@"test-inconsistency" format:@"error: fixture %@ doesn't respond to test message %@ for test %@",self,testName,[test description]];
    }
}

@end

//#ifdef Darwin

@implementation NSProxy(TestSupport)

+testSelectors
{
    return [NSArray array];
}

+testClass
{
    return [MPWTestCase class];
}

+testFixture
{
    return self;
}

+(void)doTest:(NSString*)testName withTest:test
{
    SEL testMethod=NSSelectorFromString(testName);
    if ( testMethod ) {
        [self performSelector:testMethod];
    } else {
        [NSException raise:@"test-inconsistency" format:@"fixture %@ doesn't respond to test message %@ for test %@",self,NSStringFromSelector(testMethod),[test description]];
    }
}

-(void)doTest:(NSString*)testName withTest:test
{
    SEL testMethod=NSSelectorFromString(testName);
    if ( testMethod ) {
        [self performSelector:testMethod];
    } else {
        [NSException raise:@"test-inconsistency" format:@"fixture %@ doesn't respond to test message %@ for test %@",self,NSStringFromSelector(testMethod),[test description]];
    }
}


@end

//#endif

