//
//  TMockController.m
//  MPWTest
//
//  Created by Marcel Weiher on 4/10/11.
//  Copyright 2011 metaobject ltd. All rights reserved.
//

#import "TMockController.h"
#import <objc/objc-runtime.h>
#import "TMock.h"
#import "TMessageExpectation.h"


@implementation TMockController


static NSMapTable* mockControllers=nil;

+(NSMapTable*)mockControllers
{
	if  (!mockControllers ) {
		mockControllers=[[NSMapTable mapTableWithStrongToStrongObjects] retain];
	}
	return mockControllers;
}

+(void)removeMocks
{
	[mockControllers release];
	mockControllers=nil;
}

+mockControllerForObject:anObject
{
	TMockController* controller=[[self mockControllers] objectForKey:anObject];
	if ( !controller ) {
		controller=[[[self alloc] initWithObject:anObject] autorelease];
		[[self mockControllers] setObject:controller forKey:anObject];
	}
	NSLog(@"controller for object %p is %p",anObject,controller);
	return controller;
	
}

-initWithObject:anObject
{
	self=[super init];
	if ( self ) {
		originalObject=[anObject retain];
		expectations=[[NSMutableArray alloc] init];
		recordNumberOfMessages=100000;
	}
	return self;
}


+mockController
{
	return [[[self alloc] initWithObject:nil] autorelease];
}

-mockForObject:anObject
{
	originalObject=[anObject retain];
	mock=NSAllocateObject(NSClassFromString(@"TMock"), 0, NSDefaultMallocZone());
	[mock initWithController:self];
	recordNumberOfMessages=100000;
	return mock;
}

-mockForClass:(Class)aClass
{
	return [self mockForObject:[[[aClass alloc] init] autorelease]];
}


-inlineMock
{
	if ( !mock ) {
		int size =  class_getInstanceSize( [originalObject class] );
		copyOfOriginalObject=malloc( size );
		memcpy( copyOfOriginalObject, originalObject, size );
		mock=originalObject;
		memset( mock,0, size );
		*(Class*)mock=NSClassFromString(@"TMock");
		[mock initWithController:self];
	}
	return mock;
}

-mockForMetaClassOfClass:(Class)aClass
{
	originalObject = aClass;
	mock=NSAllocateObject(NSClassFromString(@"TMock"), 0, NSDefaultMallocZone());
	recordNumberOfMessages=100000;
	[mock initWithController:self];
	return mock;
}



-(void)replay
{
	recordNumberOfMessages=0;
}

-(NSMethodSignature*)methodSignatureForMockedSelector:(SEL)sel
{
//	NSLog(@"methodSignatureForMockedSelector: %@",NSStringFromSelector(sel));
//	NSLog(@"originalObject: %@",originalObject);
	return [copyOfOriginalObject ? copyOfOriginalObject : originalObject methodSignatureForSelector:sel];
}

-(void)recordInvocation:(NSInvocation *)invocation
{
//	NSLog(@"recordInvocation %@",invocation);
	[expectations addObject:[TMessageExpectation expectationWithInvocation: invocation]];
}

-(BOOL)matchesInvocation:(NSInvocation*)invocation
{
	return ([expectations count] > 0) && [[expectations objectAtIndex:0] matchesInvocation:invocation];
}

-(void)checkAndRunInvocation:(NSInvocation *)invocation
{
	NSLog(@"checkAndRunInvocation %@",invocation);
//	[invocation setReturnValue:&empty];
	if ( [expectations count] > 0 ) {
		if (   [self matchesInvocation:invocation] ) {
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

-(void)recordOneMessage
{
	recordNumberOfMessages=1;
}

-(BOOL)shouldRecordMessage
{
	return recordNumberOfMessages>0 ;
}

-(void)handleMockedInvocation:(NSInvocation *)invocation
{
	NSLog(@"handleMockedInvocation %@",invocation);
	if ( [self shouldRecordMessage] ) {
		NSLog(@"recording %@",NSStringFromSelector([invocation selector]));
		recordNumberOfMessages--;
		[self recordInvocation:invocation];
#if 1		
		if  ( *[[invocation methodSignature] methodReturnType] != 'v' ) {
//			[[expectations objectAtIndex:0] getReturnValue:buf];
			[invocation setReturnValue:&mock];
		}
#endif		
	} else {
		NSLog(@"replay / check %@",NSStringFromSelector([invocation selector]));
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


void verifyAndCleanupMocks() 
{}

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
