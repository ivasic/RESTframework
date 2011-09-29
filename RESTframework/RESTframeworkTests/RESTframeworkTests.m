//
//  RESTframeworkTests.m
//  RESTframeworkTests
//
//  Created by ivan on 5.4.11..
//  Copyright 2011 MobileWasp. All rights reserved.
//

#import "RESTframeworkTests.h"
#import "RFRequest.h"
#import "RFResponse.h"

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

-(void) testRFRequestGET
{
	RFRequest* r = [[[RFRequest alloc] init] autorelease];
	r.serviceEndpoint = [NSURL URLWithString:@"http://dummy.url/path1/"];
	r.resourcePath = [NSArray arrayWithObjects:@"sub1", @"sub2", @"sub 3", @"sub+4", @"sub&5", @"sub-6", @"sub%7", @"sub@8", @"sub!9", nil];
	
	//additional headers
	r.additionalHTTPHeaders = [NSDictionary dictionaryWithObjectsAndKeys:@"v1", @"k1", @"v2", @"k2", nil];
	
	STAssertFalse(r.hasParams, @"Request has params even though none added");
	[r addParam:@"v1" forKey:@"k1"];
	[r addParam:@"v2" forKey:@"k2"];
	[r addParam:@"v3" forKey:@"k3"];
	[r addParam:@"v 4" forKey:@"k 4"];
	[r addParam:@"v+5" forKey:@"k+5"];
	[r addParam:@"v%6" forKey:@"k%6"];
	[r addParam:@"v&7" forKey:@"k&7"];
	STAssertTrue(r.hasParams, @"Request doesn't have params even though added");
	
	//try to confuse it
	[r addData:[@"qdwdqdqwdqwd" dataUsingEncoding:NSUTF8StringEncoding] withContentType:@"application/junk" forKey:@"junkData"];
	[r addData:[@"qdwdqdqwdqwd" dataUsingEncoding:NSUTF8StringEncoding] withContentType:@"application/junk" forKey:@"junkData"];
	STAssertTrue(r.hasParams, @"Request doesn't have params even though added");
	
	NSURL* url = [r URL];
	NSURLRequest* urlReq = [r urlRequest];
	
	STAssertEqualObjects(url, [NSURL URLWithString:@"http://dummy.url/path1/sub1/sub2/sub%203/sub+4/sub&5/sub-6/sub%257/sub@8/sub!9?k1=v1&k2=v2&k3=v3&k%204=v%204&k+5=v+5&k%256=v%256&k&7=v&7"], @"Incorrect URL");
	STAssertEqualObjects(url, [urlReq URL], @"URL's don't match");
	STAssertEqualObjects(urlReq.HTTPMethod, @"GET", @"Invalid HTTP method");
	STAssertEquals(r.requestMethod, RFRequestMethodGet, @"Invalid request type");
	STAssertEqualObjects([urlReq valueForHTTPHeaderField:@"k1"], @"v1", @"Invalid arg");
	STAssertEqualObjects([urlReq valueForHTTPHeaderField:@"k2"], @"v2", @"Invalid arg");
	STAssertNil([urlReq valueForHTTPHeaderField:@"Content-Type"], @"Shouldn't have Content-Type");
	STAssertNil([urlReq HTTPBody], @"Shouldn't have body");
	STAssertNotNil(r.serviceEndpoint, @"No endpoint");
	STAssertNotNil(r.resourcePath, @"No res path");
	STAssertTrue(r.additionalHTTPHeaders.count == 2, @"Additional headers count");
	
	
	STAssertEqualObjects([urlReq valueForHTTPHeaderField:@"Accept"], @"*/*", @"Invalid Accept HTTP field");
	STAssertNil([r acceptsContentType], @"Different Accept");
	r.acceptsContentType = @"my/type";
	urlReq = [r urlRequest];
	STAssertEqualObjects([urlReq valueForHTTPHeaderField:@"Accept"], @"my/type", @"Invalid Accept HTTP field");
}

-(void) testPOST
{
	//RFPostRequest
	RFRequest* r = [[[RFRequest alloc] init] autorelease];
	
	STAssertNil(r.serviceEndpoint , @"Service Endpoint should be nil");	
	STAssertNil(r.resourcePath, @"Resource path should be nil");
	STAssertNil(r.additionalHTTPHeaders, @"Aditionals HTTP headers should be nil");
	
	r.serviceEndpoint = [NSURL URLWithString:@"http://dummy.url/path1/"];
	r.resourcePath = [NSArray arrayWithObjects:@"sub1", @"sub2", @"sub 3", @"sub+4", @"sub&5", @"sub-6", @"sub%7", @"sub@8", @"sub!9", nil];
	r.requestMethod = RFRequestMethodPost;
	
	//additional headers
	r.additionalHTTPHeaders = [NSDictionary dictionaryWithObjectsAndKeys:@"v1", @"k1", @"v2", @"k2", nil];

	STAssertFalse(r.hasParams, @"Request has params even though none added");
	[r addParam:@"v1" forKey:@"k1"];
	[r addParam:@"v2" forKey:@"k2"];
	[r addParam:@"v3" forKey:@"k3"];
	[r addParam:@"v 4" forKey:@"k 4"];
	[r addParam:@"v+5" forKey:@"k+5"];
	[r addParam:@"v%6" forKey:@"k%6"];
	[r addParam:@"v&7" forKey:@"k&7"];
	STAssertTrue(r.hasParams, @"Request doesn't have params even though added");
	
	NSData *d = [[NSData alloc] initWithData:[@"qdwdqdqwdqwd" dataUsingEncoding:NSUTF8StringEncoding]];
	[r addData:d withContentType:@"application/junk" forKey:@"junkData"];
	
	r.bodyData = d;

	NSURL* url = [r URL];
	NSURLRequest* urlReq = [r urlRequest];

	STAssertTrue(r.hasParams, @"Request doesn't have params even though added");
	STAssertNotNil([urlReq HTTPBody], @"Should have body");
	STAssertEqualObjects([urlReq HTTPBody], d, @"Bodies shoud be same");
	
	STAssertEqualObjects(url, [urlReq URL], @"URL's don't match");
	STAssertEqualObjects(urlReq.HTTPMethod, @"POST", @"Invalid HTTP method");
	STAssertEquals(r.requestMethod, RFRequestMethodPost, @"Invalid request type");
	STAssertTrue(r.additionalHTTPHeaders.count == 2, @"Additional headers count");

	STAssertEqualObjects([urlReq valueForHTTPHeaderField:@"Accept"], @"*/*", @"Invalid Accept HTTP field");
	STAssertNil([r acceptsContentType], @"Different Accept");
	r.acceptsContentType = @"my/type";
	urlReq = [r urlRequest];
	STAssertEqualObjects([urlReq valueForHTTPHeaderField:@"Accept"], @"my/type", @"Invalid Accept HTTP field");
}

-(void) testRequestTypes
{
	RFRequest* r = [RFRequest requestWithURL:[NSURL URLWithString:@"http://dummy"] type:RFRequestMethodGet resourcePathComponents:nil];
	NSURLRequest* ur = [r urlRequest];
	STAssertEqualObjects(ur.HTTPMethod, @"GET", @"GET request invalid");
	
	r = [RFRequest requestWithURL:[NSURL URLWithString:@"http://dummy"] type:RFRequestMethodPut resourcePathComponents:nil];
	ur = [r urlRequest];
	STAssertEqualObjects(ur.HTTPMethod, @"PUT", @"PUT request invalid");
	
	r = [RFRequest requestWithURL:[NSURL URLWithString:@"http://dummy"] type:RFRequestMethodPost resourcePathComponents:nil];
	ur = [r urlRequest];
	STAssertEqualObjects(ur.HTTPMethod, @"POST", @"POST request invalid");
	
	r = [RFRequest requestWithURL:[NSURL URLWithString:@"http://dummy"] type:RFRequestMethodDelete resourcePathComponents:nil];
	ur = [r urlRequest];
	STAssertEqualObjects(ur.HTTPMethod, @"DELETE", @"DELETE request invalid");
}


-(void) testDefaults
{
	RFRequest* r = [RFRequest requestWithURL:[NSURL URLWithString:@"http://dummy"] type:RFRequestMethodGet resourcePathComponents:nil];
	NSURLRequest* ur = [r urlRequest];
	STAssertEqualObjects([ur valueForHTTPHeaderField:@"Accept"], @"*/*", @"invalid accept content type");
	
	//body content type
	r.requestMethod = RFRequestMethodPost;
	r.bodyData = [@"test" dataUsingEncoding:NSUTF8StringEncoding];
	ur = [r urlRequest];
	STAssertEqualObjects([ur valueForHTTPHeaderField:@"Content-Type"], @"application/x-www-form-urlencoded", @"Invalid content type");
}

- (void)testGetRequestResponse1
{
	RFRequest* r = [RFRequest requestWithURL:[NSURL URLWithString:@"test/"] type:RFRequestMethodGet bodyContentType:RFRequestBodyTypeFormUrlEncoded resourcePathComponents:@"sub1", @"sub2", nil];
	[r addParam:@"v1" forKey:@"p1"];
	[r addParam:@"v2" forKey:@"p2"];
	
	STAssertNotNil(r.serviceEndpoint, @"Endpoint is null!");
	STAssertNotNil(r.resourcePath, @"Path is null!");
	STAssertTrue(r.hasParams, @"No params!?");
	STAssertNil(r.bodyData, @"No custom body data assigned yet the property holds some value?");
	
	NSURLRequest* req = [r urlRequest];
	STAssertNil(r.bodyData, @"GET request shouldn't have body even after URLRequest is created");
	STAssertNotNil(req, @"Invalid url request");
	STAssertEqualObjects([[req URL] absoluteString], @"test/sub1/sub2?p1=v1&p2=v2", @"URL invalid");
	STAssertNil([req valueForHTTPHeaderField:@"Content-Type"], @"Content Type should be NULL");
	
	
	///response, empty w/ error
	NSError* err = [NSError errorWithDomain:@"testError" code:400 userInfo:nil];
	RFResponse* response = [RFResponse responseWithRequest:r error:err statusCode:400];
	STAssertEquals(r, response.request, @"Invalid request pointer");
	STAssertEquals(err, response.error, @"Invalid error pointer");
	STAssertEquals(response.httpCode, 400, @"Invalid HTTP code");
	STAssertEqualObjects([response stringValue], nil, @"Junk stringValue");
	STAssertEqualObjects([response dataValue], nil, @"Junk data");
}

- (void)testPostRequestResponse1
{
	RFRequest* r = [RFRequest requestWithURL:[NSURL URLWithString:@"test/"] type:RFRequestMethodPost bodyContentType:RFRequestBodyTypeFormUrlEncoded resourcePathComponents:@"sub1", @"sub2", nil];
	[r addParam:@"v1" forKey:@"p1"];
	[r addParam:@"v2" forKey:@"p2"];
	
	STAssertNotNil(r.serviceEndpoint, @"Endpoint is null!");
	STAssertNotNil(r.resourcePath, @"Path is null!");
	STAssertTrue(r.hasParams, @"No params!?");
	STAssertNil(r.bodyData, @"No custom body data assigned yet the property holds some value?");
	
	NSURLRequest* req = [r urlRequest];
	STAssertNotNil(req, @"Invalid url request");
	STAssertEqualObjects([[req URL] absoluteString], @"test/sub1/sub2", @"URL invalid");
	STAssertEqualObjects([req valueForHTTPHeaderField:@"Content-Type"], @"application/x-www-form-urlencoded", @"Invalid content type");
	
	STAssertTrue([[req HTTPBody] length] == 11, @"Invalid HTTP body, daata length should be 11 bytes instead of %d", [[req HTTPBody] length]);
}


- (void)testPostRequestBodyType
{
	RFRequest* r = [RFRequest requestWithURL:[NSURL URLWithString:@"test/"] type:RFRequestMethodPost bodyContentType:RFRequestBodyTypeRawBytes resourcePathComponents:@"sub1", @"sub2", nil];	
	[r addParam:@"v1" forKey:@"p1"];
	[r addParam:@"v2" forKey:@"p2"];
	NSString *xmlDataString = @"<Node>data</Node>";
	r.bodyData = [xmlDataString dataUsingEncoding:NSUTF8StringEncoding];
	r.rawBytesBodyContentType = @"application/xml";
	STAssertNotNil(r.serviceEndpoint, @"Endpoint is null!");
	STAssertNotNil(r.resourcePath, @"Path is null!");
	STAssertNotNil(r.bodyData, @"No custom body data assigned yet the property holds some value?");
	STAssertTrue(r.hasParams, @"No params!?");
	
	NSURLRequest* req = [r urlRequest];
	STAssertEqualObjects([[req URL] absoluteString], @"test/sub1/sub2", @"URL invalid");
	NSString *httpData = [[NSString alloc] initWithData:[req HTTPBody] encoding:NSUTF8StringEncoding];
	STAssertEqualObjects(httpData, xmlDataString, @"Data don't match");
	
	
}


-(void) testGETWithDateChars
{
	RFRequest* r = [[[RFRequest alloc] init] autorelease];
	r.serviceEndpoint = [NSURL URLWithString:@"http://dummy.url/path1/"];
	r.resourcePath = [NSArray arrayWithObjects:@"sub1", nil];
	
	NSDate* d = [NSDate date];
	NSDateFormatter* df = [[[NSDateFormatter alloc] init] autorelease];
	df.dateStyle = NSDateFormatterShortStyle;
	
	NSString* date = [[df stringFromDate:d] stringByAppendingString:@" 15:22h"];
	NSLog(@"%@", date);
	NSLog(@"%@", [date stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]);
	[r addParam:date forKey:@"date1 1"];
	STAssertEqualObjects([[[r urlRequest] URL] absoluteString], @"http://dummy.url/path1/sub1?date1%201=9/29/11%2015:22h", @"Param not encoded properly?");
	NSLog(@"%@", [[r urlRequest] URL]);
	
	//now the same but encoded
	r = [[[RFRequest alloc] init] autorelease];
	r.serviceEndpoint = [NSURL URLWithString:@"http://dummy.url/path1/"];
	r.resourcePath = [NSArray arrayWithObjects:@"sub1", nil];
	date = [[df stringFromDate:d] stringByAppendingString:@"%2015:22h"];
	[r addParam:date forKey:@"date1%201" alreadyEncoded:YES];
	STAssertEqualObjects([[[r urlRequest] URL] absoluteString], @"http://dummy.url/path1/sub1?date1%201=9/29/11%2015:22h", @"Param not encoded properly?");
	
	
}

@end
