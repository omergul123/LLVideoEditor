//
//  LLCropCommand.m
//  LLVideoEditorExample
//
//  Created by Ömer Faruk Gül on 30/05/15.
//  Copyright (c) 2015 Ömer Faruk Gül. All rights reserved.
//

#import "LLCropCommand.h"

@interface LLCropCommand ()
@property (weak, nonatomic) LLVideoData *videoData;
@property (nonatomic) CGRect cropFrame;
@end

@implementation LLCropCommand
- (instancetype)initWithVideoData:(LLVideoData *)videoData cropFrame:(CGRect)cropFrame {
    self = [super init];
    if(self) {
        _videoData = videoData;
        _cropFrame = cropFrame;
    }
    
    return self;
}

- (void)execute {
    
    AVMutableVideoCompositionInstruction *instruction = nil;
    AVMutableVideoCompositionLayerInstruction *layerInstruction = nil;
    
    //CMTime duration = self.videoData.videoCompositionTrack.timeRange.duration;
    CMTime duration = [self.videoData.composition duration];
    
    if(self.videoData.videoComposition.instructions.count == 0) {
        NSLog(@"zero instruction!");
        // The rotate transform is set on a layer instruction
        instruction = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
        instruction.timeRange = CMTimeRangeMake(kCMTimeZero, duration);
        
        layerInstruction = [AVMutableVideoCompositionLayerInstruction
                            videoCompositionLayerInstructionWithAssetTrack:self.videoData.videoCompositionTrack];
        
        
        [layerInstruction setCropRectangle:self.cropFrame atTime:kCMTimeZero];
        CGAffineTransform t1 = CGAffineTransformMakeTranslation(-1*self.cropFrame.origin.x, -1*self.cropFrame.origin.y);
        [layerInstruction setTransform:t1 atTime:kCMTimeZero];
    }
    else {
        // Extract the existing layer instruction on the mutableVideoComposition
        instruction = (AVMutableVideoCompositionInstruction *)[self.videoData.videoComposition.instructions lastObject];
        layerInstruction = (AVMutableVideoCompositionLayerInstruction *)[instruction.layerInstructions lastObject];
        
        CGAffineTransform existingTransform;
        
        BOOL success = [layerInstruction getTransformRampForTime:duration
                                                  startTransform:&existingTransform
                                                    endTransform:NULL timeRange:NULL];
        
        if (!success) {
            [layerInstruction setCropRectangle:self.cropFrame atTime:kCMTimeZero];
            CGAffineTransform t1 = CGAffineTransformMakeTranslation(-1*self.cropFrame.origin.x, -1*self.cropFrame.origin.y);
            [layerInstruction setTransform:t1 atTime:kCMTimeZero];
        } else {
            //CGAffineTransform t3 = CGAffineTransformMakeTranslation(-1 * videoSize.height / 2, 0.0);
            //CGAffineTransform newTransform = CGAffineTransformConcat(existingTransform, CGAffineTransformConcat(t2, t3));
            //[layerInstruction setTransform:newTransform atTime:kCMTimeZero];
            
            CGAffineTransform t1 = CGAffineTransformMakeTranslation(-1*self.cropFrame.origin.x, -1*self.cropFrame.origin.y);
            CGAffineTransform newTransform = CGAffineTransformConcat(existingTransform, t1);
            [layerInstruction setTransform:newTransform atTime:kCMTimeZero];
        }
    }
    
    // set render size
    self.videoData.videoComposition.renderSize = self.cropFrame.size;
    self.videoData.videoSize = self.cropFrame.size;
    
    instruction.layerInstructions = @[layerInstruction];
    self.videoData.videoComposition.instructions = @[instruction];
}

@end
