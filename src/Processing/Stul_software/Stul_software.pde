//vytvoření pole pro zobrazené pixely a čudlíky
ArrayList<Pixel> Pix = new ArrayList<Pixel>(); 
ArrayList<Button> Butt = new ArrayList<Button>();
ArrayList<Button> Butt1 = new ArrayList<Button>();
ArrayList<Button> Mbutt = new ArrayList<Button>();
//Definování nového objektu Pixel(class z duhé záložky) a přiřazení názvu "P" k tomuto oběku -> stejné jako "int x;"
//pokud kdekoli v programu uvidíte P.***; tak je to berte jako "referenci" na druhou záožku "pixel"
Pixel P;
Button B;
Button M;

//Vytvoření datové proměné pro ukládání rozpoložení
String [] Data;

//Velikost všech polí na obrazovce
int size=100;

//proměné počtu barevných polí
int G,R,Y,Off;


//Pomocné proměné
int counter=0;
int count=-1;

//Pomocné proměné
int prevxpos=0;
int prevypos=0;
long time=0;
int screen=-1;
int score=50;


int BARVA_Z=0;
int BARVA_SCORE=0;
int BARVA_INIT=0;

//Flag
boolean getpos=true;
boolean mouseReleased=true;
boolean conected=false;
boolean CON=false;
boolean DC=false;
boolean menu=false;

//proěné použité pro sériovou komunikaci
byte send;
int recieved;
long wait=0;


//Proměná k dekodování příchozí komunikace
int hal[]=new int[3];

//Dočasné testovací proměné - v dalších verzích budou odstraněny
int sonda[]={0,3,1};
int barva=0;

//knihovna seriové komunikace pro processing
import processing.serial.*;
Serial port;
int expectedPortID = 0;
String ComPort = "";

//MsgBox pro zprávy o spojení
MsgBox msg = new MsgBox(10,10,width,height/4,#323232);

//=====================================================================
int ScoreF()
{
  int s=0;
  for(Pixel P : Pix)
  {
     if(P.col==BARVA_SCORE)
     {
       s++;
     }
  }
  return s;
}
//=====================================================================

boolean terminating = false;
boolean tryingToConect = false;

void waitForConn()
{
  tryingToConect = true;
  wait=0;
  println("Establishing connection...");
  msg.addS("Establishing connection...");
  println("Waiting for Serial...");
  msg.addS("Waiting for Serial...");
  while(Serial.list().length==0)
  {
     wait++;
     if(terminating)
     {
       println("Thread exit");
       System.exit(0);
     }
     delay(1);
  }
  msg.addS("Found " + Serial.list().length + " serial devices.");
  printArray(Serial.list());
  if(DC)
  {
    msg.addS("Trying to reconect on same port \"" + ComPort + "\"");
    println("Stoping previous serial...");
    port.stop();
    printArray(Serial.list());
    println(expectedPortID);
    println(Serial.list().length);
    wait = 0;
    if(expectedPortID >=Serial.list().length)
    {
      while(expectedPortID >=Serial.list().length){
        if(terminating)
        {
          println("Thread exit");
          System.exit(0);
        }
        if(wait>10000)
        {
          wait = 0;
          msg.addS("Automatic conecting Failed please, check USB connection and click on button to try again.");
          tryingToConect = false;
          expectedPortID = 0;
          conected = false;
          return;
        }
        wait++;
        delay(1);
      }
    }else
    {
      while(!ComPort.equals(Serial.list()[expectedPortID])){
        if(terminating)
        {
          println("Thread exit");
          System.exit(0);
        }
        if(wait>10000)
        {
          wait = 0;
          msg.addS("Automatic conecting Failed please, check USB connection and click on button to try again.");
          tryingToConect = false;
          expectedPortID = 0;
          conected = false;
          return;
        }
        wait++;
        delay(1);
      }
    }
    
    printArray(Serial.list());
    delay(100);
    msg.addS("Opening serial port" + Serial.list()[expectedPortID] + " .");
    port = new Serial(this,Serial.list()[expectedPortID],115200);
    msg.addS("Waiting for arduino restart and handshake...");
    while(port.read()!=255)
    {
      if(terminating)
      {
        println("Thread exit");
        System.exit(0);
      }
      wait++;
      
      delay(1);
    }
    send=send_led(7,7,3);
    port.write(send);
    conected=true;
    CON=true;
    DC=false;
    println("Connection established after "+wait+"ms"); 
    Allpixels(0);
    send=send_led(7,0,0);
    port.write(send);
  }else{
    //Pokud je jeden nebo víc portů otevřených musí se arduino hledat
    msg.addS("Finding correct port (this may take a while)...");
    while(!conected){
      msg.addS("Scaning port "+ Serial.list()[expectedPortID] + " trying next port in 5s.");
      msg.addS("Opening serial port" + Serial.list()[expectedPortID] + " .");
      port = new Serial(this,Serial.list()[expectedPortID],115200);
      msg.addS("Waiting for arduino restart and handshake...");
      boolean notfound = false;
      while(port.read()!=255)
      {
        if(terminating)
        {
          println("Thread exit");
          System.exit(0);
        }
        wait++;
        if(wait>5000)
        {
          notfound = true;
          break;
        }
        delay(1);
      }
      if(notfound)
      {
        wait = 0;
        expectedPortID++;
        msg.addS("Stoping previous serial...");
        port.stop();
        if(expectedPortID >= Serial.list().length)
        {
          msg.addS("Automatic conecting Failed please, check USB connection and click on button to try again.");
          tryingToConect = false;
          expectedPortID = 0;
          conected = false;
          return;
        }
        delay(100);
      }else
      {
        send=send_led(7,7,3);
        port.write(send);
        conected=true;
        CON=true;
        DC=false;
        ComPort = Serial.list()[expectedPortID];
        println("Connection established after "+wait+"ms"); 
        Allpixels(0);
        send=send_led(7,0,0);
        port.write(send);
      }
      
    }
    
  }
  msg.clean();
  tryingToConect = false;
  screen = 1;
}

void ping()
{
    send=send_led(7,7,2);
    port.write(send);
    delay(100);
    if(recieved==254)
    {
      CON=true;
    }
    else
    {
      CON=false;
      DC=true;
    }
    recieved=255;
}

void exit(){
  println("exiting");
  terminating = true;
  super.exit();
}


void setup()
{
  //Vytvoření okna s velikostí 1280*720 px a centrování všech textů na střed
  size(1280,720);
  textAlign(CENTER,CENTER);
  //vytvoření oběktu "port" pro komunikaci s rychlostí 115200 baudů
  //port = new Serial(this,Serial.list()[0],115200);
  
  //Načtení pozic polí
  Data=loadStrings("data/pozice.data");
  
  //navazování spojení seriové komunikace
  
  background(192);
  fill(32);
  textSize(50);
  text("Navazuji spojení s Arduinem...",width/2,height/2);
  thread("waitForConn");
  //send=send_led(7,5,3);
  //port.write(send);
  //println(binary(send));
  
  //vytvoření rozložení stolu pokud se v souboru nenachází údaje o pozicích 
  //nebo tento soubor neexistuje vytvoří normální rozpoložení stolu s indexy po sloupcích
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
  //pokud soubor existuje načte poslední uložené pozice
  {
    for(int i=0;i<Data.length;i++)
    {
      String s = Data[i];
      String [] temp = split(s,';');
      P = new Pixel(int(temp[0]),int(temp[1]),size,size,int(temp[2]));
      Pix.add(P);
    }
  }
  
  B = new Button(950,20,290,50,"OFF",#323232,0);
  Butt.add(B);
  B = new Button(950,90,290,50,"GREEN",#329632,1);
  Butt.add(B);
  B = new Button(950,160,290,50,"RED",#963232,2);
  Butt.add(B);
  B = new Button(950,230,290,50,"YELLOW",#969632,3);
  Butt.add(B);
  B = new Button(950,300,140,50,"RESET",#323232,4);
  Butt.add(B);
  B = new Button(1100,300,140,50,"SAVE",#323232,5);
  Butt.add(B);
  B = new Button(1100,650,140,50,"CON",#323232,6);
  Butt.add(B);
  B = new Button(950,650,140,50,"MENU",#323232,7);
  Butt.add(B);
  B = new Button(950,370,290,50,"SCORE RESET",#323232,8);
  Butt.add(B);
  
  B = new Button(950,650,140,50,"MENU",#323232,0);
  Butt1.add(B);
  B = new Button(1100,650,140,50,"CON",#323232,1);
  Butt1.add(B);
  B = new Button(950,20,290,50,"POČÁTEČNÍ",#323232,2);
  Butt1.add(B);
  B = new Button(950,90,290,50,"ZMĚNIT NA",#323232,3);
  Butt1.add(B);
  B = new Button(950,160,290,50,"SCORE",#323232,4);
  Butt1.add(B);
  B = new Button(1023,230,145,50,"RESET",#323232,5);
  Butt1.add(B);
  
  M = new Button(width/2-70,350,140,50,"EXIT",#323232,0);
  Mbutt.add(M);
  M = new Button(width/2-70,280,140,50,"DEBUG",#323232,1);
  Mbutt.add(M);
  M = new Button(width/2-70,210,140,50,"SCORE",#323232,2);
  Mbutt.add(M);
  
}

//------------------------------------------------------------------------

void Screen(){
  score=ScoreF();
  //vykreslení pozadí
  background(192);
  
  //switch obrazovek
  switch(screen)
  {
    case 0:
      //vykreslování čudlíků 
      for(Button B : Butt)
      {
        B.show();
      }
      
      //text dole počet barevných polí
      textSize(40);
      fill(#329632);
      text("G:"+G,110,650);
      fill(#963232);
      text("R:"+R,310,650);
      fill(#969632);
      text("Y:"+Y,510,650);
      fill(#323232);
      text("Off:"+Off,710,650);
      
      //score text
      //text("score:",1100,400);
      textSize(200);
      text(score,1100,510);
      
      Off=0;
      G=0;
      R=0;
      Y=0;
      
      //vykreslení polí "Pixelů"
      for(Pixel P : Pix)
      {
        //zjišťování počtů barevných polí
        switch(P.col)
        {
          case 0:
            Off++;
          break;
          case 1:
            G++;
          break;
          case 2:
            R++;
          break;
          case 3:
            Y++;
          break;
        }
        P.show();
      }
    break;
    case 1:
      //vykreslování čudlíků 
      for(Button B : Butt1)
      {
        B.show();
      }
      //score text
      //text("score:",1100,400);
      textSize(500);
      fill(#323232);
      text(score,width/2-200,height/2-75);
    break;
  } 
  
  //indikátor připojení
  //println(time);
  if(time>=180)
  {
    
    time=0;
    if(CON)
    {
      thread("ping");
    }
    else
    {
      conected=false;
      DC=true;
      thread("waitForConn");
      //waitForConn();
    }
  }
  if(CON)
  {
    fill(#329632);
  }
  else
  {
    fill(#963232);
  }
  ellipse(1120,675,30,30);
    
  //println((((mouseX-10)/(size+1)*size)+10),(mouseY-10)/size);
  //menu - tmavší pozadí
  if(menu)
  {
    fill(0,192);
    rect(0,0,width,height);
    for(Button M : Mbutt)
    {
      M.show();
    }
  }
  
  //pokud arduino zjistilo změnu na hall sondě ulož ji
  if(port.available()>0)
  {
    //recieved převezme poslaný byte
    recieved=port.read();
    //dekodování bytu
    hal=recieve_hall(recieved);
    //println(hal[0]);
    //println(binary(hal[0]));
    //println(hal[1]);
    //println(binary(hal[1]));
    //println(hal[2]);
    //println(binary(hal[2]));
    if(recieved!=254)
    {
      println("=================");
      println("hall("+hal[0]+","+hal[1]+","+hal[2]+",)");
    }
   
    //println("++++++++");
    
    //Vyhledává změny na sondách x<7 pro sedm desek
    for(int x=0;x<7;x++)
    {
      //y<8 - 8 portů desky 
      for(int y=0;y<8;y++)
      {
        //pokud hallova sona na xté desce a ytém kolečku detekovala magnet
        if(hal[0]==x&&hal[1]==y&&hal[2]==1)
        {
          //println("hall("+hal[0]+","+hal[1]+","+hal[2]+",)");
          //==============================ZDE BUDETE MĚNIT FUNKCE STOLU=========================
          //pro všechny pixely
          for(Pixel P : Pix)
          {
            //zjisti který index odpovídá indexu hallové sondy
            if(P.ind==(x*8+y))
            {
              //změň barvu pixelu (Co se renderuje na počítač)
              P.setColor(BARVA_Z);
              //zakóduj tuto barvu pro poslání
              send=send_led(P.ind/8,P.ind%8,P.col);
              //pošli tuto barvu do arduina
              port.write(send);
            }
          }
        }
      }
    }
  }
}

void wait_screen(){
  background(192);
  fill(32);
  textSize(50);
  text("Navazuji spojení s Arduinem...",width/2,height/2);
  msg.render();
  Butt.get(6).show();
  fill(#963232);
  ellipse(1120,675,30,30);
}

void draw()
{
  time++;
  //print(time);
  if(!conected)
  {
    screen = -1;
    wait_screen();
  }else
  {
    Screen();
  }
  
  
  
  //println(mouseX,mouseY);

}
//DRAW END



//pouze tesování------------------------------------------------
void keyReleased()
{
  //if(key=='f'||key=='F')
  //{
  //  send=send_led(0,6,0);
  //  port.write(send);
  //}
  //if(key=='g'||key=='G')
  //{
  //  send=send_led(0,6,1);
  //  port.write(send);
  //}
  //if(key=='r'||key=='R')
  //{
  //  send=send_led(0,6,2);
  //  port.write(send);
  //}
  //if(key=='b'||key=='B')
  //{
  //  send=send_led(0,6,3);
  //  port.write(send);
  //}
  if(key=='S')
  {
    println("Saved");
    saveStat();
  }
}

//-------------------------------------------------------------
//Funkce pro zapsání dat o pozicích "pixelů" do souboru
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


//zjišťování kliknutí na pixel -- v dalším updatu budou odstraněny zakomentované funkce
void mouseClicked()
{
  //counter=0;
  //count=-1;
  
  if(!menu)
  {
    switch(screen)
    {
      case 0:
        for(Button B : Butt)
        {
          if(B.mouseOnButton())
          {
            switch(B.index)
            {
              case 0:
                println("Off");
                Allpixels(0);
                send=send_led(7,0,0);
                port.write(send);
              break;
              case 1:
                println("Green");
                Allpixels(1);
                send=send_led(7,0,1);
                port.write(send);
              break;
              case 2:
                println("Red");
                Allpixels(2);
                send=send_led(7,0,2);
                port.write(send);
              break;
              case 3:
                println("Yellow");
                Allpixels(3);
                send=send_led(7,0,3);
                port.write(send);
              break;
              case 4:
                println("Reset");
                Reset();
              break;
              case 5:
                println("Saved");
                saveStat();
              break;
              case 6:
                if(conected)
                {
                  DC=true;
                }else
                {
                  DC = false;
                }
                conected=false;
                thread("waitForConn");
              break;
              case 7:
                menu=true;
              break;
              case 8:
                println("Score Reset");
                println(BARVA_INIT);
                Allpixels(BARVA_INIT);
                send=send_led(7,0,BARVA_INIT);
                port.write(send);
              break;
                
            }
          }
        }
      
      
        //pro všechny pole(pixely)
        for(Pixel P : Pix)
        {
          
          if(P.mouseOverPix())
          {
            println("Sending");
            P.changeColor();
            send=send_led(P.ind/8,P.ind%8,P.col);
            port.write(send);
            println("("+P.ind/8+","+P.ind%8+")",P.col);
            println("==========");
            //Pix.add(new Pixel(P.xpos-10,P.ypos-10,20,20,color(random(255),random(255),random(255))));
            //count=counter;
          }
          //counter++;
        }
      break;
      case 1:
        for(Button B : Butt1)
        {
          if(B.mouseOnButton())
          {
            switch(B.index)
            {
              case 0:
                menu=true;
              break;
              case 1:
                if(conected)
                {
                  DC=true;
                }else
                {
                  DC = false;
                }
                conected=false;
                thread("waitForConn");
              break;
              case 2:
                B.changeCol();
                BARVA_INIT=B.Barva;
              break;
              case 3:
                B.changeCol();
                BARVA_Z=B.Barva;
              break;
              case 4:
                B.changeCol();
                BARVA_SCORE=B.Barva;
              break;
              case 5:
                Allpixels(BARVA_INIT);
                send=send_led(7,0,BARVA_INIT);
                port.write(send);
              break;
            }
          }
        }
      break;
      default:
        if(Butt.get(6).mouseOnButton())
        {
          if(tryingToConect)
          {
            print("here");
            msg.addS("Automatic conecting didnot finsh, please wait.");
          }else
          {
            if(conected)
            {
              DC=true;
            }else
            {
              DC = false;
            }
            conected=false;
            thread("waitForConn");
          }
        }
      break;
    }
    
  }
  
  //pokud menu zapni čudlíky na menu
  if(menu)
  {
    for(Button M : Mbutt)
    {
      if(M.mouseOnButton())
      {
        switch(M.index)
        {
          case 0:
            menu=false;
          break;
          case 1:
            menu=false;
            screen=0;
          break;
          case 2:
            menu=false;
            screen=1;
          break;
        }
      }
    }
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
//===============================================================

//funkce pro detekci posuvu "pixelů"
void mouseDragged()
{
  if(mouseReleased)
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
  }
  
  //println("+++++++++");
  //println(count);
  mouseReleased=false;
  
  //pokud byl nalezen pixel na který se kliklo levým tlačítkem
  if(mouseButton == LEFT &&count!=-1)
  {
    //uloží se data toho pixelu
    Pixel P=Pix.get(count);
    //zjistí se jesli je poslední v poli
    if(count!=Pix.size()-1)
    {
      //pokud není tak jej smažeme a přidáme na KONEC pole, aby se renderoval před ostatnímy
      Pix.remove(count);
      Pix.add(P);
    }
    count=Pix.size()-1;
    P.xpos=mouseX-(P.widt/2);
    P.ypos=mouseY-(P.heig/2);
  }
}

//===============================================================================


//získání pozice kliknutí pro funkci prohození "pixelů"
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

//==========================================================

//Funkce pro položení pixelu a "upevnění" na grid
void mouseReleased()
{
  mouseReleased=true;
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
    if(mouseX>10&&mouseX<910&&mouseY>10&&mouseY<610)
    {
      P.xpos=(((mouseX-10)/size)*size)+10;
      P.ypos=(((mouseY-10)/size)*size)+10;
    }
    else
    {
      P.xpos=prevxpos;
      P.ypos=prevypos;
    }
    
    //println(prevxpos,prevypos);
    
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

//=======================================================


//adresování všech pixelů barvu
void Allpixels(int col)
{
  for(Pixel P : Pix)
  {
    P.col=col;
  }
}

void Reset()
{
  send=send_led(7,0,0);
  port.write(send);
  Pix.clear();
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
  //pokud soubor existuje načte poslední uložené pozice
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

//kodování seriové komunikace -> odesílání
byte send_led(int x,int y,int state)
{
  int b=0;
  b=(x<<5)+(y<<2)+state;
  return byte(b);
}

//dekodování sériové komunikace -> příjem 
int[] recieve_hall(int b)
{
  int[] state = new int[3];
  state[0]=(b>>5)&7;
  state[1]=(b>>2)&7;
  state[2]=b&3;
  
  return state;
}
