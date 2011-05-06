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
}

+expectationWithInvocation:(NSInvocation*)invocation;
-(BOOL)matchesInvocation:(NSInvocation*)invocation;

-(void)setExpectedCount:(int)newCount;


-(void)setReturnValue:(void*)value;
-(void)getReturnValue:(void*)value;
-(BOOL)unfulfilled;

@end
