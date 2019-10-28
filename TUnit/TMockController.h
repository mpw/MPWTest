//
//  TMockController.h
//  MPWTest
//
//  Created by Marcel Weiher on 4/10/11.
//  Copyright 2011 Marcel Weiher. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AccessorMacros.h"

@class MPWClassMirror,MPWObjectMirror;

@interface TMockController : NSObject {
	id originalObject;
	NSMutableArray* expectations;
	id mock;
	int recordNumberOfMessages;
	int nextExpectedCount;
	BOOL partialMockAllowed;
	int  size;
	MPWClassMirror *originalClass,*mockingSubclass;
	MPWObjectMirror *objectMirror;
	NSMutableDictionary *mockedMessagesForClass;
}

+fetchControllerForObject:anObject;
+mockControllerForObject:anObject;
-initWithObject:anObject;

boolAccessor_h( partialMockAllowed, setPartialMockAllowed )


-(void)replay;
-(void)recordOneMessage;
-inlineMock;

-(void)setDoubleResult:(double)aResult;
-(void)setFloatResult:(float)aResult;
-(void)setLongLongResult:(long long)aResult;
-(void)setIntResult:(int)aResult;
-(void)setShortResult:(short)aResult;
-(void)setCharResult:(char)aResult;
-(void)setExpectedCount:(int)newCount;
-(void)setCurrentExpectedCount:(int)newCount;

@end
