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
    NSMutableArray * layerInstructions = [NSMutableArray array];
    AVMutableComposition *mixComposition = self.videoData.composition;
    CMTime duration = [self.videoData.composition duration];
    CMTime overalDuration = duration;
    for (int i = 0; i < [self.assets count]; i++) {
        AVAsset * asset = self.assets[i];
        NSError *error = nil;
        AVMutableVideoCompositionLayerInstruction *layerInstruction = nil;
        NSArray<AVAssetTrack *> * videoTracks = [asset tracksWithMediaType:AVMediaTypeVideo];
        NSArray<AVAssetTrack *> * audioTracks = [asset tracksWithMediaType:AVMediaTypeAudio];
        if ([videoTracks count]) {
            AVMutableCompositionTrack *videoTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeVideo
                                                                                preferredTrackID:kCMPersistentTrackID_Invalid];
            
            [videoTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, asset.duration)
                                ofTrack:[videoTracks objectAtIndex:0]
                                 atTime:overalDuration
                                  error:&error];
            if (error) {
                NSLog(@"LLMergeCommand Error loading video asset %@", error);
            }
            layerInstruction = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:videoTrack];
            CGAffineTransform transform = videoTrack.preferredTransform;
            [layerInstruction setTransform:transform atTime:overalDuration];
            [layerInstructions addObject:layerInstruction];
        }
        if ([audioTracks count]) {
            AVMutableCompositionTrack *audioTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeAudio
                                                                                preferredTrackID:kCMPersistentTrackID_Invalid];
            
            [audioTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, asset.duration)
                                ofTrack:[audioTracks objectAtIndex:0]
                                 atTime:overalDuration
                                  error:&error];
            if (error) {
                NSLog(@"LLMergeCommand Error loading audio asset %@", error);
            }
        }
        overalDuration = CMTimeAdd(overalDuration, asset.duration);
        [layerInstruction setOpacity:0.0 atTime:overalDuration];
    }
    
    AVMutableVideoCompositionInstruction *instruction = nil;
    if(self.videoData.videoComposition.instructions.count == 0) {
        instruction = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
        AVMutableVideoCompositionLayerInstruction *layerInstruction = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:self.videoData.videoCompositionTrack];
        CGAffineTransform firstTransform = self.videoData.videoCompositionTrack.preferredTransform;
        [layerInstruction setTransform:firstTransform atTime:kCMTimeZero];
        [layerInstruction setOpacity:0.0 atTime:duration];
        instruction.layerInstructions = @[layerInstruction];
    }
    else {
        instruction = (AVMutableVideoCompositionInstruction *) [self.videoData.videoComposition.instructions lastObject];
        AVMutableVideoCompositionLayerInstruction *layerInstruction = (AVMutableVideoCompositionLayerInstruction *)[instruction.layerInstructions firstObject];
        [layerInstruction setOpacity:0.0 atTime:duration];
    }
    instruction.timeRange = CMTimeRangeMake(kCMTimeZero, overalDuration);
    
    [layerInstructions insertObject:[instruction.layerInstructions firstObject] atIndex:0];
    instruction.layerInstructions = layerInstructions;
    
    self.videoData.videoComposition.instructions = @[instruction];
}

@end
