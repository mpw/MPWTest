
#include <Foundation/Foundation.h>


typedef struct _TMockTestStruct {
    int anInt;
    id anObject;
    double aDouble;
} TMockTestStruct;


@protocol TMockTestProtocol


- (void)voidProtocolMethod;
- (char)charProtocolMethod;
- (short)shortProtocolMethod;
- (int)intProtocolMethod;
- (long long)longLongProtocolMethod;
- (float)floatProtocolMethod;
- (double)doubleProtocolMethod;
- (void *)pointerProtocolMethod;
- (TMockTestStruct)structProtocolMethod;

@end


@protocol TMockTestInheritedProtocol <NSObject>


@end


@interface TMockTestClass:NSObject
{
}

- (void)voidMethod;
- (char)charMethod;
- (short)shortMethod;
- (int)intMethod;
- (long long)longLongMethod;
- (float)floatMethod;
- (double)doubleMethod;
- (void *)pointerMethod;
- (BOOL)boolMethod;
//- (TMockTestStruct)structMethod;
- methodReturningArgument: arg;
- (long long)testMethod: (int)param;
+ (void)voidClassMethod;
+ (char)charClassMethod;
+ (short)shortClassMethod;
+ (int)intClassMethod;
+ (long long)longLongClassMethod;
+ (float)floatClassMethod;
+ (double)doubleClassMethod;
+ (void *)pointerClassMethod;
+ (BOOL)boolClassMethod;
//+ (TMockTestStruct)structClassMethod;

+ classMethodReturningArgument: arg;
+ (int)testClassMethod: (int)param;
- (void)methodWithArgumentsChar: (char)c;


@end
