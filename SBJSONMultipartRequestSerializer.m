//
//  SBJSONMultipartRequestSerializer.m
//
//  Copyright (c) 2015 Skye Book. All rights reserved.
//

#import "SBJSONMultipartRequestSerializer.h"

// Need to re-declare this interface
@interface AFStreamingMultipartFormData : NSObject <AFMultipartFormData>
- (instancetype)initWithURLRequest:(NSMutableURLRequest *)urlRequest
                    stringEncoding:(NSStringEncoding)encoding;

- (NSMutableURLRequest *)requestByFinalizingMultipartFormData;
@end

@implementation SBJSONMultipartRequestSerializer : AFJSONRequestSerializer

- (NSMutableURLRequest *)multipartFormRequestWithMethod:(NSString *)method
                                              URLString:(NSString *)URLString
                                             parameters:(NSDictionary *)parameters
                              constructingBodyWithBlock:(void (^)(id <AFMultipartFormData> formData))block
                                                  error:(NSError *__autoreleasing *)error
{
    NSParameterAssert(method);
    NSParameterAssert(![method isEqualToString:@"GET"] && ![method isEqualToString:@"HEAD"]);
    
    NSMutableURLRequest *mutableRequest = [self requestWithMethod:method URLString:URLString parameters:nil error:error];
    
    __block AFStreamingMultipartFormData *formData = [[AFStreamingMultipartFormData alloc] initWithURLRequest:mutableRequest stringEncoding:NSUTF8StringEncoding];
    
    if (parameters) {
        NSData *data = [NSJSONSerialization dataWithJSONObject:parameters options:self.writingOptions error:error];
        
        if (data) {
            [formData appendPartWithFileData:data name:@"post" fileName:@"post.json" mimeType:@"application/json"];
        }
    }
    
    if (block) {
        block(formData);
    }
    
    return [formData requestByFinalizingMultipartFormData];
}

@end
