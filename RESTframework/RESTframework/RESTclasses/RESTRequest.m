//
//  RESTRequest.m
//
//  Created by Ivan on 9.3.11..
//  Copyright 2011 Ivan Vasic https://github.com/ivasic/RESTframework. All rights reserved.
//

#import "RESTRequest.h"
#import "RESTConf.h"
#import "JSONKit.h"

#define GS_POST_BOUNDARY @"----------ThIs_Is_tHe_bouNdaRY_$"

@interface RESTRequest ()
@property (nonatomic, retain) NSMutableDictionary*	params;
@property (nonatomic, retain) NSMutableDictionary*	files;
@end

@implementation RESTRequest
@synthesize type, resourcePath, requestType, bodyType, params, files, tag;

#pragma mark -
#pragma mark Properties

-(NSString*) requestType {
	return [RESTRequest requestTypeToString:self.type];
}

-(BOOL) hasParams {
	return self.params.count != 0;
}

-(BOOL) hasFiles {
	return self.files.count != 0;
}

#pragma mark - Initialization

-(id) initWithType:(RESTRequestType)t resourcePath:(NSArray*)path
{
	return [self initWithType:t resourcePath:path bodyType:RESTRequestBodyTypeFormUrlEncoded];
}

-(id) initWithType:(RESTRequestType)t resourcePath:(NSArray*)path bodyType:(RESTRequestBodyType)bt
{
    if ((self = [super init])) {
		self.type = t;
		self.resourcePath = path;
		self.bodyType = bt;
	}
	return self;
}

-(void) dealloc {
	self.params = nil;
	self.files = nil;
	self.resourcePath = nil;
	[super dealloc];
}

#pragma mark -
#pragma mark Methods

-(void) addParam:(NSString*)value forKey:(NSString*)key {
	if (!self.params) {
		self.params = [NSMutableDictionary dictionary];
	}
	
	//add key/value
	[self.params setObject:value forKey:key];
}

-(void) addFile:(NSData*)data withContentType:(NSString*)ct forKey:(NSString*)key {
	if (!self.files) {
		self.files = [NSMutableDictionary dictionary];
	}
	
	//add key/value
	[self.files setObject:[NSDictionary dictionaryWithObjectsAndKeys:data,@"data", ct, @"type", nil] forKey:key];
}

-(NSData*) body {
	if (!self.hasFiles && !self.hasParams) {
		return nil;
	}
	
	if (self.bodyType == RESTRequestBodyTypeFormUrlEncoded) {
		
		NSMutableArray* ps = [NSMutableArray array];
		for (NSString* p in self.params) {
			[ps addObject:[NSString stringWithFormat:@"%@=%@", p, [self.params objectForKey:p]]];
		}
		
		return [[ps componentsJoinedByString:@"&"] dataUsingEncoding:NSUTF8StringEncoding];
	}
	else if(self.bodyType == RESTRequestBodyTypeMultiPartFormData)
	{
		NSMutableData* data = [NSMutableData data];
		NSData* crlf = [[NSString stringWithString:@"\r\n"] dataUsingEncoding:NSUTF8StringEncoding];
		
		//plain params
		for (NSString* p in self.params) {
			[data appendData:[[NSString stringWithFormat:@"--%@", GS_POST_BOUNDARY] dataUsingEncoding:NSUTF8StringEncoding]];
			[data appendData:crlf];
			[data appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"", p] dataUsingEncoding:NSUTF8StringEncoding]];
			[data appendData:crlf];
			[data appendData:crlf];
			[data appendData:[[self.params objectForKey:p] dataUsingEncoding:NSUTF8StringEncoding]];
		}
		
		//files
		for (NSString* p in self.files) {
			NSDictionary* d = [self.files objectForKey:p];
			[data appendData:[[NSString stringWithFormat:@"--%@", GS_POST_BOUNDARY] dataUsingEncoding:NSUTF8StringEncoding]];
			[data appendData:crlf];
			[data appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"file\"; filename=\"%@\"", p] dataUsingEncoding:NSUTF8StringEncoding]];
			[data appendData:crlf];
			[data appendData:[[NSString stringWithFormat:@"Content-Type: %@", [d objectForKey:@"type"]] dataUsingEncoding:NSUTF8StringEncoding]];
			[data appendData:crlf];
			[data appendData:crlf];
			[data appendData:[d objectForKey:@"data"]];
			[data appendData:[[NSString stringWithFormat:@"--%@--", GS_POST_BOUNDARY] dataUsingEncoding:NSUTF8StringEncoding]];
			[data appendData:crlf];
			[data appendData:crlf];
		}
		
		return data;
	}
	else if (self.bodyType == RESTRequestBodyTypeJSON) {
		return [[self.params JSONString] dataUsingEncoding:NSUTF8StringEncoding];
	}
	
	NSLog(@"Unknown POST encoding?");
	return nil;
}

-(NSString*) contentType {
	switch (self.bodyType) {
		case RESTRequestBodyTypeFormUrlEncoded:
			return @"application/x-www-form-urlencoded";
		case RESTRequestBodyTypeMultiPartFormData:
			return [NSString stringWithFormat:@"multipart/form-data; boundary=%@", GS_POST_BOUNDARY];
		case RESTRequestBodyTypeJSON:
			return @"application/json";
		default:
			break;
	}
	
	NSLog(@"Unknown form encoding?");
	return nil;
}

-(NSURLRequest*) getUrlRequest {
	NSString* urlString = [NSString stringWithFormat:@"%@%@", 
						   ENDPOINT_URL, [self resourcePathString]];
	
	//We need to alter URL if it's a GET req..
	if (self.type == RESTRequestTypeGet && self.hasParams) {
		NSString* str = @"?";
		BOOL first = YES;
		for (NSString* p in self.params) {
			if(first) {
				str = [str stringByAppendingFormat:@"%@=%@", p, [self.params objectForKey:p]];
				first = NO;
				continue;
			}
			
			str = [str stringByAppendingFormat:@"&%@=%@", p, [self.params objectForKey:p]];
		}
		urlString = [urlString stringByAppendingString:str];
	}
	
	//URL
	NSURL* url = [NSURL URLWithString:urlString];
	
	//Request
	NSMutableURLRequest *urlRequest = [[[NSMutableURLRequest alloc] initWithURL:url] autorelease];
	
	//prepare http body
	[urlRequest setHTTPMethod: self.requestType];
	[urlRequest setValue:@"application/json" forHTTPHeaderField:@"Accept"];
	
	NSData* requestData = [self body];
	if ((self.type == RESTRequestTypePost || self.type == RESTRequestTypePut) && requestData) {
		[urlRequest setValue:[NSString stringWithFormat:@"%d", [requestData length]] forHTTPHeaderField:@"Content-Length"];
		[urlRequest setValue:[self contentType] forHTTPHeaderField:@"Content-Type"];
		[urlRequest setHTTPBody: requestData];
	}
	
	return urlRequest;
}

#pragma mark -
#pragma mark private

-(NSString*) resourcePathString {
	return [self.resourcePath componentsJoinedByString:@"/"];
}

+(NSString*) requestTypeToString:(RESTRequestType)t {
	switch (t) {
		case RESTRequestTypeGet:
			return @"GET";
		case RESTRequestTypePost:
			return @"POST";
		case RESTRequestTypePut:
			return @"PUT";
		case RESTRequestTypeDelete:
			return @"DELETE";
		default:
			return nil;
	}
}

-(NSString*) description {
	return [self resourcePathString];
}

@end
