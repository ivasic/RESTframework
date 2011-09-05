//
//  RFService.h
//  RESTframework
//
//  Created by Ivan Vasić on 9/4/11.
//  Copyright 2011 Ivan Vasic https://github.com/ivasic/RESTframework. All rights reserved.
//

#import <Foundation/Foundation.h>

@class RFRequest;
@class RFResponse;
@class RFService;
typedef void (^RFRequestCompletion)(RFResponse* response);

/*!
 * @protocol RFServiceDelegate
 * @abstract The RFServiceDelegate protocol allows you to be informed when the RFServiceRFService service finishes
 * loading remote data and/or fails to do so.
 */
@protocol RFServiceDelegate <NSObject>
/*!
 * @method restSvc:didFinishWithResponse:
 * @abstract This selector is performed on the delegate when the RFService is finished loading remote data
 * @param svc The RFService service
 * @param response RFResponse
 */
-(void) restService:(RFService*)svc didFinishWithResponse:(RFResponse*)response;

@optional

/*!
 * @method restService:didStartLoadingRequest:
 * @abstract This selector is performed on the delegate when the RFService has just started to execute REST request
 * @discussion This method will notify the delegate that the request has just started loading. It is also a perfect place to start a network activity indicator(s)
 * @param svc The RFService service
 * @param request RFRequest
 */
-(void) restService:(RFService*)svc didStartLoadingRequest:(RFRequest*)request;

/*!
 * @method restService:loadedData:
 * @abstract This method notifies the delegate how much data has been received in total (bytes).
 * @discussion If the delegate implements this method, it will be notified with the amount of data the service received since start. It's a good place to implement a progress view to show the user how many bytes are received.
 * @param svc The RFService service
 * @param bytes NSUInteger number of data bytes received since the request started executing
 */
-(void) restService:(RFService*)svc loadedData:(NSUInteger)bytes;

@end



@interface RFService : NSObject <RFServiceDelegate> {
	
	id<RFServiceDelegate> delegate;
	
@private
	NSURLConnection*			urlConnection;
	NSMutableData*				webData;
	
	int							httpCode;
	RFRequest*				currentRequest;
	
	NSMutableArray*				requestsQueue;
}

/*!
 * @property delegate
 * @abstract This is the pointer to RFServiceDelegate
 */
@property (assign) id<RFServiceDelegate> delegate;

/*!
 * @method execRequest:
 * @abstract Adds the request to the queue for execution and executes it when the time comes
 * @param request RFRequest to be executed
 */
-(void) execRequest:(RFRequest*)request;

/*!
 * @method execRequest:completion
 * @abstract Creates a RFService object and executes RFRequest async. Notifies about completion via completion block.
 * @param request RFRequest to be executed
 */
+(void) execRequest:(RFRequest*)request completion:(RFRequestCompletion)completion;

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

@end

