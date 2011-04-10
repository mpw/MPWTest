//
//  TMock.m
//  MPWTest
//
//  Created by Marcel Weiher on 4/10/11.
//  Copyright 2011 metaobject ltd. All rights reserved.
//

#import "TMock.h"


@implementation TMock

-(void)forwardInvocation:(NSInvocation *)invocation
{
	NSLog(@"forwarding %@ to %@",invocation,controller);
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

@end
