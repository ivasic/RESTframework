//
//  RFRequest.h
//  RESTframework
//
//  Created by Ivan Vasić on 9/2/11.
//  Copyright 2011 Ivan Vasic https://github.com/ivasic/RESTframework. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
	RFRequestMethodGet,
	RFRequestMethodPost,
	RFRequestMethodPut,
	RFRequestMethodDelete
} RFRequestMethod;

typedef enum {
    RFRequestBodyTypeFormUrlEncoded,
    RFRequestBodyTypeMultiPartFormData
} RFRequestBodyType;

@interface RFRequest : NSObject
{
	NSURL* serviceEndpoint;
	RFRequestMethod requestMethod;
	NSArray* resourcePath;
	
	NSDictionary* additionalHTTPHeaders;
	
	NSString* acceptsContentType;
	RFRequestBodyType bodyContentType;
	NSData* bodyData;
	
	NSMutableArray* params;
	
	NSUInteger tag;
}

/*!
 * @property serviceEndpoint
 * @abstract URL pointing to the base of RESTful service
 */
@property (nonatomic, retain) NSURL* serviceEndpoint;

/*!
 * @property requestMethod
 * @abstract REST request type, GET, POST, PUT or DELETE (RFRequestMethodGet, RFRequestMethodPost, RFRequestMethodPut, RFRequestMethodDelete)
 */
@property (nonatomic, assign) RFRequestMethod requestMethod;

/*!
 * @property resourcePath
 * @abstract REST resource path components. Appended to serviceEndpoint URL
 */
@property (nonatomic, retain) NSArray* resourcePath;

/*!
 * @property additionalHTTPHeaders
 * @abstract Additional HTTP headers in form of key/value dictionary to include with the HTTP request
 */
@property (nonatomic, retain) NSDictionary* additionalHTTPHeaders;

/*!
 * @property acceptsContentType
 * @abstract MIME ContentType service will accept. If nil, default is used * / *
 */
@property (nonatomic, retain) NSString* acceptsContentType;

/*!
 * @property hasParams
 * @abstract Helper, gets a BOOL indicating whether or not RFRequest has params
 */
@property (readonly) BOOL hasParams;

/*!
 * @method addParam:forKey:
 * @abstract Adds string param to request. The value SHOULD NOT BE url encoded.
 */
-(void) addParam:(NSString*)value forKey:(NSString*)key;

/*!
 * @method addData:withContentType:forKey:
 * @abstract Adds data (e.g. file) with specified MIME type for specified key
 */
-(void) addData:(NSData*)data withContentType:(NSString*)contentType forKey:(NSString*)key;

/*!
 * @property bodyContentType
 * @abstract RFRequestBodyType ContentType of request body. Not used with GET nor if there's no bodyData. Default is: application/x-www-form-urlencoded RFRequestBodyTypeMultiPartFormData
 */
@property (nonatomic, assign) RFRequestBodyType bodyContentType;

/*!
 * @property bodyData
 * @abstract Data send as HTTP request body. Not used if requestType is RFRequestMethodGet. If NIL NSURLRequest body will be set from params/data (@see addParam:forKey, @see addData:withContentType:forKey:). If set, this property takes precedence over params/data and will be sent as NSURLRequest body. 
 */
@property (nonatomic, retain) NSData* bodyData;

/*!
 * @property tag
 * @abstract optional int tag assigned to this RFRequest
 */
@property (nonatomic, assign) NSUInteger tag;

/*!
 * @method URL
 * @abstract Gets URL for this request
 */
-(NSURL*) URL;

/*!
 * @method urlRequest
 * @abstract Main method to convert RFRequest to NSURLRequest. Will take all RFRequest params & settings and convert them into NSURLRequest for futher usage (in RFService e.g.)
 */
-(NSURLRequest*) urlRequest;

/*!
 * @method initWithURL:type:resourcePath
 * @abstract Initializes RFRequest with url, type and resource path
 */
-(id) initWithURL:(NSURL*)url type:(RFRequestMethod)t resourcePath:(NSArray*)path;

/*!
 * @method initWithURL:type:resourcePath
 * @abstract Initializes RFRequest with url, type, resource path and bodyType (see bodyContentType)
 */
-(id) initWithURL:(NSURL*)url type:(RFRequestMethod)t resourcePath:(NSArray*)path bodyContentType:(RFRequestBodyType)bt;

/*!
 * @method requestWithURL:type:resourcePathComponents
 * @abstract Initializes RFRequest with url, type, resource path and returns an autoreleased RFRequest object
 */
+(id) requestWithURL:(NSURL*)url type:(RFRequestMethod)t resourcePathComponents:(id)firstObject, ... NS_REQUIRES_NIL_TERMINATION;

/*!
 * @method requestWithURL:type:bodyContentType:resourcePathComponents
 * @abstract Initializes RFRequest with url, type, resource path and returns an autoreleased RFRequest object
 */
+(id) requestWithURL:(NSURL*)url type:(RFRequestMethod)t bodyContentType:(RFRequestBodyType)bt resourcePathComponents:(id)firstObject, ... NS_REQUIRES_NIL_TERMINATION;

@end
