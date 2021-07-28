
#define pocet_desek 7

#define HCLK 3
#define HIN 5
#define HLATCH 2
#define HRST 4
#define LED_DATA 6
#define LED_CLK 9
#define LED_LE 7
#define LED_OE 8

byte vystup;
byte vstup;

//pole pro data hall sond
byte hall_stat[pocet_desek]={B10101000};
byte prev_hall_stat[pocet_desek];

//pole pro led data ve formátu GRGRGRGR
byte led_G[pocet_desek];
byte led_R[pocet_desek]; 
byte led_mesh[2*pocet_desek]={B11111111,B11111111};
byte mesh_top=B11111111;
byte mesh_bot;
byte led_data[3]={B10101000,B11111111,B00000000};

byte hall_x;
byte hall_y;
byte hall_state;


void setup()
{
  pinMode(HCLK,OUTPUT);
  pinMode(HIN,INPUT);
  pinMode(HLATCH,OUTPUT);
  pinMode(HRST,OUTPUT);
  pinMode(LED_DATA,OUTPUT);
  pinMode(LED_CLK,OUTPUT);
  pinMode(LED_LE,OUTPUT);
  pinMode(LED_OE,OUTPUT);

  pulseout(HRST,1,1);
  digitalWrite(HCLK,LOW);
  digitalWrite(HLATCH,HIGH);
  digitalWrite(LED_OE,LOW);
  
  Serial.begin(115200);
  //vystup=hall(7,5,3);
  //Serial.write(vystup);
  Serial.write(hall(7,7,3));

  while(Serial.read()!=B11111111)
  {
    
  }
  //hall_status();
  //Serial.println(hall_stat[0],BIN);
  
}

void loop()
{
  if(millis()%100==0)
  {
    pulseout(HRST,1,1);
  }

  if(Serial.available())
  { 
    //pulseout(HRST,1,1);
    vstup=Serial.read();
    //Serial.print(vstup);
    //Serial.println(led_data[0],BIN);
    //Serial.println(led_data[1],BIN);
    //Serial.println(led_data[2],BIN);
    led(vstup);
    //funguj pouze pokud máš přiřazený počet desek
    //Serial.write(hall(led_data[0],led_data[1],led_data[2]));
    if(led_data[0]<pocet_desek)
    {
      //pokud jde o kolečko s indexem menším než 4 tak je červený byte posunutý za zelenou
      if(led_data[1]<4)
      {
        //rozhodování co se má stát 2 bity - 4 možnosti
        switch(led_data[2])
        {
          case 0:
            led_G[led_data[0]]&=~(1<<(7-((led_data[1]*2)%8)));
            led_R[led_data[0]]&=~(1<<(7-((led_data[1]*2+1)%8)));
            //led(led_G[0]);
            //Serial.write(hall(led_data[0],led_data[1],led_data[2]));
            //Serial.write(hall(7,6,0));
           break;
          case 1:
            led_G[led_data[0]]|=1<<(7-((led_data[1]*2)%8));
            led_R[led_data[0]]&=~(1<<(7-((led_data[1]*2+1)%8)));
            //led(led_G[0]);
            //Serial.write(hall(led_data[0],led_data[1],led_data[2]));
            //Serial.write(hall(7,6,1));
           break;
          case 2:
            led_G[led_data[0]]&=~(1<<(7-((led_data[1]*2)%8)));
            led_R[led_data[0]]|=1<<(7-((led_data[1]*2+1)%8));
            //led(led_G[0]);
            //Serial.write(hall(led_data[0],led_data[1],led_data[2]));
            //Serial.write(hall(7,6,2));
            
           break;
          case 3:
            led_G[led_data[0]]|=1<<(7-((led_data[1]*2)%8));
            led_R[led_data[0]]|=1<<(7-((led_data[1]*2+1)%8));
            //Serial.write(hall(7,6,3));
           break; 
        }
      }
      else
      {
        switch(led_data[2])
        {
          case 0:
            led_G[led_data[0]]&=~(1<<(7-((led_data[1]*2+1)%8)));
            led_R[led_data[0]]&=~(1<<(7-((led_data[1]*2)%8)));
            //led(led_G[0]);
            //Serial.write(hall(led_data[0],led_data[1],led_data[2]));
            //Serial.write(hall(6,7,0));
           break;
          case 1:
            led_G[led_data[0]]|=1<<(7-((led_data[1]*2+1)%8));
            led_R[led_data[0]]&=~(1<<(7-((led_data[1]*2)%8)));
            //led(led_G[0]);
            //Serial.write(hall(led_data[0],led_data[1],led_data[2]));
            //Serial.write(hall(6,7,1));
           break;
          case 2:
            led_G[led_data[0]]&=~(1<<(7-((led_data[1]*2+1)%8)));
            led_R[led_data[0]]|=1<<(7-((led_data[1]*2)%8));
            //led(led_G[0]);
            //Serial.write(hall(led_data[0],led_data[1],led_data[2]));
            //Serial.write(hall(6,7,2));
            
           break;
          case 3:
            led_G[led_data[0]]|=1<<(7-((led_data[1]*2+1)%8));
            led_R[led_data[0]]|=1<<(7-((led_data[1]*2)%8));
            //Serial.write(hall(6,7,3));
           break; 
        }
      }
      //update pouze pokud je pro definovaný počet desek
      update_LED(0);
      
    }
    else
    {
      if(led_data[0]==7)
      {
        if(led_data[1]==0)
        {
          switch(led_data[2])
          {
            case 0:
              //Serial.write(hall(7,0,0));
              for(int i=0;i<pocet_desek;i++)
              {
                led_G[i]=B00000000;
                
                led_R[i]=B00000000;
                //Serial.write(led_G[i]);
              }
            break;
            case 1:
              //Serial.write(hall(7,0,1));
              for(int i=0;i<pocet_desek;i++)
              {
                led_G[i]=255;
                led_R[i]=0;
                //Serial.write(led_G[i]);
              }
            break;
            case 2:
              //Serial.write(hall(7,0,2));
              for(int i=0;i<pocet_desek;i++)
              {
                led_R[i]=255;
                led_G[i]=0;
              }
            break;
            case 3:
             //Serial.write(hall(7,0,3));
              for(int i=0;i<pocet_desek;i++)
              {
                led_G[i]=255;
                led_R[i]=255;
              }
            break;  
          }
          
          update_LED(1);
          
        }
      }
      
    }

    

    
    
    //Serial.write(hall(led_data[0],led_data[1],led_data[2]));
    //Serial.print(hall(led_data[0],led_data[1],led_data[2]),DEC);
  }

  
  hall_status();
  for(int i=0;i<pocet_desek;i++)
  { 
    //zjištování změn stavu hall sond na deskách (X souradnice pro odeslání)
    if(hall_stat[i]!=prev_hall_stat[i])
    {
      //Serial.write(hall(1,1,3));
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
  //delay(10);
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
void led(byte b)
{
  led_data[0]=(b>>5)&7;
  led_data[1]=(b>>2)&7;
  led_data[2]=b&3;
}

void update_LED(boolean special)
{
  if(special)
  {
    //Serial.write(hall(2,2,2));
    for(int i=0;i<pocet_desek;i++)
    {
      mesh_top=((led_G[i]&B10101010)>>1)|((led_R[i]&B01010101))<<1;
      mesh_bot=(led_G[i]&B01010101)|(led_R[i]&B10101010);
    
      led_mesh[2*i]=mesh_top;
      led_mesh[2*i+1]=mesh_bot;
    }
  }
  else
  {
    //Serial.write(hall(1,1,1));
    mesh_top=((led_G[led_data[0]]&B10101010)>>1)|((led_R[led_data[0]]&B01010101))<<1;
    mesh_bot=(led_G[led_data[0]]&B01010101)|(led_R[led_data[0]]&B10101010);
  
    led_mesh[2*led_data[0]]=mesh_top;
    led_mesh[2*led_data[0]+1]=mesh_bot;
  }
  

  //led(led_G[0]);
  //Serial.write(hall(led_data[0],led_data[1],led_data[2]));
  //led(led_R[0]);
  //Serial.write(hall(led_data[0],led_data[1],led_data[2]));
  //led(mesh_top);
  //Serial.write(hall(led_data[0],led_data[1],led_data[2]));
  //led(mesh_bot);
  //Serial.write(hall(led_data[0],led_data[1],led_data[2]));
   //
   //
   //Led oe - pin 8
   //Led le - pin 7
  PORTB |= B00000001;
  //digitalWrite(LED_OE,HIGH);
  
  for(int i=pocet_desek;i>=0;i--)
  {
    shiftout(LED_DATA,LED_CLK,led_mesh[2*i],led_mesh[2*i+1]);
  }

  PORTD |= B10000000;
  //digitalWrite(LED_LE,HIGH);
  PORTD &= !B10000000;
  //digitalWrite(LED_LE,LOW);
  PORTB &= !B00000001;
  //digitalWrite(LED_OE,LOW);
  
}

void shiftout(int Output,int Clock,byte topB,byte botB)
{
  //1. Byte
  for(int x=0;x<8;x++)
  {
    
    if((botB>>x)&1==1)
    {
      PORTD |= B01000000;
      //digitalWrite(Output,HIGH);
    }
    else
    {
      PORTD &= !B01000000;
      //digitalWrite(Output,LOW);
    }
    
    PORTB |= B00000010;
    //digitalWrite(Clock,HIGH);
    PORTB &= !B00000010;
    //digitalWrite(Clock,LOW);
    PORTB |= B00000001;
  }
  //2. Byte
  for(int x=0;x<8;x++)
  {
    if((topB>>x)&1==1)
    {
      PORTD |= B01000000;
      //digitalWrite(Output,HIGH);
    }
    else
    {
      PORTD &= !B01000000;
      //digitalWrite(Output,LOW);
    }
    
    PORTB |= B00000010;
    //digitalWrite(Clock,HIGH);
    PORTB &= !B00000010;
    //digitalWrite(Clock,LOW);
    PORTB |= B00000001;
  }
  
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
