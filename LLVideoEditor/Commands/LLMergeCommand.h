//
//  LLMergeCommand.h
//  LLVideoEditorExample
//
//  Created by Hariton Batkov on 12/24/15.
//  Copyright © 2015 Ömer Faruk Gül. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LLVideoEditor.h"
#import "LLVideoData.h"

@interface LLMergeCommand : NSObject <LLCommandProtocol>

- (instancetype)initWithVideoData:(LLVideoData *)videoData mergeWithAsset:(AVAsset *)asset;

- (instancetype)initWithVideoData:(LLVideoData *)videoData mergeWithAssets:(NSArray <AVAsset *> *)assets;

@end
