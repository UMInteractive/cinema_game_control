#pragma once

#include "ofMain.h"
#include "ofxiPhone.h"
#include "ofxiPhoneExtras.h"
#include "ofxOsc.h"
#include "ofxBonjourIp.h"
#include "ofxCenteredTrueTypeFont.h"
#include "ofxOpenALSoundPlayer.h"

#define HOST "169.254.150.105"
#define PORT 9000
#define ACCELEROMETER_PADDING .15
#define GAME_STATE_NO_SERVER_CONNECTION -1

#define OFXNERDLAB_GAME_STATE_WAITING               0
#define OFXNERDLAB_GAME_STATE_PAUSED                1
#define OFXNERDLAB_GAME_STATE_PLAYING               2
#define OFXNERDLAB_GAME_STATE_SHOW_MESSAGE          3
#define OFXNERDLAB_GAME_STATE_IN_PROGRESS_CANT_JOIN 4
#define OFXNERDLAB_GAME_STATE_ROLL_CALL             5


#define OFXNERDLAB_GAME_CONTROL_MOVE                0
#define OFXNERDLAB_GAME_CONTROL_AUDIO               1
#define OFXNERDLAB_GAME_CONTROL_ACCEL               2
#define OFXNERDLAB_GAME_CONTROL_TAP                 3
#define OFXNERDLAB_GAME_CONTROL_ROTATE              4

#define OFXNERDLAB_REACTION_PULSE                   0
#define OFXNERDLAB_REACTION_ROLL_CALL               1

#define OFXNERDLAB_IMAGE_SET_SQUARE            0
#define OFXNERDLAB_IMAGE_SET_ABSTRACT          1
#define OFXNERDLAB_IMAGE_SET_HUMANS            2
#define OFXNERDLAB_IMAGE_SET_TANKS             3




class testApp : public ofxiPhoneApp {

	public:
		void setup();
		void update();
		void draw();
		void exit();
		
		void touchDown(ofTouchEventArgs & touch);
		void touchMoved(ofTouchEventArgs & touch);
		void touchUp(ofTouchEventArgs & touch);
		void touchDoubleTap(ofTouchEventArgs & touch);
		void touchCancelled(ofTouchEventArgs & touch);

		void lostFocus();
		void gotFocus();
		void gotMemoryWarning();
		void deviceOrientationChanged(int newOrientation);
        void audioIn(float * input, int bufferSize, int nChannels);
        void onPublishedService(const void* sender, string &serviceIp);
        void onDiscoveredService(const void* sender, string &serviceIp);
        void onRemovedService(const void* sender, string &serviceIp);

        void play(NSString *name);
        void loadImageSet(int set);
        void endGame();
    
        void drawQuitBar();
    
        void react(int reaction);
    
        int	initialBufferSize;
        int	sampleRate;
        int	drawCounter;
        int bufferCounter;
        float * buffer;
		ofxOscSender sender;
        ofxOscReceiver receiver;
        ofxBonjourIp *bonjour;
        ofxOpenALSoundPlayer *sound;
        int playerNumber;
        int playerTeam;
        int playerSubteam;
        int playerAvatar;
        int playerIndex;
        int gameState;
        int gameControl;
        int secondsUntilNextGame;
        string playerName;
        string instructions;
        string message;
        //int score;
        string status;
    
        ofColor playerColor;
        ofPoint velocity;
        ofPoint position;
        ofPoint smooth;
        float rotation;
    
        float holdingTime;
        bool holding;
        bool reacting;
        int reactionNumber;
        float reactionTime;
    
        bool wantsToQuit;
    
        float micAmplitude;
    
        vector<ofImage> playerImage;
        ofxCenteredTrueTypeFont joystix;
        string host;
       // string chosenGame;
        bool playing;
        bool keepAlive;
};

