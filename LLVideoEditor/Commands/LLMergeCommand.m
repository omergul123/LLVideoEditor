//
//  LLMergeCommand.m
//  LLVideoEditorExample
//
//  Created by Hariton Batkov on 12/24/15.
//  Copyright © 2015 Ömer Faruk Gül. All rights reserved.
//

#import "LLMergeCommand.h"

@interface LLMergeCommand ()
@property (weak, nonatomic) LLVideoData *videoData;
@property (strong, nonatomic) NSArray <AVAsset *> *assets;

@end

@implementation LLMergeCommand

// Thanks to http://www.raywenderlich.com/13418/how-to-play-record-edit-videos-in-ios

- (instancetype)initWithVideoData:(LLVideoData *)videoData mergeWithAssets:(NSArray <AVAsset *> *)assets {
    NSAssert(assets, @"Assets cannot be nil");
    NSAssert([assets count], @"Assets cannot be empty");
    if (self = [super init]) {
        self.videoData = videoData;
        self.assets = assets;
    }
    return self;
}

- (instancetype)initWithVideoData:(LLVideoData *)videoData mergeWithAsset:(AVAsset *)asset {
    return [self initWithVideoData:videoData
                   mergeWithAssets:@[asset]];
}

- (void)execute {
    AVMutableComposition *mixComposition = self.videoData.composition;
    
    for (int i = 0; i < [self.assets count]; i++) {
        AVAsset * asset = self.assets[i];
        AVMutableCompositionTrack *theTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeVideo
                                                                            preferredTrackID:kCMPersistentTrackID_Invalid];
        [theTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, asset.duration)
                          ofTrack:[[asset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0]
                           atTime:kCMTimeZero
                            error:nil];
    }
}

@end
