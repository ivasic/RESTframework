# Introduction

RESTframework is a lightweight Cocoa framework for working with RESTful web services. It's designed for simplicity rather than robustness. Although it will be enhanced in time with more and more features, simplicity of usage will be kept priority. RESTframework supports GET, POST, PUT and DELETE HTTP verbs wrapped in a simple interface keeping the implementation abstract. 


# How to use

To start, simply copy all files from RFClasses directory into your Xcode project. Build & make sure you get no errors. Now simply import RFRequest.h, RFResponse.h and RFService.h and you're ready to roll.

Xcode project also comes with a simple Flickr demo for echoing input and searching.

## Examples

### GET example

To GET a resource from URL that looks like http://myapi.example/api/v1/resources/myresource?param1=2&param2=test, we would do the following.


```objc
RFRequest *r = [RFRequest requestWithURL:[NSURL URLWithString:@"http://myapi.example/"] type:RFRequestMethodGet resourcePathComponents:@"api", @"v1", @"resources", @"myresource", nil];

[r addParam:@"2" forKey:@"param1"];
[r addParam:@"test" forKey:@"param2"];

//now execute this request and fetch the response in a block
[RFService execRequest:r completion:^(RFResponse *response) {
  NSLog(@"%@", r); //print out full response
  NSLog(@"%@", r.dataValue); //dataValue is received response as NSData (e.g. you can do [r.dataValue objectFromJSONData])
}];
```

### POST example

To POST application/x-www-form-urlencoded data to a resource at URL that looks like http://myapi.example/api/v1/resources, we would do the following.

```objc
RFRequest *r = [RFRequest requestWithURL:[NSURL URLWithString:@"http://myapi.example/"] type:RFRequestMethodGet resourcePathComponents:@"api", @"v1", @"resources", nil];

[r addParam:@"2" forKey:@"param1"];
[r addParam:@"test" forKey:@"param2"];

//now execute this request and fetch the response in a block
[RFService execRequest:r completion:^(RFResponse *response){
	NSLog(@"%@", r); //print out full response
	NSLog(@"%@", r.dataValue); //dataValue is received response as NSData (e.g. you can do [r.dataValue objectFromJSONData])
}];
```

Now, RESTframework currently has body encoding helpers for x-www-form-urlencoded and multipart/form-data (you can post files etc...). Third option is raw bytes where user is responsible for assigning NSData bytes for HTTP request body and setting appropriate content type.


**POST files (multipart/form-data)**

```objc
RFRequest* r = [RFRequest requestWithURL:[NSURL URLWithString:@"test/"] type:RFRequestMethodPost bodyContentType:RFRequestBodyTypeMultiPartFormData resourcePathComponents:@"sub1", @"sub2", nil];

//add files...
[r addData:[NSData dataWithContentsOfFile:@"myfilepath"] withContentType:@"image/png" forKey:@"mypic.png"]
```

**POST request with custom body encoding (content type)**

```objc
RFRequest* r = [RFRequest requestWithURL:[NSURL URLWithString:@"test/"] type:RFRequestMethodPost bodyContentType:RFRequestBodyTypeRawBytes resourcePathComponents:@"sub1", @"sub2", nil];	
	
//assign custom body data
NSString *xmlDataString = @"<Node>data</Node>";
r.bodyData = [xmlDataString dataUsingEncoding:NSUTF8StringEncoding];
  
//set custom content type
r.rawBytesBodyContentType = @"application/xml";
```

## License

RESTframework is licensed under GNU LGPL v2.1

## Credits

  - Ivan Vasic : http://www.ivanvasic.com/
  - Follow me @ivanvasic http://twitter.com/ivanvasic/
