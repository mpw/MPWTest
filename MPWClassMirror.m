//
//  MPWClassMirror.m
//  MPWTest
//
//  Created by Marcel Weiher on 5/29/11.
//  Copyright 2011 metaobject ltd. All rights reserved.
//

#import "MPWClassMirror.h"


@implementation MPWClassMirror

-initWithClass:(Class)aClass
{
	self=[super init];
	theClass=aClass;
	return self;
}

+mirrorWithClass:(Class)aClass
{
	return [[[self alloc] initWithClass:aClass] autorelease];
}

-(BOOL)isInBundle:(NSBundle*)aBundle
{
	return [NSBundle bundleForClass:[self theClass]] == aBundle;
}

-(NSString*)name
{
	return [NSString stringWithUTF8String:[self cStringClassName]];
}


-(NSArray*)invalidClassNames
{
	static id invalidClassNames=nil;
	if (!invalidClassNames) {
		invalidClassNames=[[NSArray alloc] initWithObjects:
						   @"NSFramework_",
						   @"NSATSGlyphGen",
						   @"_",
						   @"Object",
						   @"NSMessageBuilder",
#if WINDOWS						   
						   @"Object",
						   @"NSProxy",
						   @"MPWSoftPointerProxy",
						   @"MPWTrampoline",
						   @"MPWDirectForwarding",
						   @"Protocol",
						   @"MPWEnum",
						   @"MPWFutu",
						   @"SoftPointer",
						   @"_SoftPointer",
						   @"MPWFastInfoSet",
						   @"MPWXmlWrapper",
						   @"MPWXmlArchiver",
						   @"MPWXmlUnarchiver",
#endif						   
						   nil];
		
	}
	return invalidClassNames;
}


-(BOOL)isValidClass
{
	//	NSLog(@"checking validity of %@",cName);
#if WINDOWS	
	Class superclass= [self superclass];
	if ( superclass == nil ) {
		return NO;
	}
	if ( superclass == [NSProxy class] ) {
		return NO;
	}
#endif
	NSString *cName=[self name];
	for ( id name in [self invalidClassNames] ) {
		if ( [cName hasPrefix:name] ) {
			return NO;
		}
	}
	return YES;
}

+(NSArray*)allUsefulClasses
{
	NSMutableArray *useful=[NSMutableArray array];
	for ( MPWClassMirror *mirror in [self allClasses] ) {
		if ( [mirror isValidClass] ) {
			[useful addObject:mirror];
		}
	}
	return useful;
}

+(NSEnumerator*)classEnumerator
{
	return [[self allUsefulClasses] objectEnumerator];
}

-(Class)theClass { return theClass; }

-description { return [NSString stringWithFormat:@"<Mirror for class: %@/%p",[self name],[self theClass]]; }

-(MPWClassMirror*)superclassMirror
{
	return [[self class] mirrorWithClass:[self superclass]];
}

-(BOOL)isEqual:(id)otherMirror
{
	return [self theClass] == [otherMirror theClass];
}

-(NSUInteger)hash { return (NSUInteger)[self theClass]; }

-(BOOL)isSublcassOfClass:(Class)potentialSuperclass
{
	Class checkClass=[self theClass];
	while (checkClass) {
		if ( checkClass==potentialSuperclass ) {
			return YES;
		}
		checkClass=[[self class] superclassOfClass:checkClass];
	}
	return NO;
}

-(BOOL)isSublcassOfMirror:(MPWClassMirror *)potentialSuperclassMirror
{
	return [self isSublcassOfClass: [potentialSuperclassMirror theClass]];
}

-superclass
{
	return [[self class] superclassOfClass:[self theClass]];
}

-(MPWClassMirror*)createSubclassWithName:(NSString*)name
{
	return [[self class] mirrorWithClass:[self _createClass:[name UTF8String]]];
}

@end

#if __NEXT_RUNTIME__

#import <objc/runtime.h>

@implementation MPWClassMirror(objc)

-(const char*)cStringClassName
{
	return class_getName( [self theClass] );
}

+(Class)superclassOfClass:(Class)aClass
{
	return class_getSuperclass( aClass );
}

-(Class)_createClass:(const char*)name
{
	return objc_allocateClassPair([self theClass], name,0);
}

-(void)registerClass
{
	objc_registerClassPair([self theClass]);
}

+(NSArray*)allClasses
{
	NSMutableArray *allClasses=[NSMutableArray array];
    int classCount = objc_getClassList(NULL, 0);
    Class classes[classCount + 10];
    int i;
    objc_getClassList(classes, classCount);
	for (i=0;i<classCount;i++) {
		[allClasses addObject:[self mirrorWithClass:classes[i]]];
	}
	return allClasses;
}

-(void)addMethod:(IMP)aMethod forSelector:(SEL)aSelector
{
	class_addMethod([self theClass], aSelector, aMethod, "@@:");
}

-(void)replaceMethod:(IMP)aMethod forSelector:(SEL)aSelector
{
	class_replaceMethod([self theClass], aSelector, aMethod, "@@:");
}



@end

#elif 0



#endif

#import <MPWFoundation/DebugMacros.h>
#import <objc/message.h>
#import "MPWObjectMirror.h"


extern id _objc_msgForward(id receiver, SEL sel, ...);
@implementation MPWClassMirror(testing)

-(NSString*)__testMessageHi
{
	return @"Hello added method";
}

-(void)forwardInvocation:(NSInvocation*)inv
{
	NSString *hi=@"hi there";
	[inv setReturnValue:&hi];
}

+(void)testCreateSubclass
{
	NSObject *hi=[[[NSObject alloc] init] autorelease];
	id result=nil;
	MPWObjectMirror *objectMirror=[MPWObjectMirror mirrorWithObject:hi];
	@try {
		result = [hi __testMessageHi];
	} @catch (id e) {
		;
	}
	EXPECTNIL( result, @"should not have assigned a value");
	MPWClassMirror *mirror=[MPWClassMirror mirrorWithClass:[hi class]];
	MPWClassMirror *sub= [mirror createSubclassWithName:@"NSObjectSubclass"];
	[sub addMethod:[mirror methodForSelector:@selector(__testMessageHi)] forSelector:@selector(__testMessage)];
	[sub registerClass];
	[objectMirror setObjectClass:[sub theClass]];
	result = [hi __testMessage];
	IDEXPECT( result, @"Hello added method", @"after addition");
	[sub replaceMethod:_objc_msgForward  forSelector:@selector(__testMessage)];
	[sub replaceMethod:[mirror methodForSelector:@selector(forwardInvocation:)] forSelector:@selector(forwardInvocation:)];
	result = [hi __testMessage];
	IDEXPECT(result,@"hi there",@"via invocation");
}


+testSelectors
{
	return [NSArray arrayWithObjects:
				@"testCreateSubclass",
			nil];
}

@end


