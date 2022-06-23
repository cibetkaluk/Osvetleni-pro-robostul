class MsgBox
{
  int xpos,ypos,widt,heig;
  StringList text = new StringList();
  int amount=0;
  color col;
  int index;
  int Barva=0;
  MsgBox(int x,int y,int w,int h,color c)
  {
    xpos=x;
    ypos=y;
    widt=w;
    heig=h;
    col=c;
  }
  
  void addS(String s)
  {
    amount++;
    text.append(s);
    if(amount>10)
    {
      text.remove(0);
    }
  }
  
  void render()
  {
    fill(32);
    textSize(15);
    textAlign(LEFT,TOP);
    for(int i = text.size()-1; i>=0; i--)
    {
      text(text.get(i),xpos,ypos + i*20);
    }
    textAlign(CENTER,CENTER);
  }
  
  void clean()
  {
    text.clear();
    amount=0;
  }
  
}
