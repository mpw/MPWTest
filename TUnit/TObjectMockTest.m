//
// (C) Copyright Tilo Prütz
//

#include "TObjectMockTest.h"

#pragma .h #include <TUnit/TUnit.h>

#include "TMockTestClass.h"


@implementation TObjectMockTest:TTestCase
{
    TMockController *_controller;
    TFileInputStream *_mock;
}


- (void)prepare
{
    _controller = [TMockController mockController];
    _mock = (TFileInputStream *)[_controller
            mockForClass: [TFileInputStream class]];
}


- (void)cleanup
{
    [_controller verify];
    _controller = nil;
    _mock = nil;
}


- (void)testReplaySingle
{
    TFileInputStream *stream = _mock;

    [stream readIntoBuffer: NULL length: 0];
    [_controller replay];
    [stream readIntoBuffer: NULL length: 0];
}


- (void)testReplayMultiple
{
    TFileInputStream *stream = _mock;
    char buf[10];

    [stream readIntoBuffer: buf length: 10];
    [_controller setIntResult: 10];
    [stream close];

    [_controller replay];

    ASSERT([stream readIntoBuffer: buf length: 10] == 10);
    [stream close];
}


- (void)testReplayStrict
{
    TFileInputStream *stream = _mock;
    TFileInputStream *s2 = (TFileInputStream *)[_controller
            mockForClass: [TFileInputStream class]];
    char buf[10];

    [stream readIntoBuffer: buf length: 10];
    [_controller setIntResult: 10];
    [s2 dealloc];
    [stream readIntoBuffer: buf length: 10];
    [_controller setIntResult: 10];
    [stream readIntoBuffer: buf length: 5];
    [_controller setIntResult: 2];
    [_controller setCallCount: 2];
    [_controller setIntResult: 3];
    [_controller setCallCount: 2];
    [stream close];
    [_controller setCallCount: 2];

    [_controller replayStrict];

    ASSERTEQUALSINT(10, [stream readIntoBuffer: buf length: 10]);
    [s2 dealloc];
    ASSERTEQUALSINT(10, [stream readIntoBuffer: buf length: 10]);
    ASSERTEQUALSINT(2, [stream readIntoBuffer: buf length: 5]);
    ASSERTEQUALSINT(2, [stream readIntoBuffer: buf length: 5]);
    ASSERTEQUALSINT(3, [stream readIntoBuffer: buf length: 5]);
    ASSERTEQUALSINT(3, [stream readIntoBuffer: buf length: 5]);
    [stream close];
    [stream close];
}


- (void)testReplayOutOfSequence
{
    TFileInputStream *stream = _mock;
    TFileInputStream *s2 = (TFileInputStream *)[_controller
            mockForClass: [TFileInputStream class]];
    char buf[10];

    [stream readIntoBuffer: buf length: 10];
    [_controller setIntResult: 10];
    [s2 dealloc];
    [stream readIntoBuffer: buf length: 10];
    [_controller setIntResult: 10];
    [stream close];

    [_controller replay];

    [s2 dealloc];
    ASSERT([stream readIntoBuffer: buf length: 10] == 10);
    ASSERT([stream readIntoBuffer: buf length: 10] == 10);
    // TODO: extraTest für zu früh verify (nicht alle messages gerufen) und
    // message calling zwischen verify und record
    FAIL([_controller verify]);
    FAIL([stream close]);
}


- (void)testReplayStrictOutOfSequence
{
    TFileInputStream *stream = _mock;
    TFileInputStream *s2 = (TFileInputStream *)[_controller
            mockForClass: [TFileInputStream class]];
    char buf[10];

    [stream readIntoBuffer: buf length: 10];
    [_controller setIntResult: 10];
    [s2 dealloc];
    [stream readIntoBuffer: buf length: 10];
    [_controller setIntResult: 10];
    [stream close];
    [stream readIntoBuffer: buf length: 5];
    [_controller setIntResult: 5];
    [_controller setCallCount: 3];
    [stream close];
    [_controller setCallCount: 2];

    [_controller replayStrict];

    FAIL([s2 dealloc]);
    ASSERT([stream readIntoBuffer: buf length: 10] == 10);
    FAIL([stream readIntoBuffer: buf length: 10]);
    FAIL([stream close]);
    [s2 dealloc];
    FAIL([stream close]);
    ASSERT([stream readIntoBuffer: buf length: 10] == 10);
    [stream close];
    ASSERT([stream readIntoBuffer: buf length: 5] == 5);
    FAIL([stream close]);
    ASSERT([stream readIntoBuffer: buf length: 5] == 5);
    FAIL([stream close]);
    ASSERT([stream readIntoBuffer: buf length: 5] == 5);
    [stream close];
    [stream close];
}


- (void)testConvenienceSmokeTest
{
    TFileInputStream *stream = _mock;
    char buf[10];

    [stream readIntoBuffer: buf length: 10];
    [_controller setIntResult: 10 andCallCount: 2];

    [_controller replay];

    ASSERT([stream readIntoBuffer: buf length: 10] == 10);
    ASSERT([stream readIntoBuffer: buf length: 10] == 10);

    [_controller verify];
//    [_controller record];
//
//    [stream readIntoBuffer: buf length: 10];
//    [_controller setIntResult: 10 andCallRangeFrom: 1 to: 3];
//
//    [_controller replay];
//
//    ASSERT([stream readIntoBuffer: buf length: 10] == 10);
//    ASSERT([stream readIntoBuffer: buf length: 10] == 10);
//
//    [_controller verify];
    [_controller record];

    [_controller expect: [stream readIntoBuffer: buf length: 10]
            withIntResult: 10];

    [_controller replay];

    ASSERT([stream readIntoBuffer: buf length: 10] == 10);

    [_controller verify];
    [_controller record];

    [_controller expect: [stream readIntoBuffer: buf length: 10]
            withIntResult: 10 andCallCount: 2];

    [_controller replay];

    ASSERT([stream readIntoBuffer: buf length: 10] == 10);
    ASSERT([stream readIntoBuffer: buf length: 10] == 10);

    [_controller verify];
//    [_controller record];
//
//    [_controller expect: [stream readIntoBuffer: buf length: 10]
//            withIntResult: 10 andCallRangeFrom: 1 to: 3];
//
//    [_controller replay];
//
//    ASSERT([stream readIntoBuffer: buf length: 10] == 10);
//    ASSERT([stream readIntoBuffer: buf length: 10] == 10);
}


// TODO Die Callcount-Funktionstets gehören eigentlich zur Message - hier müsste nur das korrekte
// Durchschleifen der Parameter getestet werden.
- (void)testSetCallCount
{
    TFileInputStream *stream = _mock;
    char buf[10];

    [stream readIntoBuffer: buf length: 10];
    [_controller setIntResult: 10];
    [_controller setCallCount: 3];

    [_controller replay];

    ASSERT([stream readIntoBuffer: buf length: 10] == 10);
    ASSERT([stream readIntoBuffer: buf length: 10] == 10);
    ASSERT([stream readIntoBuffer: buf length: 10] == 10);

    [_controller verify];
    [_controller record];

    TFileInputStream *s2 = (TFileInputStream *)[_controller
            mockForClass: [TFileInputStream class]];
    [stream readIntoBuffer: buf length: 10];
    [_controller setIntResult: 10];
    [_controller setCallCount: 3];
    [s2 dealloc];
    [_controller setCallCount: 3];

    [_controller replay];

    [s2 dealloc];
    ASSERT([stream readIntoBuffer: buf length: 10] == 10);
    ASSERT([stream readIntoBuffer: buf length: 10] == 10);
    [s2 dealloc];
    ASSERT([stream readIntoBuffer: buf length: 10] == 10);
    [s2 dealloc];
}


- (void)testSetCallCountToInfinity
{
    TFileInputStream *stream = _mock;
    char buf[10];

    [stream readIntoBuffer: buf length: 10];
    [_controller setIntResult: 10];
    [_controller setCallCount: TUNIT_UNLIMITEDCALLCOUNT];

    [_controller replay];

    ASSERT([stream readIntoBuffer: buf length: 10] == 10);
    ASSERT([stream readIntoBuffer: buf length: 10] == 10);
    ASSERT([stream readIntoBuffer: buf length: 10] == 10);
    ASSERT([stream readIntoBuffer: buf length: 10] == 10);
    ASSERT([stream readIntoBuffer: buf length: 10] == 10);
    ASSERT([stream readIntoBuffer: buf length: 10] == 10);
    ASSERT([stream readIntoBuffer: buf length: 10] == 10);
    ASSERT([stream readIntoBuffer: buf length: 10] == 10);

    [_controller verify];
    [_controller record];

    TFileInputStream *s2 = (TFileInputStream *)[_controller
            mockForClass: [TFileInputStream class]];
    [stream readIntoBuffer: buf length: 10];
    [_controller setIntResult: 10];
    [_controller setCallCount: TUNIT_UNLIMITEDCALLCOUNT];
    [_controller setIntResult: 9];
    [_controller setCallCount: 3];
    [stream readIntoBuffer: buf length: 11];
    [_controller setIntResult: 11];
    [s2 dealloc];
    [_controller setCallCount: 3];
    [stream readIntoBuffer: buf length: 12];
    [_controller setIntResult: 12];
    [_controller setCallCount: TUNIT_UNLIMITEDCALLCOUNT];

    [_controller replay];

    [s2 dealloc];
    ASSERT([stream readIntoBuffer: buf length: 10] == 10);
    ASSERT([stream readIntoBuffer: buf length: 10] == 10);
    [s2 dealloc];
    ASSERT([stream readIntoBuffer: buf length: 10] == 10);
    [s2 dealloc];
    ASSERT([stream readIntoBuffer: buf length: 10] == 10);
    ASSERT([stream readIntoBuffer: buf length: 10] == 10);
    ASSERT([stream readIntoBuffer: buf length: 10] == 10);
    FAIL(ASSERT([stream readIntoBuffer: buf length: 10] == 11));
    ASSERT([stream readIntoBuffer: buf length: 11] == 11);
    ASSERT([stream readIntoBuffer: buf length: 10] == 10);
    FAIL([_controller verify]);
}


- (void)testSetCallCountWithFewerCalls
{
    TFileInputStream *stream = _mock;
    char buf[10];

    [stream readIntoBuffer: buf length: 10];
    [_controller setIntResult: 10];
    [_controller setCallCount: 3];

    [_controller replay];

    ASSERT([stream readIntoBuffer: buf length: 10] == 10);
    ASSERT([stream readIntoBuffer: buf length: 10] == 10);
    FAIL([_controller verify]);

    [_controller record];

    TFileInputStream *s2 = (TFileInputStream *)[_controller
            mockForClass: [TFileInputStream class]];
    [stream readIntoBuffer: buf length: 10];
    [_controller setIntResult: 10];
    [_controller setCallCount: 3];
    [s2 dealloc];
    [_controller setCallCount: 3];

    [_controller replay];

    [s2 dealloc];
    ASSERT([stream readIntoBuffer: buf length: 10] == 10);
    ASSERT([stream readIntoBuffer: buf length: 10] == 10);
    ASSERT([stream readIntoBuffer: buf length: 10] == 10);
    [s2 dealloc];
    FAIL([_controller verify]);
}


- (void)testSetCallCountWithMoreCalls
{
    TFileInputStream *stream = _mock;
    char buf[10];

    [stream readIntoBuffer: buf length: 10];
    [_controller setIntResult: 10];
    [_controller setCallCount: 3];

    [_controller replay];

    ASSERT([stream readIntoBuffer: buf length: 10] == 10);
    ASSERT([stream readIntoBuffer: buf length: 10] == 10);
    ASSERT([stream readIntoBuffer: buf length: 10] == 10);
    FAIL([stream readIntoBuffer: buf length: 10]);

    [_controller verify];
    [_controller record];

    TFileInputStream *s2 = (TFileInputStream *)[_controller
            mockForClass: [TFileInputStream class]];
    [stream readIntoBuffer: buf length: 10];
    [_controller setIntResult: 10];
    [_controller setCallCount: 3];
    [s2 dealloc];
    [_controller setCallCount: 3];

    [_controller replay];

    [s2 dealloc];
    ASSERT([stream readIntoBuffer: buf length: 10] == 10);
    ASSERT([stream readIntoBuffer: buf length: 10] == 10);
    [s2 dealloc];
    ASSERT([stream readIntoBuffer: buf length: 10] == 10);
    [s2 dealloc];
    FAIL([stream readIntoBuffer: buf length: 10]);
    FAIL([s2 dealloc]);
}


- (void)testUncheckedCallCount
{
    TFileInputStream *stream = _mock;
    char buf[10];

    [_controller expect: [stream readIntoBuffer: buf length: 10]
            withIntResult: 10 andCallCount: TUNIT_UNCHECKEDCALLCOUNT];

    [_controller replay];

    [_controller verify];
    [_controller record];

    [_controller expect: [stream readIntoBuffer: buf length: 10]
            withIntResult: 10 andCallCount: TUNIT_UNCHECKEDCALLCOUNT];

    [_controller replay];

    ASSERT([stream readIntoBuffer: buf length: 10] == 10);

    [_controller verify];
    [_controller record];

    [_controller expect: [stream readIntoBuffer: buf length: 10]
            withIntResult: 10 andCallCount: TUNIT_UNCHECKEDCALLCOUNT];

    [_controller replay];

    ASSERT([stream readIntoBuffer: buf length: 10] == 10);
    ASSERT([stream readIntoBuffer: buf length: 10] == 10);
    ASSERT([stream readIntoBuffer: buf length: 10] == 10);
}


- (void)testCallCountCanBeZero
{
    TFileInputStream *stream = _mock;
    char buf[10];

    [_controller expect: [stream readIntoBuffer: buf length: 10]
            withIntResult: 10 andCallCount: 0];

    [_controller replay];

    [_controller verify];
    [_controller record];

    [_controller expect: [stream readIntoBuffer: buf length: 10]
            withIntResult: 10 andCallCount: 0];

    [_controller replay];

    FAIL([stream readIntoBuffer: buf length: 10]);
}


- (void)testDescription
{
    ASSERTEQUALS([TMockController descriptionFor:
            [_controller mockForClass: [TObject class]]],
            @"Mock for class TObject");
    ASSERTEQUALS([TMockController descriptionFor:
            [_controller mockForProtocol: @protocol(TObject)]],
            @"Mock for protocol TObject");
    ASSERTEQUALS([TMockController descriptionFor:
            [_controller mockForMetaClassOfClass: [TObject class]]],
            @"Mock for meta class of class TObject");

    ASSERTEQUALS([TMockController descriptionFor:
            [_controller mockWithName: @"mockName" forClass: [TObject class]]],
            @"Mock with name 'mockName' for class TObject");
    ASSERTEQUALS([TMockController descriptionFor: [_controller
            mockWithName: @"mockName" forProtocol: @protocol(TObject)]],
            @"Mock with name 'mockName' for protocol TObject");
    ASSERTEQUALS([TMockController descriptionFor: [_controller
            mockWithName: @"mockName" forMetaClassOfClass: [TObject class]]],
            @"Mock with name 'mockName' for meta class of class TObject");
}


@end


