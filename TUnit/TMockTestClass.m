//
// (C) Copyright Tilo Prütz
//

#include "TMockTestClass.h"


@implementation TMockTestClass:NSObject
{
}


- (void)voidMethod
{
}


- (char)charMethod
{
    return 0;
}


- (short)shortMethod
{
    return 0;
}


- (int)intMethod
{
    return 0;
}


- (long long)longLongMethod
{
    return 0;
}


- (float)floatMethod
{
    return 0.0;
}


- (double)doubleMethod
{
    return 0.0;
}


- (void *)pointerMethod
{
    return NULL;
}


- (BOOL)boolMethod
{
    return NO;
}


//- (TMockTestStruct)structMethod
//{
//    TMockTestStruct s;
//
//    return s;
//}


- methodReturningArgument: arg
{
    return arg;
}


- (long long)testMethod: (int)param
{
    return param + 3;
}


+ (void)voidClassMethod
{
}


+ (char)charClassMethod
{
    return 0;
}


+ (short)shortClassMethod
{
    return 0;
}


+ (int)intClassMethod
{
    return 0;
}


+ (long long)longLongClassMethod
{
    return 0;
}


+ (float)floatClassMethod
{
    return 0.0;
}


+ (double)doubleClassMethod
{
    return 0.0;
}


+ (void *)pointerClassMethod
{
    return NULL;
}


+ (BOOL)boolClassMethod
{
    return NO;
}


//+ (TMockTestStruct)structClassMethod
//{
//    TMockTestStruct s;
//
//    return s;
//}


+ classMethodReturningArgument: arg
{
    return arg;
}


+ (int)testClassMethod: (int)param
{
    return param + 4;
}


- (void)methodWithArgumentsChar: (char)c
        short: (short)s
        int: (int)i
        long: (long)l
        longLong: (long long)ll
        float: (float)f
        double: (double)d
        cPtr: (char *)cp
        constCPtr: (const char *)ccp
        vPtr: (void *)vp
        constVPtr: (const void *)cvp
        id: o
{
}


@end
