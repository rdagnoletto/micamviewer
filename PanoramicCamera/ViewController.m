//
//  ViewController.m
//  PanoramicCamera
//
//

#import "ViewController.h"
#import "AAPanoView.h"
#import <AVFoundation/AVFoundation.h>

@interface ViewController ()

{
    CGPoint startPoint;
    NSMutableArray *startFrames;
    int numberOfViews, centerTag;
    float shiftWidth;
    double currentDegree;
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    _viewArray = [NSMutableArray new];
    currentDegree = 180;
    numberOfViews = 3;
    centerTag = ceil(numberOfViews/2.0f);

    shiftWidth = (self.view.frame.size.height*6);

    NSMutableArray *playerArray = [NSMutableArray new];

    for (int i = 0; i < numberOfViews; i++)
    {
        AAPanoView *container = [[AAPanoView alloc] initWithFrame:CGRectMake(self.view.frame.origin.x - (shiftWidth - self.view.frame.size.width)/2 - (self.view.frame.size.height*6)*(floor(numberOfViews/2.0f)) + shiftWidth*i, self.view.frame.origin.y, shiftWidth, self.view.frame.size.height)];

        //UIImageView *contentImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, container.frame.size.width, container.frame.size.height)];

        AVPlayer *player = [[AVPlayer alloc] initWithURL:[[NSBundle mainBundle] URLForResource:@"EastWestVidLongTrim" withExtension:@"mp4"]];

        AVPlayerLayer *playerLayer = [AVPlayerLayer playerLayerWithPlayer:player];

        playerLayer.frame = container.bounds;

        [container.layer addSublayer:playerLayer];

        //contentImage.image = [UIImage imageNamed:[NSString stringWithFormat:@"test%d", i+1]];
        //contentImage.image = [UIImage imageNamed:@"testimage.jpg"];
        //contentImage.contentMode = UIViewContentModeScaleToFill;

        container.tag = i+1;
        //[container addSubview:contentImage];

        container.name = [NSString stringWithFormat:@"View %d", i+1];

        UIPanGestureRecognizer *pannedImage = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panned:)];

        [container addGestureRecognizer:pannedImage];

        [_viewArray addObject:container];

        [self.view addSubview:container];

        [playerArray addObject:player];

    }

    //AUDIO ENGINE SETUP

    _engine = [[AVAudioEngine alloc] init];

    _playerX = [[AVAudioPlayerNode alloc] init];
    _playerY = [[AVAudioPlayerNode alloc] init];
    _playerZ = [[AVAudioPlayerNode alloc] init];
    _playerW = [[AVAudioPlayerNode alloc] init];

    [_engine attachNode:_playerX];
    [_engine attachNode:_playerY];
    [_engine attachNode:_playerZ];
    [_engine attachNode:_playerW];

    NSURL *fileX = [[NSBundle mainBundle] URLForResource:@"EastWest_X" withExtension:@"wav"];
    NSURL *fileY = [[NSBundle mainBundle] URLForResource:@"EastWest_Y" withExtension:@"wav"];
    NSURL *fileZ = [[NSBundle mainBundle] URLForResource:@"EastWest_Z" withExtension:@"wav"];
    NSURL *fileW = [[NSBundle mainBundle] URLForResource:@"EastWest_W" withExtension:@"wav"];

    _fileX = [[AVAudioFile alloc] initForReading:fileX error:nil];
    _fileY = [[AVAudioFile alloc] initForReading:fileY error:nil];
    _fileZ = [[AVAudioFile alloc] initForReading:fileZ error:nil];
    _fileW = [[AVAudioFile alloc] initForReading:fileW error:nil];

    _mainMixer = [_engine mainMixerNode];

    [_engine connect:_playerX to:_mainMixer format:_fileX.processingFormat];
    [_engine connect:_playerY to:_mainMixer format:_fileY.processingFormat];
    [_engine connect:_playerZ to:_mainMixer format:_fileZ.processingFormat];
    [_engine connect:_playerW to:_mainMixer format:_fileW.processingFormat];

    [_playerX scheduleFile:_fileX atTime:nil completionHandler:nil];
    [_playerY scheduleFile:_fileY atTime:nil completionHandler:nil];
    [_playerZ scheduleFile:_fileZ atTime:nil completionHandler:nil];
    [_playerW scheduleFile:_fileW atTime:nil completionHandler:nil];

    NSError *error;
    [_engine startAndReturnError:&error];

    [_playerX play];
    [_playerY play];
    [_playerZ play];
    [_playerW play];

    for (AVPlayer *player in playerArray)
    {
        [player play];
    }


    [self.view bringSubviewToFront:_degreeLabel];
    _degreeLabel.text = [NSString stringWithFormat:@"%d%@", (int)currentDegree, @"\u00B0" ];
    // Do any additional setup after loading the view, typically from a nib.
}

-(void)panned:(UIPanGestureRecognizer *)pan;
{

    if ([pan state] == UIGestureRecognizerStateBegan)
    {
        startPoint = [pan locationInView:self.view];

        for (AAPanoView * currentView in _viewArray)
        {
            currentView.startFrame = currentView.frame.origin;
        }

    }
    else if ([pan state] == UIGestureRecognizerStateEnded)
    {
        for (AAPanoView *currentView in _viewArray)
        {
            if (CGRectContainsRect(currentView.frame, [[UIScreen mainScreen] applicationFrame])) {
                if (currentView.tag != centerTag)
                {
                    NSLog(@"Moving views by tag:%ld, - center: %d", (long)currentView.tag, centerTag);
                    [self moveViewsBy:((int)currentView.tag - centerTag)];
                }
            }
        }

    }
    else
    {

        CGPoint newLocation = [pan locationInView:self.view];

        newLocation.x = newLocation.x - startPoint.x;
        newLocation.y = newLocation.y - startPoint.y;

        for (AAPanoView *currentView in _viewArray)
        {
            currentView.frame = CGRectMake(currentView.startFrame.x + newLocation.x, currentView.startFrame.y, currentView.frame.size.width, currentView.frame.size.height);
            if (currentView.tag == centerTag)
            {
                currentDegree = (int)((((self.view.frame.size.width/2.0f) - currentView.frame.origin.x) / currentView.frame.size.width) * 360.0f) % 360;
                if (currentDegree < 0) currentDegree = 360 + currentDegree;
                _degreeLabel.text = [NSString stringWithFormat:@"%d%@", (int)currentDegree, @"\u00B0" ];
            }
        }
    }

    [self adjustAudio];
}

-(void) adjustAudio
{
    NSLog(@"Adjusted");
    [_playerX setVolume:cosf((currentDegree - 45) / 180 * M_PI)];
    [_playerY setVolume:sinf((currentDegree - 45) / 180 * M_PI)];
    [_playerZ setVolume:0.0];
    [_playerW setVolume:1.0];

}

- (void) moveViewsBy:(int)shift
{
    NSLog(@"Shifting by %d", shift);
    //shift = -1;
    if (shift < 0)
    {
        CGRect newFrame = ((AAPanoView*)[self.view viewWithTag:1]).frame;
        newFrame.origin.x = newFrame.origin.x - shiftWidth;
       // NSLog(@"SHIFTING %@ from %f to: %f", ((AAPanoView*)[self.view viewWithTag:(numberOfViews)]).name, ((AAPanoView*)[self.view viewWithTag:(numberOfViews)]).frame.origin.x, newFrame.origin.x);
        ((AAPanoView*)[self.view viewWithTag:(numberOfViews)]).frame = newFrame;
        ((AAPanoView*)[self.view viewWithTag:(numberOfViews)]).startFrame = newFrame.origin;
        ((AAPanoView*)[self.view viewWithTag:(numberOfViews)]).tag = 0;
        for (AAPanoView* view in _viewArray)
        {
            view.startFrame = view.frame.origin;
            view.tag ++;
        }
    }
    else if (shift > 0)
    {
        CGRect newFrame = ((AAPanoView*)[self.view viewWithTag:(numberOfViews)]).frame;
        newFrame.origin.x = newFrame.origin.x + shiftWidth;
        ((AAPanoView*)[self.view viewWithTag:1]).frame = newFrame;
        ((AAPanoView*)[self.view viewWithTag:1]).startFrame = newFrame.origin;
        ((AAPanoView*)[self.view viewWithTag:1]).tag = numberOfViews+1;
        for (AAPanoView* view in _viewArray)
        {
            view.startFrame = view.frame.origin;
            view.tag --;
        }
    }

    /*for (AAPanoView* view in _viewArray)
    {
        view.tag = view.tag - shift;
    }*/
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
