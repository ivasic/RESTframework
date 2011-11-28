/*
 *	RFService.h
 *	RESTframework
 *
 *	Created by Ivan Vasić on 9/4/11.
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

/*!
 * @method restService:sentData:
 * @abstract This method notifies the delegate how much data has been sent in total (bytes).
 * @discussion If the delegate implements this method, it will be notified with the amount of data the service sent since start. It's a good place to implement a progress view to show the user how many bytes are sent.
 * @param svc The RFService service
 * @param bytes NSUInteger number of data bytes sent since the request started executing
 * @param totalBytesExpected NSUInteger number of data bytes the service expects to send (can vary)
 */
-(void) restService:(RFService*)svc sentData:(NSUInteger)bytes totalBytesExpectedToSend:(NSUInteger)totalBytesExpected;

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
 * @abstract This is the pointer to @link RFServiceDelegate @/link
 */
@property (assign) id<RFServiceDelegate> delegate;

/*!
 * @method execRequest:
 * @abstract Adds the request to the queue for execution and executes it when the time comes
 * @param request @link RFRequest @/link to be executed
 */
-(void) execRequest:(RFRequest*)request;

/*!
 * @method execRequest:completion
 * @abstract Creates a RFService object and executes @link RFRequest @/link async. Notifies about completion via completion block.
 * @param request @link RFRequest @/link to be executed
 * @return RFService instance (use it to e.g. cancel the request)
 */
+(RFService*) execRequest:(RFRequest*)request completion:(RFRequestCompletion)completion;

/*!
 * @method execRequest:completion:dataReceived:dataSending:
 * @abstract Creates a RFService object and executes @link RFRequest @/link async. Notifies about completion via completion block.
 * @param request @link RFRequest @/link to be executed
 * @return RFService instance (use it to e.g. cancel the request)
 */
+(RFService*) execRequest:(RFRequest*)request completion:(RFRequestCompletion)completion dataReceived:(void(^)(NSUInteger totalBytesReceived))dataReceivedBlock dataSent:(void(^)(NSUInteger totalBytesSent, NSUInteger totalBytesExpected))dataSentBlock;

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

