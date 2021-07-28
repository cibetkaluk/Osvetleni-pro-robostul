
ArrayList<Pixel> Pix = new ArrayList<Pixel>(); 

Pixel P;

String [] Data;

int size=100;

int counter=0;
int count=-1;

int prevxpos=0;
int prevypos=0;

boolean getpos=true;

//proěné použité pro sériovou komunikaci
byte send;
int recieved;

int hal[]=new int[3];

int sonda[]={0,3,1};
int barva=0;

//knihovna seriové komunikace pro processing
import processing.serial.*;
Serial port;

void setup()
{
  size(1280,720);
  //vytvoření oběktu "port" pro komunikaci s rychlostí 115200 baudů
  port = new Serial(this,Serial.list()[0],115200);
  
  Data=loadStrings("data/pozice.data");
  
  //test seriové komunikace
  send=send_led(7,5,3);
  //port.write(send);
  println(binary(send));
  //vytvoření rozložení stolu
  textAlign(CENTER,CENTER);
  if(Data==null)
  {
    for(int x=0;x<9;x++)
    {
      for(int y=0;y<6;y++)
      {
        P = new Pixel(x*(size)+10,y*(size)+10,size,size,(x*6+y));
        Pix.add(P);
      }
    }
  }
  else
  {
    for(int i=0;i<Data.length;i++)
    {
      String s = Data[i];
      String [] temp = split(s,';');
      P = new Pixel(int(temp[0]),int(temp[1]),size,size,int(temp[2]));
      Pix.add(P);
    }
  }
  
  
}

void draw()
{
  //pozadí
  background(192);
  //vykreslení stolu
  for(Pixel P : Pix)
  {
    P.show();
  }
  //println((((mouseX-10)/(size+1)*size)+10),(mouseY-10)/size);
  
  //pokud arduino zjistilo změnu na hall sondě ulož ji
  if(port.available()>0)
  {
    //recieved převezme poslaný byte
    recieved=port.read();
    //dekodování bytu
    hal=recieve_hall(recieved);
    println(hal[0]);
    println(binary(hal[0]));
    println(hal[1]);
    println(binary(hal[1]));
    println(hal[2]);
    println(binary(hal[2]));
    println("=================");
    
    //pro učely testování
    for(int x=0;x<1;x++)
    {
      for(int y=0;y<8;y++)
      {
        if(hal[0]==x&&hal[1]==y&&hal[2]==1)
        {
          
          for(Pixel P : Pix)
          {
            if(P.ind==(x*6+y))
            {
              P.changeColor();
              send=send_led(P.ind/8,P.ind%8,P.col);
              port.write(send);
            }
          }
        }
      }
    }
  }
}


//pouze tesování
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
  if(key=='S')
  {
    saveStat();
  }
  port.write(send);
}

void saveStat()
{
  Data = new String[0];
  for(Pixel P : Pix)
  {
    int x=P.xpos;
    int y=P.ypos;
    int ind=P.ind;

    String S =x+";"+y+";"+ind;
    String temp[] = new String[1];
    temp[0]=S;
    Data=concat(Data,temp);
  }
  saveStrings("data/pozice.data",Data);
}

void mouseClicked()
{
  //counter=0;
  //count=-1;
  
  
  //pro všechny pole(pixely)
  for(Pixel P : Pix)
  {
    
    if(P.mouseOverPix())
    {
      println("Sending");
      P.changeColor();
      send=send_led(P.ind/8,P.ind%8,P.col);
      port.write(send);
      //Pix.add(new Pixel(P.xpos-10,P.ypos-10,20,20,color(random(255),random(255),random(255))));
      //count=counter;
    }
    //counter++;
  }
  
  /*
  
  if(mouseButton == LEFT &&count!=-1)
  {
    //Pix.add(new Pixel(Pix.get(count).xpos-10,Pix.get(count).ypos-10,20,20,color(random(255),random(255),random(255))));
    //Pix.add(new Pixel(Pix.get(count).xpos+10,Pix.get(count).ypos-10,20,20,color(random(255),random(255),random(255))));
    //Pix.add(new Pixel(Pix.get(count).xpos-10,Pix.get(count).ypos+10,20,20,color(random(255),random(255),random(255))));
    //Pix.add(new Pixel(Pix.get(count).xpos+10,Pix.get(count).ypos+10,20,20,color(random(255),random(255),random(255))));
    //Pix.remove(count);
  }
  
  if(mouseButton == CENTER &&count!=-1)
  {
    Pix.remove(count);
  }
  
  //if(mouseButton == RIGHT)
  //{
  //  Pix.add(new Pixel(mouseX-10,mouseY-10,20,(mouseX+10)/10,color(random(255),random(255),random(255))));
  //}
  
  */
}
void mouseDragged()
{
  counter=0;
  count=-1;
  for(Pixel P : Pix)
  {
    if(P.mouseOverPix())
    {
      //println("baf");
      //P.changeColor(color(random(255),random(255),random(255)));
      //Pix.add(new Pixel(P.xpos-10,P.ypos-10,20,20,color(random(255),random(255),random(255))));
      count=counter;
    }
    counter++;
  }
  if(mouseButton == LEFT &&count!=-1)
  {
    Pixel P=Pix.get(count);
    if(count!=Pix.size())
    {
      Pix.remove(count);
      Pix.add(P);
    }
    P.xpos=mouseX-(P.widt/2);
    P.ypos=mouseY-(P.heig/2);
  }
}

void mousePressed()
{

  for(Pixel P : Pix)
  {
    if(P.mouseOverPix())
    {
      //println("baf");
      //P.changeColor(color(random(255),random(255),random(255)));
      //Pix.add(new Pixel(P.xpos-10,P.ypos-10,20,20,color(random(255),random(255),random(255))));
      if(getpos==true)
      {
        prevxpos=P.xpos;
        prevypos=P.ypos;
        getpos=false;
      }
    }
 
  }
  
}

void mouseReleased()
{
  getpos=true;
  counter=0;
  count=-1;
  for(Pixel P : Pix)
  {
    if(P.mouseOverPix())
    {
      //println("baf");
      //P.changeColor(color(random(255),random(255),random(255)));
      //Pix.add(new Pixel(P.xpos-10,P.ypos-10,20,20,color(random(255),random(255),random(255))));
      count=counter;
    }
    counter++;
  }
  if(count>0)
  {
    Pixel P=Pix.get(count);
    P.xpos=(((mouseX-10)/size)*size)+10;
    P.ypos=(((mouseY-10)/size)*size)+10;
    println(prevxpos,prevypos);
    for(Pixel X : Pix)
    {
      if(X.xpos==P.xpos&&X.ypos==P.ypos&&X!=P)
      {
        X.xpos=prevxpos;
        X.ypos=prevypos;
      }
    }
  }
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
