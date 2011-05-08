//
//  TMock.m
//  MPWTest
//
//  Created by Marcel Weiher on 4/10/11.
//  Copyright 2011 metaobject ltd. All rights reserved.
//

#import "TMock.h"
#import "TMockController.h"

@implementation TMock

-(void)forwardInvocation:(NSInvocation *)invocation
{
//	NSLog(@"forwarding %@ to %@",invocation,controller);
	[controller handleMockedInvocation:invocation];
}

-(NSMethodSignature*)methodSignatureForSelector:(SEL)sel
{
	return [controller methodSignatureForMockedSelector:sel];
}

-initWithController:anObject
{
	controller=[anObject retain];
	return self;
}

-(void)returnBool:(BOOL)aValue
{
//	NSLog(@"should return bool: %d",aValue);
	[controller setCharResult:aValue];
}

-andReturnBool:(BOOL)aValue
{
	[controller setCharResult:aValue];
}

-shouldNotReceive
{
	return self;
}

-andThrow:objectToThrow
{
	[controller setExceptionResult:objectToThrow];
}

-andReturnInt:(int)anInt
{
//	NSLog(@"TMock should return int: %d",anInt);
	[controller setIntResult:anInt];
//	NSLog(@"self in andReturnInt: %d = %p",anInt,self);
	return self;
}

-andReturn:returnValue
{
	[controller setResult:returnValue];
	return self;
}

-shouldReceive
{
	[controller recordOneMessage];
	[controller setExpectedCount:1];
	return self;
}

-receiveTimes:(int)expected
{
//	NSLog(@"receiveTimes: %d forwarding to controller",expected);
	[controller setCurrentExpectedCount:expected];
	return self;
}

-stub
{
	[controller recordOneMessage];
	[controller setExpectedCount:-1];
	return self;
}

@end


@implementation NSObject(mock)

-mock
{
	TMockController *controller=[TMockController mockControllerForObject:self];
	return [controller mockForObject:self];
}

-stub
{
	TMockController *controller=[TMockController mockControllerForObject:self];
	[controller recordOneMessage];
	id stub = [controller inlineMock];
//	NSLog(@"will return inline mock: %p",stub);
	return stub;
}

-shouldReceive
{
	TMockController *controller=[TMockController mockControllerForObject:self];
	[controller recordOneMessage];
	return [controller inlineMock];
}

-andReturnInt:(int)anInt
{
	NSLog(@"NSObject should return int: %d",anInt);
	[[TMockController mockControllerForObject:self] setIntResult:anInt];
	return self;
}



-ordered 
{
	return self;
}


@end