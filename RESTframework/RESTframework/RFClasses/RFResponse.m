//
//  RFResponse.m
//  RESTframework
//
//  Created by Ivan Vasić on 9/4/11.
//  Copyright 2011 Ivan Vasic https://github.com/ivasic/RESTframework. All rights reserved.
//

#import "RFResponse.h"
#import "RFRequest.h"

@interface RFResponse()
@property (nonatomic, readwrite, retain) RFRequest*	request;
@property (nonatomic, readwrite, retain) NSData*	responseData;
@property (nonatomic, readwrite, retain) NSError*	error;
@end


@implementation RFResponse
@synthesize responseData, error, request, httpCode;

#pragma mark -
#pragma mark Initialization

-(id) initWithRequest:(RFRequest*)req data:(NSData*)data statusCode:(int)statusCode {
	if ((self = [super init])) {
		self.responseData = data;
		self.request = req;
		self.httpCode = statusCode;
	}
	
	return self;
}

-(id) initWithRequest:(RFRequest*)req error:(NSError*)e statusCode:(int)statusCode {
	if ((self = [super init])) {
		self.error = e;
		self.request = req;
		self.httpCode = statusCode;
	}
	
	return self;
}

+(RFResponse*) responseWithRequest:(RFRequest*)req data:(NSData*)data statusCode:(int)statusCode {
	return [[[RFResponse alloc] initWithRequest:req data:data statusCode:statusCode] autorelease];
}

+(RFResponse*) responseWithRequest:(RFRequest*)req error:(NSError*)e statusCode:(int)statusCode {
	return [[[RFResponse alloc] initWithRequest:req error:e statusCode:statusCode] autorelease];
}

#pragma mark - Value Getters

-(NSString*) stringValue {
	if (!self.responseData || self.responseData.length == 0) {
		return nil;
	}
	
	return [[[NSString alloc] initWithData:self.responseData encoding:NSUTF8StringEncoding] autorelease];
}

-(NSString*) stringValueWithEncoding:(NSStringEncoding)encoding {
	if (!self.responseData || self.responseData.length == 0) {
		return nil;
	}
	
	return [[[NSString alloc] initWithData:self.responseData encoding:encoding] autorelease];
}

-(NSData*) dataValue {
	return self.responseData;
}

-(NSString*) description {
	if (self.error) {
		return [NSString stringWithFormat:@"RFResponse %@, HTTP: %d\r\nData: %@\r\nError: %@", [self.request URL], self.httpCode, self.stringValue, self.error];
	} else {
		return [NSString stringWithFormat:@"RFResponse %@, HTTP: %d\r\nData: %@", [self.request URL], self.httpCode, self.stringValue];
	}
}

-(void) dealloc {
	self.request = nil;
	self.responseData = nil;
	self.error = nil;
	[super dealloc];
}

@end