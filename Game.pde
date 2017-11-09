class Game extends GUI{
  
  long lastShot;
  
  float shipX=100, shipY=100;
  float shipVelX=0, shipVelY=0;
  
  
  
  //<-------------    Stats   --------------------->
  int cooldown = 100;
  float bulletSpeed = 20;
  int attackDamage = 5;
  int maxHealth=20;
  
  //<------------- Live stats --------------------->
  int health = 20;
  int scrap = 0;
  
  
  
  
  
  
  
  boolean pause=false;
  GUI currentMenu = null;
  GUI map = new Map();
  
  Room currentRoom = new Room(1000, 1000, this);
  
  public void render(int x, int w, int oX, int oY){
    background(0);
    pushMatrix();
    
    float zoomFactor = 1;
    float viewWidth = 400*sqrt(((float)width)/height)*zoomFactor;
    float viewHeight = 400/sqrt(((float)width)/height)*zoomFactor;
    //println("screen " + (((float)width)/height));
    //println("viewport " + (((float)viewWidth)/viewHeight));
    //float viewWidth = 400*(160000f/(width*height))*zoomFactor;
    //float viewHeight = 400*(160000f/(width*height))*zoomFactor;
    
    float viewX=constrain(shipX-viewWidth/2, 0, currentRoom.sizeX-viewWidth);
    float viewY=constrain(shipY-viewHeight/2, 0, currentRoom.sizeY-viewHeight);
    //float viewX = 0;
    //float viewY = 0;
    //if(shipX > viewWidth/2)viewX = shipX-viewWidth/2;
    //if(shipY > viewHeight/2)viewY = shipY-viewHeight/2;
    
    scale(width/viewWidth);
    translate(-viewX, -viewY);
    //scale(height/viewHeight);
    //println(viewWidth + ", " + viewHeight);
    
    
    currentRoom.render(map(viewX, 0, currentRoom.sizeX-viewWidth, -1, 1), map(viewY, 0, currentRoom.sizeY-viewHeight, -1, 1));
    renderShip((int)map(mouseX, 0, width, viewX, viewX+viewWidth), (int)map(mouseY, 0, height, viewY, viewY+viewHeight), currentRoom);
    popMatrix();
    
    if(button(0, height-40, 100, 40, "Warp", color(80, 100), color(120, 150), color(255, 0, 0, 200), color(255, 200), 0, 0)){
      
    }
    noStroke();
    fill(80, 100);
    rect(100, height-40, 100, 40);
    fill(255, 0, 0, 200);
    rect(100, height-40, map(health, 0, maxHealth, 0, 100), 40);
  }
  
  void renderShip(int scaledMouseX, int scaledMouseY, Room room){
    pushMatrix();
    translate(shipX, shipY);
    //println(shipX + ", " + shipY + ", " + shipVelX + ", " + shipVelY);
    float shipFacing=getAngle(shipX, shipY, scaledMouseX, scaledMouseY);
    if(Float.isNaN(shipFacing))shipFacing=0;
    //println("facing = " + shipFacing);
    shipFacing = radians(shipFacing);
    
    rotate(shipFacing);
    
    fill(255);
    noStroke();
    beginShape();
    vertex(0, -14);
    vertex(4, -1);
    vertex(4, -4);
    vertex(6, -4);
    vertex(6, 1);
    vertex(8, 3);
    vertex(8, -2);
    vertex(10, -2);
    vertex(10, 8);
    vertex(4, 4);
    vertex(4, 6);
    
    vertex(-4, 6);
    vertex(-4, 4);
    vertex(-10, 8);
    vertex(-10, -2);
    vertex(-8, -2);
    vertex(-8, 3);
    vertex(-6, 1);
    vertex(-6, -4);
    vertex(-4, -4);
    vertex(-4, -1);
    
    endShape(CLOSE);
    /*
    if(keyPresses['w'-'a']){
      shipVelX+=sin(shipFacing)*getAcceleration();
      shipVelY-=cos(shipFacing)*getAcceleration();
    }
    if(keyPresses['s'-'a']){
      shipVelX-=sin(shipFacing)*getAcceleration();
      shipVelY+=cos(shipFacing)*getAcceleration();
    }
    if(keyPresses['a'-'a']){
      shipVelX+=sin(shipFacing-HALF_PI)*getAcceleration();
      shipVelY-=cos(shipFacing-HALF_PI)*getAcceleration();
    }
    if(keyPresses['d'-'a']){
      shipVelX+=sin(shipFacing+HALF_PI)*getAcceleration();
      shipVelY-=cos(shipFacing+HALF_PI)*getAcceleration();
    }*/
    if(keyPresses['w'-'a']){
      shipVelY-=getAcceleration();
    }
    if(keyPresses['s'-'a']){
      shipVelY+=getAcceleration();
    }
    if(keyPresses['a'-'a']){
      shipVelX-=getAcceleration();
    }
    if(keyPresses['d'-'a']){
      shipVelX+=getAcceleration();
    }
    
    
    float shipVel = sqrt(sq(shipVelX)+sq(shipVelY));
    //println("Velocity " + shipVel);
    if(shipVel > getMaxSpeed())shipVel = getMaxSpeed();
    shipVel-=.1;
    //println("Velocity " + shipVel);
    if(shipVel>.1){
      //println("stage 1 " + shipVel);
      float velAngle = radians(getAngle(0, 0, shipVelX, shipVelY));
      shipVelX = sin(velAngle)*shipVel;
      shipVelY = -cos(velAngle)*shipVel;
    }else{
      shipVelX = 0;
      shipVelY = 0;
    }
    
    shipX+=shipVelX;
    shipY+=shipVelY;
    
    if(shipX > currentRoom.sizeX){shipX=currentRoom.sizeX;shipVelX=0;}
    if(shipY > currentRoom.sizeY){shipY=currentRoom.sizeY;shipVelY=0;}
    if(shipX < 0){shipX = 0;shipVelX=0;}
    if(shipY < 0){shipY = 0;shipVelY=0;}
    
    
    
    if(mousePressed && mouseY < height-40 && currentMenu == null){
      long time = millis() - lastShot;
      if(time > cooldown){
        lastShot = millis();
        room.entities.add(new Bullet(shipX, shipY, sin(shipFacing)*bulletSpeed, -cos(shipFacing)*bulletSpeed, true, attackDamage, 2));
      }
    }
    
    
    if(health <=0){
      
      currentGUI = new GUI(){
        
        long startTime = millis();
        
        public void render(int x, int y, int oX, int oY){
          background(0);
          textFont(h1Font);
          textAlign(CENTER, CENTER);
          fill(255, 0, 0);
          text("You Died!", width/2, height/2);
          if(millis()-startTime > 2000){
            currentGUI = mainMenu;
            mainMenu.leaveMenu=false;
          }
        }
        public int getWidth(int w, int h){
          return w;
        }
        public int getHeight(int w, int h){
          return h;
        }
      };
    }
    
    
    popMatrix();
  }
  
  public float getMaxSpeed(){
    return 10;
  }
  public float getAcceleration(){
    return .4;
  }
  
  public int getWidth(int w, int h){
    return w;
  }
  public int getHeight(int w, int h){
    return h;
  }
}

class Room{
  
  ArrayList<Particle> particles = new ArrayList<Particle>();
  
  int sizeX, sizeY;
  
  Coord[] firstLayer = new Coord[400];
  Coord[] secondLayer = new Coord[400];
  Coord[] thirdLayer = new Coord[200];
  
  ArrayList<Entity> entities = new ArrayList<Entity>();
  
  Game game;
  
  public Room(int x, int y, Game game){
    sizeX=x;
    sizeY=y;
    this.game=game;
    for(int i=0; i<firstLayer.length; i++)firstLayer[i] = new Coord((int)random(x), (int)random(y));
    for(int i=0; i<secondLayer.length; i++)secondLayer[i] = new Coord((int)random(x), (int)random(y));
    for(int i=0; i<thirdLayer.length; i++)thirdLayer[i] = new Coord((int)random(x), (int)random(y));
    
    for(int i=0; i<(x*y)/40000; i++)entities.add(new Asteroid(random(x), random(y), 10+(int)random(10)));
    for(int i=0, m=2+(int)random(2); i<m; i++)entities.add(new Enemy(random(x), random(y), this));
  }
  
  public void render(float oX, float oY){
    fill(180);
    noStroke();
    stroke(255);
    pushMatrix();
    translate(oX*50f, oY*50f);
    for(int i=0; i<firstLayer.length; i++)point(firstLayer[i].x, firstLayer[i].y);
    popMatrix();
    pushMatrix();
    translate(oX*100f, oY*100f);
    for(int i=0; i<secondLayer.length; i++)point(secondLayer[i].x, secondLayer[i].y);
    popMatrix();
    pushMatrix();
    translate(oX*150f, oY*150f);
    for(int i=0; i<thirdLayer.length; i++)point(thirdLayer[i].x, thirdLayer[i].y);
    popMatrix();
    
    for(int i=particles.size()-1; i>=0; i--){
      Particle p = particles.get(i);
      p.render();
      if(p.isDone())particles.remove(i);
    }
    
    for(int i=entities.size()-1; i>=0; i--){
      Entity e = entities.get(i);
      e.render(this);
      if(e.isDone()){
        e.onRemove(this);
        entities.remove(i);
      }
    }
    
  }
  
}

class Coord{
  public float x, y;
  
  Coord(float x, float y){
    this.x=x;
    this.y=y;
  }
}

abstract class Entity{
  
  float x, y;
  float velX, velY;
  
  public Entity(float x, float y){
    this.x=x;
    this.y=y;
    velX=0;
    velY=0;
  }
  
  public abstract void render(Room room);
  
  public abstract boolean isDone();
  
  public void onRemove(Room room){
    
  }
  
}

class Asteroid extends Entity implements Shootable{
  
  ArrayList<Coord> points = new ArrayList<Coord>();
  int size;
  int health;
  
  public Asteroid(float x, float y, int size){
    super(x, y);
    this.size=size;
    this.health=size;
    for(int i=0, m=5+(int)random(4); i<m; i++){
      int depth = 8+(int)random(4);
      points.add(new Coord(depth*sin(map(i, 0, m, 0, TWO_PI)), depth*-cos(map(i, 0, m, 0, TWO_PI))));
    }
  }
  
  public void render(Room room){
    pushMatrix();
    translate(x, y);
    scale(size/10f);
    
    noStroke();
    fill(210, 160, 160);
    beginShape();
    for(Coord i : points)vertex(i.x, i.y);
    endShape(CLOSE);
    
    popMatrix();
    x+=velX;
    y+=velY;
    float vel = sqrt(sq(velX)+sq(velY))-.02;
    if(vel > .1){
      float velAngle = radians(getAngle(0, 0, velX, velY));
      velX = sin(velAngle)*vel;
      velY =-cos(velAngle)*vel;
    }else{
      velX=0;
      velY=0;
    }
  }
  
  public boolean isDone(){
    return health<0;
  }
  
  public boolean isShootable(boolean isPlayerBullet){
    return true;
  }
  
  void onShoot(Bullet b){
    health-=b.damage;
  }
  
  Asteroid setVel(float vX, float vY){
    this.velX=vX;
    this.velY=vY;
    return this;
  }
  
  public void onRemove(Room room){
    if(size > 10){
      float angle = random(TWO_PI);
      room.entities.add(new Asteroid(x, y, size/2).setVel(cos(angle)*3f, sin(angle)*3f));
      room.entities.add(new Asteroid(x, y, size/2).setVel(cos(angle + PI)*3f, sin(angle + PI)*3f));
    }
  }
  boolean collides(float x, float y, float r){
    return getDistance(x, y, this.x, this.y) < size+r;
  }
}

public interface Shootable{
  boolean isShootable(boolean isPlayerBullet);
  
  void onShoot(Bullet b);
  
  boolean collides(float x, float y, float r);
}

public class Bullet extends Entity{
  
  boolean isDone = false;
  boolean isPlayerBullet;
  int damage;
  int size;
  
  public Bullet(float x, float y, float velX, float velY, boolean isPlayerBullet, int damage, int size){
    super(x, y);
    this.velX=velX;
    this.velY=velY;
    this.isPlayerBullet=isPlayerBullet;
    this.damage=damage;
    this.size=size;
  }
  
  
  public void render(Room room){
    float oldX = x;
    float oldY = y;
    x+=velX;
    y+=velY;
    if(x > room.sizeX)isDone=true;
    if(y > room.sizeY)isDone=true;
    if(x < 0)isDone=true;
    if(y < 0)isDone=true;
    for(int n=0; n<4; n++){
      for(Entity i : room.entities)if(i instanceof Shootable){
        Shootable s = (Shootable)i;
        if(s.isShootable(isPlayerBullet) && s.collides(map(n, 0, 3, oldX, x), map(n, 0, 3, oldY, y), size)){
          s.onShoot(this);
          isDone=true;
          println("hit!");
          break;
        }
      }
      if(!isPlayerBullet){
        if(getDistance(room.game.shipX, room.game.shipY, map(n, 0, 3, oldX, x), map(n, 0, 3, oldY, y)) < 10+size){
          room.game.health-=damage;
          isDone=true;
          break;
        }
      }
    }
    noStroke();
    fill(255);
    if(!isPlayerBullet)fill(0, 255, 0);
    ellipse(x, y, size*2, size*2);
  }
  
  public boolean isDone(){
    return isDone;
  }
}