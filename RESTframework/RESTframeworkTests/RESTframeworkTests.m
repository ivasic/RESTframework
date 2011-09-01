//
//  RESTframeworkTests.m
//  RESTframeworkTests
//
//  Created by ivan on 5.4.11..
//  Copyright 2011 MobileWasp. All rights reserved.
//

#import "RESTframeworkTests.h"
#import "RESTRequest.h"
#import "RESTResponse.h"
#import "RESTSvc.h"

@implementation RESTframeworkTests

- (void)setUp
{
    [super setUp];
    
    // Set-up code here.
}

- (void)tearDown
{
    // Tear-down code here.
    
    [super tearDown];
}

-(void) testRequestTypes
{
	RESTRequest* r = [RESTRequest requestWithURL:nil type:RESTRequestTypeGet resourcePathComponents:nil];
	STAssertEqualObjects(r.requestType, @"GET", @"GET request invalid");
	
	r = [RESTRequest requestWithURL:nil type:RESTRequestTypePut resourcePathComponents:nil];
	STAssertEqualObjects(r.requestType, @"PUT", @"PUT request invalid");
	
	r = [RESTRequest requestWithURL:nil type:RESTRequestTypePost resourcePathComponents:nil];
	STAssertEqualObjects(r.requestType, @"POST", @"POST request invalid");
	
	r = [RESTRequest requestWithURL:nil type:RESTRequestTypeDelete resourcePathComponents:nil];
	STAssertEqualObjects(r.requestType, @"DELETE", @"DELETE request invalid");
}

- (void)testGetRequestResponse1
{
	RESTRequest* r = [RESTRequest requestWithURL:[NSURL URLWithString:@"test/"] type:RESTRequestTypeGet bodyType:RESTRequestBodyTypeFormUrlEncoded resourcePathComponents:@"sub1", @"sub2", nil];
	[r addParam:@"v1" forKey:@"p1"];
	[r addParam:@"v2" forKey:@"p2"];
	
	STAssertNotNil(r.serviceEndpoint, @"Endpoint is null!");
	STAssertNotNil(r.resourcePath, @"Path is null!");
	STAssertTrue(r.hasParams, @"No params!?");
	STAssertNotNil([r body], @"No body");
	STAssertEqualObjects(r.contentType, @"application/x-www-form-urlencoded", @"Content Type not ok");
	STAssertEqualObjects(r.resourcePathString, @"sub1/sub2", @"Invalid resource path");
	
	NSURLRequest* req = [r getUrlRequest];
	STAssertNotNil(req, @"Invalid url request");
	STAssertEqualObjects([[req URL] absoluteString], @"test/sub1/sub2?p2=v2&p1=v1", @"URL invalid");
	
	
	///response, empty w/ error
	NSError* err = [NSError errorWithDomain:@"testError" code:400 userInfo:nil];
	RESTResponse* response = [RESTResponse responseWithRequest:r error:err statusCode:400];
	STAssertEquals(r, response.request, @"Invalid request pointer");
	STAssertEquals(err, response.error, @"Invalid error pointer");
	STAssertEquals(response.httpCode, 400, @"Invalid HTTP code");
	STAssertEqualObjects([response stringValue], nil, @"Junk stringValue");
	STAssertEqualObjects([response dataValue], nil, @"Junk data");
}

- (void)testPostRequestResponse1
{
	RESTRequest* r = [RESTRequest requestWithURL:[NSURL URLWithString:@"test/"] type:RESTRequestTypePost bodyType:RESTRequestBodyTypeFormUrlEncoded resourcePathComponents:@"sub1", @"sub2", nil];
	[r addParam:@"v1" forKey:@"p1"];
	[r addParam:@"v2" forKey:@"p2"];
	
	STAssertNotNil(r.serviceEndpoint, @"Endpoint is null!");
	STAssertNotNil(r.resourcePath, @"Path is null!");
	STAssertTrue(r.hasParams, @"No params!?");
	STAssertNotNil([r body], @"No body");
	STAssertEqualObjects(r.contentType, @"application/x-www-form-urlencoded", @"Content Type not ok");
	STAssertEqualObjects(r.resourcePathString, @"sub1/sub2", @"Invalid resource path");
	
	NSURLRequest* req = [r getUrlRequest];
	STAssertNotNil(req, @"Invalid url request");
	STAssertEqualObjects([[req URL] absoluteString], @"test/sub1/sub2", @"URL invalid");
	
}

- (void)testPostDataRequestResponse1
{
	NSString* jsonBody = @"{\"p2\":\"v2\",\"p1\":\"v1\"}";
	NSData* jsonData = [jsonBody dataUsingEncoding:NSUTF8StringEncoding];
	
	RESTRequest* r = [RESTRequest requestWithURL:[NSURL URLWithString:@"test/"] type:RESTRequestTypePost bodyData:jsonData bodyType:RESTRequestBodyTypeFormUrlEncoded resourcePathComponents:@"sub1", @"sub2", @"sub3", nil];

	[r addParam:@"v1" forKey:@"p1"];
	[r addParam:@"v2" forKey:@"p2"];
	
	STAssertNotNil(r.serviceEndpoint, @"Endpoint is null!");
	STAssertNotNil(r.resourcePath, @"Path is null!");
	STAssertTrue(r.hasParams, @"No params!?");
	STAssertNotNil([r body], @"No body");
	STAssertEqualObjects(r.contentType, @"application/x-www-form-urlencoded", @"Content Type not ok");
	STAssertEqualObjects(r.resourcePathString, @"sub1/sub2/sub3", @"Invalid resource path");
	
	
	NSURLRequest* req = [r getUrlRequest];
	STAssertNotNil(req, @"Invalid url request");
	STAssertEqualObjects([[req URL] absoluteString], @"test/sub1/sub2/sub3", @"URL invalid");
}

@end
