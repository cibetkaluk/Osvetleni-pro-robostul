class Button
{
  int xpos,ypos,widt,heig;
  String text;
  Button(int x,int y,int w,int h,String s)
  {
    xpos=x;
    ypos=y;
    widt=w;
    heig=h;
    text=s;
  }
  
  boolean mouseOverButton()
  {
    boolean click=false;
    if(mouseX>xpos&&mouseX<xpos+widt&&mouseY>ypos&&mouseY<ypos+heig)
    {
      click=true;
    }
    return click;
  }
  
  void Show()
  {
    fill(162);
    rect(xpos,ypos,widt,heig);
    fill(255);
    textSize(20);
    text(text,xpos+(widt/2),ypos+15);
  }
}
