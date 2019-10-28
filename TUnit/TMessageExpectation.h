//
//  TMessageExpectation.h
//  MPWTest
//
//  Created by Marcel Weiher on 5/6/11.
//  Copyright 2011 Marcel Weiher. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AccessorMacros.h"


@interface TMessageExpectation : NSObject {
	NSInvocation *invocationToMatch;
	int			 expectedCount;
	int			 actualMatch;
	id			 exceptionToThrow;
	NSMutableIndexSet *skippedParameters;
	BOOL		isOrdered;
}

boolAccessor_h( isOrdered, setIsOrdered) 
+expectationWithInvocation:(NSInvocation*)invocation;
-(BOOL)matchesInvocation:(NSInvocation*)invocation;

-(void)setExpectedCount:(int)newCount;
-(void)setExceptionToThrow:throwThis;

-(void)setReturnValue:(void*)value;
-(void)getReturnValue:(void*)value;
-(BOOL)unfulfilled;

@end
