//
//  TMockController.h
//  MPWTest
//
//  Created by Marcel Weiher on 4/10/11.
//  Copyright 2011 metaobject ltd. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface TMockController : NSObject {
	id originalObject;
	NSMutableArray* expectations;
	BOOL recording;
}


-(void)setDoubleResult:(double)aResult;
-(void)setFloatResult:(float)aResult;
-(void)setLongLongResult:(long long)aResult;
-(void)setIntResult:(int)aResult;
-(void)setShortResult:(short)aResult;
-(void)setCharResult:(char)aResult;

@end
