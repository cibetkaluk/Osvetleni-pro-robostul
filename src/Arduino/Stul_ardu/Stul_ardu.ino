byte vystup;
byte hal[3];

void setup()
{
  Serial.begin(9600);
  vystup=hall(7,5,3);
  Serial.write(vystup);
}

void loop()
{
  if(Serial.available())
  {
    Serial.read();
    Serial.print(vystup,BIN);
  }
}



//kodování komunikace výchozí
byte hall(byte x,byte y,byte state)
{
  byte b=0;
  b=(x<<5)+(y<<2)+state;
  return byte(b);
}

//dekodování komunikace příchozí
byte led(byte b)
{
  byte state[3] ;
  state[0]=(b>>5)&7;
  state[1]=(b>>2)&7;
  state[2]=b&3;
  
  return state;
}
