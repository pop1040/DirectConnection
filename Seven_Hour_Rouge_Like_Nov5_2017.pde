import java.lang.reflect.Field;
import javax.swing.JFrame;

static java.awt.GraphicsDevice device = java.awt.GraphicsEnvironment.getLocalGraphicsEnvironment().getScreenDevices()[0];

boolean fullscreen = false;
int oldWidth=width, oldHeight=height;
JFrame superFrame;

PFont h1Font;
PFont menuFont;

boolean[] keyPresses = new boolean[26];

final color bB = color(80);        //button background
final color bH = color(120);       //button hightlight
final color bC = color(255, 0, 0); //button click color
final color text = color(255);     //text color

MainMenu mainMenu;

void setup(){
  size(640, 480);
  surface.setResizable(true);
  println(surface.getClass());
  
  h1Font = loadFont("FreeSansBold-48.vlw");
  menuFont = loadFont("LiberationSans-24.vlw");
  
  for(Field i : surface.getClass().getDeclaredFields())if(i.getName().equals("frame")){
    i.setAccessible(true);
    try{
      Object f = i.get(surface);
      if(f instanceof JFrame)superFrame = (JFrame)f;
    }catch(Exception e){
      
    }
  }
  mainMenu = new MainMenu();
  currentGUI = mainMenu;
}

abstract class Particle{
  public float x;
  public float y;
  
  public Particle(float x, float y){
    this.x=x;
    this.y=y;
  }
  
  abstract void render();
  
  public abstract boolean isDone();
}

class StarDust extends Particle{
  
  float rotation;
  float direction;
  
  public StarDust(float x, float y){
    super(x, y);
    rotation = map(30+random(30), 0, 180, 0, PI);
    direction = map(30+random(30), 0, 180, 0, PI);
  }
  
  void render(){
    pushMatrix();
    translate(x, y);
    rotate(rotation);
    fill(255);
    noStroke();
    rect(-4, -4, 8, 8);
    popMatrix();
    x+=sin(direction)*.5f;
    y+=cos(direction)*.5f;
  }
  
  public boolean isDone(){
    return false;
  }
}
/*
void draw(){
  background(255);
  rect(50, 50, width-100, height-100);
  
  int aniFrame = millis()%4000;
  if(aniFrame<1000){
    ellipse(map(aniFrame, 0, 1000, 50, width-100)+25, 50+25, 50, 50);
  }else if(aniFrame<2000){
    ellipse(width-100+25, map(aniFrame, 1000, 2000, 50, height-100)+25, 50, 50);
  }else if(aniFrame<3000){
    ellipse(map(aniFrame, 2000, 3000, width-100, 50)+25, height-100+25, 50, 50);
  }else if(aniFrame<4000){
    ellipse(50+25, map(aniFrame, 3000, 4000, height-100, 50)+25, 50, 50);
  }
}*/

GUI currentGUI;
int oW = width;
int oH = height;
boolean pPressed;

void draw(){
  pushMatrix();
  currentGUI.render(width, height, 0, 0);
  popMatrix();
  if(oW != width || oH != height)currentGUI.onResize();
  oW=width;
  oH=height;
  pPressed = mousePressed;
}

abstract class GUI{
  
  public abstract void render(int w, int h, int oX, int oY);
  
  public void onResize(){
    
  }
  
  public abstract int getWidth(int w, int h);
  public abstract int getHeight(int w, int h);
  
}
public class MainMenu extends GUI{
  ArrayList<Particle> particles = new ArrayList<Particle>();
  
  public GUI currentMenu, oldMenu, mainMenu, settings;
  
  long lastMenuChange=0;
  
  boolean aniLeft=true;
  
  boolean leaveMenu = false;
  long leaveMenuTimer = 0;
  
  public MainMenu(){
    genParticles();
    mainMenu = new GUI(){
      public void render(int x, int y, int oX, int oY){
        
        textFont(h1Font);
        textAlign(LEFT, TOP);
        
        
        fill(40);
        text("Direct", -48, -18);
        
        fill(40);
        text("Connection", 2, 22);
        
        fill(255, 0, 0);
        text("D", -50, -20);
        fill(255);
        text("irect", -50+textWidth("D"), -20);
        
        fill(255, 0, 0);
        text("C", 0, 20);
        fill(255);
        text("onnection", textWidth("C"), 20);
        
        noStroke();
        fill(180);
        rect(0, 100, 200, 300);
        textFont(menuFont);
        if(button(10, 110, 180, 80, "Start", bB, bH, bC, text, oX, oY)){
          //aniLeft=true;
          //switchMenu(settings);
          leaveMenu=true;
          leaveMenuTimer = millis();
        }
        if(button(10, 210, 180, 80, "Settings", bB, bH, bC, text, oX, oY)){
          aniLeft=true;
          switchMenu(settings);
        }
        if(button(10, 310, 180, 80, "Exit", bB, bH, bC, text, oX, oY)){
          exit();
        }
      }
      public int getWidth(int w, int h){return 200;}
      public int getHeight(int w, int h){return 400;}
    };
    settings = new GUI(){
      public void render(int x, int y, int oX, int oY){
        noStroke();
        fill(180);
        rect(0, 200, 200, 200);
        textFont(menuFont);
        if(button(10, 210, 180, 80, "fullscreen", bB, bH, bC, text, oX, oY)){
          toggleFullscreen();
        }
        if(button(10, 310, 180, 80, "Back", bB, bH, bC, text, oX, oY)){
          aniLeft=false;
          switchMenu(mainMenu);
        }
      }
      public int getWidth(int w, int h){return 200;}
      public int getHeight(int w, int h){return 400;}
    };
    currentMenu = mainMenu;
  }
  
  public void switchMenu(GUI menu){
    oldMenu = currentMenu;
    currentMenu = menu;
    lastMenuChange = millis();
  }
  
  public void onResize(){
    genParticles();
  }
  
  private void genParticles(){
    particles.clear();
    int particleCount = (width*height)/10000;
    for(int i=0; i<particleCount; i++){
      particles.add(new StarDust(random(width), random(height)));
    }
  }
  
  public void render(int x, int w, int oX, int oY){
    background(0);
    for(Particle p : particles){
      p.render();
      if(p.x > width+5)p.x=-5;
      if(p.y > height+5)p.y=-5;
    }
    if(leaveMenu){
      long timer = millis()-leaveMenuTimer;
      
      if(timer > 1000)currentGUI = new Game();
      translate(width/2, height/2);
      scale(map(timer, 0, 1000, 1, 2));
      translate(-width/2, -height/2);
    }
    if(millis() - lastMenuChange < 200 && oldMenu != null){
      int aniTimer = (int)(millis() - lastMenuChange);
      pushMatrix();
      translate(width/2+(aniLeft?map(aniTimer, 0, 200, width, 0):map(aniTimer, 0, 200, -width, 0))-currentMenu.getWidth(width, height)/2, height/2-currentMenu.getHeight(width, height)/2);
      currentMenu.render(0, 0, width/2+(int)(aniLeft?map(aniTimer, 0, 200, width, 0):map(aniTimer, 0, 200, -width, 0))-currentMenu.getWidth(width, height)/2, height/2-currentMenu.getHeight(width, height)/2);
      popMatrix();
      pushMatrix();
      translate(width/2+(aniLeft?map(aniTimer, 0, 200, 0, -width):map(aniTimer, 0, 200, 0, width))-oldMenu.getWidth(width, height)/2, height/2-oldMenu.getHeight(width, height)/2);
      oldMenu.render(0, 0, oX+width/2+(int)(aniLeft?map(aniTimer, 0, 200, 0, -width):map(aniTimer, 0, 200, 0, width))-oldMenu.getWidth(width, height)/2, oY+height/2-oldMenu.getHeight(width, height)/2);
      popMatrix();
    }else{
      pushMatrix();
      translate(width/2-currentMenu.getWidth(width, height)/2, height/2-currentMenu.getHeight(width, height)/2);
      currentMenu.render(0, 0, width/2-currentMenu.getWidth(width, height)/2 + oX, height/2-currentMenu.getHeight(width, height)/2 + oY);
      popMatrix();
    }
    if(leaveMenu){
      long timer = millis()-leaveMenuTimer;
      
      fill(0, map(timer, 0, 1000, 0, 255));
      noStroke();
      rect(0, 0, width, height);
    }
  }
  
  
  public int getWidth(int w, int h){
    return w;
  }
  public int getHeight(int w, int h){
    return h;
  }
}



void keyPressed(){
  if(key >= 'a' && key <= 'z')keyPresses[key-'a'] = true;
}

void keyReleased(){
  if(key >= 'a' && key <= 'z')keyPresses[key-'a'] = false;
}



boolean button(int x, int y, int w, int h, String text, color background, color highlight, color clickColor, color textColor, int bOx, int bOy){
  boolean hover = mouseX >= x+bOx && mouseX <= x+w+bOx && mouseY >= y+bOy && mouseY <= y+h+bOy;
  boolean clicked = mousePressed && !pPressed;
  if(hover){
    if(clicked)fill(highlight);
    else fill(clickColor);
  }else{
    fill(background);
  }
  noStroke();
  rect(x, y, w, h);
  fill(textColor);
  textAlign(CENTER, CENTER);
  text(text, x+w/2, y+h/2);
  return clicked && hover;
}






void mousePressed(){
  //toggleFullscreen();
}

void toggleFullscreen(){
  if(!fullscreen){
    oldWidth=width;
    oldHeight=height;
    surface.setSize(displayWidth, displayHeight);
    //surface.setLocation(0, 0);
    superFrame.dispose();
    superFrame.setUndecorated(true);
    //superFrame.setExtendedState(JFrame.MAXIMIZED_BOTH); 
    superFrame.setLocation(0, 0);
    superFrame.setVisible(true);
    device.setFullScreenWindow(superFrame);
    surface.setAlwaysOnTop(true);
  }else{
    //surface.setLocation(10, 10);
    device.setFullScreenWindow(null);
    superFrame.dispose();
    superFrame.setUndecorated(false);
    superFrame.setVisible(true);
    surface.setAlwaysOnTop(false);
    surface.setSize(oldWidth, oldHeight);
  }
  fullscreen=!fullscreen;
}

float getDistance(float x1,float y1,float x2,float y2){
  return sqrt(sq(abs(x1-x2))+sq(abs(y1-y2)));
}
float getAngle(float x1,float y1,float x2,float y2){
  float output;
  if(x2>x1){
    output=map(acos((y2-y1)/getDistance(x1,y1,x2,y2)),0,PI,0,180);
  }else{
    output=(180-map(acos((y2-y1)/getDistance(x1,y1,x2,y2)),0,PI,0,180))+180;
  }
  output=180-output;
  output=mapToDeg(output);
  return output;
}
float mapToDeg(float input){
  while(input<0){
    if(input<0){
      input=input+360;
    }
  }
  while(input>=360){
    if(input>=360){
      input=input-360;
    }
  }
  return input;
}