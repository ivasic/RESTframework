//
//  RESTSvc.m
//
//  Created by Ivan on 9.3.11..
//  Copyright 2011 Ivan Vasic https://github.com/ivasic/RESTframework. All rights reserved.
//

#import "RESTSvc.h"
#import "RESTRequest.h"
#import "RESTResponse.h"
#import "JSONKit.h"

@interface RESTSvc ()
@property (nonatomic, retain) RESTRequest* currentRequest;
@property (readonly) NSMutableArray* requestsQueue;
@end

@interface RESTSvc (privates)
-(void) continueExecFromQueue;
@end

@implementation RESTSvc
@synthesize delegate, currentRequest, requestsQueue;

#pragma mark - Props

-(NSMutableArray*) requestsQueue
{
	if (!requestsQueue) {
		requestsQueue = [[NSMutableArray array] retain];
	}
	
	return requestsQueue;
}

#pragma mark - Execution

-(void) execRequest:(RESTRequest*)request {
	
	//check if something is already running...
	if (self.currentRequest) {
		//if it is, queue the request for later
		[self.requestsQueue addObject:request];
		NSLog(@"Request %@ queued", request);
		return;
	}
	
	self.currentRequest = request;
	NSURLRequest* urlRequest = [request getUrlRequest];
	
	if (urlConnection != nil) {
		[urlConnection release];
		urlConnection = nil;
	}
	
	NSLog(@"REST Request: %@", [request resourcePathString]);
	urlConnection = [[NSURLConnection alloc] initWithRequest:urlRequest delegate:self startImmediately:YES];
	
	
	if (self.delegate && [self.delegate respondsToSelector:@selector(restSvc:didStartLoadingRequest:)]) {
		[self.delegate restSvc:self didStartLoadingRequest:request];
	}
}

-(void) continueExecFromQueue
{
	assert(!self.currentRequest);
	if (self.requestsQueue.count == 0) {
		return;
	}
	
	RESTRequest* r = [[self.requestsQueue objectAtIndex:0] retain];
	[self.requestsQueue removeObjectAtIndex:0]; //remove from queue
	NSLog(@"Executing queued request: %@", r);
	[self execRequest:r];
	[r release];
}

-(void) cancelRequests {
	
	if (urlConnection) {
		[urlConnection cancel];
		[urlConnection release];
		urlConnection = nil;
		[webData release];
		webData = nil;
	}
	
	self.currentRequest = nil;
	[requestsQueue release];
	requestsQueue = nil;
}

-(BOOL) hasRequestWithTag:(NSUInteger)tag
{
	if (self.currentRequest && self.currentRequest.tag == tag) {
		return YES;
	}
	
	for (RESTRequest* r in self.requestsQueue) {
		if (r.tag == tag) {
			return YES;
		}
	}
	
	return NO;
}

#pragma mark -
#pragma mark NSURLConnection delegate

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
	[webData release];
	webData = [[NSMutableData alloc] init];
	
	httpCode = 200; //OK
	if ([response respondsToSelector:@selector(statusCode)])
	{
		httpCode = [(NSHTTPURLResponse*)response statusCode];
	}
}


-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
	assert(webData != nil);
	[webData appendData:data];
	if (self.delegate && [self.delegate respondsToSelector:@selector(restSvc:loadedData:)]) {
		[self.delegate restSvc:self loadedData:[webData length]];
	}
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
	[webData release];
	webData = nil;
	[urlConnection release];
	urlConnection = nil;
	
	//notify
	if (self.delegate && [(NSObject*)self.delegate respondsToSelector:@selector(restSvc:didFinishWithResponse:)]) {
		[self.delegate restSvc:self didFinishWithResponse:[RESTResponse responseWithRequest:self.currentRequest error:error statusCode:httpCode]];
	}
	
	//nil it
	self.currentRequest = nil;
	[self continueExecFromQueue];
}


-(void)connectionDidFinishLoading:(NSURLConnection *)connection {
	[urlConnection release];
	urlConnection = nil;
	
	if (self.delegate && [(NSObject*)self.delegate respondsToSelector:@selector(restSvc:didFinishWithResponse:)]) {
		[self.delegate restSvc:self didFinishWithResponse:[RESTResponse 
														   responseWithRequest:self.currentRequest 
														   data:[NSData dataWithData:webData] 
														   statusCode:httpCode]];
	}
	
	[webData release];
	webData = nil;
	
	//nil it
	self.currentRequest = nil;
	[self continueExecFromQueue];
}


-(void) dealloc {
	[self cancelRequests];//if any...
	[requestsQueue release];
	requestsQueue = nil;
	self.currentRequest = nil;
	self.delegate = nil;
	[webData release];
	[urlConnection release];
	[super dealloc];
}

@end
