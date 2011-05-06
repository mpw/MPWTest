//
// (C) Copyright Tilo Prütz
//

#include "TObjectMockInjectionTest.h"

#pragma .h #include <TUnit/TUnit.h>

#pragma .h @class TMockTestClass;

#include "TMockTestClass.h"

#import <objc/objc-runtime.h>

#define TUNIT_UNLIMITEDCALLCOUNT -1

@implementation TObjectMockInjectionTest:TTestCase
{
    TMockTestClass *_obj;
}


- (void)prepare
{
    _obj = [[[TMockTestClass alloc] init] autorelease];
}


- (void)testNormalObjectMockingAMessageReturnsMockedValueOnMockedCall
{
    // normales Verhalten sicherstellen
    ASSERTEQUALSINT(6, [_obj testMethod: 3]);
    [(id)[[_obj stub] 
			testMethod: 3] 
			andReturnInt: 666];
	NSLog(@"class of _obj: %@",NSStringFromClass(object_getClass(_obj)));
	NSLog(@"did prime, will test return");
    ASSERTEQUALSINT(666, [_obj testMethod: 3]);
}


- (void)_disabled_testNormalObjectMockingAMessageReturnsToNormalBehaviourAfterReceivingMockedCall
{
    [(id)[[_obj shouldReceive] testMethod: 3] andReturnInt: 666];
    [_obj testMethod: 3];
    ASSERTEQUALSINT(6, [_obj testMethod: 3]);
}


- (void)testVoidMethodCanBeMocked
{
    [[_obj shouldReceive] voidMethod];
    [_obj voidMethod];
}


- (void)testIntMethodCanBeMocked
{
	[[_obj shouldReceive] intMethod];
    [_obj andReturnInt: 666];
    ASSERTEQUALSINT(666, [_obj intMethod]);
}




#if 0

- (void)testStubbingAMethodLastsForever
{
    [(id)[[_obj stub] testMethod: 3] andReturnInt: 666];
    ASSERTEQUALSINT(666, [_obj testMethod: 3]);
    ASSERTEQUALSINT(666, [_obj testMethod: 3]);
    ASSERTEQUALSINT(666, [_obj testMethod: 3]);
    ASSERTEQUALSINT(666, [_obj testMethod: 3]);
}



- (void)testBoolMethodCanBeMocked
{
    BOOL wert = YES;
    [[_obj stub] boolMethod];
    [_obj returnBool: wert];
    ASSERT(wert == [_obj boolMethod]);
	
    wert = NO;
    [[_obj stub] boolMethod];
    [_obj returnBool: wert];
    ASSERT(wert == [_obj boolMethod]);
	
    wert = YES;
    [[_obj stub] boolMethod];
    [_obj andReturnBool: wert];
    ASSERT(wert == [_obj boolMethod]);
	
    wert = NO;
    [[_obj stub] boolMethod];
    [_obj andReturnBool: wert];
    ASSERT(wert == [_obj boolMethod]);
}


- (void)testPointerMethodCanBeMocked
{
    const char *wert = "hallo";
    [(id)[[_obj stub] pointerMethod] andReturn: wert];
    ASSERT(wert == [_obj pointerMethod]);
}


// FIXME andere typen unterstützen


- (void)testMockingAccountsForMethodsArguments
{
    [[[_obj stub] methodReturningArgument: @"du da"] andReturn: @"ist da wer?"];
    ASSERTEQUALS(@"Hallo", [_obj methodReturningArgument: @"Hallo"]);
    ASSERTEQUALS(@"ist da wer?", [_obj methodReturningArgument: @"du da"]);
}


- (void)testStubbingAMethodCanBeOverridenByANewStubOfTheSameMethod
{
    [(id)[[_obj stub] testMethod: 3] andReturnInt: 666];
    ASSERTEQUALSINT(666, [_obj testMethod: 3]);
    [(id)[[_obj stub] testMethod: 3] andReturnInt: 667];
    ASSERTEQUALSINT(667, [_obj testMethod: 3]);
    ASSERTEQUALSINT(667, [_obj testMethod: 3]);
    ASSERTEQUALSINT(667, [_obj testMethod: 3]);
}


- (void)testStubbingAMethodCanBeInterruptedByShouldReceiveOnTheSameMethodAndContinuesAfterwards
{
    [(id)[[_obj stub] testMethod: 3] andReturnInt: 666];
    ASSERTEQUALSINT(666, [_obj testMethod: 3]);
    [(id)[[_obj shouldReceive] testMethod: 3] andReturnInt: 667];
    ASSERTEQUALSINT(667, [_obj testMethod: 3]);
    ASSERTEQUALSINT(666, [_obj testMethod: 3]);
}


- (void)testMockCountCanBeSet
{
    [[(id)[[_obj stub] testMethod: 3] andReturnInt: 666] receiveTimes: 3];
    ASSERTEQUALSINT(666, [_obj testMethod: 3]);
    ASSERTEQUALSINT(666, [_obj testMethod: 3]);
    ASSERTEQUALSINT(666, [_obj testMethod: 3]);
    ASSERTEQUALSINT(6, [_obj testMethod: 3]);
}


// TODO nach einem mock (recording) mehrmals andReturn/andRaise als Sequenz von Rückgabewerten (1.
// Wert -> 1. Call, 2. Wert -> 2. Call ...)


- (void)testMockedMethodCanThrowException
{
    BOOL exceptionCaught = NO;
    [[[_obj stub] methodReturningArgument: _obj] andThrow: @"anException"];
    @try {
        [_obj methodReturningArgument: _obj];
    } @catch (id e) {
        ASSERTEQUALS(@"anException", e);
        exceptionCaught = YES;
    }
    ASSERT(exceptionCaught);
}


- (void)testMockedMethodWithByteResultCanThrowException
{
    BOOL exceptionCaught = NO;
    [[_obj stub] charMethod]; [[_obj andReturnBool: YES] andThrow: @"anException"];
    @try {
        [_obj charMethod];
    } @catch (id e) {
        ASSERTEQUALS(@"anException", e);
        exceptionCaught = YES;
    }
    ASSERT(exceptionCaught);
}


- (void)testDeallocationOfObjectShouldRaiseAnExceptionIfNotAllMockedMethodsWereCalled
{
    id o = [[TMockTestClass alloc] init];
    [(id)[[o stub] testMethod: 3] andReturnInt: 666];
    [[[o stub] methodReturningArgument: _obj] andReturn: @"hui"];
    [o testMethod: 3];
    BOOL exceptionCaught = NO;
    @try {
        [o release];
    } @catch (id e) {
        exceptionCaught = YES;
    }
    ASSERT(exceptionCaught);
}


- (void)testDeallocationOfObjectShouldNotRaiseAnExceptionIfAllMockedMethodsWereCalled
{
    id o = [[TMockTestClass alloc] init];
    [(id)[[o stub] testMethod: 3] andReturnInt: 666];
    [[[o stub] methodReturningArgument: _obj] andReturn: @"hui"];
    [o testMethod: 3];
    [o methodReturningArgument: _obj];
    [o release];
}


- (void)testDeallocationOfObjectShouldNotRaiseAnExceptionIfAllMockedMethodsWereStubbed
{
    id o = [[TMockTestClass alloc] init];
    [(id)[[o stub] testMethod: 3] andReturnInt: 666];
    [[[o stub] methodReturningArgument: _obj] andReturn: @"hui"];
    [o release];
}


- (void)testVerifyAndCleanupMocksShouldRaiseAnExceptionIfNotAllMockedMethodsWereCalled
{
    [(id)[[_obj stub] testMethod: 3] andReturnInt: 666];
    [[[_obj stub] methodReturningArgument: _obj] andReturn: @"hui"];
    [_obj testMethod: 3];
    BOOL exceptionCaught = NO;
    @try {
        verifyAndCleanupMocks();
    } @catch (id e) {
        exceptionCaught = YES;
    }
    ASSERT(exceptionCaught);
}


- (void)testVerifyAndCleanupMocksShouldNotRaiseAnExceptionIfAllMockedMethodsWereCalled
{
    [(id)[[_obj stub] testMethod: 3] andReturnInt: 666];
    [[[_obj stub] methodReturningArgument: _obj] andReturn: @"hui"];
    [_obj testMethod: 3];
    [_obj methodReturningArgument: _obj];
    verifyAndCleanupMocks();
}


- (void)testVerifyAndCleanupMocksShouldNotRaiseAnExceptionIfAllMockedMethodsWereStubbed
{
    [(id)[[_obj stub] testMethod: 3] andReturnInt: 666];
    [[[_obj stub] methodReturningArgument: _obj] andReturn: @"hui"];
    verifyAndCleanupMocks();
}


- (void)testStubbedMethodsShouldBeRemovedAfterVerifyAndCleanupMocks
{
    [(id)[[_obj stub] testMethod: 3] andReturnInt: 666];
    [[[_obj stub] methodReturningArgument: _obj] andReturn: @"hui"];
    verifyAndCleanupMocks();
    ASSERTEQUALSINT(6, [_obj testMethod: 3]);
    ASSERTEQUALS(_obj, [_obj methodReturningArgument: _obj]);
}


- (void)testShouldReceiveMocksMethodAndThrowsExceptionIfMethodIsCalledTooOften
{
    [[[_obj shouldReceive] methodReturningArgument: @"hallo"] andReturn: @"du da"];
    ASSERTEQUALS(@"du da", [_obj methodReturningArgument: @"hallo"]);
    FAIL([_obj methodReturningArgument: @"hallo"]);
}


- (void)testMethodMockedViaShouldReceiveThrowsExceptionIfArgumentIsWrong
{
    [[[_obj shouldReceive] methodReturningArgument: @"hallo"] andReturn: @"du da"];
    FAIL([_obj methodReturningArgument: @"falscher parameter"]);
    [_obj methodReturningArgument: @"hallo"];
}


- (void)testInvokingAMethodThatShouldNotBeReceivedThrowsAnException
{
    [[_obj shouldNotReceive] methodReturningArgument: @"hallo"];
    FAIL([_obj methodReturningArgument: @"hallo"]);
}


- (void)testMethordOrderCanBeExpected
{
    [[[_obj shouldReceive] methodReturningArgument: @"3"] ordered];
    [[[_obj shouldReceive] methodReturningArgument: @"2"] ordered];
    [[[_obj shouldReceive] methodReturningArgument: @"1"] ordered];
    [_obj methodReturningArgument: @"3"];
    [_obj methodReturningArgument: @"2"];
    [_obj methodReturningArgument: @"1"];
}


- (void)testExceptionIsRaisedOnOrderedMethodsIfCalledInWrongOrder
{
    [[[_obj shouldReceive] methodReturningArgument: @"3"] ordered];
    [[[_obj shouldReceive] methodReturningArgument: @"2"] ordered];
    [[[_obj shouldReceive] methodReturningArgument: @"1"] ordered];
    FAIL([_obj methodReturningArgument: @"2"]);
    [_obj methodReturningArgument: @"3"];
    [_obj methodReturningArgument: @"2"];
    [_obj methodReturningArgument: @"1"];
}


- (void)testExpectOrderingOnStubbedMethodFails
{
    FAIL([[[_obj stub] methodReturningArgument: @"3"] ordered]);
}


- (void)testExpectOrderingOnUnexpectedMethodFails
{
    FAIL([[[_obj shouldNotReceive] methodReturningArgument: @"3"] ordered]);
}


- (void)testExpectOrderingOnUnlimitedMethodFails
{
    FAIL([[[[_obj shouldReceive] methodReturningArgument: @"3"]
            receiveTimes: TUNIT_UNLIMITEDCALLCOUNT] ordered]);
    [_obj methodReturningArgument: @"3"];
}


- (void)testMethodsCanBeExpectedOrderedWithSameArgumentsAndDifferentResults
{
    [[[[_obj shouldReceive] methodReturningArgument: @"1"] ordered] andReturn: @"1"];
    [[[[_obj shouldReceive] methodReturningArgument: @"1"] ordered] andReturn: @"2"];
    [[[[_obj shouldReceive] methodReturningArgument: @"1"] ordered] andReturn: @"3"];
    ASSERTEQUALS(@"1", [_obj methodReturningArgument: @"1"]);
    ASSERTEQUALS(@"2", [_obj methodReturningArgument: @"1"]);
    ASSERTEQUALS(@"3", [_obj methodReturningArgument: @"1"]);
}


- (void)testMultipleReceivedMessagesCanBeOrdered
{
    [[[[[_obj shouldReceive] methodReturningArgument: @"1"] ordered] receiveTimes: 2]
            andReturn: @"1"];
    [[[[_obj shouldReceive] methodReturningArgument: @"2"] ordered] andReturn: @"2"];
    ASSERTEQUALS(@"1", [_obj methodReturningArgument: @"1"]);
    ASSERTEQUALS(@"1", [_obj methodReturningArgument: @"1"]);
    ASSERTEQUALS(@"2", [_obj methodReturningArgument: @"2"]);
}


- (void)testMethodsCanBeExpectedOrderedWithDifferentResultsAndOtherCallsBetweenThem
{
    [[[[_obj shouldReceive] methodReturningArgument: @"1"] ordered] andReturn: @"1"];
    [[(id)[[_obj shouldReceive] intMethod] ordered] andReturnInt: 123];
    [[[[_obj shouldReceive] methodReturningArgument: @"1"] ordered] andReturn: @"3"];
    [[(id)[[_obj shouldReceive] intMethod] ordered] andReturnInt: 456];
    ASSERTEQUALS(@"1", [_obj methodReturningArgument: @"1"]);
    ASSERTEQUALSINT(123, [_obj intMethod]);
    ASSERTEQUALS(@"3", [_obj methodReturningArgument: @"1"]);
    ASSERTEQUALSINT(456, [_obj intMethod]);
}


- (void)_disabled_testReleaseCanBeMocked
{
    [[_obj shouldReceive] release];
    [_obj release];
}


- (void)testShouldReceiveMessageExceptionContainsLocationInformation
{
    char *file = __FILE__; int line = __LINE__; [[_obj shouldReceive] methodReturningArgument: nil];
    id expected = [NSString stringWithFormat: @"%s:%d", file, line];
    @try {
        verifyAndCleanupMocks();
    } @catch(id e) {
        ASSERTSUBSTRING(expected, [e message]);
    }
}


- (void)testShouldNotReceiveMessageExceptionContainsLocationInformation
{
    char *file = __FILE__; int line = __LINE__; [[_obj shouldNotReceive] retain];
    id expected = [NSString stringWithFormat: @"%s:%d", file, line];
    @try {
        [_obj retain];
        verifyAndCleanupMocks();
    } @catch(id e) {
        ASSERTSUBSTRING(expected, [e message]);
    }
}


// FIXME: mock ist zu allgemein, um per Makro definiert zu werden -> erstmal besseren Namen finden.
//- (void)testMockMessageExceptionContainsLocationInformation
//{
//    char *file = __FILE__; int line = __LINE__; [[_obj stub] methodReturningArgument: nil];
//    id expected = [NSString stringWithFormat: @"%s:%d", file, line];
//    @try {
//        verifyAndCleanupMocks();
//    } @catch(TTestException *e) {
//        ASSERTSUBSTRING(expected, [[e autorelease] message]);
//    }
//}


- (void)testShouldNotReceiveCanOverrideStubbingOfTheSameMethod
{
    [(id)[[_obj stub] testMethod: 3] andReturnInt: 666];
    [[_obj shouldNotReceive] testMethod: 3];
    FAIL([_obj testMethod: 3]);
}


- (void)testShouldNotReceiveCanOverrideStubbingOfAFinerSpecificationOFTheSameMethod
{
    [(id)[[_obj stub] testMethod: 3] andReturnInt: 666];
    [(id)[[_obj shouldNotReceive] testMethod: 0] skipParameterCheck: 1];
    FAIL([_obj testMethod: 3]);
}


- (void)testSkipParameterCheckIsAvailableForAllParameters
{
    [[_obj shouldReceive] methodWithArgumentsChar: 0 short: 0 int: 0 long: 0 longLong: 0 float: 0
            double: 0 cPtr: NULL constCPtr: NULL vPtr: NULL constVPtr: NULL id: nil];
    [_obj skipParameterChecks];
    [_obj methodWithArgumentsChar: 'a' short: 1 int: 2 long: 3 longLong: 4 float: 5 double: 6
            cPtr: "b" constCPtr: "c" vPtr: "d" constVPtr: "e" id: _obj];
}

#endif

@end
