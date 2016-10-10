
#include <Arduino.h>
#include "lib/MidiUSB/MidiUSB.h"

MIDIController midiController;


Multiplexer mux1(A5, 11, 10, 9);

void setup()
{

    mux1.init();

    midiController.initUSB();
    //midiController.mapPinToNote(12,60);
    midiController.mapPinToControl(&mux1, 0, 0);
    midiController.mapPinToControl(&mux1, 1, 1);
    midiController.mapPinToControl(&mux1, 2, 2);
    midiController.mapPinToControl(&mux1, 3, 3);
    midiController.mapPinToControl(&mux1, 4, 4);
    midiController.mapPinToControl(&mux1, 5, 5);
    midiController.mapPinToControl(&mux1, 6, 6);
    midiController.mapPinToControl(&mux1, 7, 7);

}

void loop()
{

    midiController.update();

    delay(10);

    //analogWrite(5, analogRead(5) / 4);

    //digitalWrite(5, HIGH);

}




