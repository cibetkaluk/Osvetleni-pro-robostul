class Button
{
  int xpos,ypos,widt,heig;
  String text;
  color col;
  int index;
  int Barva=0;
  Button(int x,int y,int w,int h,String s,color c,int i)
  {
    xpos=x;
    ypos=y;
    widt=w;
    heig=h;
    text=s;
    col=c;
    index=i;
  }
  
  boolean mouseOnButton()
  {
    boolean click=false;
    if(mouseX>xpos&&mouseX<xpos+widt&&mouseY>ypos&&mouseY<ypos+heig)
    {
      click=true;
    }
    return click;
  }
  
  void show()
  {
    fill(col);
    rect(xpos,ypos,widt,heig);
    fill(255);
    textSize(30);
    text(text,xpos+(widt/2),ypos+(heig/3)+5);
  }
  
  void changeCol()
  {
   if(Barva<3)
    {
      Barva++;
    }
    else
    {
      Barva=0;
    } 
    switch(Barva)
    {
      case 0:
        col=#323232;
      break;
      case 1:
        col=#329632;
      break;
      case 2:
        col=#963232;
      break;
      case 3:
        col=#969632;
      break;
    }
  }
  
}
