//
//  VideoEditor.h
//  LLVideEditor
//
//  Created by Ömer Faruk Gül on 22/05/15.
//  Copyright (c) 2015 Ömer Faruk Gül. All rights reserved.
//

#import <Foundation/Foundation.h>
@import AVFoundation;

typedef enum : NSUInteger {
    LLRotateDegree90,
    LLRotateDegree180,
    LLRotateDegree270
} LLRotateDegree;

@protocol LLCommandProtocol <NSObject>
- (void)execute;
@end

@interface LLVideoEditor : NSObject

/**
 * Initialize the vide with the video URL.
 * @param videoURL URL of the asset.
 */
- (instancetype)initWithVideoURL:(NSURL *)videoURL;

/**
 * Rotate the video.
 * @param rotateDegree Rotation degree.
 */
- (void)rotate:(LLRotateDegree)rotateDegree;

/**
 * Add a layer (watermark) to the video.
 * @param aLayer Layer to be added.
 */
- (void)addLayer:(CALayer *)aLayer;

/**
 * Crop the video with the given frame.
 * @param cropFrame Frame to be cropped.
 */
- (void)crop:(CGRect)cropFrame;

/**
 * Add audio to the video.
 * @param asset Audio asset
 */
- (void)addAudio:(AVAsset *)asset;

/**
 * Add audio to the video.
 * @param startingAt The delay after audio will start playing in the video.
 */
- (void)addAudio:(AVAsset *)asset startingAt:(float)startingAt;

/**
 * Add audio to the video.
 * @param startingAt The delay after audio will start playing in the video.
 * @param trackDuration The duration of your track will play in the video.
 */
- (void)addAudio:(AVAsset *)asset startingAt:(float)startingAt trackDuration:(float)trackDuration;

/**
 * Merge video with given video.
 * @param asset Video asset
 */
- (void)addVideoAsset:(AVAsset *)asset;

/**
 * Merge video with given videos.
 * @param asset Video asset
 */
- (void)addVideoAssets:(NSArray<AVAsset *> *)assets;

/**
 * Export the edited video.
 * @param exportUrl Provide a valid URL to export the edited video.
 * @param completionBlock block to be executed after export is completed (called on main thread)
 */
- (void)exportToUrl:(NSURL *)exportUrl
    completionBlock:(void (^)(AVAssetExportSession *session))completionBlock;

/**
 * Export the edited video with more options.
 */
- (void)exportToUrl:(NSURL *)exportUrl
         presetName:(NSString *)presetName optimizeForNetworkUse:(BOOL)optimizeForNetworkUse
     outputFileType:(NSString*)outputFileType completionBlock:(void (^)(AVAssetExportSession *session))completionBlock;

/**
 * Size of the video.
 */
@property (nonatomic, readonly) CGSize videoSize;

@end
