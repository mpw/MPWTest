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
	NSLog(@"should return bool: %d",aValue);
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

-andThrow:anException
{
	return self;
}

-(void)andReturnInt:(int)anInt
{
	NSLog(@"TMock should return int: %d",anInt);
	[controller setIntResult:anInt];
}

-stub
{
	[controller recordOneMessage];
	return self;
}

@end


@implementation NSObject(mock)

-andReturn:returnValue
{
	return nil;
}

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
	NSLog(@"will return inline mock: %p",stub);
	return stub;
}

-shouldReceive
{
	TMockController *controller=[TMockController mockControllerForObject:self];
	[controller recordOneMessage];
	return [controller inlineMock];
}

-(void)andReturnInt:(int)anInt
{
	NSLog(@"NSObject should return int: %d",anInt);
	[[TMockController mockControllerForObject:self] setIntResult:anInt];
}



-ordered 
{
	return self;
}


@end