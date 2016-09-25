#include "Multiplexer.h"

Multiplexer::Multiplexer(int pin, int controlPinA, int controlPinB, int controlPinC)
{
    this->pin          = pin;
    this->controlPinA  = controlPinA;
    this->controlPinB  = controlPinB;
    this->controlPinC  = controlPinC;
}

void Multiplexer::init()
{
    pinMode(pin,          INPUT);
    pinMode(controlPinA, OUTPUT);
    pinMode(controlPinB, OUTPUT);
    pinMode(controlPinC, OUTPUT);
}

void Multiplexer::select(unsigned char id)
{
    if ((id < 0) || (id >= 8)) return;

    delay(1);
    digitalWrite(controlPinA, id & (1 << 0));
    digitalWrite(controlPinB, id & (1 << 1));
    digitalWrite(controlPinC, id & (1 << 2));
}

int Multiplexer::getPin()
{
    return pin;
}


