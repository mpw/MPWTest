//
//  MPWClassMirror.h
//  MPWTest
//
//  Created by Marcel Weiher on 5/29/11.
//  Copyright 2011 metaobject ltd. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface MPWClassMirror : NSObject {
	Class theClass;
}

+mirrorWithClass:(Class)aClass;
-(NSString*)name;
+(NSArray*)allUsefulClasses;
-(Class)theClass;
-(Class)superclass;
-(BOOL)isInBundle:(NSBundle*)aBundle;

@end


@interface MPWClassMirror(objc)

-(const char*)cStringClassName;
+(Class)superclassOfClass:(Class)aClass;
+(NSArray*)allClasses;
-(Class)_createClass:(const char*)name;
-(void)registerClass;

@end
