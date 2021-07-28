
//proěné použité pro sériovou komunikaci
byte send;
int recieved;

int hal[]=new int[3];

//knihovna seriové komunikace pro processing
import processing.serial.*;
Serial port;

void setup()
{
  //vytvoření oběktu "port" pro komunikaci s rychlostí 115200 baudů
  port = new Serial(this,Serial.list()[0],115200);
  
  //test seriové komunikace
  send=send_led(7,5,3);
  port.write(send);
  println(binary(send));
  size(300,200);
}

void draw()
{
  
  //pokud je něco v portu přečti to
  if(port.available()>0)
  {
    recieved=port.read();
    hal=recieve_hall(recieved);
    println(hal[0]);
    println(binary(hal[0]));
    println(hal[1]);
    println(binary(hal[1]));
    println(hal[2]);
    println(binary(hal[2]));
    println("=================");
  }
}

void keyReleased()
{
  if(key=='f'||key=='F')
  {
    send=send_led(0,6,0);
  }
  if(key=='g'||key=='G')
  {
    send=send_led(0,6,1);
  }
  if(key=='r'||key=='R')
  {
    send=send_led(0,6,2);
  }
  if(key=='b'||key=='B')
  {
    send=send_led(0,6,3);
  }
  port.write(send);
}

void mouseReleased()
{
  if(mouseButton==LEFT)
  {
    send=send_led(0,6,0);
  }
  if(mouseButton==RIGHT)
  {
    send=send_led(0,6,1);
  }
  if(mouseButton==CENTER)
  {
    send=send_led(0,6,2);
  }
  port.write(send);
}

//kodování seriové komunikace -> odesílání
byte send_led(int x,int y,int state)
{
  int b=0;
  b=(x<<5)+(y<<2)+state;
  return byte(b);
}

//dekodování komunikace -> příjem 
int[] recieve_hall(int b)
{
  int[] state = new int[3];
  state[0]=(b>>5)&7;
  state[1]=(b>>2)&7;
  state[2]=b&3;
  
  return state;
}
