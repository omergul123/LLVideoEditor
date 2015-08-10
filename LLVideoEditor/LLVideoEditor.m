//
//  VideoEditor.m
//  LLVideEditor
//
//  Created by Ömer Faruk Gül on 22/05/15.
//  Copyright (c) 2015 Ömer Faruk Gül. All rights reserved.
//

#import "LLVideoEditor.h"
#import "LLVideoData.h"
@import UIKit;

// commands
#import "LLCropCommand.h"
#import "LLRotateCommand.h"
#import "LLAddLayerCommand.h"
#import "LLAddAudioCommand.h"

@interface LLVideoEditor()
@property (strong, nonatomic) LLVideoData *videoData;
@property (strong, nonatomic) AVAssetExportSession *exportSession;
@property (strong, nonatomic) NSMutableArray *commands;
@end

@implementation LLVideoEditor

- (instancetype)initWithVideoURL:(NSURL *)videoURL {
   self = [super init];
    if(self) {
        AVAsset *asset = [[AVURLAsset alloc] initWithURL:videoURL options:nil];
        _videoData = [[LLVideoData alloc] initWithAsset:asset];
        _commands = [NSMutableArray array];
    }
    
    return self;
}


#pragma Command Facades

- (void)rotate:(LLRotateDegree)rotateDegree {
    
    NSInteger commandCount = 0;
    if(rotateDegree == LLRotateDegree90) {
        commandCount = 1;
    }
    else if(rotateDegree == LLRotateDegree180) {
        commandCount = 2;
    }
    else if(rotateDegree == LLRotateDegree270) {
        commandCount = 3;
    }
    
    for(NSInteger i = 0; i<commandCount; i++) {
        LLRotateCommand *command = [[LLRotateCommand alloc] initWithVideoData:self.videoData];
        [self.commands addObject:command];
    }
}

- (void)crop:(CGRect)cropFrame {
    LLCropCommand *command = [[LLCropCommand alloc] initWithVideoData:self.videoData cropFrame:cropFrame];
    [self.commands addObject:command];
}


- (void)addLayer:(CALayer *)layer {
    LLAddLayerCommand *command = [[LLAddLayerCommand alloc] initWithVideoData:self.videoData layer:layer];
    [self.commands addObject:command];
}

- (void)addAudio:(AVAsset *)asset {
    LLAddAudioCommand *command = [[LLAddAudioCommand alloc] initWithVideoData:self.videoData audioAsset:asset];
    [self.commands addObject:command];
}

- (void)addAudio:(AVAsset *)asset startingAt:(float)startingAt {
    LLAddAudioCommand *command = [[LLAddAudioCommand alloc] initWithVideoData:self.videoData
                                                                   audioAsset:asset
                                                                   startingAt:startingAt];
    [self.commands addObject:command];
}

- (void)addAudio:(AVAsset *)asset startingAt:(float)startingAt trackDuration:(float)trackDuration {
    LLAddAudioCommand *command = [[LLAddAudioCommand alloc] initWithVideoData:self.videoData
                                                                   audioAsset:asset
                                                                   startingAt:startingAt
                                                                trackDuration:trackDuration];
    [self.commands addObject:command];
}

#pragma mark Apply and Export Methods.

- (void)applyCommands {
    
    LLAddLayerCommand *addLayerCommand = nil;
    
    for(id<LLCommandProtocol> command in self.commands) {
        if([command isKindOfClass:[LLAddLayerCommand class]]) {
            // will execute at final stage
            addLayerCommand = command;
            continue;
        }
        [command execute];
    }
    
    // finally execute the add layer command
    if(addLayerCommand) {
        [addLayerCommand execute];
    }
}

- (void)exportToUrl:(NSURL *)exportUrl completionBlock:(void (^)(AVAssetExportSession *session))completionBlock {
        [self exportToUrl:exportUrl
               presetName:AVAssetExportPreset1280x720
    optimizeForNetworkUse:YES
           outputFileType:AVFileTypeQuickTimeMovie
          completionBlock:completionBlock];
}

- (void)exportToUrl:(NSURL *)exportUrl
         presetName:(NSString *)presetName optimizeForNetworkUse:(BOOL)optimizeForNetworkUse
     outputFileType:(NSString*)outputFileType completionBlock:(void (^)(AVAssetExportSession *session))completionBlock {
    
    [self applyCommands];
    
    _exportSession = [[AVAssetExportSession alloc] initWithAsset:[self.videoData.composition copy]
                                                      presetName:presetName];
    
    if(self.videoData.videoComposition) {
        _exportSession.videoComposition = self.videoData.videoComposition;
    }
    
    // delete the existing file
    NSError *error = nil;
    if ([[NSFileManager defaultManager] isDeletableFileAtPath:exportUrl.path]) {
        BOOL success = [[NSFileManager defaultManager] removeItemAtPath:exportUrl.path error:&error];
        if (!success) {
            NSLog(@"Error removing file at path: %@", error.localizedDescription);
        }
    }
    
    _exportSession.outputFileType = outputFileType;
    _exportSession.outputURL = exportUrl;
    _exportSession.shouldOptimizeForNetworkUse = optimizeForNetworkUse;
    
    [_exportSession exportAsynchronouslyWithCompletionHandler:^(void ) {
        
        if(completionBlock) {
            dispatch_async(dispatch_get_main_queue(), ^{
                AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:exportUrl options:nil];
                _videoData = [[LLVideoData alloc] initWithAsset:asset];
                _commands = [NSMutableArray array];
                completionBlock(_exportSession);
            });
        }
    }];
}

#pragma mark Getters

- (CGSize)videoSize {
    return self.videoData.videoSize;
}

@end
