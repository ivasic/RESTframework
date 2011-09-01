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
@property (nonatomic, readonly, retain) NSError*		error;

-(id) initWithRequest:(RESTRequest*)req data:(NSData*)data statusCode:(int)statusCode;
-(id) initWithRequest:(RESTRequest*)req error:(NSError*)e statusCode:(int)statusCode;

+(RESTResponse*) responseWithRequest:(RESTRequest*)req data:(NSData*)data statusCode:(int)statusCode;
+(RESTResponse*) responseWithRequest:(RESTRequest*)req error:(NSError*)e statusCode:(int)statusCode;

-(NSString*) stringValue;
-(NSString*) stringValueWithEncoding:(NSStringEncoding)encoding;
-(NSData*) dataValue;

@end
