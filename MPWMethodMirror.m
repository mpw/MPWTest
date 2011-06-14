//
//  MPWMethodMirror.m
//  MPWTest
//
//  Created by Marcel Weiher on 5/30/11.
//  Copyright 2011 metaobject ltd. All rights reserved.
//

#import "MPWMethodMirror.h"
#import "AccessorMacros.h"

#pragma .h #import <Foundation/Foundation.h>

@implementation MPWMethodMirror : NSObject
{
	SEL selector;
	IMP imp;
	const char *typestring;
}

scalarAccessor( SEL, selector,setSelector )
scalarAccessor( IMP, imp, setImp )
scalarAccessor( const char *, typestring, setTypestring )

-(NSString*)name
{
	return NSStringFromSelector(selector);
}

-initWithSelector:(SEL)newSel typestring:(const char*)newTypes
{
	self=[super init];
	[self setSelector:newSel];
	[self setTypestring:newTypes];
	return self;
}



@end
