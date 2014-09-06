#include "testApp.h"
#include "ofxiPhoneExtras.h"
#include "SetupViewController.h"


SetupViewController *setupController;

//--------------------------------------------------------------
void testApp::setup(){
    cout << "starting app" << endl;
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
	rotation = 0;
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
//    pauseController = [[PauseViewController alloc] initWithNibName:@"PauseViewController" bundle:nil];
//    [ofxiPhoneGetGLView() addSubview:pauseController.view];
//    pauseController.view.hidden = true;
    
    setupController = [[SetupViewController alloc] initWithNibName:@"SetupViewController" bundle:nil];
    [ofxiPhoneGetGLView() addSubview:setupController.view];
    playing = false;
    keepAlive = false;
    joystix.loadFont("joystix.ttf", 10);
    ofSetRectMode(OF_RECTMODE_CENTER);
    position.set(ofGetWidth()/2, ofGetHeight()/2);
    gameState = GAME_STATE_NO_SERVER_CONNECTION;
//    chosenGame = "no game chosen";
    cout << "trying to load images" << endl;
    loadImageSet(OFXNERDLAB_IMAGE_SET_ABSTRACT);
}



//--------------------------------------------------------------
void testApp::update(){
    if (keepAlive) {
        //we do a heartbeat on iOS as the phone will shut down the network connection to save power
        //this keeps the network alive as it thinks it is being used.
        
        if( ofGetFrameNum() % 120 == 0 ){
            ofxOscMessage m;
            m.setAddress( "/misc/heartbeat" );
            m.addIntArg( ofGetFrameNum() );
            sender.sendMessage( m );
        }
    }
    if (playing) {
      //ACCELEROMETER CONTROL
        if (gameControl == OFXNERDLAB_GAME_CONTROL_ACCEL) {
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
        if (gameControl == OFXNERDLAB_GAME_CONTROL_TAP) {
            if (holding) {
                holdingTime++;
            }
        }
        //AUDIO CONTROL
        if (gameControl == OFXNERDLAB_GAME_CONTROL_AUDIO) {
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
        else {
            micAmplitude = 0;
        }

    }
    
    while (receiver.hasWaitingMessages()) {
        ofxOscMessage msg;
        receiver.getNextMessage(&msg);
        cout << "MESSAGE RECEIVED" << endl;
        cout << msg.getAddress() << endl;
        if (msg.getAddress() == "/quit") {
            //quit to main screen
            keepAlive = false;
        }
        
        if (msg.getAddress() == "/reset") {
            cout << "got message to reset" << endl;
            sender.setup(host, PORT);
            setupController.view.hidden = true;
            ofxOscMessage m;
            m.setAddress( "/alive" );
            sender.sendMessage( m );
//            play(ofxStringToNSString(playerName));
        }
    /*
        if (msg.getAddress() == "/feedback") {

            
            if (msg.getArgAsString(0) == "control") {
                gameControl = msg.getArgAsInt32(1);
            }
            
            if (msg.getArgAsString(0) == "instructions") {
                instructions = msg.getArgAsString(1);
            }
            
            if (msg.getArgAsString(0) == "score") {
                score = msg.getArgAsInt32(1);
            }
            
        }
        */
        
        if (msg.getAddress() == "set") {
            if (msg.getArgAsString(0) == "state") {
                gameState = msg.getArgAsInt32(1);
                cout << "changing game state to " << gameState << endl;

            }
            
            if (msg.getArgAsString(0) == "reaction") {
                cout << "reacting" << endl;
                react(msg.getArgAsInt32(1));
            }
            
            if (msg.getArgAsString(0) == "wait") {
                secondsUntilNextGame = msg.getArgAsInt32(1);
                cout << "got wait time" << endl;
            }

            if (msg.getArgAsString(0) == "playing") {
                playing = msg.getArgAsInt32(1);
                gameState = OFXNERDLAB_GAME_STATE_PLAYING;
                cout << "setting state for playing" << endl;
            }
            
            if (msg.getArgAsString(0) == "control") {
                gameControl = msg.getArgAsInt32(1);
                cout << "setting controls" << endl;
            }

            if (msg.getArgAsString(0) == "color") {
                //change color of player
                playerColor.set(msg.getArgAsInt32(1), msg.getArgAsInt32(2), msg.getArgAsInt32(3));
                cout << "setting color" << endl;
            }
            
            if (msg.getArgAsString(0) == "image") {
                //change image of player
                cout << "changing avatar to " << msg.getArgAsInt32(1) << endl;
                if (msg.getArgAsInt32(1) < playerImage.size()) {
                    playerAvatar = msg.getArgAsInt32(1);
                    
                }
                else {
                    cout << "can't change avatar, that id doesn't exist" <<endl;
                }
            }
            
            if (msg.getArgAsString(0) == "id") {
                //change player id
                playerNumber = msg.getArgAsInt32(1);
                cout << "setting id" << endl;
            }
            
            if (msg.getArgAsString(0) == "images") {
                //change image set
                loadImageSet(msg.getArgAsInt32(1));
                cout << "setting images" << endl;
            }
            
            if (msg.getArgAsString(0) == "index") {
                playerIndex = msg.getArgAsInt32(1);
                cout << "setting index" << endl;
            }
            
            
            if (msg.getArgAsString(0) == "ingamemessage") {
                instructions = msg.getArgAsString(1);
                cout << "Got in game message" << instructions << endl;
            }

            if (msg.getArgAsString(0) == "outgamemessage") {
                message = msg.getArgAsString(1);
                cout << "Got instructions" << instructions << endl;
            }

            
            
            if (msg.getArgAsString(0) == "status") {
                status = msg.getArgAsString(1);
                cout << "setting in game status" << endl;
            }
        }
    }
}

void testApp::react(int reaction) {
    reactionTime = ofGetElapsedTimef() + 2;
    reactionNumber = reaction;
    reacting = true;
    switch (reaction) {
        case OFXNERDLAB_REACTION_PULSE:
            cout << "should pulse" << endl;
            break;
        case OFXNERDLAB_REACTION_ROLL_CALL:
            cout << "Trying to vibrate..." << endl;
            sound->vibrate();
            break;
        default:
            break;
    }
}


void testApp::loadImageSet(int set) {
    string directoryPath;
    switch (set) {
        case OFXNERDLAB_IMAGE_SET_ABSTRACT:
            directoryPath = "abstract";
            break;
        case OFXNERDLAB_IMAGE_SET_HUMANS:
            directoryPath = "humans";
            break;
        case OFXNERDLAB_IMAGE_SET_SQUARE:
            directoryPath = "square";
            break;
        case OFXNERDLAB_IMAGE_SET_TANKS:
            directoryPath = "tanks";
            break;
        default:
            break;
    }

    ofDirectory dir(directoryPath);
    dir.allowExt("png");
    dir.listDir();
    dir.sort();
    playerImage.clear();
    cout << "cleared current images" << endl;

    for (int i = 0; i < dir.numFiles(); i++) {
        ofImage img;
        img.loadImage(dir.getFile(i));
        playerImage.push_back(img);
        cout << "creating new image with " << i << endl;
    }

}

//--------------------------------------------------------------
void testApp::draw(){
    if (reacting) {
        cout << "reacting in draw" << endl;
        if (reactionTime >= ofGetElapsedTimef()) {
            cout << "still reacting" << endl;
            if (reactionNumber == OFXNERDLAB_REACTION_ROLL_CALL) {
                cout << "reaction is screen flash" << endl;
                ofBackground(255, 255, 255);
            }
        }
        else {
            reacting = false;
        }
    }
    else {
        ofBackground(0);
    }
    
    if(playing) {
//        ofSetColor(255, 255, 255);
        joystix.drawString(instructions, ofGetWidth() - joystix.stringWidth(instructions), 40);

        if (gameControl == OFXNERDLAB_GAME_CONTROL_ACCEL) {
            ofSetColor(200, 200);
            for (int x = 0; x < ofGetWidth(); x+=10) {
                ofLine(x, smooth.y, x + 5, smooth.y);
                
            }
            for (int y = 0; y < ofGetHeight(); y+=10) {
                ofLine(smooth.x, y, smooth.x, y + 5);

                
            }
        }
        if (gameControl == OFXNERDLAB_GAME_CONTROL_AUDIO) {
            ofSetColor(0, 255, 255, 127);
            float amplitude = ofMap(micAmplitude, 0, 1, playerImage[playerAvatar].width, ofGetWidth());
            ofRect(position.x, position.y, amplitude, amplitude);
            ofSetColor(0);
            ofRect(position.x, position.y, playerImage[playerAvatar].width, playerImage[playerAvatar].height);
        }
        
        
        ofSetColor(playerColor);
        if (gameControl != OFXNERDLAB_GAME_CONTROL_TAP) {
            holdingTime = 0;
        }
        ofPushMatrix();
        ofTranslate(position);
        ofRotate(rotation);
//        playerImage[playerAvatar].draw(position.x, position.y, playerImage[playerAvatar].width + holdingTime, playerImage[playerAvatar].height + holdingTime);
        playerImage[playerAvatar].draw(0,0, playerImage[playerAvatar].width + holdingTime, playerImage[playerAvatar].height + holdingTime);
        ofPopMatrix();

    }
    else {
        ofSetColor(255, 255, 255);
        switch (gameState) {
            case GAME_STATE_NO_SERVER_CONNECTION:
                joystix.drawStringCentered("Waiting for Connection...", ofGetWidth()/2, ofGetHeight()/2);
                //double tap should resend info
                ofSetColor(255, 0, 0);
                drawQuitBar();
                
                break;
            case OFXNERDLAB_GAME_STATE_WAITING:
//                playerImage[playerAvatar].draw(ofGetWidth()/2, playerImage[playerAvatar].height/2 + 20);
                joystix.drawStringCentered("Connected", ofGetWidth()/2, ofGetHeight()/2);
                joystix.drawStringCentered("Next Game in " + ofToString(secondsUntilNextGame) + " Seconds", ofGetWidth()/2, ofGetHeight()/2 + 30);
                joystix.drawStringCentered(instructions, ofGetWidth()/2, ofGetHeight()/2+80);
                drawQuitBar();
                break;
                
            case OFXNERDLAB_GAME_STATE_PLAYING:
                joystix.drawString(status, 10, 30);
                drawQuitBar();
                break;
/*            case OFXNERDLAB_GAME_STATE_SHOW_SCORE:
                joystix.drawStringCentered(status, ofGetWidth()/2, ofGetHeight()/2);
                joystix.drawStringCentered(status, ofGetWidth()/2, ofGetHeight()/2 + 30);
//                joystix.drawStringCentered("Double Tap to Quit", ofGetWidth()/2, ofGetHeight()/2 + 100);

                break;
 */
            default:
                break;
        }
    }
    ofSetColor(255, 255, 255);
    joystix.drawString(playerName, 10, 10);
//    joystix.drawString(chosenGame, ofGetWidth() - joystix.stringWidth(chosenGame), 20);
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
//    pauseController.view.hidden = true;
    setupController.view.hidden = false;
    keepAlive = false;
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
    keepAlive = true;
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

void testApp::drawQuitBar() {
    ofSetRectMode(OF_RECTMODE_CORNER);
    ofRect(0, ofGetHeight()-40, ofGetWidth()*2, 80);
    ofSetRectMode(OF_RECTMODE_CENTER);
    ofSetColor(0, 0, 0);
    joystix.drawStringCentered("quit", ofGetWidth()/2-2, ofGetHeight()-20);
    ofSetColor(255, 255, 255);
    joystix.drawStringCentered("quit", ofGetWidth()/2, ofGetHeight()-20);
    

}
//--------------------------------------------------------------
void testApp::touchDown(ofTouchEventArgs & touch){
    if (playing) {
        velocity.set(touch.x, touch.y);
        if (gameControl == OFXNERDLAB_GAME_CONTROL_TAP) {
            ofxOscMessage m;
            m.setAddress( "/tap" );
            m.addIntArg(playerNumber);
            sender.sendMessage(m);
            holding = true;
        }
        
    }
    
    if (touch.y >= ofGetHeight()-40) {
        wantsToQuit = true;
    }
}

//--------------------------------------------------------------
void testApp::touchMoved(ofTouchEventArgs & touch){
    if (playing) {
        if (gameControl == OFXNERDLAB_GAME_CONTROL_MOVE) {
            cout << "sending movement" << endl;
            position.set(touch.x, touch.y);
            ofxOscMessage m;
            m.setAddress( "/move" );
            m.addIntArg(playerNumber);
        
            m.addFloatArg( (velocity.x - touch.x));
            m.addFloatArg( (velocity.y - touch.y));
            sender.sendMessage( m );
        }
        if (gameControl == OFXNERDLAB_GAME_CONTROL_ROTATE) {
    
            rotation = velocity.x - touch.x;//
            ofxOscMessage m;
            m.setAddress("/rotate");
            m.addIntArg(playerNumber);
            m.addFloatArg(rotation);
            sender.sendMessage(m);
        }
    }
}

//--------------------------------------------------------------
void testApp::touchUp(ofTouchEventArgs & touch){
    if (playing) {
        if (gameControl == OFXNERDLAB_GAME_CONTROL_TAP) {
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
    if (wantsToQuit) {
        if (touch.y >= ofGetHeight()-40) {
            if (gameState == GAME_STATE_NO_SERVER_CONNECTION) {
                setupController.view.hidden = false;
                playing = false;
                keepAlive = false;
            }
            else {
                setupController.view.hidden = false;
                ofxOscMessage m;
                playing = false;
                keepAlive = false;
                m.setAddress( "/quit" );
                m.addIntArg(playerNumber);
                sender.sendMessage(m);
                
            }

        }
    }
    wantsToQuit = false;
}

//--------------------------------------------------------------
void testApp::touchDoubleTap(ofTouchEventArgs & touch){
        /*
    if (gameState == GAME_STATE_SHOW_SCORE) {
        setupController.view.hidden = false;
        ofxOscMessage m;
        playing = false;
        m.setAddress( "/quit" );
        m.addIntArg(playerNumber);
        sender.sendMessage(m);
        
    }
     */
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
