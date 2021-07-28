class Pixel
{
  int xpos,ypos,widt,heig;
  int ind;
  int col;
  color[] colors={#222222,#007700,#770000,#777700};
  Pixel(int x,int y,int w,int h,int index)
  {
    xpos=x;
    ypos=y;
    widt=w;
    heig=h;
    ind=index;
  }
  
  boolean mouseOverPix()
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
    
    fill(colors[col]);
    rect(xpos,ypos,widt,heig);
    fill(255);
    textSize(14);
    text("("+ind/8+","+ind%8+")",xpos+(widt/2),ypos+10);
  }
  
  void changeColor()
  {
    if(col<3)
    {
      col++;
    }
    else
    {
      col=0;
    }
    
  }
  void setColor(int c)
  {
     col=c; 
  }
  /*
  void setColor(String S)
  {
    if(S=="RED"||S=="Red"||S=="red")
    {
      col=2;
    }
    else if(S=="GREEN"||S=="Green"||S=="green")
    {
      col=1;
    }
    else if (S=="YELLOW"||S=="Yellow"||S=="yellow")
    {
      col=3;
    }
    else if(S=="OFF"||S=="Off"||S=="off")
    {
      col=0;
    }
  }
  */
   
}
