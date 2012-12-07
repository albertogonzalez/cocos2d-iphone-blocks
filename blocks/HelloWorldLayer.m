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

@interface HelloWorldLayer()
@property (nonatomic, retain) NSMutableArray *blocks;
@end


#pragma mark - HelloWorldLayer

// HelloWorldLayer implementation
@implementation HelloWorldLayer

@synthesize blocks = _blocks;

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
		
		// block
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
	
	// don't forget to call "super dealloc"
	[super dealloc];
}

@end
