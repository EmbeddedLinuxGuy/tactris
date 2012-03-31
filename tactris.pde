/* -*- c -*-
    by embeddedlinuxguy@gmail.com
    GPL v2
 */

#include <Bounce.h>

#define BUTTON1 32
#define BUTTON2 33
#define BUTTON3 34
#define BUTTON4 35

#define LED 31
#define TIME 10

Bounce bouncer = Bounce(BUTTON4, TIME); 

#define PIN 11

#define ROWS 4
#define COLS 4

bool tacstate[ROWS][COLS] = {
    {0, 0, 0, 0},
    {0, 0, 0, 0},
    {0, 0, 0, 0},
    {0, 0, 0, 0}
};

int MOLE[ROWS][COLS] = {
    {2, 3, 4, 5},
    {6, 7, 8, 9},
    {25, 24, 23, 22},
    {10, 11, 12, 13},
};

int value;

#define DELAY 500

void setup() {                
    Serial.begin(19200);
 
    int j;
    int i;

    pinMode(BUTTON1, INPUT);
    pinMode(BUTTON2, INPUT);
    pinMode(BUTTON3, INPUT);
    pinMode(BUTTON4, INPUT);
    digitalWrite(BUTTON1, LOW);
    digitalWrite(BUTTON2, LOW);
    digitalWrite(BUTTON3, LOW);
    digitalWrite(BUTTON4, LOW);

    pinMode(LED,OUTPUT);
    digitalWrite(LED, LOW);

    for (i = 0; i < 4; ++i) {
	for (j = 0; j < 4; ++j) {
	    pinMode(MOLE[i][j], OUTPUT);     
	    digitalWrite(MOLE[i][j], HIGH);
	}
    }
}

void loop() {
    int i, j;
    int value2;
    int state;

    for (i = 0; i < 4; ++i) {
	for (j = 0; j < 4; ++j) {
	    Serial.println(MOLE[i][j]);
	    digitalWrite(MOLE[i][j], HIGH);
	    delay(DELAY);              // wait for a second

	    bouncer.update();
	    state = bouncer.read();
	    if (state != value) {
		value = state;
		digitalWrite(LED, value);
	    }
	}
    }

    for (i = 0; i < 4; ++i) {
	for (j = 0; j < 4; ++j) {
	    Serial.println(MOLE[i][j]);
	    digitalWrite(MOLE[i][j], LOW);
	    delay(DELAY);              // wait for a second

	    bouncer.update();
	    state = bouncer.read();
	    if (state != value) {
		value = state;
		digitalWrite(LED, value);
	    }
	}
    }


}
