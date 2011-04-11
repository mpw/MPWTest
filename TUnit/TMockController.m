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
//	NSLog(@"methodSignatureForMockedSelector: %@",NSStringFromSelector(sel));
//	NSLog(@"originalObject: %@",originalObject);
	return [originalObject methodSignatureForSelector:sel];
}



-(void)recordInvocation:(NSInvocation *)invocation
{
//	NSLog(@"recordInvocation %@",invocation);
	[invocation retainArguments];
	[expectations addObject:invocation];
}

-(BOOL)compareInvocation:(NSInvocation*) inv1 withInvocation:(NSInvocation*)inv2
{
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
		char argbuf1[128];
		char argbuf2[128];
		bzero(argbuf1, sizeof argbuf1);
		bzero(argbuf2, sizeof argbuf2);
		[inv1 getArgument:argbuf1 atIndex:i]; 
		[inv2 getArgument:argbuf2 atIndex:i];
		char * argType = [sig1 getArgumentTypeAtIndex:i];
//		NSLog(@"arg at index %d with type %s",i,argType);
		if ( argType ) {
			if ( *argType == 'r' ) {
				argType++;
			}
			switch (*argType) {
#if 0
				case 'I':
				case 'i':
				case 's':
				case 'S':
				case 'c':
				case 'C':
				{
					int i1=*(int*)argbuf1;
					int i2=*(int*)argbuf2;
					if ( i1!=i2 ) {
						NSLog(@"scalar at %d doesn't match: %d %d",i,i1,i2);
						return NO;
					}
					break;
				}
				case 'f':
				{
					float f1=*(float*)argbuf1;
					float f2=*(float*)argbuf2;
					NSLog(@"float at %d: %g %g",i,f1,f2);
					if ( f1!=f2 ) {
						NSLog(@"float at %d doesn't match: %g %g",i,f1,f2);
						return NO;
					}
					break;
				}
				case 'd':
				{
					double f1=*(double*)argbuf1;
					double f2=*(double*)argbuf2;
					if ( f1!=f2 ) {
						NSLog(@"double at %d doesn't match: %g %g",i,f1,f2);
						return NO;
					}
					break;
				}	
#endif
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
//						NSLog(@"arg at index %d with type %s didn't match!",i,argType);
//						for (int j=0;j<10;j++ ) {
//							NSLog(@"%d: %x %x",j,argbuf1[j],argbuf2[j]);
//						}
						return NO;
					}
					
					break;
			}
		}
		
	}
	return YES;
}

-(void)checkAndRunInvocation:(NSInvocation *)invocation
{
//	NSLog(@"checkAndRunInvocation %@",invocation);
//	[invocation setReturnValue:&empty];
	if ( [expectations count] > 0 ) {
		if ( [self compareInvocation:invocation withInvocation:[expectations objectAtIndex:0]] ) {
			char buf[128];
			if  ( *[[invocation methodSignature] methodReturnType] != 'v' ) {
				[[expectations objectAtIndex:0] getReturnValue:buf];
				[invocation setReturnValue:buf];
			}
//			NSLog(@"invocation checked out OK, returning: %@",invocation);
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
//	NSLog(@"handleMockedInvocation %@",invocation);
	if ( recording ) {
		[self recordInvocation:invocation];
	} else {
		[self checkAndRunInvocation:invocation];
	}
	
}

#define setSomeResult( type, methodName ) \
-(void)methodName:(type)aResult {\
	[(NSInvocation*)[expectations lastObject] setReturnValue:&aResult];\
}\

setSomeResult( double, setDoubleResult )
setSomeResult( float, setFloatResult )
setSomeResult( long long, setLongLongResult )
setSomeResult( int, setIntResult )
setSomeResult( short, setShortResult )
setSomeResult( char, setCharResult )



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
