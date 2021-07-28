class Button
{
  int xpos,ypos,widt,heig;
  String text;
  color col;
  int index;
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
}
