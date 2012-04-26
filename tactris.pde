/* -*- c -*-
    by embeddedlinuxguy@gmail.com
    GPL v2
 */

#include <Bounce.h>


#define FINGERS 4
#define JOINTS 4

#define SPECIAL_FINGER_1 1
#define SPECIAL_JOINT_1  1

#define SPECIAL_FINGER_2 2
#define SPECIAL_JOINT_2 2

int button[JOINTS] = {
    //    33, 34, 35, 32
    33, 34, 35, 32
};
#define TIME 10
Bounce bouncer[JOINTS] = {
    Bounce(button[0], TIME),
    Bounce(button[1], TIME),
    Bounce(button[2], TIME),
    Bounce(button[3], TIME)
};


#define LED 31

#define OFF LOW
#define ON HIGH

bool tacstate[FINGERS][JOINTS] = {
    {OFF, OFF, OFF, OFF},
    {OFF, OFF, OFF, OFF},
    {OFF, OFF, OFF, OFF},
    {OFF, OFF, OFF, OFF}
};

int MOLE[FINGERS][JOINTS] = {
    {10, 11, 12, 13},
    {25, 24, 23, 22},
    {6, 7, 8, 9},
    {2, 3, 4, 5}
};

int value;

#define BAUD 19200
#define UNCONNECTED_PIN 0 // for randomSeed

void setup() {                
    Serial.begin(BAUD);
 
    int f, j;

    for (j=0; j < JOINTS; ++j) {
	pinMode(button[j], INPUT);
	digitalWrite(button[j], LOW);
    }

    pinMode(LED, OUTPUT);
    digitalWrite(LED, LOW);

    for (f = 0; f < FINGERS; ++f) {
	for (j = 0; j < JOINTS; ++j) {
	    pinMode(MOLE[f][j], OUTPUT);     
	    digitalWrite(MOLE[f][j], tacstate[f][j]);
	}
    }
    randomSeed(analogRead(UNCONNECTED_PIN));
    //    while(true) { delay(1000); }

    // button test
    while (false) {
	int i;
	for (i=0; i < 4; ++i) {
	    Serial.print("Button "); Serial.print(i, DEC); Serial.print(" ");
	    Serial.println(bouncer[i].update());
	    delay(500);
	}
    }
}

#define UP LOW
#define DOWN HIGH

int joints_left = JOINTS;
int finger = 0;

/* return a random joint which is in UP state */

int joint_seed = 0;

int getJoint(void) {
    int joint = random(0, JOINTS);
    while (tacstate[finger][joint] == ON) {
	Serial.print("Ignoring "); Serial.println(joint);
	joint = random(0, JOINTS);
    }
    return joint;
}

//#define TIMEOUT 4000    
//#define BASE_DELAY 2000 // ms
//#define EXTRA_DELAY 2000 // ms


unsigned long TIMEOUT = 4000;

#define BASE_DELAY 200 // ms
#define EXTRA_DELAY 20 // ms

#define PRESSES_NEEDED 2

void fail() {
    int f, j;
    Serial.println("Game Over");

    int i;
    for (i=0; i < 5; ++i) {
	for (f = 0; f < FINGERS-1; ++f) {
	    for (j = 0; j < JOINTS; ++j) {
		digitalWrite(MOLE[f][j], OFF);
	    }
	}
	delay(500);
	for (f = 0; f < FINGERS-1; ++f) {
	    for (j = 0; j < JOINTS; ++j) {
		digitalWrite(MOLE[f][j], ON);
	    }
	}
	delay(500);
    }
    while (true) { delay(10000); } //dead
}

int getPressedJoint() {
    int j;
    int count = 0;

    while (tacstate[finger][j] == OFF) {
	j = random(0, JOINTS);
    }
    return j;
}
void loop() {
    delay(BASE_DELAY + random(0, EXTRA_DELAY));

    int joint = getJoint();
    Serial.print("finger ") + Serial.print(finger, DEC);
    Serial.print(" joint: ");
    Serial.println(joint);

    bouncer[joint].update(); // reset push state
    digitalWrite(MOLE[finger][joint], ON);

    unsigned long up_time = millis();
    bool wait_press = true;
    int num_presses = 0;

    while ((millis() < (up_time + (TIMEOUT - (unsigned long)(500*finger)))) && (num_presses < PRESSES_NEEDED)) {
	// wait for button click
	bool is_pressed = bouncer[joint].update();
	if (wait_press && is_pressed) {
	    ++num_presses;
	    wait_press = false;
	} else {
	    if (!wait_press && !is_pressed) {
		wait_press = true;
	    }
	}
	delay(5); // ?
    }

    if (num_presses >= PRESSES_NEEDED) {
	/* success */
	Serial.println("Succeeded - pin retracts");
	digitalWrite(MOLE[finger][joint], OFF);
	if ((finger == SPECIAL_FINGER_1) && (joint == SPECIAL_JOINT_1)) {
	    if (joints_left < JOINTS) {
		int reset_joint = getPressedJoint();
		digitalWrite(MOLE[finger][reset_joint], OFF);
		tacstate[finger][reset_joint] = OFF;
		joints_left++;
	    } else {

	    }
	}
    } else {
	/* failure */
	Serial.println("Failed - pin stays");
	tacstate[finger][joint] = ON;
	joints_left--;
	if (joints_left == 0) {
	    joints_left = JOINTS;
	    ++finger;
	    if (finger == FINGERS) {
		fail();
	    }
	}
    }
}

void test()
{
    int i,j;
#define ROWS 4
#define COLS 4
#define DELAY 500


    for (i = 0; i < ROWS; ++i) {
	for (j = 0; j < COLS; ++j) {
	    Serial.println(MOLE[i][j]);
	    digitalWrite(MOLE[i][j], HIGH);
	    delay(DELAY);              // wait for a second

	}
    }

    for (i = 0; i < 4; ++i) {
	for (j = 0; j < 4; ++j) {
	    Serial.println(MOLE[i][j]);
	    digitalWrite(MOLE[i][j], LOW);
	    delay(DELAY);              // wait for a second

	}
    }
}

#if 0
    Serial.print("RANGE: [0,"); Serial.print(joints_left);
    Serial.print(") "); Serial.println(joint);
    int j, ji = 0;

    while (tacstate[finger][ji] == ON) {
	Serial.print("Skipping "); Serial.println(ji);
	++ji;
    }

    for (j=0; j < joint; ++j) {
	while (tacstate[finger][ji] == ON) {
	    Serial.print("Skipping "); Serial.println(ji);
	    ++ji;
	}
    }
    /*
     */
    Serial.print("Returning "); Serial.println(ji);
    return ji;
#endif
//int button[JOINTS] = { 32, 35, 34, 33 };
/* Button layout:
   1
   2
   3
   0
*/
    //    int s = joint_seed;
    //    joint_seed = (joint_seed+1)%4;
    //    return s;
    
    //    int joint = random(0, joints_left);
