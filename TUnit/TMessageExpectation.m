//
//  TMessageExpectation.m
//  MPWTest
//
//  Created by Marcel Weiher on 5/6/11.
//  Copyright 2011 metaobject ltd. All rights reserved.
//

#import "TMessageExpectation.h"
#import "AccessorMacros.h"


@implementation TMessageExpectation

idAccessor( exceptionToThrow, setExceptionToThrow )
objectAccessor( NSInvocation* , invocationToMatch, setInvocationToMatch )
objectAccessor( NSMutableIndexSet* , skippedParameters, setSkippedParameters )


-initWithInvocation:(NSInvocation*)invocation
{
	self=[super init];
	if ( self ) {
		[invocation retainArguments];
		[self setInvocationToMatch:invocation];
		[self setSkippedParameters:[NSMutableIndexSet indexSet]];
		
	}
	return self;
}

+expectationWithInvocation:(NSInvocation*)invocation
{
	return [[[self alloc] initWithInvocation:invocation] autorelease];
}

-(BOOL)compareInvocation:(NSInvocation*) inv1 withInvocation:(NSInvocation*)inv2
{
	if ( expectedCount > 0 && actualMatch >= expectedCount ) {
		return NO;
	}
	if (  [inv1 selector] != [inv2 selector] ) {
		return NO;
	} 
	NSMethodSignature *sig1=[inv1 methodSignature];
	NSMethodSignature *sig2=[inv2 methodSignature];
	if ( [sig1 numberOfArguments] != [sig2 numberOfArguments] ) {
		//		NSLog(@"numArgs %d %d",[sig1 numberOfArguments] ,[sig2 numberOfArguments] );
		return NO;
	}
	//	NSLog(@"-- checking: %@",NSStringFromSelector([inv1 selector]));
	for ( int i=2;i<[sig1 numberOfArguments]; i++) {
		if ( ![[self skippedParameters] containsIndex:i] ) {
			char argbuf1[128];
			char argbuf2[128];
			bzero(argbuf1, sizeof argbuf1);
			bzero(argbuf2, sizeof argbuf2);
			[inv1 getArgument:argbuf1 atIndex:i]; 
			[inv2 getArgument:argbuf2 atIndex:i];
			const char * argType = [sig1 getArgumentTypeAtIndex:i];
			//		NSLog(@"arg at index %d with type %s",i,argType);
			if ( argType ) {
				if ( *argType == 'r' ) {
					argType++;
				}
				switch (*argType) {
					case '*':
					{
						char *s1=*(char**)argbuf1;
						char *s2=*(char**)argbuf2;
						if (strcmp(s1,s2) ) {
							return NO;
						}
					}
						break;
					default:
						if ( memcmp(argbuf1, argbuf2, 128 ) ) {
							NSLog(@"arg at index %d with type %s didn't match!",i,argType);
							//						for (int j=0;j<10;j++ ) {
							//							NSLog(@"%d: %x %x",j,argbuf1[j],argbuf2[j]);
							//						}
							return NO;
						}
						
						break;
				}
			}		}
		

		
	}
	actualMatch++;
//	NSLog(@"actualMatch: %d / %d",actualMatch,expectedCount);
	return YES;
}

-(BOOL)unfulfilled
{
	return expectedCount > 0 && actualMatch < expectedCount;
}

-(void)setExpectedCount:(int)newCount
{
	expectedCount=newCount;
}

-(BOOL)matchesInvocation:(NSInvocation*)invocation
{
	return [self compareInvocation:invocation withInvocation:invocationToMatch];
}

-(void)setReturnValue:(void*)value
{
	[invocationToMatch setReturnValue:value];
	
}

-(void)getReturnValue:(void*)value
{
	[invocationToMatch getReturnValue:value];
	
}

-skipParameterChecks
{
	[self setSkippedParameters:[NSMutableIndexSet indexSetWithIndexesInRange:NSMakeRange(0, 10000)]];
	return self;
}

-description
{
	return [NSString stringWithFormat:@"<%@:%p: selector: %@ expected:%d actual: %d>",[self class],self,NSStringFromSelector([invocationToMatch selector]),expectedCount,actualMatch];
}


@end
