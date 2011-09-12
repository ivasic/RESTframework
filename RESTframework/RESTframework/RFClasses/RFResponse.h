/*
 *	RFResponse.h
 *	RESTframework
 *
 *	Created by Ivan Vasić on 9/4/11.
 *	Copyright 2011 Ivan Vasic https://github.com/ivasic/RESTframework.
 *
 *	RESTframework is free software: you can redistribute it and/or modify
 *	it under the terms of the GNU Lesser General Public License as published by
 *	the Free Software Foundation, either version 3 of the License, or
 *	(at your option) any later version.
 *
 *	RESTframework is distributed in the hope that it will be useful,
 *	but WITHOUT ANY WARRANTY; without even the implied warranty of
 *	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *	GNU Lesser General Public License for more details.
 *	
 *	You should have received a copy of the GNU Lesser General Public License
 *	along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

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
