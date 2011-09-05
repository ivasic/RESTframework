//
//  RFService.m
//  RESTframework
//
//  Created by Ivan Vasić on 9/4/11.
//  Copyright 2011 Ivan Vasic https://github.com/ivasic/RESTframework. All rights reserved.
//

#import "RFService.h"
#import "RFconf.h"
#import "RFRequest.h"
#import "RFResponse.h"

@interface RFService ()
@property (nonatomic, retain) RFRequest* currentRequest;
@property (readonly) NSMutableArray* requestsQueue;
@property (retain) id<RFServiceDelegate> asyncDelegate;
@property (copy) RFRequestCompletion asyncCompletionBlock;
@end

@interface RFService (privates)
-(void) continueExecFromQueue;
@end

@implementation RFService
@synthesize delegate, currentRequest, requestsQueue, asyncDelegate, asyncCompletionBlock;

#pragma mark - Props

-(NSMutableArray*) requestsQueue
{
	if (!requestsQueue) {
		requestsQueue = [[NSMutableArray array] retain];
	}
	
	return requestsQueue;
}

#pragma mark - Initialization

-(void) dealloc {
	[self cancelRequests];//if any...
	[requestsQueue release];
	requestsQueue = nil;
	self.currentRequest = nil;
	self.delegate = nil;
	self.asyncDelegate = nil;
	self.asyncCompletionBlock = nil;
	[webData release];
	[urlConnection release];
	[super dealloc];
}

#pragma mark - Execution

-(void) execRequest:(RFRequest*)request {
	
	//check if something is already running...
	if (self.currentRequest) {
		//if it is, queue the request for later
		[self.requestsQueue addObject:request];
		RFLog(@"Request %@ queued", request);
		return;
	}
	
	self.currentRequest = request;
	NSURLRequest* urlRequest = [request urlRequest];
	
	if (urlConnection != nil) {
		[urlConnection release];
		urlConnection = nil;
	}
	
	RFLog(@"executing: %@", [request URL]);
	urlConnection = [[NSURLConnection alloc] initWithRequest:urlRequest delegate:self startImmediately:YES];
	
	
	if (self.delegate && [self.delegate respondsToSelector:@selector(restService:didStartLoadingRequest:)]) {
		[self.delegate restService:self didStartLoadingRequest:request];
	}
}

-(void) continueExecFromQueue
{
	assert(!self.currentRequest);
	if (self.requestsQueue.count == 0) {
		return;
	}
	
	RFRequest* r = [[self.requestsQueue objectAtIndex:0] retain];
	[self.requestsQueue removeObjectAtIndex:0]; //remove from queue
	RFLog(@"Executing queued request: %@", r);
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
	
	for (RFRequest* r in self.requestsQueue) {
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
	if (self.delegate && [self.delegate respondsToSelector:@selector(restService:loadedData:)]) {
		[self.delegate restService:self loadedData:[webData length]];
	}
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
	[webData release];
	webData = nil;
	[urlConnection release];
	urlConnection = nil;
	
	//notify
	if (self.delegate && [(NSObject*)self.delegate respondsToSelector:@selector(restService:didFinishWithResponse:)]) {
		[self.delegate restService:self didFinishWithResponse:[RFResponse responseWithRequest:self.currentRequest error:error statusCode:httpCode]];
	}
	
	//nil it
	self.currentRequest = nil;
	[self continueExecFromQueue];
}


-(void)connectionDidFinishLoading:(NSURLConnection *)connection {
	[urlConnection release];
	urlConnection = nil;
	
	if (self.delegate && [(NSObject*)self.delegate respondsToSelector:@selector(restService:didFinishWithResponse:)]) {
		[self.delegate restService:self didFinishWithResponse:[RFResponse 
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

#pragma mark - Class Methods

+(void) execRequest:(RFRequest*)request completion:(RFRequestCompletion)completion
{
	RFService* svc = [[[RFService alloc] init] autorelease];
	svc.delegate = svc;
	svc.asyncDelegate = svc;
	svc.asyncCompletionBlock = completion;
	[svc execRequest:request];
}

#pragma mark - SVC delegate

-(void) restService:(RFService *)svc didFinishWithResponse:(RFResponse *)response
{
	self.asyncCompletionBlock(response);
	self.asyncCompletionBlock = nil;
	self.asyncDelegate = nil;
}
@end
