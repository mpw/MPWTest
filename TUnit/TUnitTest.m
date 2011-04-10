//
// (C) Copyright Tilo Prütz
//

#include "TUnitTest.h"

//#pragma .h #include <TUnit/TUnit.h>


@implementation TUnitTest:TTestCase
{
}


- (void)testAssertions
{
    ASSERTEQUALS(@"0", @"0");
    ASSERTEQUALS(@"", @"");
    ASSERTEQUALS(nil, nil);
    FAIL(ASSERTEQUALS(@"0", @"1"));
    FAIL(ASSERTEQUALS(@"", @"0"));
    FAIL(ASSERTEQUALS(nil, @"0"));
    FAIL(ASSERTEQUALS(@"0", nil));
    FAIL(ASSERTEQUALS(@"", nil));
    FAIL(ASSERTEQUALS(nil, @""));
    ASSERT(0 == 0);
    FAIL(ASSERT(0 != 0));
}


@end

