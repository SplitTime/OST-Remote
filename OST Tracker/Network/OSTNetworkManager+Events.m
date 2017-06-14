//
//  OSTNetworkManager+Events.m
//  OST Tracker
//
//  Created by Luciano Castro on 6/14/17.
//  Copyright © 2017 OST. All rights reserved.
//

#import "OSTNetworkManager+Events.h"

#define OSTEventsEndpoint @"events"

@implementation OSTNetworkManager (Events)

- (NSURLSessionDataTask*)getAllEventsWithCompletionBlock:(OSTCompletionObjectBlock)onCompletion errorBlock:(OSTErrorBlock)onError
{
    NSURLSessionDataTask *dataTask = [self GET:OSTEventsEndpoint parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject)
    {
      onCompletion(responseObject);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
      onError(error);
    }];
    
    [dataTask resume];
    return dataTask;
}

@end
