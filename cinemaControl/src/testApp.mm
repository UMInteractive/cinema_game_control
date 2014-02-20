#include "testApp.h"
#include "ofxiPhoneExtras.h"
#include "SetupViewController.h"
#include "PauseViewController.h"


PauseViewController *pauseController;
SetupViewController *setupController;

//--------------------------------------------------------------
void testApp::setup(){
	ofSetOrientation(OF_ORIENTATION_DEFAULT);
    ofxAccelerometer.setup();
    ofEnableAlphaBlending();
    bonjour = new ofxBonjourIp();
    bonjour->addEventListeners(this);
    bonjour->discoverService();
	//for some reason on the iphone simulator 256 doesn't work - it comes in as 512!
	//so we do 512 - otherwise we crash

	initialBufferSize = 512;
	sampleRate = 44100;
	drawCounter = 0;
	bufferCounter = 0;
	
	buffer = new float[initialBufferSize];
	memset(buffer, 0, initialBufferSize * sizeof(float));
    
	// 0 output channels,
	// 1 input channels
	// 44100 samples per second
	// 512 samples per buffer
	// 4 num buffers (latency)
	ofSoundStreamSetup(0, 1, this, sampleRate, initialBufferSize, 4);
	ofSetFrameRate(60);

	ofBackground(0);
    pauseController = [[PauseViewController alloc] initWithNibName:@"PauseViewController" bundle:nil];
    [ofxiPhoneGetGLView() addSubview:pauseController.view];
    pauseController.view.hidden = true;
    
    setupController = [[SetupViewController alloc] initWithNibName:@"SetupViewController" bundle:nil];
    [ofxiPhoneGetGLView() addSubview:setupController.view];
    playing = false;
    joystix.loadFont("joystix.ttf", 10);
    for (int i = 0; i < 10; i++) {
        playerImage[i].loadImage(ofToString(i) + ".png");
    }
    ofSetRectMode(OF_RECTMODE_CENTER);
    position.set(ofGetWidth()/2, ofGetHeight()/2);
    gameState = GAME_STATE_NO_SERVER_CONNECTION;
    chosenGame = "no game chosen";
}



//--------------------------------------------------------------
void testApp::update(){
    if (playing) {
	//we do a heartbeat on iOS as the phone will shut down the network connection to save power
	//this keeps the network alive as it thinks it is being used. 
        if( ofGetFrameNum() % 120 == 0 ){
            ofxOscMessage m;
            m.setAddress( "/misc/heartbeat" );
            m.addIntArg( ofGetFrameNum() );
            sender.sendMessage( m );
        }
        //ACCELEROMETER CONTROL
        if (gameControl == GAME_CONTROL_ACCEL) {
            float accelX = ofMap(ofxAccelerometer.getForce().x, -1, 1, 0, ofGetWidth());
            float accelY = ofMap(ofxAccelerometer.getForce().y, 1, -1, 0, ofGetHeight());
            smooth.x = (.9f * smooth.x) + (.1f * accelX);
            smooth.y = (.9f * smooth.y) + (.1f * accelY);
            ofxOscMessage m;
            m.setAddress( "/accel" );
            m.addIntArg(playerNumber);
            m.addFloatArg(accelX);
            m.addFloatArg(accelY);
            sender.sendMessage(m);
        }
        //TAP CONTROL
        if (gameControl == GAME_CONTROL_TAP) {
            if (holding) {
                holdingTime++;
            }
        }
        //AUDIO CONTROL
        if (gameControl == GAME_CONTROL_AUDIO) {
            float power = -999;
            for(int i = 0; i < initialBufferSize; i++){
                if (buffer[i] > power) {
                    power = buffer[i];
                
                }
            }
            
            micAmplitude = power;

            ofxOscMessage m;
            m.setAddress( "/sound" );
            m.addIntArg(playerNumber);
            m.addFloatArg(power);
            sender.sendMessage(m);

        }

    }
    
    while (receiver.hasWaitingMessages()) {
        ofxOscMessage msg;
        receiver.getNextMessage(&msg);
        cout << "got message!!" << endl;
        if (msg.getAddress() == "/feedback") {
            if (msg.getArgAsString(0) == "state") {
                cout << "Game State Changed" << endl;
                gameState = msg.getArgAsInt32(1);
                if (gameState == GAME_STATE_PLAYING) {
                    playing = true;
                }
                else {
                    playing = false;
                }
            }
            if (msg.getArgAsString(1) == "control") {
                gameState = msg.getArgAsInt32(1);
            }
        }
        if (msg.getAddress() == "/joined") {
            //got response from server to join game
            cout << "Got response from server" << endl;
            playerNumber = msg.getArgAsInt32(0);
            playerTeam = msg.getArgAsInt32(1);
            playerSubteam = msg.getArgAsInt32(2);
            switch (playerTeam) {
                case 0:
                    playerColor = ofColor::springGreen;
                    break;
                case 1:
                    playerColor = ofColor::orchid;
                    break;
                case 2:
                    playerColor = ofColor::blueViolet;
                    break;
                case 3:
                    playerColor = ofColor::turquoise;
                    break;
                case 4:
                    playerColor = ofColor::whiteSmoke;
                    break;
                case 5:
                    playerColor = ofColor::tomato;
                    break;
                case 6:
                    playerColor = ofColor::violet;
                    break;
                case 7:
                    playerColor = ofColor::mintCream;
                    break;
                case 8:
                    playerColor = ofColor::darkorange;
                    break;
                case 9:
                    playerColor = ofColor::darkMagenta;
                    break;
                default:
                    playerColor = ofColor::darkGrey;
                    break;
            }
            
            gameControl = msg.getArgAsInt32(3);
            gameState = msg.getArgAsInt32(4);
            switch (gameControl) {
                case GAME_CONTROL_ACCEL:
                    chosenGame = "AXIS";
                    break;
                case GAME_CONTROL_AUDIO:
                    chosenGame = "AUDIO";
                    break;
                case GAME_CONTROL_MOVE:
                    chosenGame = "DRAG";
                    break;
                case GAME_CONTROL_TAP:
                    chosenGame = "TAP AND HOLD";
                    break;
                    
                default:
                    break;
            }

        }
        
    }
}

//--------------------------------------------------------------
void testApp::draw(){
    if(playing) {
        ofSetColor(200, 200);
        for (int x = 0; x < ofGetWidth(); x+=10) {
            ofLine(x, smooth.y, x + 5, smooth.y);
            
        }
        for (int y = 0; y < ofGetHeight(); y+=10) {
            ofLine(smooth.x, y, smooth.x, y + 5);

            
        }
        ofSetColor(0, 255, 255, 127);
        float amplitude = ofMap(micAmplitude, 0, 1, playerImage[playerSubteam].width, ofGetWidth());

        ofRect(position.x, position.y, amplitude, amplitude);
        ofSetColor(0);
        ofRect(position.x, position.y, playerImage[playerSubteam].width, playerImage[playerSubteam].height);
        ofSetColor(playerColor);
        playerImage[playerSubteam].draw(position.x, position.y, playerImage[playerSubteam].width + holdingTime, playerImage[playerSubteam].height + holdingTime);
    }
    else {
        ofSetColor(255, 255, 255);

        switch (gameState) {
            case GAME_STATE_NO_SERVER_CONNECTION:
                joystix.drawStringCentered("Waiting for Server...", ofGetWidth()/2, ofGetHeight()/2);
                joystix.drawStringCentered("Double Tap to Quit", ofGetWidth()/2, ofGetHeight()/2 + 30);

                break;
            case GAME_STATE_WAITING:
                joystix.drawStringCentered("Waiting for Players...", ofGetWidth()/2, ofGetHeight()/2);
                break;
            case GAME_STATE_PLAYING:
                break;
            default:
                break;
        }
    }
    ofSetColor(255, 255, 255);
    joystix.drawString(playerName, 0, 20);
    joystix.drawString(chosenGame, ofGetWidth() - joystix.stringWidth(chosenGame), 20);
}

//--------------------------------------------------------------
void testApp::onPublishedService(const void* sender, string &serviceIp) {
    ofLog() << "Received published service event: " << serviceIp;
}

void testApp::onDiscoveredService(const void* sender, string &serviceIp) {
    ofLog() << "Received discovered service event: " << serviceIp;

    [setupController updateBonjourList:ofxStringToNSString(serviceIp)];
}

void testApp::onRemovedService(const void* sender, string &serviceIp) {
    ofLog() << "Received removed service event: " << serviceIp;
    
}

//----------------
void testApp::endGame() {
    pauseController.view.hidden = true;
    setupController.view.hidden = false;
}

//----------------
void testApp::play(NSString *name) {
    playerName = ofxNSStringToString(name);
//    playing = true;
    cout << "SETTING UP ON HOST : " << host << " PORT " << PORT<< endl;
	sender.setup(host, PORT );
    setupController.view.hidden = true;
    ofxOscMessage m;
    m.setAddress( "/join" );
    m.addStringArg(ofxNSStringToString(name));
   // m.addStringArg(ofxNSStringToString(setupController.nameTextField.text));
    sender.sendMessage( m );
    receiver.setup(9001);
    
    
}

//--------------------------------------------------------------
void testApp::audioIn(float * input, int bufferSize, int nChannels){
    if(initialBufferSize != bufferSize){
		ofLog(OF_LOG_ERROR, "your buffer size was set to %i - but the stream needs a buffer size of %i", initialBufferSize, bufferSize);
		return;
	}
	
	// samples are "interleaved"
	for(int i = 0; i < bufferSize; i++){
		buffer[i] = input[i];
	}
	bufferCounter++;

 
}

//--------------------------------------------------------------
void testApp::exit(){

}
//--------------------------------------------------------------
void testApp::touchDown(ofTouchEventArgs & touch){
    if (playing) {
        velocity.set(touch.x, touch.y);
        if (gameControl == GAME_CONTROL_TAP) {
            ofxOscMessage m;
            m.setAddress( "/tap" );
            m.addIntArg(playerNumber);
            sender.sendMessage(m);
            holding = true;
        }
        
        if (touch.x >= ofGetWidth() - 60 && touch.y <= 60) {
            playing = false;
            pauseController.view.hidden = false;
        }
    }

}

//--------------------------------------------------------------
void testApp::touchMoved(ofTouchEventArgs & touch){
    if (playing) {
        if (gameControl == GAME_CONTROL_MOVE) {
    
            position.set(touch.x, touch.y);
            ofxOscMessage m;
            m.setAddress( "/move" );
            m.addIntArg(playerNumber);
        
            m.addFloatArg( (velocity.x - touch.x));
            m.addFloatArg( (velocity.y - touch.y));
            sender.sendMessage( m );
        }
    }
}

//--------------------------------------------------------------
void testApp::touchUp(ofTouchEventArgs & touch){
    if (playing) {
        if (gameControl == GAME_CONTROL_TAP) {
            holding = false;
            position.set(ofGetWidth()/2, ofGetHeight()/2);
            ofxOscMessage m;
            m.setAddress( "/release" );
            m.addIntArg(playerNumber);
            m.addFloatArg(holdingTime);
            sender.sendMessage(m);
            holdingTime = 0;
        }
    }
}

//--------------------------------------------------------------
void testApp::touchDoubleTap(ofTouchEventArgs & touch){
    if (gameState == GAME_STATE_NO_SERVER_CONNECTION) {
        setupController.view.hidden = false;

    }
}

//--------------------------------------------------------------
void testApp::touchCancelled(ofTouchEventArgs & touch){
    
}

//--------------------------------------------------------------
void testApp::lostFocus(){

}

//--------------------------------------------------------------
void testApp::gotFocus(){

}

//--------------------------------------------------------------
void testApp::gotMemoryWarning(){

}

//--------------------------------------------------------------
void testApp::deviceOrientationChanged(int newOrientation){

}
