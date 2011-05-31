//
//  TMockController.h
//  MPWTest
//
//  Created by Marcel Weiher on 4/10/11.
//  Copyright 2011 metaobject ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AccessorMacros.h"

@interface TMockController : NSObject {
	id originalObject;
	NSMutableArray* expectations;
	id mock;
//	NSMutableDictionary* results;
	int recordNumberOfMessages;
	id  copyOfOriginalObject;
	int nextExpectedCount;
	BOOL partialMockAllowed;
	int  size;
	

	
}

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
