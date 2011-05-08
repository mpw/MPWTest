//
//  TMessageExpectation.h
//  MPWTest
//
//  Created by Marcel Weiher on 5/6/11.
//  Copyright 2011 metaobject ltd. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface TMessageExpectation : NSObject {
	NSInvocation *invocationToMatch;
	int			 expectedCount;
	int			 actualMatch;
	id			 exceptionToThrow;
}

+expectationWithInvocation:(NSInvocation*)invocation;
-(BOOL)matchesInvocation:(NSInvocation*)invocation;

-(void)setExpectedCount:(int)newCount;
-(void)setExceptionToThrow:throwThis;

-(void)setReturnValue:(void*)value;
-(void)getReturnValue:(void*)value;
-(BOOL)unfulfilled;

@end
