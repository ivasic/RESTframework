//
//  RESTSvc.h
//
//  Created by Ivan on 9.3.11..
//  Copyright 2011 Ivan Vasic ivasic@gmail.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@class RESTRequest;
@class RESTResponse;
@protocol RESTSvcDelegate;

@interface RESTSvc : NSObject {
	
	id<RESTSvcDelegate> delegate;
	
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

@end


/*!
 * @protocol RESTSvcDelegate
 * @abstract The RESTSvcDelegate protocol allows you to be informed when the RESTSvc service finishes
 * loading remote data and/or fails to do so.
 */
@protocol RESTSvcDelegate
/*!
 * @method restSvc:didFinishWithResponse:
 * @abstract This selector is performed on the delegate when the RESTSvc is finished loading remote data
 * @param svc The RESTSvc service
 * @param response RESTResponse
 */
-(void) restSvc:(RESTSvc*)svc didFinishWithResponse:(RESTResponse*)response;

@end


