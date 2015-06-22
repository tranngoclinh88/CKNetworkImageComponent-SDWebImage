//
//  IAWCKImageDownloader.h
//  uChat
//
//  Created by Linh Tran on 6/19/15.
//  Copyright (c) 2015 Vietnam Unity App Studio. All rights reserved.
//

#import "CKNetworkImageDownloading.h"
#import "SDWebImageManager.h"

@interface IAWCKImageDownloader : NSObject <CKNetworkImageDownloading>
+ (instancetype)sharedManager;
- (instancetype)initWithWebImageManager:(SDWebImageManager *)manager NS_DESIGNATED_INITIALIZER;
- (instancetype)initWithSDWebImageManager;
@end
