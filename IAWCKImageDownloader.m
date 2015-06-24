//
//  IAWCKImageDownloader.m
//
//  The MIT License (MIT)
//
//  Created by Linh Tran on 6/19/15.
//  Copyright (c) 2015 Vietnam Unity App Studio. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
//

#import "IAWCKImageDownloader.h"

@interface IAWCKImageDownloader ()
@property (nonatomic, strong) SDWebImageManager *webImageManager;
@property (nonatomic, assign) SDWebImageOptions webImageOptions;
@end

@implementation IAWCKImageDownloader

+ (instancetype)sharedManager {
	static IAWCKImageDownloader *instance;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		SDWebImageManager *webImageManager = [SDWebImageManager sharedManager];
		instance = [[self alloc] initWithWebImageManager:webImageManager];
		instance.webImageOptions = SDWebImageRetryFailed | SDWebImageContinueInBackground;
	});
	return instance;
}

- (instancetype)initWithWebImageManager:(SDWebImageManager *)manager {
	if (self = [super init]) {
		_webImageManager = manager;
	}
	return self;
}

- (instancetype)initWithSDWebImageManager {
	SDWebImageManager *webImageManager = [SDWebImageManager sharedManager]; // or other?
	return [self initWithWebImageManager:webImageManager];
}

#pragma mark - CKNetworkImageDownloading

- (id)downloadImageWithURL:(NSURL *)URL
                 scenePath:(id)scenePath
                    caller:(id)caller
             callbackQueue:(dispatch_queue_t)callbackQueue
     downloadProgressBlock:(void (^)(CGFloat progress))downloadProgressBlock
                completion:(void (^)(CGImageRef image, NSError *error))completion {
	// Validate the input URL
	if (!URL) {
		NSString *domain = [NSBundle bundleForClass:[self class]].bundleIdentifier;
		NSString *description = @"The URL of the image to download is unspecified";
		completion(nil, [NSError errorWithDomain:domain code:0 userInfo:@{ NSLocalizedDescriptionKey: description }]);
		return nil;
	}

	return [self.webImageManager downloadImageWithURL:URL options:self.webImageOptions progress: ^(NSInteger receivedSize, NSInteger expectedSize) {
	    if (downloadProgressBlock) {
	        dispatch_async(callbackQueue ? : dispatch_get_main_queue(), ^{
				downloadProgressBlock((CGFloat)receivedSize / expectedSize);
			});
		}
	} completed: ^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
	    if (!finished) {
	        return;
		}

	    dispatch_async(callbackQueue ? : dispatch_get_main_queue(), ^{
			completion(image.CGImage, error);
		});
	}];
}

- (void)cancelImageDownload:(id)download {
	if (!download) {
		return;
	}

	NSAssert([[download class] conformsToProtocol:@protocol(SDWebImageOperation)], @"Unexpected image download identifier");
	id <SDWebImageOperation> downloadOperation = download;
	[downloadOperation cancel];
}

@end
