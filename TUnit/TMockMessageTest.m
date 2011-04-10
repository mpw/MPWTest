//
// (C) Copyright Tilo Prütz
//

#include "TMockMessageTest.h"

#pragma .h #include <TUnit/TUnit.h>


@implementation TTestMockMessage:TMockMessage
{
    TMockController *_controller;
}


+ message
{
    return [[[self alloc] init] autorelease];
}


- (void)testMessageChar: (char)c
        andShort: (short)s
        andId: eid
        andSel: (SEL)sel
        andClass: (Class)class
        andPtr: (void *)p
        andInt: (int)i
        andLongLong: (long long)l
        andFloat: (float)f
        andDouble: (double)d
        : nix
        andList: start, ...
{
}


- init
{
    [super init];
    _controller = [[TMockController mockController] retain];
    _sel = @selector(testMessageChar:andShort:andId:andSel:andClass:andPtr:andInt:andLongLong:andFloat:andDouble::andList:);
    _argStrings = [[TMutableArray arrayWithObjects:
            @"(char)0x00",
            @"(short)1234",
            @"<bla description>",
            @"@selector(init)",
            @"TArray",
            @"0x00000000",
            @"12345678",
            @"12345678901234",
            @"123.456",
            @"12345.678901",
            @"nix",
            @"12", @"34", @"56", nil] retain];
    _argCount = [_argStrings count] + 2;
    _skipCheck = (BOOL *)tAllocZero(_argCount * sizeof(BOOL));
    _receiver = [_controller mockForClass: [self class]];
    return self;
}


- (void)dealloc
{
    [_controller release];
    [super dealloc];
}


@end


@implementation TMockMessageTest:TTestCase
{
}


- (void)testDescribeOnStream
{
    ASSERTEQUALS([[TTestMockMessage message] description],
            @"[<Mock for class TTestMockMessage> "
            @"testMessageChar: (char)0x00 "
            @"andShort: (short)1234 "
            @"andId: <bla description> "
            @"andSel: @selector(init) "
            @"andClass: TArray "
            @"andPtr: 0x00000000 "
            @"andInt: 12345678 "
            @"andLongLong: 12345678901234 "
            @"andFloat: 123.456 "
            @"andDouble: 12345.678901 "
            @": nix "
            @"andList: 12, 34, 56] (0/0)");
}


- (void)testDescribeOnStreamMarksUncheckedParameters
{
    id message = [TTestMockMessage message];
    [message skipParameterCheck: 3];
    [message skipParameterCheck: 6];
    [message skipParameterCheck: 14];
    ASSERTEQUALS([message description],
            @"[<Mock for class TTestMockMessage> "
            @"testMessageChar: (char)0x00 "
            @"andShort: UNCHECKED "
            @"andId: <bla description> "
            @"andSel: @selector(init) "
            @"andClass: UNCHECKED "
            @"andPtr: 0x00000000 "
            @"andInt: 12345678 "
            @"andLongLong: 12345678901234 "
            @"andFloat: 123.456 "
            @"andDouble: 12345.678901 "
            @": nix "
            @"andList: 12, UNCHECKED, 56] (0/0)");
}


@end
