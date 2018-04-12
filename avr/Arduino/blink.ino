/*
  Blink
  Turns on an LED on for one second, then off for one second, repeatedly.
 
  This example code is in the public domain.
 */

void setup() {                
  // initialize the digital pin as an output.
  // Pin 13 has an LED connected on most Arduino boards
int i;
for (i=0;i<=13;i++) {
  pinMode(i, OUTPUT);     
}
}

void loop() {
int i;
for (i=0;i<=13;i++) {
  digitalWrite(i, HIGH);   // set the LED on
}
  delay(30);              // wait for a second
for (i=0;i<=13;i++) {
  digitalWrite(i, LOW);   // set the LED off
}
  delay(30);              // wait for a second



}
