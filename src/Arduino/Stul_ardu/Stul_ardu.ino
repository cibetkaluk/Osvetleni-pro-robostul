
#define pocet_desek 2

#define HCLK 3
#define HIN 5
#define HLATCH 2
#define HRST 4

byte vystup;

byte hall_stat[pocet_desek]={B10101000};
byte prev_hall_stat[pocet_desek];

byte hall_x;
byte hall_y;
byte hall_state;


void setup()
{
  pinMode(HCLK,OUTPUT);
  pinMode(HIN,INPUT);
  pinMode(HLATCH,OUTPUT);
  pinMode(HRST,OUTPUT);
  
  digitalWrite(HCLK,LOW);
  digitalWrite(HLATCH,HIGH);

  Serial.begin(115200);
  vystup=hall(7,5,3);
  //Serial.write(vystup);
  
  hall_status();
  //Serial.println(hall_stat[0],DEC);
  
}

void loop()
{
//  if(Serial.available())
//  {
//    Serial.read();
//    Serial.print(vystup,BIN);
//  }
  hall_status();
  for(int i=0;i<pocet_desek;i++)
  { 
    //zjištování změn stavu hall sond na deskách (X souradnice pro odeslání)
    if(hall_stat[i]!=prev_hall_stat[i])
    {
      hall_x=i;

      if(hall_stat[i]>prev_hall_stat[i])
      {
        hall_state=1;
      }
      else
      {
        hall_state=0;
      }

      //izolace pouze změněné sondy
      hall_stat[i]=hall_stat[i]^prev_hall_stat[i];
      
      //zjištování která sonda se zmenila na x-té desce (Y souradnice pro odeslání)
      for(int y=0;y<8;y++)
      {
        if((hall_stat[i]>>(y+1))<1)
        {
          hall_y=y;
          break;
        }
      }
      Serial.write(hall(hall_x,hall_y,hall_state));
      prev_hall_stat[i]=prev_hall_stat[i]^hall_stat[i];
    }
    //Serial.println(hall_stat[i],BIN);
  }
  //Serial.println("========");
  delay(1000);
}

//získání dat z hall sond
void hall_status()
{
  pulseout(HLATCH,1,0);
  //digitalWrite(HCLK,LOW);
  //delay(1);
  for(int i=0;i<pocet_desek;i++)
  { 
    //digitalWrite(HCLK,HIGH);
    hall_stat[i]=shiftin(HIN,HCLK);
    
  }
}

void pulseout(int pin ,int len,boolean High)
{
  if(High)
  {
    digitalWrite(pin,HIGH);
    delayMicroseconds(len);
    digitalWrite(pin,LOW);
  }
  else
  {
    digitalWrite(pin,LOW);
    delayMicroseconds(len);
    digitalWrite(pin,HIGH);
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

byte shiftin(int Input,int Clock)
{
  byte out=0;
  for(int i=0;i<8;i++)
  {
    if(digitalRead(Input))
    {
      out = out|(1<<(7-i));
    }
    digitalWrite(Clock,HIGH);
    digitalWrite(Clock,LOW);
  }
  return out;
}
