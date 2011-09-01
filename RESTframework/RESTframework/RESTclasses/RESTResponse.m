//
//  RESTResponse.m
//
//  Created by Ivan on 9.3.11..
//  Copyright 2011 Ivan Vasic https://github.com/ivasic/RESTframework. All rights reserved.
//

#import "RESTResponse.h"
#import "RESTRequest.h"

@interface RESTResponse()
@property (nonatomic, readwrite, retain) RESTRequest*	request;
@property (nonatomic, readwrite, retain) NSData*	responseData;
@property (nonatomic, readwrite, retain) NSError*	error;
@end


@implementation RESTResponse
@synthesize responseData, error, request, httpCode;

#pragma mark -
#pragma mark Initialization

-(id) initWithRequest:(RESTRequest*)req data:(NSData*)data statusCode:(int)statusCode {
	if ((self = [super init])) {
		self.responseData = data;
		self.request = req;
		self.httpCode = statusCode;
	}
	
	return self;
}

-(id) initWithRequest:(RESTRequest*)req error:(NSError*)e statusCode:(int)statusCode {
	if ((self = [super init])) {
		self.error = e;
		self.request = req;
		self.httpCode = statusCode;
	}
	
	return self;
}

+(RESTResponse*) responseWithRequest:(RESTRequest*)req data:(NSData*)data statusCode:(int)statusCode {
	return [[[RESTResponse alloc] initWithRequest:req data:data statusCode:statusCode] autorelease];
}

+(RESTResponse*) responseWithRequest:(RESTRequest*)req error:(NSError*)e statusCode:(int)statusCode {
	return [[[RESTResponse alloc] initWithRequest:req error:e statusCode:statusCode] autorelease];
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
	return [NSString stringWithFormat:@"RESTResponse %@, HTTP: %d\r\nData: %@\r\nError: %@",
			[self.request resourcePathString], self.httpCode, self.stringValue, self.error];
}

-(void) dealloc {
	self.request = nil;
	self.responseData = nil;
	self.error = nil;
	[super dealloc];
}

@end
