//
// (C) Copyright Tilo Prütz
//

#include "TClassMockInjectionTest.h"

#pragma .h #include <TUnit/TUnit.h>

#pragma .h @class TMockTestClass;

#include "TMockTestClass.h"


@implementation TClassMockInjectionTest:TTestCase
{
    Class _class;
}


- (void)prepare
{
    _class = [TMockTestClass class];
}


- (void)testNormalClassMockingAMessageReturnsMockedValueOnMockedCall
{
    // normales Verhalten sicherstellen
    ASSERTEQUALSINT(7, [_class testClassMethod: 3]);
    [(Class)[[_class mock] testClassMethod: 3] andReturnInt: 666];
    ASSERTEQUALSINT(666, [_class testClassMethod: 3]);
}


- (void)testNormalClassMockingAMessageReturnsToNormalBehaviourAfterReceivingMockedCall
{
    [(Class)[[_class mock] testClassMethod: 3] andReturnInt: 666];
    [_class testClassMethod: 3];
    ASSERTEQUALSINT(7, [_class testClassMethod: 3]);
}


- (void)testVoidMethodCanBeMocked
{
    [[_class mock] voidClassMethod];
    [_class voidClassMethod];
}


- (void)testIntMethodCanBeMocked
{
    [(id)[[_class mock] intClassMethod] andReturnInt: 666];
    ASSERTEQUALSINT(666, [_class intClassMethod]);
}


- (void)testPointerMethodCanBeMocked
{
    const char *wert = "hallo";
    [(id)[[_class mock] pointerClassMethod] andReturn: wert];
    ASSERT(wert == [_class pointerClassMethod]);
}


- (void)testBoolMethodCanBeMocked
{
    BOOL wert = YES;
    [[_class mock] boolClassMethod];
    [_class returnBool: wert];
    ASSERT(wert == [_class boolClassMethod]);

    wert = NO;
    [[_class mock] boolClassMethod];
    [_class returnBool: wert];
    ASSERT(wert == [_class boolClassMethod]);

    wert = YES;
    [[_class mock] boolClassMethod];
    [_class andReturnBool: wert];
    ASSERT(wert == [_class boolClassMethod]);

    wert = NO;
    [[_class mock] boolClassMethod];
    [_class andReturnBool: wert];
    ASSERT(wert == [_class boolClassMethod]);
}


// FIXME andere typen unterstützen


- (void)testMockingAccountsForMethodsArguments
{
    [[[_class mock] classMethodReturningArgument: @"du da"] andReturn: @"ist da wer?"];
    ASSERTEQUALS(@"Hallo", [_class classMethodReturningArgument: @"Hallo"]);
    ASSERTEQUALS(@"ist da wer?", [_class classMethodReturningArgument: @"du da"]);
}


- (void)testStubbingAMethodLastsForever
{
    [(id)[[_class stub] testClassMethod: 3] andReturnInt: 666];
    ASSERTEQUALSINT(666, [_class testClassMethod: 3]);
    ASSERTEQUALSINT(666, [_class testClassMethod: 3]);
    ASSERTEQUALSINT(666, [_class testClassMethod: 3]);
    ASSERTEQUALSINT(666, [_class testClassMethod: 3]);
}


- (void)testMockCountCanBeSet
{
    [[(id)[[_class mock] testClassMethod: 3] andReturnInt: 666] receiveTimes: 3];
    ASSERTEQUALSINT(666, [_class testClassMethod: 3]);
    ASSERTEQUALSINT(666, [_class testClassMethod: 3]);
    ASSERTEQUALSINT(666, [_class testClassMethod: 3]);
    ASSERTEQUALSINT(7, [_class testClassMethod: 3]);
}


- (void)testMockedMethodCanThrowException
{
    BOOL exceptionCaught = NO;
    [[[_class mock] classMethodReturningArgument: _class] andThrow: @"anException"];
    @try {
        [_class classMethodReturningArgument: _class];
    } @catch (id e) {
        ASSERTEQUALS(@"anException", [e autorelease]);
        exceptionCaught = YES;
    }
    ASSERT(exceptionCaught);
}


- (void)testVerifyAndCleanupMocksShouldRaiseAnExceptionIfNotAllMockedMethodsWereCalled
{
    [(id)[[_class mock] testClassMethod: 3] andReturnInt: 666];
    [[[_class mock] classMethodReturningArgument: _class] andReturn: @"hui"];
    [_class testClassMethod: 3];
    BOOL exceptionCaught = NO;
    @try {
        verifyAndCleanupMocks();
    } @catch (TTestException *e) {
        [e autorelease];
        exceptionCaught = YES;
    }
    ASSERT(exceptionCaught);
}


- (void)testVerifyAndCleanupMocksShouldNotRaiseAnExceptionIfAllMockedMethodsWereCalled
{
    [(id)[[_class mock] testClassMethod: 3] andReturnInt: 666];
    [[[_class mock] classMethodReturningArgument: _class] andReturn: @"hui"];
    [_class testClassMethod: 3];
    [_class classMethodReturningArgument: _class];
    verifyAndCleanupMocks();
}


- (void)testVerifyAndCleanupMocksShouldNotRaiseAnExceptionIfAllMockedMethodsWereStubbed
{
    [(id)[[_class stub] testClassMethod: 3] andReturnInt: 666];
    [[[_class stub] classMethodReturningArgument: _class] andReturn: @"hui"];
    verifyAndCleanupMocks();
}


- (void)testStubbedMethodsShouldBeRemovedAfterVerifyAndCleanupMocks
{
    [(id)[[_class stub] testClassMethod: 3] andReturnInt: 666];
    [[[_class stub] classMethodReturningArgument: _class] andReturn: @"hui"];
    verifyAndCleanupMocks();
    ASSERTEQUALSINT(7, [_class testClassMethod: 3]);
    ASSERTEQUALS(_class, [_class classMethodReturningArgument: _class]);
}


- (void)testShouldReceiveMocksMethodAndThrowsExceptionIfMethodIsCalledToOften
{
    [[[_class shouldReceive] classMethodReturningArgument: @"hallo"] andReturn: @"du da"];
    ASSERTEQUALS(@"du da", [_class classMethodReturningArgument: @"hallo"]);
    FAIL([_class classMethodReturningArgument: @"hallo"]);
}


- (void)testMethodMockedViaShouldReceiveThrowsExceptionIfArgumentIsWrong
{
    [[[_class shouldReceive] classMethodReturningArgument: @"hallo"] andReturn: @"du da"];
    FAIL([_class classMethodReturningArgument: @"falscher parameter"]);
    [_class classMethodReturningArgument: @"hallo"];
}


@end

