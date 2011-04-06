//
//  RESTSvc.h
//
//  Created by Ivan on 9.3.11..
//  Copyright 2011 Ivan Vasic https://github.com/ivasic/RESTframework. All rights reserved.
//

#import <Foundation/Foundation.h>

@class RESTRequest;
@class RESTResponse;
@protocol RESTSvcDelegate;

@interface RESTSvc : NSObject {
	
	id<RESTSvcDelegate> delegate;
	NSURL* serviceEndpoint;
	
@private
	NSURLConnection*			urlConnection;
	NSMutableData*				webData;
	
	int							httpCode;
	RESTRequest*				currentRequest;
	
	NSMutableArray*				requestsQueue;
}

/*!
 * @property delegate
 * @abstract This is the pointer to RESTSvcDelegate
 */
@property (assign) id<RESTSvcDelegate> delegate;

/*!
 * @property serviceEndpoint
 * @abstract URL pointing to the base of RESTful service
 */
@property (retain) NSURL* serviceEndpoint;

/*!
 * @method execRequest:
 * @abstract Adds the request to the queue for execution and executes it when the time comes
 * @param request RESTRequest to be executed
 */
-(void) execRequest:(RESTRequest*)request;

/*!
 * @method cancelRequests
 * @abstract Cancels all the asynchronous REST HTTP requests in queue and releases all used resources
 */
-(void) cancelRequests;


/*
 * @method hasRequestWithTag:
 * @abstract This method checks if there's a queued or currently executing request with the specified tag
 * @param tag NSUInteger value to look up
 */
-(BOOL) hasRequestWithTag:(NSUInteger)tag;

/*
 * @method initWithEndpointURL:
 * @abstract Initializes the service with the enpoint URL
 * @param tag NSUInteger value to look up
 */
-(id) initWithEndpointURL:(NSURL*)url;

@end

/*!
 * @protocol RESTSvcDelegate
 * @abstract The RESTSvcDelegate protocol allows you to be informed when the RESTSvc service finishes
 * loading remote data and/or fails to do so.
 */
@protocol RESTSvcDelegate <NSObject>
/*!
 * @method restSvc:didFinishWithResponse:
 * @abstract This selector is performed on the delegate when the RESTSvc is finished loading remote data
 * @param svc The RESTSvc service
 * @param response RESTResponse
 */
-(void) restSvc:(RESTSvc*)svc didFinishWithResponse:(RESTResponse*)response;

@optional

/*!
 * @method restSvc:didStartLoadingRequest:
 * @abstract This selector is performed on the delegate when the RESTSvc has just started to execute REST request
 * @discussion This method will notify the delegate that the request has just started loading. It is also a perfect place to start a network activity indicator(s)
 * @param svc The RESTSvc service
 * @param request RESTRequest
 */
-(void) restSvc:(RESTSvc*)svc didStartLoadingRequest:(RESTRequest*)request;

/*!
 * @method restSvc:loadedData:
 * @abstract This method notifies the delegate how much data has been received in total (bytes).
 * @discussion If the delegate implements this method, it will be notified with the amount of data the service received since start. It's a good place to implement a progress view to show the user how many bytes are received.
 * @param svc The RESTSvc service
 * @param bytes NSUInteger number of data bytes received since the request started executing
 */
-(void) restSvc:(RESTSvc*)svc loadedData:(NSUInteger)bytes;

@end


