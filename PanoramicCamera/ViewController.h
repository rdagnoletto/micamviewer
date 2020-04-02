//
//  ViewController.h
//  PanoramicCamera
//
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <AVKit/AVKit.h>


@interface ViewController : UIViewController

@property (nonatomic, strong) NSMutableArray *viewArray;

@property (nonatomic, strong) AVAudioEngine *engine;

@property (nonatomic, strong) AVAudioPlayerNode *playerX;
@property (nonatomic, strong) AVAudioPlayerNode *playerY;
@property (nonatomic, strong) AVAudioPlayerNode *playerZ;
@property (nonatomic, strong) AVAudioPlayerNode *playerW;

@property (nonatomic, strong) AVAudioFile *fileX;
@property (nonatomic, strong) AVAudioFile *fileY;
@property (nonatomic, strong) AVAudioFile *fileZ;
@property (nonatomic, strong) AVAudioFile *fileW;
@property (nonatomic, strong) AVAudioMixerNode *mainMixer;

@property (nonatomic, strong) IBOutlet UILabel *degreeLabel;

@end

