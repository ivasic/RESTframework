/*
 *	RFRequest.m
 *	RESTframework
 *
 *	Created by Ivan Vasić on 9/2/11.
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

#import "RFRequest.h"
#import "RFconf.h"

#define kRFRequestParamKey @"kRFRequestParamKey"
#define kRFRequestParamValue @"kRFRequestParamValue"
#define kRFRequestParamEncoded @"kRFRequestParamEncoded"
#define kRFRequestParamMIME @"kRFRequestParamMIME"


#define kRFPostBoundary @"----------ThIs_Is_tHe_bouNdaRY_$"

@interface RFRequest ()
+(NSString*) requestMethodToString:(RFRequestMethod)t;
-(NSString*) contentTypeToString:(RFRequestBodyType)bt;
-(NSData*) constructBody;
-(BOOL) paramIsKeyValue:(NSDictionary*)d;

@property (nonatomic, retain) NSMutableArray* params;
@end

@implementation RFRequest
@synthesize serviceEndpoint;
@synthesize requestMethod;
@synthesize resourcePath;
@synthesize additionalHTTPHeaders;
@synthesize acceptsContentType;
@synthesize params;
@synthesize hasParams;
@synthesize bodyData;
@synthesize bodyContentType;
@synthesize rawBytesBodyContentType;
@synthesize tag;

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
		params = [[NSMutableArray array] retain];
    }
    
    return self;
}

-(id) initWithURL:(NSURL*)url type:(RFRequestMethod)t resourcePath:(NSArray*)path
{
	return [self initWithURL:url type:t resourcePath:path bodyContentType:RFRequestBodyTypeFormUrlEncoded];
}


-(id) initWithURL:(NSURL*)url type:(RFRequestMethod)t resourcePath:(NSArray*)path bodyContentType:(RFRequestBodyType)bt
{
	self = [self init];
	self.serviceEndpoint = url;
	self.requestMethod = t;
	self.resourcePath = path;
	self.bodyContentType = bt;
	
	return self;
}

+(id) requestWithURL:(NSURL*)url type:(RFRequestMethod)t resourcePathComponents:(id)firstObject, ... 
{
	NSMutableArray* path = [NSMutableArray array];
	id eachObject;
	va_list argumentList;
	if (firstObject) // The first argument isn't part of the varargs list,
	{                                   // so we'll handle it separately.
		[path addObject: firstObject];
		va_start(argumentList, firstObject); // Start scanning for arguments after firstObject.
		while ((eachObject = va_arg(argumentList, id))) // As many times as we can get an argument of type "id"
			[path addObject: eachObject]; // that isn't nil, add it to self's contents.
		va_end(argumentList);
	}
	return [[[RFRequest alloc] initWithURL:url type:t resourcePath:[NSArray arrayWithArray:path]] autorelease];
}

+(id) requestWithURL:(NSURL*)url type:(RFRequestMethod)t bodyContentType:(RFRequestBodyType)bt resourcePathComponents:(id)firstObject, ... 
{
	NSMutableArray* path = [NSMutableArray array];
	id eachObject;
	va_list argumentList;
	if (firstObject) // The first argument isn't part of the varargs list,
	{                                   // so we'll handle it separately.
		[path addObject: firstObject];
		va_start(argumentList, firstObject); // Start scanning for arguments after firstObject.
		while ((eachObject = va_arg(argumentList, id))) // As many times as we can get an argument of type "id"
			[path addObject: eachObject]; // that isn't nil, add it to self's contents.
		va_end(argumentList);
	}
	
	return [[[RFRequest alloc] initWithURL:url type:t resourcePath:path bodyContentType:bt] autorelease];
}

-(void) dealloc
{
	[additionalHTTPHeaders release], additionalHTTPHeaders = nil;
	[params release], params = nil;
	[bodyData release], bodyData = nil;
	[acceptsContentType release], acceptsContentType = nil;
	[serviceEndpoint release], serviceEndpoint = nil;
	[resourcePath release], resourcePath = nil;
	[super dealloc];
}

#pragma mark - Properties

-(BOOL) hasParams {
	return self.params.count != 0;
}

#pragma mark - Methods

-(void) addParam:(NSString*)value forKey:(NSString*)key
{
	[self addParam:value forKey:key alreadyEncoded:NO];
}

-(void) addParam:(NSString*)value forKey:(NSString*)key alreadyEncoded:(BOOL)encoded {
	if (!self.params) {
		params = [[NSMutableArray array] retain];
	}
	
	NSDictionary* pd = [NSDictionary dictionaryWithObjectsAndKeys:key, kRFRequestParamKey, value, kRFRequestParamValue, [NSNumber numberWithBool:encoded], kRFRequestParamEncoded, nil];
	
	//add param
	[self.params addObject:pd];
}

-(void) addData:(NSData*)data withContentType:(NSString*)contentType forKey:(NSString*)key {
	if (!self.params) {
		params = [[NSMutableArray array] retain];
	}
	
	NSDictionary* pd = [NSDictionary dictionaryWithObjectsAndKeys:key, kRFRequestParamKey, data, kRFRequestParamValue, contentType, kRFRequestParamMIME, nil];
	
	//add param
	[self.params addObject:pd];
}

-(NSURL*) URL
{
	NSString* urlString = [self.serviceEndpoint absoluteString];
	urlString = [urlString stringByAppendingString:[[self.resourcePath componentsJoinedByString:@"/"] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
	
	//We need to alter URL if it's a GET req..
	if (self.requestMethod == RFRequestMethodGet && self.hasParams) {
		NSString* str = @"?";
		BOOL first = YES;
		for (NSDictionary* p in self.params) {
			
			//strip out non-key value params (e.g. files, data...)
			if (![self paramIsKeyValue:p]) {
				continue;
			}
			
			BOOL isEncoded = [[p objectForKey:kRFRequestParamEncoded] boolValue];
			NSString* pKey = isEncoded ? [p objectForKey:kRFRequestParamKey] : [[p objectForKey:kRFRequestParamKey] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
			NSString* pValue = isEncoded ? [p objectForKey:kRFRequestParamValue] : [[p objectForKey:kRFRequestParamValue] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
			
			if(first) {
				first = NO;
			} else {
				str = [str stringByAppendingString:@"&"];
			}
			
			str = [str stringByAppendingFormat:@"%@=%@", pKey, pValue];
		}
		
		urlString = [urlString stringByAppendingString:str];
	}
	
	//URL
	NSURL* url = [NSURL URLWithString:urlString];
	return url;
}

-(NSURLRequest*) urlRequest
{
	//Request
	NSMutableURLRequest *urlRequest = [[[NSMutableURLRequest alloc] initWithURL:[self URL]] autorelease];
	
	//prepare http headers
	[urlRequest setHTTPMethod:[RFRequest requestMethodToString:self.requestMethod]];
	if (self.acceptsContentType && self.acceptsContentType.length > 0) {
		[urlRequest setValue:self.acceptsContentType forHTTPHeaderField:@"Accept"];
	} else {
		[urlRequest setValue:@"*/*" forHTTPHeaderField:@"Accept"];
	}
	
	//additional http headers
	if (self.additionalHTTPHeaders && self.additionalHTTPHeaders.count > 0) {
		for (id key in self.additionalHTTPHeaders) {
			[urlRequest setValue:[self.additionalHTTPHeaders objectForKey:key] forHTTPHeaderField:key];
		}
	}
	
	//use pre-set body data OR construct body from internal params
	NSData* bData = (self.bodyData && self.bodyData.length > 0) ? self.bodyData : [self constructBody];
	if (self.bodyData && self.bodyData.length > 0 && self.hasParams) {
		RFLogWarning(@"RFRequest has both bodyData set and params/data added");
	}
	
	if (self.requestMethod != RFRequestMethodGet && bData && bData.length > 0) {
		[urlRequest setValue:[NSString stringWithFormat:@"%d", [bData length]] forHTTPHeaderField:@"Content-Length"];
		[urlRequest setValue:[self contentTypeToString:self.bodyContentType] forHTTPHeaderField:@"Content-Type"];
		[urlRequest setHTTPBody:bData];
	}
	
	return urlRequest;
}

#pragma mark - Private

-(NSData*) constructBody
{
	if (self.requestMethod == RFRequestMethodGet) {
		return nil; //skip GET
	}
	
	NSData* bData = nil;
	
	if (self.bodyContentType == RFRequestBodyTypeFormUrlEncoded) {
		
		NSMutableArray* ps = [NSMutableArray array];
		for (NSDictionary* pd in self.params) {
			
			//strip out non-key value params (e.g. files, data...)
			if (![self paramIsKeyValue:pd]) {
				continue;
			}
			
			[ps addObject:[NSString stringWithFormat:@"%@=%@", [pd objectForKey:kRFRequestParamKey], [pd objectForKey:kRFRequestParamValue]]];
		}
		
		if (ps.count > 0) {
			bData = [[ps componentsJoinedByString:@"&"] dataUsingEncoding:NSUTF8StringEncoding];
		} else {
			RFLogWarning(@"FormUrlEncoded request has no params");
		}
		
		return bData;
	}
	else if(self.bodyContentType == RFRequestBodyTypeMultiPartFormData)
	{
		NSMutableData* data = [NSMutableData data];
		NSData* crlf = [[NSString stringWithString:@"\r\n"] dataUsingEncoding:NSUTF8StringEncoding];
		
		//plain params
		for (NSDictionary* pd in self.params) {
			
			//strip out non-key value params (e.g. files, data...)
			if (![self paramIsKeyValue:pd]) {
				continue;
			}
			
			[data appendData:[[NSString stringWithFormat:@"--%@", kRFPostBoundary] dataUsingEncoding:NSUTF8StringEncoding]];
			[data appendData:crlf];
			[data appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"", [pd objectForKey:kRFRequestParamKey]] dataUsingEncoding:NSUTF8StringEncoding]];
			[data appendData:crlf];
			[data appendData:crlf];
			[data appendData:[[pd objectForKey:kRFRequestParamValue] dataUsingEncoding:NSUTF8StringEncoding]];
		}
		
		//files
		for (NSDictionary* pd in self.params) {
			
			//strip out key value params
			if ([self paramIsKeyValue:pd]) {
				continue;
			}

			[data appendData:[[NSString stringWithFormat:@"--%@", kRFPostBoundary] dataUsingEncoding:NSUTF8StringEncoding]];
			[data appendData:crlf];
			[data appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"file\"; filename=\"%@\"", [pd objectForKey:kRFRequestParamKey]] dataUsingEncoding:NSUTF8StringEncoding]];
			[data appendData:crlf];
			[data appendData:[[NSString stringWithFormat:@"Content-Type: %@", [pd objectForKey:kRFRequestParamMIME]] dataUsingEncoding:NSUTF8StringEncoding]];
			[data appendData:crlf];
			[data appendData:crlf];
			[data appendData:[pd objectForKey:kRFRequestParamValue]];
			[data appendData:[[NSString stringWithFormat:@"--%@--", kRFPostBoundary] dataUsingEncoding:NSUTF8StringEncoding]];
			[data appendData:crlf];
			[data appendData:crlf];
		}
		
		if (data && data.length > 0) {
			bData = data;
		}
		
		return bData;
	}
/*	else if (self.bodyType == RESTRequestBodyTypeJSON) {
		if ([self.params objectForKey:GS_BODY_DATA_KEY]) {
			return [self.params objectForKey:GS_BODY_DATA_KEY];
		}
		NSAssert(NO, @"Invalid Request body");
	}*/
	
	RFLogError(@"Unknown body type encoding: %d", self.bodyContentType);
	return nil;
}

+(NSString*) requestMethodToString:(RFRequestMethod)t
{
	switch (t) {
		case RFRequestMethodGet:
			return @"GET";
		case RFRequestMethodPost:
			return @"POST";
		case RFRequestMethodPut:
			return @"PUT";
		case RFRequestMethodDelete:
			return @"DELETE";
		default:
			RFLogError(@"RFRequestMethod invalid %d", t);
			return nil;
	}
}

-(NSString*) contentTypeToString:(RFRequestBodyType)bt
{
	switch (bt) {
		case RFRequestBodyTypeFormUrlEncoded:
			return @"application/x-www-form-urlencoded";
		case RFRequestBodyTypeMultiPartFormData:
			return [NSString stringWithFormat:@"multipart/form-data; boundary=%@", kRFPostBoundary];
			/*case RESTRequestBodyTypeJSON:
			 return @"application/json";*/
		case RFRequestBodyTypeRawBytes:
			if (!self.rawBytesBodyContentType || self.rawBytesBodyContentType.length == 0) 
				RFLogError(@"RFRequest body content type set to RFRequestBodyTypeRawBytes but rawBytesBodyContentType is NULL");
			return self.rawBytesBodyContentType;
		default:
			break;
	}
	
	RFLogError(@"Unknown form encoding? %d", bt);
	return nil;
}

-(BOOL) paramIsKeyValue:(NSDictionary*)d;
{
	//right now, params without MIME are key/value. Might change in the future
	return [d objectForKey:kRFRequestParamMIME] == nil;
}

#pragma mark - Overriden

-(NSString*) description
{
	return [NSString stringWithFormat:@"RFRequest %@ %@", [RFRequest requestMethodToString:self.requestMethod], [self URL]];
}

@end
