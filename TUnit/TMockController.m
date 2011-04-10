//
//  TMockController.m
//  MPWTest
//
//  Created by Marcel Weiher on 4/10/11.
//  Copyright 2011 metaobject ltd. All rights reserved.
//

#import "TMockController.h"


@implementation TMockController

-init
{
	self=[super init];
	expectations=[[NSMutableArray alloc] init];
	recording=YES;
	return self;
}


+mockController
{
	return [[[self alloc] init] autorelease];
}

-mockForClass:(Class)aClass
{
	originalObject = [[aClass alloc] init];
	id mock=NSAllocateObject(NSClassFromString(@"TMock"), 0, NSDefaultMallocZone());
	[mock initWithController:self];
	return mock;
}

-(void)replay
{
	recording=NO;
}

-(NSMethodSignature*)methodSignatureForMockedSelector:(SEL)sel
{
	NSLog(@"methodSignatureForMockedSelector: %@",NSStringFromSelector(sel));
	NSLog(@"originalObject: %@",originalObject);
	return [originalObject methodSignatureForSelector:sel];
}



-(void)recordInvocation:(NSInvocation *)invocation
{
	NSLog(@"recordInvocation %@",invocation);
	[invocation retainArguments];
	[expectations addObject:invocation];
}

-(BOOL)compareInvocation:(NSInvocation*) inv1 withInvocation:(NSInvocation*)inv2
{
	return [inv1 selector] == [inv2 selector];
}

-(void)checkAndRunInvocation:(NSInvocation *)invocation
{
	NSLog(@"checkAndRunInvocation %@",invocation);
//	[invocation setReturnValue:&empty];
	if ( [expectations count] > 0 ) {
		if ( [self compareInvocation:invocation withInvocation:[expectations objectAtIndex:0]] ) {
			char buf[128];
			if  ( *[[invocation methodSignature] methodReturnType] != 'v' ) {
				[[expectations objectAtIndex:0] getReturnValue:buf];
				[invocation setReturnValue:buf];
			}
			NSLog(@"invocation checked out OK, returning: %@",invocation);
			[expectations removeObjectAtIndex:0];
			return;
		} else {
			[NSException raise:@"mock" format:@"mock doesn't match: %@ %@",invocation,[expectations objectAtIndex:0]];
		}
	} else {
		[NSException raise:@"mocktomuch" format:@"unexpected mock message %@",NSStringFromSelector([invocation selector])];
	}
}

-(void)handleMockedInvocation:(NSInvocation *)invocation
{
	NSLog(@"handleMockedInvocation %@",invocation);
	if ( recording ) {
		[self recordInvocation:invocation];
	} else {
		[self checkAndRunInvocation:invocation];
	}
	
}



-(void)setDoubleResult:(double)aResult
{
	[(NSInvocation*)[expectations lastObject] setReturnValue:&aResult];
}

-(void)setFloatResult:(float)aResult
{
	[(NSInvocation*)[expectations lastObject] setReturnValue:&aResult];
}

-(void)setLongLongResult:(long long)aResult
{
	[(NSInvocation*)[expectations lastObject] setReturnValue:&aResult];
}

-(void)setIntResult:(int)aResult
{
	[(NSInvocation*)[expectations lastObject] setReturnValue:&aResult];
}

-(void)setShortResult:(short)aResult
{
	[(NSInvocation*)[expectations lastObject] setReturnValue:&aResult];
}

-(void)setCharResult:(char)aResult
{
	[(NSInvocation*)[expectations lastObject] setReturnValue:&aResult];

}



-(void)verify
{
	if ( [expectations count] != 0) {
		[NSException raise:@"mock"  format:@"remaining expected messages: %@",expectations];
	}
}


-(NSArray*)recorded {
	return expectations;
}

-(void)dealloc
{
//	NSDeallocateObject(mock);
	[originalObject release];
	[expectations release];
	[super dealloc];
}



@end
