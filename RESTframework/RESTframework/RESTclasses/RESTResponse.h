//
//  RESTResponse.h
//
//  Created by Ivan on 9.3.11..
//  Copyright 2011 Ivan Vasic https://github.com/ivasic/RESTframework. All rights reserved.
//

#import <Foundation/Foundation.h>

@class RESTRequest;

@interface RESTResponse : NSObject {
	RESTRequest*	request;
	NSData*			responseData;
	NSError*		error;
	int				httpCode;
}

@property int											httpCode;
@property (nonatomic, readonly, retain) RESTRequest*	request;
@property (nonatomic, readonly, retain) NSData*			responseData;
@property (nonatomic, readonly, retain) NSError*		error;
@property (nonatomic, readonly)			NSString*		stringValue;
@property (nonatomic, readonly)			NSDictionary*	dictionaryValue;
@property (nonatomic, readonly)			NSArray*		arrayValue;

-(id) initWithRequest:(RESTRequest*)req data:(NSData*)data statusCode:(int)statusCode;
-(id) initWithRequest:(RESTRequest*)req error:(NSError*)e statusCode:(int)statusCode;

+(RESTResponse*) responseWithRequest:(RESTRequest*)req data:(NSData*)data statusCode:(int)statusCode;
+(RESTResponse*) responseWithRequest:(RESTRequest*)req error:(NSError*)e statusCode:(int)statusCode;

@end
