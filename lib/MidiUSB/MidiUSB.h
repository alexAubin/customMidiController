#ifndef _MIDIUSB_H_
#define _MIDIUSB_H_

#include "Multiplexer.h"

#define DEBOUNCE_PARAMETER 5
#define MAX_NUMBER_OF_ELEMENTS 32

class MIDIController
{

    public :

        MIDIController();

        int initUSB();
        void mapPinToNote   (                  int pinNumber, char noteValue);
        void mapPinToNote   (Multiplexer* mux, int pinNumber, char noteValue);
        void mapPinToControl(                  int pinNumber, char controlId);
        void mapPinToControl(Multiplexer* mux, int pinNumber, char controlId);
        void update();
        void readElement(int i);
        void updateElement(int i);
        void sendMidiMessage(char a, char b, char c);

    private :

        void initElement(int pinNumber, char function, char functionParameter, Multiplexer* mux = 0);

        int  numberOfElements;
        int  elementPin              [MAX_NUMBER_OF_ELEMENTS];
        char elementFunction         [MAX_NUMBER_OF_ELEMENTS];
        char elementFunctionParameter[MAX_NUMBER_OF_ELEMENTS];
        char elementLastState        [MAX_NUMBER_OF_ELEMENTS];
        char elementDebounceCount    [MAX_NUMBER_OF_ELEMENTS];
        char elementStatus           [MAX_NUMBER_OF_ELEMENTS];


        Multiplexer* elementMux      [MAX_NUMBER_OF_ELEMENTS];

        unsigned char usbMessage[8];

};



#endif
