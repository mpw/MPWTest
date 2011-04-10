//
// (C) Copyright Tilo Prütz
//

#include "TProtocolMockTest.h"

#pragma .h #include <TUnit/TUnit.h>

#pragma .h @protocol TMockTestProtocol, TMockTestInheritedProtocol;

#include "TMockTestClass.h"


@implementation TProtocolMockTest:TTestCase
{
    TMockController *_controller;
    id <TMockTestProtocol> _mock;
}


- (void)prepare
{
    _controller = [TMockController mockController];
    _mock = (id <TMockTestProtocol>)[_controller
            mockForProtocol: @protocol(TMockTestProtocol)];
}


- (void)cleanup
{
    [_controller verify];
    _controller = nil;
    _mock = nil;
}


- (void)testVoidMethod
{
    [_mock voidProtocolMethod];
    [_controller replay];
    [_mock voidProtocolMethod];
}


- (void)testCharMethod
{
    [_mock charProtocolMethod];
    [_controller setCharResult: 'x'];
    [_controller replay];
    ASSERT([_mock charProtocolMethod] == 'x');
}


- (void)testShortMethod
{
    [_mock shortProtocolMethod];
    [_controller setShortResult: (short)33000];
    [_controller replay];
    ASSERT([_mock shortProtocolMethod] == (short)33000);
}


- (void)testIntMethod
{
    [_mock intProtocolMethod];
    [_controller setIntResult: 0x80000000];
    [_controller replay];
    ASSERT([_mock intProtocolMethod] == 0x80000000);
}


- (void)testLongLongMethod
{
    [_mock longLongProtocolMethod];
    [_controller setLongLongResult: 0x8000000000000000LL];
    [_controller replay];
    ASSERT([_mock longLongProtocolMethod] == 0x8000000000000000LL);
}


- (void)testFloatMethod
{
    float value = 1234.5678;

    [_mock floatProtocolMethod];
    [_controller setFloatResult: value];
    [_controller replay];
    ASSERT([_mock floatProtocolMethod] == value);
}


- (void)testDoubleMethod
{
    [_mock doubleProtocolMethod];
    [_controller setDoubleResult: 1234567890.1234567890123456789];
    [_controller replay];
    ASSERT([_mock doubleProtocolMethod] == 1234567890.1234567890123456789);
}


- (void)testStructMethod
{
    FAIL([_mock structProtocolMethod]);
    [_controller replay];
    FAIL([_mock structProtocolMethod]);
}


- (void)testInvalidMethod
{
    FAIL([(TObject *)_mock retain]);
    [_controller replay];
    FAIL([(TObject *)_mock release]);
}


@end
//
// FIXME: GCC-Bug mit Protokollen
//@implementation TInheritedProtocolMockTest:TTestCase
//{
//    TMockController *_controller;
//    id <TMockTestInheritedProtocol> _mock;
//}
//
//
//- (void)prepare
//{
//    _controller = [TMockController mockController];
//    _mock = (id <TMockTestInheritedProtocol>)[_controller
//            mockForProtocol: @protocol(TMockTestInheritedProtocol)];
//}
//
//
//- (void)cleanup
//{
//    [_controller verify];
//    _controller = nil;
//    _mock = nil;
//}
//
//
//- (void)testInheritedMethod
//{
//    [_mock retain];
//    [_mock release];
//    [_controller replay];
//    [_mock retain];
//    [_mock release];
//}
//
//
//- (void)testInvalidMethod
//{
//    FAIL([(TArray *)_mock objectAtIndex: 0]);
//    [_controller replay];
//    FAIL([(TArray *)_mock objectAtIndex: 0]);
//}
//
//
//@end
//
