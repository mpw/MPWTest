//
// (C) Copyright Tilo Prütz
//

#include "TMockTestClass.h"

#pragma .h #include <TUnit/TUnit.h>


#pragma .h typedef struct _TMockTestStruct {
#pragma .h     int anInt;
#pragma .h     id anObject;
#pragma .h     double aDouble;
#pragma .h } TMockTestStruct;


#pragma .h @protocol TMockTestProtocol


#pragma .h - (void)voidProtocolMethod;


#pragma .h - (char)charProtocolMethod;


#pragma .h - (short)shortProtocolMethod;


#pragma .h - (int)intProtocolMethod;


#pragma .h - (long long)longLongProtocolMethod;


#pragma .h - (float)floatProtocolMethod;


#pragma .h - (double)doubleProtocolMethod;


#pragma .h - (void *)pointerProtocolMethod;


#pragma .h - (TMockTestStruct)structProtocolMethod;


#pragma .h @end


#pragma .h @protocol TMockTestInheritedProtocol <TObject>


#pragma .h @end


@implementation TMockTestClass:TObject
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


- (int)testMethod: (int)param
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
