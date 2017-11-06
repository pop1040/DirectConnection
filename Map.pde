

class Map extends GUI{
  public void render(int x, int y, int oX, int oY){
    noStroke();
    fill(180);
    rect(0, 0, 600, 400);
    textFont(menuFont);
    //if(button(10, 210, 180, 80, "fullscreen", bB, bH, bC, text, oX, oY)){
    //  toggleFullscreen();
    //}
  }
  public int getWidth(int w, int h){return 600;}
  public int getHeight(int w, int h){return 400;}
}