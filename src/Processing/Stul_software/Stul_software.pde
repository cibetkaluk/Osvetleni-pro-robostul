
byte send;
int hal[]=new int[3];

void setup()
{
  send=send_led(7,5,3);
  println(binary(send));
  hal=recieve_hall(send);
  println(hal[0]);
  println(binary(hal[0]));
  println(hal[1]);
  println(binary(hal[1]));
  println(hal[2]);
  println(binary(hal[2]));
}

void draw()
{
  
}

byte send_led(int x,int y,int state)
{
  int b=0;
  b=(x<<5)+(y<<2)+state;
  return byte(b);
}

int[] recieve_hall(byte b)
{
  int[] state = new int[3];
  state[0]=(b>>5)&7;
  state[1]=(b>>2)&7;
  state[2]=b&3;
  
  return state;
}
