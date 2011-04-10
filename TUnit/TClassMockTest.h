
#include "TTestCase.h"

@class TMockTestClass;
@class TMockController;



@interface TClassMockTest:TTestCase
{
    TMockController *_controller;
    TMockTestClass *_mock;
}


@end