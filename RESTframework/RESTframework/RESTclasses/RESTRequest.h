//
//  RESTRequest.h
//
//  Created by Ivan on 9.3.11..
//  Copyright 2011 Ivan Vasic https://github.com/ivasic/RESTframework. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum restRequestType {
	RESTRequestTypeGet,
	RESTRequestTypePost,
	RESTRequestTypePut,
	RESTRequestTypeDelete
} RESTRequestType;

typedef enum {
    RESTRequestBodyTypeFormUrlEncoded,
    RESTRequestBodyTypeMultiPartFormData,
	RESTRequestBodyTypeJSON
} RESTRequestBodyType;

@interface RESTRequest : NSObject {
	RESTRequestType			type;
    RESTRequestBodyType     bodyType;
	NSArray*				resourcePath;
	NSMutableDictionary*	params;
	NSMutableDictionary*	files;
	NSUInteger				tag;
	NSURL*					serviceEndpoint;
}

/*!
 * @property serviceEndpoint
 * @abstract URL pointing to the base of RESTful service
 */
@property (retain) NSURL* serviceEndpoint;

@property RESTRequestType type;
@property RESTRequestBodyType bodyType;
@property (readonly) NSString* requestType;
@property (nonatomic, retain) NSArray* resourcePath;
@property (readonly) BOOL hasParams;
@property (readonly) BOOL hasFiles;
@property NSUInteger tag;

-(id) initWithURL:(NSURL*)url type:(RESTRequestType)t resourcePath:(NSArray*)path;
-(id) initWithURL:(NSURL*)url type:(RESTRequestType)t resourcePath:(NSArray*)path bodyType:(RESTRequestBodyType)bt;

+(id) requestWithURL:(NSURL*)url type:(RESTRequestType)t resourcePath:(NSArray*)path;
+(id) requestWithURL:(NSURL*)url type:(RESTRequestType)t resourcePath:(NSArray*)path bodyType:(RESTRequestBodyType)bt;

-(void) addParam:(NSString*)value forKey:(NSString*)key;
-(void) addFile:(NSData*)data withContentType:(NSString*)ct forKey:(NSString*)key;

-(NSData*) body;
-(NSString*) contentType;

-(NSURLRequest*) getUrlRequest;
-(NSString*) resourcePathString;

+(NSString*) requestTypeToString:(RESTRequestType)t;

@end
