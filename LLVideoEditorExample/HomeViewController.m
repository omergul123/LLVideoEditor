//
//  HomeViewController.m
//  LLVideEditorExample
//
//  Created by Ömer Faruk Gül on 24/05/15.
//  Copyright (c) 2015 Ömer Faruk Gül. All rights reserved.
//

//
//  HomeViewController.m
//  Memento
//
//  Created by Ömer Faruk Gül on 16/05/15.
//  Copyright (c) 2015 Ömer Faruk Gül. All rights reserved.
//

#import "HomeViewController.h"
#import "LLSimpleCamera.h"
#import <Masonry.h>
#import <EDColor.h>
#import <ViewUtils.h>
#import "VideoViewController.h"
#import "LLVideoEditor.h"

@interface HomeViewController ()
@property (strong, nonatomic) LLSimpleCamera *camera;
@property (strong, nonatomic) UIButton *snapButton;
@property (strong, nonatomic) UIVisualEffectView *snapButtonBgView;
@property (strong, nonatomic) CAShapeLayer *discLayer;
@end

@implementation HomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    [self.navigationController setNavigationBarHidden:YES];
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    
    // create camera vc
    self.camera = [[LLSimpleCamera alloc] initWithQuality:AVCaptureSessionPreset1280x720
                                                 position:CameraPositionBack
                                             videoEnabled:YES];
    
    // attach to the view
    [self.camera attachToViewController:self withFrame:CGRectMake(0, 0, screenRect.size.width, screenRect.size.height)];
    
    [self.camera setOnDeviceChange:^(LLSimpleCamera *camera, AVCaptureDevice *device) {
        NSLog(@"Device changed!");
    }];
    
    [self.camera setOnError:^(LLSimpleCamera *camera, NSError *error) {
        NSLog(@"Camera error: %@", error);
    }];
    
    
    UIView *superview = self.view;
    
    CGSize snapButtonSize = CGSizeMake(80, 80);
    
    [self.view addSubview:self.snapButtonBgView];
    [self.snapButtonBgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.and.height.equalTo(@(snapButtonSize.width));
        make.centerX.equalTo(superview);
        make.bottom.equalTo(superview).offset(-20.0f);
    }];
    
    [self.snapButtonBgView addSubview:self.snapButton];
    [self.snapButton addTarget:self action:@selector(snapButtonTouchDown:) forControlEvents:UIControlEventTouchDown];
    [self.snapButton addTarget:self action:@selector(snapButtonTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
    [self.snapButton addTarget:self action:@selector(snapButtonTouchUpOutside:) forControlEvents:UIControlEventTouchUpOutside];
    [self.snapButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.snapButtonBgView);
    }];
    
    self.discLayer.anchorPoint = CGPointMake(0.5, 0.5);
    self.discLayer.position = (CGPoint){snapButtonSize.width / 2.0f, snapButtonSize.height / 2.0f};
    self.discLayer.hidden = YES;
    
    [self.snapButtonBgView.layer addSublayer:self.discLayer];
}

-(BOOL)prefersStatusBarHidden{
    return YES;
}

- (void)snapButtonTouchDown:(UIButton *)button {
    [self startCapturing];
}

- (void)snapButtonTouchUpInside:(UIButton *)button {
    [self stopCapturing];
}

- (void)snapButtonTouchUpOutside:(UIButton *)button {
    [self stopCapturing];
}

- (NSURL *)applicationDocumentsDirectory {
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory
                                                   inDomains:NSUserDomainMask] lastObject];
}

- (void)startCapturing {
    // start recording
    NSURL *outputURL = [[[self applicationDocumentsDirectory]
                         URLByAppendingPathComponent:@"test1"] URLByAppendingPathExtension:@"mov"];
    [self.camera startRecordingWithOutputUrl:outputURL];
    
    // animate button
    [self animateButton];
}

- (void)stopCapturing {
    [self.camera stopRecording:^(LLSimpleCamera *camera, NSURL *outputFileUrl, NSError *error) {
        NSLog(@"Video recording error: %@", error);
        
        [self editVideWithUrl:outputFileUrl];
    }];
    
    self.snapButton.layer.borderColor = [UIColor whiteColor].CGColor;
    
    self.discLayer.hidden = YES;
    CALayer *layer =  self.discLayer.presentationLayer;
    [layer removeAllAnimations];
}

- (void)editVideWithUrl:(NSURL *)videoURL {
    
    NSURL *exportUrl = [[[self applicationDocumentsDirectory]
                         URLByAppendingPathComponent:@"output"] URLByAppendingPathExtension:@"mov"];
    
    NSURL *audioUrl = [[NSBundle mainBundle] URLForResource:@"applause-01" withExtension:@"mp3"];
    AVAsset *audioAsset = [[AVURLAsset alloc] initWithURL:audioUrl options:nil];
    
    CALayer *layer = [self createVideoLayer];
    
    // initialize the editor
    LLVideoEditor *videoEditor = [[LLVideoEditor alloc] initWithVideoURL:videoURL];
    
    // rotate
    [videoEditor rotate:LLRotateDegree90];
    // crop
    [videoEditor crop:CGRectMake(10, 10, 300, 200)];
    // add layer
    [videoEditor addLayer:layer];
    // add audio
    [videoEditor addAudio:audioAsset startingAt:1 trackDuration:3];
    
    AVAsset * videoAsset1 = [[AVURLAsset alloc] initWithURL:videoURL options:nil];
    AVAsset * videoAsset2 = [[AVURLAsset alloc] initWithURL:videoURL options:nil];
    [videoEditor addVideoAssets:@[videoAsset1, videoAsset2]];
    
    
    [videoEditor exportToUrl:exportUrl completionBlock:^(AVAssetExportSession *session) {
        
        switch (session.status) {
            case AVAssetExportSessionStatusCompleted: {
                // show the cropped video
                VideoViewController *vc = [[VideoViewController alloc] initWithVideoUrl:exportUrl];
                [self.navigationController pushViewController:vc animated:NO];
                break;
            }
            case AVAssetExportSessionStatusFailed:
                NSLog(@"Failed:%@",session.error);
                break;
            case AVAssetExportSessionStatusCancelled:
                NSLog(@"Canceled:%@", session.error);
                break;
            default:
                break;
        }
    }];
}

- (CALayer *)createVideoLayer {
    // a simple red rectangle
    CALayer *layer = [CALayer layer];
    layer.backgroundColor = [UIColor redColor].CGColor;
    layer.frame = CGRectMake(10, 10, 100, 50);
    return layer;
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.camera start];
}

#pragma mark Controls

- (UIButton *)snapButton {
    if(!_snapButton) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
        button.layer.cornerRadius = 80.0f/ 2.0f;
        button.layer.masksToBounds = YES;
        button.layer.borderColor = [UIColor whiteColor].CGColor;
        button.layer.borderWidth = 2.0f;
        //button.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.3];
        
        _snapButton = button;
    }
    
    return _snapButton;
}

- (UIVisualEffectView *)snapButtonBgView {
    if(!_snapButtonBgView) {
        UIBlurEffect *effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
        UIVisualEffectView *effectView = [[UIVisualEffectView alloc] initWithEffect:effect];
        [self.view addSubview:effectView];
        effectView.layer.cornerRadius = 80.0f/ 2.0f;
        effectView.layer.masksToBounds = YES;
        
        _snapButtonBgView = effectView;
    }
    
    return _snapButtonBgView;
}
- (CAShapeLayer *)discLayer {
    if(!_discLayer) {
        
        CGFloat radius = 6;
        
        CAShapeLayer *layer = [CAShapeLayer layer];
        layer.fillColor = [UIColor colorWithHexString:@"D0021B"].CGColor;
        //layer.strokeColor = [UIColor redColor].CGColor;
        //layer.lineWidth = 7;
        layer.bounds = CGRectMake(0, 0, 2 * radius, 2 * radius);
        layer.path = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(0,0, 2*radius, 2*radius)].CGPath;
        
        _discLayer = layer;
    }
    
    return _discLayer;
}

- (void)animateButton {
    
    self.snapButton.layer.borderColor = [UIColor colorWithHexString:@"D0021B"].CGColor;
    self.discLayer.hidden = NO;
    
    CGFloat newRadius = 40;
    
    CGRect newBounds = CGRectMake(0, 0, 2 * newRadius, 2 * newRadius);
    UIBezierPath *newPath = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(0,0, 2*newRadius, 2*newRadius)];
    
    CABasicAnimation* pathAnim = [CABasicAnimation animationWithKeyPath:@"path"];
    pathAnim.toValue = (id)newPath.CGPath;
    
    CABasicAnimation* boundsAnim = [CABasicAnimation animationWithKeyPath:@"bounds"];
    boundsAnim.toValue = [NSValue valueWithCGRect:newBounds];
    
    CAAnimationGroup *anims = [CAAnimationGroup animation];
    anims.animations = @[boundsAnim, pathAnim];
    anims.removedOnCompletion = NO;
    anims.duration = 10.0f;
    anims.fillMode  = kCAFillModeForwards;
    
    [self.discLayer addAnimation:anims forKey:nil];
    
    [UIView animateWithDuration:0.25 animations:^{
        self.snapButtonBgView.transform = CGAffineTransformMakeScale(1.2, 1.2);
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.3 animations:^{
            self.snapButtonBgView.transform = CGAffineTransformMakeScale(0.9, 0.9);
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:0.3 animations:^{
                self.snapButtonBgView.transform = CGAffineTransformIdentity;
            } completion:^(BOOL finished) {
                
            }];
        }];
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
