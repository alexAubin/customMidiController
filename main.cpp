
#include <Arduino.h>
#include "lib/MidiUSB/MidiUSB.h"


MIDIController midiController;


void setup()
{
    pinMode     (13, OUTPUT);
    pinMode     (12, INPUT_PULLUP);

    midiController.initUSB();
    midiController.mapPinToNote(12,60);

}

void loop()
{

    midiController.update();

    delay(10);

}


