//
//  RFResponse.h
//  RESTframework
//
//  Created by Ivan Vasić on 9/4/11.
//  Copyright 2011 Ivan Vasic https://github.com/ivasic/RESTframework. All rights reserved.
//

#import <Foundation/Foundation.h>

@class RFRequest;

@interface RFResponse : NSObject
{
	RFRequest*	request;
	NSData*			responseData;
	NSError*		error;
	int				httpCode;
}

/*!
 * @property httpCode
 * @abstract HTTP code RESTful service returned (e.g. 200, 404, 400, 500 etc...)
 */
@property int httpCode;

/*!
 * @property request
 * @abstract @link RFRequest @/link used to obtain this RFResponse
 */
@property (nonatomic, readonly, retain) RFRequest* request;

/*!
 * @property error
 * @abstract This propery will hold NSError if one occurs during request. NULL if there's no error
 */
@property (nonatomic, readonly, retain) NSError* error;


-(id) initWithRequest:(RFRequest*)req data:(NSData*)data statusCode:(int)statusCode;
-(id) initWithRequest:(RFRequest*)req error:(NSError*)e statusCode:(int)statusCode;

+(RFResponse*) responseWithRequest:(RFRequest*)req data:(NSData*)data statusCode:(int)statusCode;
+(RFResponse*) responseWithRequest:(RFRequest*)req error:(NSError*)e statusCode:(int)statusCode;

-(NSString*) stringValue;
-(NSString*) stringValueWithEncoding:(NSStringEncoding)encoding;
-(NSData*) dataValue;

@end
