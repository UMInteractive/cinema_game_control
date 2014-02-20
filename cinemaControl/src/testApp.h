#pragma once

#include "ofMain.h"
#include "ofxiPhone.h"
#include "ofxiPhoneExtras.h"
#include "ofxOsc.h"
#include "ofxBonjourIp.h"
#include "ofxCenteredTrueTypeFont.h"

#define HOST "169.254.150.105"
#define PORT 9000
#define ACCELEROMETER_PADDING .15
#define GAME_STATE_NO_SERVER_CONNECTION -1
#define GAME_STATE_WAITING  0
#define GAME_STATE_PAUSED   1
#define GAME_STATE_PLAYING  2
#define GAME_CONTROL_MOVE   0
#define GAME_CONTROL_AUDIO  1
#define GAME_CONTROL_ACCEL  2
#define GAME_CONTROL_TAP    3


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
        void endGame();
    
        int	initialBufferSize;
        int	sampleRate;
        int	drawCounter;
        int bufferCounter;
        float * buffer;
		ofxOscSender sender;
        ofxOscReceiver receiver;
        ofxBonjourIp *bonjour;
        int playerNumber;
        int playerTeam;
        int playerSubteam;
        int gameState;
        int gameControl;
        string playerName;

        ofColor playerColor;
        ofPoint velocity;
        ofPoint position;
        ofPoint smooth;
    
        float holdingTime;
        bool holding;
    
        float micAmplitude;
    
        ofImage playerImage[10];
        ofxCenteredTrueTypeFont joystix;
        string host;
        string chosenGame;
        bool playing;
};

