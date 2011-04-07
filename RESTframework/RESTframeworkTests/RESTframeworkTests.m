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
#import "JSONKit.h"

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

- (void)testGetRequest1
{
	RESTRequest* r = [RESTRequest requestWithURL:[NSURL URLWithString:@"test/"] type:RESTRequestTypeGet bodyType:RESTRequestBodyTypeJSON resourcePathComponents:@"sub1", @"sub2", nil];
	[r addParam:@"v1" forKey:@"p1"];
	[r addParam:@"v2" forKey:@"p2"];
	
	STAssertNotNil(r.serviceEndpoint, @"Endpoint is null!");
	STAssertNotNil(r.resourcePath, @"Path is null!");
	STAssertTrue(r.hasParams, @"No params!?");
	STAssertNotNil([r body], @"No body");
	STAssertEqualObjects(r.contentType, @"application/json", @"Content Type not ok");
	STAssertEqualObjects(r.resourcePathString, @"sub1/sub2", @"Invalid resource path");
	
	NSURLRequest* req = [r getUrlRequest];
	STAssertNotNil(req, @"Invalid url request");
	STAssertEqualObjects([[req URL] absoluteString], @"test/sub1/sub2?p2=v2&p1=v1", @"URL invalid");
}

- (void)testPostRequest1
{
	RESTRequest* r = [RESTRequest requestWithURL:[NSURL URLWithString:@"test/"] type:RESTRequestTypePost bodyType:RESTRequestBodyTypeJSON resourcePathComponents:@"sub1", @"sub2", nil];
	[r addParam:@"v1" forKey:@"p1"];
	[r addParam:@"v2" forKey:@"p2"];
	
	STAssertNotNil(r.serviceEndpoint, @"Endpoint is null!");
	STAssertNotNil(r.resourcePath, @"Path is null!");
	STAssertTrue(r.hasParams, @"No params!?");
	STAssertNotNil([r body], @"No body");
	STAssertEqualObjects(r.contentType, @"application/json", @"Content Type not ok");
	STAssertEqualObjects(r.resourcePathString, @"sub1/sub2", @"Invalid resource path");
	
	NSURLRequest* req = [r getUrlRequest];
	STAssertNotNil(req, @"Invalid url request");
	STAssertEqualObjects([[req URL] absoluteString], @"test/sub1/sub2", @"URL invalid");
	
	NSString* jsonBody = @"{\"p2\":\"v2\",\"p1\":\"v1\"}";
	NSData* jsonData = [jsonBody dataUsingEncoding:NSUTF8StringEncoding];
	
	STAssertEqualObjects(r.body, jsonData, @"Body failed to encode properly in RESTRequest");
	STAssertEqualObjects([req HTTPBody] , jsonData, @"Invalid body in NSURLRequest");
	STAssertEqualObjects([req valueForHTTPHeaderField:@"Content-Type"], @"application/json", @"Invalid NSURLRequest content type");
	
	NSString* len = [NSString stringWithFormat:@"%d", [jsonData length]];
	STAssertEqualObjects([req valueForHTTPHeaderField:@"Content-Length"], len, @"Content length invalid");
}


@end
