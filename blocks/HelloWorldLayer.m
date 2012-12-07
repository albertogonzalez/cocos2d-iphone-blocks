//
//  HelloWorldLayer.m
//  blocks
//
//  Created by Alberto Gonzalez on 07/12/12.
//  Copyright albertogonzalez.net 2012. All rights reserved.
//


// Import the interfaces
#import "HelloWorldLayer.h"

// Needed to obtain the Navigation Controller
#import "AppDelegate.h"

#define BACKGROUND_Z	0

#define BLOCKS_Z		1
#define BLOCKS_TAG		1
#define BLOCKS_ROWS		4
#define BLOCKS_COLS		5
#define BLOCKS_MAX		20

#define PLAYER_Z		1
#define PLAYER_TAG		2

#define BALL_Z			1
#define BALL_TAG		3
#define BALL_SPEED		150

@interface HelloWorldLayer()
@property (nonatomic, retain) NSMutableArray *blocks;
@property (nonatomic, retain) CCSprite *player;
@property (nonatomic) CGFloat playerXMin;
@property (nonatomic) CGFloat playerXMax;
@property (nonatomic, retain) CCSprite *ball;
@property (nonatomic) BOOL ballWithPaddle;
@property (nonatomic) CGPoint ballSpeedVector;
@property (nonatomic) CGFloat ballXMin;
@property (nonatomic) CGFloat ballXMax;
@property (nonatomic) CGFloat ballYMin;
@property (nonatomic) CGFloat ballYMax;
@property (nonatomic) CGPoint touchPointPrev;

- (CGPoint) getNewBallSpeedVector;
- (BOOL) collideBallWithPaddle;

@end


#pragma mark - HelloWorldLayer

// HelloWorldLayer implementation
@implementation HelloWorldLayer

@synthesize blocks = _blocks;
@synthesize player = _player;
@synthesize ball = _ball;

// Helper class method that creates a Scene with the HelloWorldLayer as the only child.
+(CCScene *) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	HelloWorldLayer *layer = [HelloWorldLayer node];
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}

// on "init" you need to initialize your instance
-(id) init
{
	// always call "super" init
	// Apple recommends to re-assign "self" with the "super's" return value
	if( (self=[super init]) ) {
		
		// ask director for the window size
		CGSize winSize = [[CCDirector sharedDirector] winSize];
		
		// background
		CCSprite *background = [CCSprite spriteWithFile:@"background.png"];
		background.position =  ccp( winSize.width/2 , winSize.height/2 );
		[self addChild:background z:BACKGROUND_Z];
		
		// blocks
		CCSprite *block = [CCSprite spriteWithFile:@"block.png"];
		CGSize blockSize = block.contentSize;
		self.blocks = [NSMutableArray arrayWithCapacity:BLOCKS_MAX];
		CGPoint blockPos;
		blockPos.y = winSize.height - blockSize.height/2;
		for (int row = 0; row < BLOCKS_ROWS; row++)
		{
			blockPos.x = blockSize.width/2;
			for (int col = 0; col < BLOCKS_COLS; col++)
			{
				CCSprite *block = [CCSprite spriteWithFile:@"block.png"];
				block.position =  blockPos;
				[self addChild:block z:BLOCKS_Z tag:BLOCKS_TAG];
				[self.blocks addObject:block];
				
				blockPos.x += blockSize.width;
			}
			blockPos.y -= blockSize.height;
		}
		
		// player
		self.player = [CCSprite spriteWithFile:@"player.png"];
		self.player.position = ccp(winSize.width/2, self.player.contentSize.height);
		[self addChild:self.player z:PLAYER_Z tag:PLAYER_TAG];
		self.playerXMin = self.player.contentSize.width/2;
		self.playerXMax = winSize.width - self.player.contentSize.width/2;
		
		// ball
		self.ball = [CCSprite spriteWithFile:@"ball.png"];
		self.ball.position = ccp(self.player.position.x, self.player.position.y + self.ball.contentSize.height);
		[self addChild:self.ball z:BALL_Z tag:BALL_TAG];
		self.ballWithPaddle = YES;
		self.ballXMin = self.ball.contentSize.width/2;
		self.ballXMax = winSize.width - self.ball.contentSize.width/2;
		self.ballYMin = -self.ball.contentSize.height;
		self.ballYMax = winSize.height - self.ball.contentSize.height/2;
		
		self.isTouchEnabled = YES;
		[self scheduleUpdate];
	}
	return self;
}

// on "dealloc" you need to release all your retained objects
- (void) dealloc
{
	// in case you have something to dealloc, do it in this method
	// in this particular example nothing needs to be released.
	// cocos2d will automatically release all the children (Label)
	
	[_blocks release];
	[_player release];
	[_ball release];
	
	// don't forget to call "super dealloc"
	[super dealloc];
}

- (CGPoint) getNewBallSpeedVector
{
	CGPoint speed;
	speed.x = arc4random() % (BALL_SPEED - BALL_SPEED/4);
	if ((arc4random()%100) < 50) {
		speed.x *= -1;
	}
	speed.y = sqrtf((BALL_SPEED*BALL_SPEED) - (speed.x*speed.x));
	return speed;
}

- (BOOL) collideBallWithPaddle
{
	return CGRectIntersectsRect(self.player.boundingBox, self.ball.boundingBox);
}

- (void) ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	UITouch *touch = [touches anyObject];
	self.touchPointPrev = [[CCDirector sharedDirector] convertToGL:[touch locationInView:touch.view]];
	
}

- (void) ccTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
	UITouch *touch = [touches anyObject];
	CGPoint touchPoint = [[CCDirector sharedDirector] convertToGL:[touch locationInView:touch.view]];
	CGPoint playerPos = self.player.position;
	playerPos.x += touchPoint.x - self.touchPointPrev.x;
	if (playerPos.x < self.playerXMin) {
		playerPos.x = self.playerXMin;
	} else if (playerPos.x > self.playerXMax) {
		playerPos.x = self.playerXMax;
	}
	[self.player setPosition:playerPos];
	
	if (self.ballWithPaddle) {
		CGPoint ballPos = self.ball.position;
		ballPos.x = playerPos.x;
		[self.ball setPosition:ballPos];
	}
	
	self.touchPointPrev = touchPoint;
}

- (void) ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	if (self.ballWithPaddle) {
		self.ballSpeedVector = [self getNewBallSpeedVector];
		self.ballWithPaddle = NO;
	}
}

- (void) update:(ccTime)delta
{
	if (!self.ballWithPaddle) {
		// update ball position with speed
		CGPoint ballPos = self.ball.position;
		ballPos.x += self.ballSpeedVector.x * delta;
		ballPos.y += self.ballSpeedVector.y * delta;
		
		// check if ball goes out of screen sides
		if (ballPos.x < self.ballXMin)
		{
			ballPos.x = self.ballXMin;
			CGPoint speedVector = self.ballSpeedVector;
			speedVector.x = -speedVector.x;
			self.ballSpeedVector = speedVector;
		}
		else if (ballPos.x > self.ballXMax)
		{
			ballPos.x = self.ballXMax;
			CGPoint speedVector = self.ballSpeedVector;
			speedVector.x = -speedVector.x;
			self.ballSpeedVector = speedVector;
		}

		// if the ball collide with the paddle
		if ([self collideBallWithPaddle]) {
			ballPos.y = self.player.position.y + self.ball.contentSize.height;
			self.ballSpeedVector = [self getNewBallSpeedVector];
		}
		// check if ball gets the top of the screen
		else if (ballPos.y > self.ballYMax)
		{
			ballPos.y = self.ballYMax;
			CGPoint speedVector = self.ballSpeedVector;
			speedVector.y = -speedVector.y;
			self.ballSpeedVector = speedVector;
		}
		// check if ball gets the bottom of the screen
		else if (ballPos.y < self.ballYMin)
		{
			CCLOG(@"GAME OVER");
		}
		
		// update ball position
		[self.ball setPosition:ballPos];
	}
}

@end
