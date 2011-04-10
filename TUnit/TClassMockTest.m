//
// (C) Copyright Tilo Pr�tz
//

#include "TClassMockTest.h"

#pragma .h #include <TUnit/TUnit.h>

#pragma .h @class TMockTestClass;

#include "TMockTestClass.h"


@implementation TClassMockTest:TTestCase
{
    TMockController *_controller;
    TMockTestClass *_mock;
}


- (void)prepare
{
    _controller = [TMockController mockController];
    _mock = (TMockTestClass *)[_controller
            mockForClass: [TMockTestClass class]];
}


- (void)cleanup
{
    [_controller verify];
    _controller = nil;
    _mock = nil;
}


- (void)testVoidMethod
{
    [_mock voidMethod];
    [_controller replay];
    [_mock voidMethod];
}


- (void)testCharMethod
{
    [_mock charMethod];
    [_controller setCharResult: '�'];
    [_controller replay];
    ASSERT([_mock charMethod] == '�');
}


- (void)testShortMethod
{
    [_mock shortMethod];
    [_controller setShortResult: (short)33000];
    [_controller replay];
    ASSERT([_mock shortMethod] == (short)33000);
}


- (void)testIntMethod
{
    [_mock intMethod];
    [_controller setIntResult: 0x80000000];
    [_controller replay];
    ASSERT([_mock intMethod] == 0x80000000);
}


- (void)testLongLongMethod
{
    [_mock longLongMethod];
    [_controller setLongLongResult: 0x8000000000000000LL];
    [_controller replay];
    ASSERT([_mock longLongMethod] == 0x8000000000000000LL);
}


- (void)testFloatMethod
{
    float value = 1234.5678;

    [_mock floatMethod];
    [_controller setFloatResult: value];
    [_controller replay];
    ASSERT([_mock floatMethod] == value);
}


- (void)testDoubleMethod
{
    [_mock doubleMethod];
    [_controller setDoubleResult: 1234567890.1234567890123456789];
    [_controller replay];
    ASSERT([_mock doubleMethod] == 1234567890.1234567890123456789);
}


//- (void)testStructMethod
//{
//    FAIL([_mock structMethod]);
//    [_controller replay];
//    FAIL([_mock structMethod]);
//}
//
//
- (void)testInvalidMethod
{
    FAIL([(id)_mock intValue]);
    FAIL([(Class)_mock intClassMethod]);
    [_controller replay];
    FAIL([(id)_mock intValue]);
    FAIL([(Class)_mock intClassMethod]);
}


- (void)testArgumentCheck
{
    [_mock methodWithArgumentsChar: 'a' short: 1000 int: 2000000
            long: 2000000 longLong: 5000000000LL float: 1234.5678
            double: 1234567890.1234567890123456789 cPtr: "Hallo"
            constCPtr: "du da" vPtr: "murks" constVPtr: "mehr murks" id: _mock];
    [_controller replay];
    FAIL([_mock methodWithArgumentsChar: 'b' short: 1000 int: 2000000
            long: 2000000 longLong: 5000000000LL float: 1234.5678
            double: 1234567890.1234567890123456789 cPtr: "Hallo"
            constCPtr: "du da" vPtr: "murks" constVPtr: "mehr murks"
            id: _mock]);
    FAIL([_mock methodWithArgumentsChar: 'a' short: 100 int: 2000000
            long: 2000000 longLong: 5000000000LL float: 1234.5678
            double: 1234567890.1234567890123456789 cPtr: "Hallo"
            constCPtr: "du da" vPtr: "murks" constVPtr: "mehr murks"
            id: _mock]);
    FAIL([_mock methodWithArgumentsChar: 'a' short: 1000 int: -900000
            long: 2000000 longLong: 5000000000LL float: 1234.5678
            double: 1234567890.1234567890123456789 cPtr: "Hallo"
            constCPtr: "du da" vPtr: "murks" constVPtr: "mehr murks"
            id: _mock]);
    FAIL([_mock methodWithArgumentsChar: 'a' short: 1000 int: 2000000
            long: -900000 longLong: 5000000000LL float: 1234.5678
            double: 1234567890.1234567890123456789 cPtr: "Hallo"
            constCPtr: "du da" vPtr: "murks" constVPtr: "mehr murks"
            id: _mock]);
    FAIL([_mock methodWithArgumentsChar: 'a' short: 1000 int: 2000000
            long: 2000000 longLong: 6000000000LL float: 1234.5678
            double: 1234567890.1234567890123456789 cPtr: "Hallo"
            constCPtr: "du da" vPtr: "murks" constVPtr: "mehr murks"
            id: _mock]);
    FAIL([_mock methodWithArgumentsChar: 'a' short: 1000 int: 2000000
            long: 2000000 longLong: 5000000000LL float: 1234.567
            double: 1234567890.1234567890123456789 cPtr: "Hallo"
            constCPtr: "du da" vPtr: "murks" constVPtr: "mehr murks"
            id: _mock]);
    FAIL([_mock methodWithArgumentsChar: 'a' short: 1000 int: 2000000
            long: 2000000 longLong: 5000000000LL float: 1234.5678
            double: 1234567890.1234 cPtr: "Hallo" constCPtr: "du da"
            vPtr: "murks" constVPtr: "mehr murks" id: _mock]);
    FAIL([_mock methodWithArgumentsChar: 'a' short: 1000 int: 2000000
            long: 2000000 longLong: 5000000000LL float: 1234.5678
            double: 1234567890.1234567890123456789 cPtr: "Hall"
            constCPtr: "du da" vPtr: "murks" constVPtr: "mehr murks"
            id: _mock]);
    FAIL([_mock methodWithArgumentsChar: 'a' short: 1000 int: 2000000
            long: 2000000 longLong: 5000000000LL float: 1234.5678
            double: 1234567890.1234567890123456789 cPtr: "Hallo"
            constCPtr: "duda" vPtr: "murks" constVPtr: "mehr murks" id: _mock]);
    FAIL([_mock methodWithArgumentsChar: 'a' short: 1000 int: 2000000
            long: 2000000 longLong: 5000000000LL float: 1234.5678
            double: 1234567890.1234567890123456789 cPtr: "Hallo"
            constCPtr: "du da" vPtr: "murks " constVPtr: "mehr murks"
            id: _mock]);
    FAIL([_mock methodWithArgumentsChar: 'a' short: 1000 int: 2000000
            long: 2000000 longLong: 5000000000LL float: 1234.5678
            double: 1234567890.1234567890123456789 cPtr: "Hallo"
            constCPtr: "du da" vPtr: "murks" constVPtr: "mehrmurks"
            id: _mock]);
    FAIL([_mock methodWithArgumentsChar: 'a' short: 1000 int: 2000000
            long: 2000000 longLong: 5000000000LL float: 1234.5678
            double: 1234567890.1234567890123456789 cPtr: "Hallo"
            constCPtr: "du da" vPtr: "murks" constVPtr: "mehr murks" id: self]);
    [_mock methodWithArgumentsChar: 'a' short: 1000 int: 2000000
            long: 2000000 longLong: 5000000000LL float: 1234.5678
            double: 1234567890.1234567890123456789 cPtr: "Hallo"
            constCPtr: "du da" vPtr: "murks" constVPtr: "mehr murks" id: _mock];
}


@end
