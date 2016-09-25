#ifndef MULTIPLEXER_H_
#define MULTIPLEXER_H_

#include "Arduino.h"

class Multiplexer
{
    public :

        Multiplexer(int pin, int controlPinA, int controlPinB, int controlPinC);

        void init();

        void select(unsigned char id);
        int  getPin();

    private :

        int pin;
        int controlPinA;
        int controlPinB;
        int controlPinC;

};

#endif
