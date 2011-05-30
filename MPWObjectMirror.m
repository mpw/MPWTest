//
//  MPWObjectMirror.m
//  MPWTest
//
//  Created by Marcel Weiher on 5/30/11.
//  Copyright 2011 metaobject ltd. All rights reserved.
//

#import "MPWObjectMirror.h"
#import "AccessorMacros.h"
#import "MPWClassMirror.h"

@implementation MPWObjectMirror

idAccessor( theObject, setTheObject )

-initWithObject:anObject
{
	self=[super init];
	[self setTheObject:anObject];
	return self;
}

+mirrorWithObject:anObject
{
	return [[[self alloc] initWithObject:anObject] autorelease];
}
-(MPWClassMirror*)classMirror
{
	return [MPWClassMirror mirrorWithClass:[theObject class]];
}

-(void)setObjectClass:(Class)aClass
{
	*(Class*)theObject=aClass;
}

@end
