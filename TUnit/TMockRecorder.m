//
//  TMock.m
//  MPWTest
//
//  Created by Marcel Weiher on 4/10/11.
//  Copyright 2011 metaobject ltd. All rights reserved.
//

#pragma .h #import <Foundation/Foundation.h>
#import "TMockRecorder.h"
#import "TMockController.h"

@implementation TMockRecorder : NSProxy
{
	id controller;
}


-controller {
	return controller;
}

-(void)forwardInvocation:(NSInvocation *)invocation
{
	[[self controller] handleMockedInvocation:invocation];
}

-(NSMethodSignature*)methodSignatureForSelector:(SEL)sel
{
	TMockController *mc=[self controller];
	return [mc methodSignatureForMockedSelector:sel];
}

-initWithController:anObject
{
	controller=anObject;
	return self;
}

-(void)returnBool:(BOOL)aValue
{
//	NSLog(@"should return bool: %d",aValue);
	[[self controller] setCharResult:aValue];
}

-andReturnBool:(BOOL)aValue
{
	[[self controller] setCharResult:aValue];
	return self;
}

-shouldNotReceive
{
	[[self controller] recordOneMessage];
	[[self controller] setExpectedCount:0];
	return self;
}

-andThrow:objectToThrow
{
	[[self controller] setExceptionResult:objectToThrow];
	return self;
}

-andReturnInt:(int)anInt
{
//	NSLog(@"TMock should return int: %d",anInt);
	[[self controller] setIntResult:anInt];
//	NSLog(@"self in andReturnInt: %d = %p",anInt,self);
	return self;
}

-andReturn:returnValue
{
	[[self controller] setResult:returnValue];
	return self;
}

-shouldReceive
{
	[[self controller] recordOneMessage];
	[[self controller] setExpectedCount:1];
	return self;
}

-receiveTimes:(int)expected
{
//	NSLog(@"receiveTimes: %d forwarding to controller",expected);
	[[self controller] setCurrentExpectedCount:expected];
	return self;
}

-stub
{
	[[self controller] recordOneMessage];
	[[self controller] setExpectedCount:-1];
	[[self controller] setPartialMockAllowed:YES];
	return self;
}

-ordered
{
	[[self controller] ordered];
	return self;
}

-mock
{
	[[self controller] recordOneMessage];
	[[self controller] setPartialMockllowed:YES];
	return self;
}

-skipParameterChecks
{
	[[self controller] skipParameterChecks];
	return self;
}

-skipParameterCheck:(int)parameterToIgnore
{
	[[self controller] skipParameterCheck:parameterToIgnore];
	return self;
}

@end


@implementation NSObject(mock)


-andThrow:objectToThrow
{
	[[TMockController mockControllerForObject:self] setExceptionResult:objectToThrow];
	return self;
}


-skipParameterChecks
{
	[[TMockController mockControllerForObject:self] skipParameterChecks];
	return self;
}


-receiveTimes:(int)expected
{
	//	NSLog(@"receiveTimes: %d forwarding to controller",expected);
	[[TMockController mockControllerForObject:self]  setCurrentExpectedCount:expected];
	return self;
}


-(void)returnBool:(BOOL)aValue
{
	//	NSLog(@"should return bool: %d",aValue);
	[[TMockController mockControllerForObject:self] setCharResult:aValue];
}


-andReturnBool:(BOOL)aValue
{
	[[TMockController mockControllerForObject:self] setCharResult:aValue];
	return self;
}



-mock
{
	TMockController *controller=[TMockController mockControllerForObject:self];
	[controller recordOneMessage];
	id stub = [controller inlineMock];
	[controller setExpectedCount:-1];
	[controller setPartialMockAllowed:YES];
	//	NSLog(@"will return inline mock: %p",stub);
	return stub;
}

-stub
{
	TMockController *controller=[TMockController mockControllerForObject:self];
	[controller recordOneMessage];
	id stub = [controller inlineMock];
	[controller setExpectedCount:-1];
	[controller setPartialMockAllowed:YES];
//	NSLog(@"will return inline mock: %p",stub);
	return stub;
}

-shouldReceive
{
	TMockController *controller=[TMockController mockControllerForObject:self];
	[controller recordOneMessage];
	[controller setExpectedCount:1];
	return [controller inlineMock];
}

-shouldNotReceive
{
	TMockController *controller=[TMockController mockControllerForObject:self];
	[controller recordOneMessage];
	[controller setExpectedCount:0];
	return [controller inlineMock];
}

-andReturnInt:(int)anInt
{
	[[TMockController mockControllerForObject:self] setIntResult:anInt];
	return self;
}

-skipParameterCheck:(int)parameterToIgnore
{
//	NSLog(@"skipParameterCheck: %d",parameterToIgnore);
	[[TMockController mockControllerForObject:self] skipParameterCheck:parameterToIgnore];
	return self;
}


-ordered 
{
	[[TMockController mockControllerForObject:self] ordered];
	return self;
}

+mock
{
	TMockController *controller=[TMockController mockControllerForObject:self];
	[controller recordOneMessage];
	id stub = [controller inlineMockClass];
	[controller setExpectedCount:-1];
	[controller setPartialMockAllowed:YES];
	//	NSLog(@"will return inline mock: %p",stub);
	return stub;
}

+shouldReceive { return self; }
+stub { return self; }

-(void)forwardInvocation:(NSInvocation *)invocation
{
	[[TMockController fetchControllerForObject:self] handleMockedInvocation:invocation];
}

+(void)forwardInvocation:(NSInvocation *)invocation
{
	[[TMockController fetchControllerForObject:self] handleMockedInvocation:invocation];
}



@end
