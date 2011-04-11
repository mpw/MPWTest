//
// (C) Copyright Tilo Prütz
//

#include "TMetaClassMockTest.h"
#include "TMockTestClass.h"
#include "TMock.h"

@implementation TMetaClassMockTest:TTestCase
{
    TMockController *_controller;
    Class _mock;
}


- (void)setUp
{
    _controller = [TMockController mockController];
    _mock = (Class)[_controller
            mockForMetaClassOfClass: [TMockTestClass class]];
}


- (void)tearDown
{
    [_controller verify];
    _controller = nil;
    _mock = Nil;
}


- (void)testVoidClassMethod
{
    [_mock voidClassMethod];
    [_controller replay];
    [_mock voidClassMethod];
}


- (void)testCharClassMethod
{
    [_mock charClassMethod];
    [_controller setCharResult: 'ü'];
    [_controller replay];
    ASSERT([_mock charClassMethod] == 'ü');
}


- (void)testShortClassMethod
{
    [_mock shortClassMethod];
    [_controller setShortResult: (short)33000];
    [_controller replay];
    ASSERT([_mock shortClassMethod] == (short)33000);
}


- (void)testIntClassMethod
{
    [_mock intClassMethod];
    [_controller setIntResult: 0x80000000];
    [_controller replay];
    ASSERT([_mock intClassMethod] == 0x80000000);
}


- (void)testLongLongClassMethod
{
    [_mock longLongClassMethod];
    [_controller setLongLongResult: 0x8000000000000000LL];
    [_controller replay];
    ASSERT([_mock longLongClassMethod] == 0x8000000000000000LL);
}


- (void)_testFloatClassMethod
{
    float value = 1234.5678;

    [_mock floatClassMethod];
    [_controller setFloatResult: value];
    [_controller replay];
	float retval = [_mock floatClassMethod];
	NSLog(@"value=%g retval=%g",value,retval);
    ASSERT( retval== value);
}


- (void)testDoubleClassMethod
{
    [_mock doubleClassMethod];
    [_controller setDoubleResult: 1234567890.1234567890123456789];
    [_controller replay];
    ASSERT([_mock doubleClassMethod] == 1234567890.1234567890123456789);
}


//- (void)testStructClassMethod
//{
//    FAIL([_mock structClassMethod]);
//    [_controller replay];
//    FAIL([_mock structClassMethod]);
//}
//
//

- (void)_testInvalidMethod
{
    FAIL([_mock descriptionFor: (TMock *)_mock]);
    FAIL([(TMockTestClass *)_mock intMethod]);
    [_controller replay];
    FAIL([_mock descriptionFor: (TMock *)_mock]);
    FAIL([(TMockTestClass *)_mock intMethod]);
}


@end
