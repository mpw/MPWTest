//
// (C) Copyright Tilo Prütz
//

#include "TTestCaseTest.h"

#define A(args...) ((NSArray *)[NSArray arrayWithObjects: args, nil])
#define I(num)     ([NSNumber numberWithInt:(num)])

@implementation TTestCaseTest:TTestCase
{
}


- (void)testAssertListsContentsEqualDoesNotFailOnListsWithEqualElements
{
    ASSERTLISTCONTENTSEQUAL(A(@"a", I(123), @"z"), A(@"z", @"a", I(123)));
}


- (void)testAssertListsContentsEqualDoesFailsIfListsContentsDiffer
{
    FAIL(ASSERTLISTCONTENTSEQUAL(A(@"a", I(123)), A(@"z", @"a", I(123))));
    FAIL(ASSERTLISTCONTENTSEQUAL(A(@"a", I(123), @"z"), A(@"z", @"a")));
}


@end

