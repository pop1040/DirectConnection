

class Enemy extends Entity implements Shootable{
  
  ArrayList<Coord> path = new ArrayList<Coord>();
  
  int maxSpeed = 6;
  int pathIndex = 0;
  float acceleration = .2;
  int health=100;
  int maxHealth=100;
  long lastHit=0;
  long fireTimer =0;
  int bulletSpeed = 3;
  int attackDamage=4;
  
  public Enemy(float x, float y, Room room){
    super(x, y);
    for(int i=0, m=6+(int)random(4); i<m; i++)path.add(new Coord(random(room.sizeX), random(room.sizeY)));
  }
  
  
  public void render(Room room){
    pushMatrix();
    translate(x, y);
    
    noStroke();
    fill(255, 100, 100);
    beginShape();
    vertex(-5, -10);
    vertex(5, -10);
    vertex(10, -5);
    vertex(10, 5);
    vertex(5, 10);
    vertex(-5, 10);
    vertex(-10, 5);
    vertex(-10, -5);
    
    endShape(CLOSE);
    
    long hitTimer = millis()-lastHit;
    if(hitTimer < 1000){
      fill(100, 100);
      noStroke();
      rect(-10, -16, 20, 4);
      fill(255, 0, 0, 100);
      rect(-10, -16, map(health, 0, maxHealth, 0, 20), 4);
    }
    
    popMatrix();
    
    x+=velX;
    y+=velY;
    
    Coord dest = path.get(pathIndex);
    if(getDistance(x, y, dest.x, dest.y) < 70){
      pathIndex++;
      if(pathIndex >= path.size())pathIndex=0;
    }else{
      float angle = radians(getAngle(x, y, dest.x, dest.y));
      velX += sin(angle)*acceleration;
      velY +=-cos(angle)*acceleration;
    }
    
    float vel = sqrt(sq(velX)+sq(velY));
    if(vel > maxSpeed)vel = maxSpeed;
    
    
    if(vel > .1){
      float velAngle = radians(getAngle(0, 0, velX, velY));
      velX = sin(velAngle)*vel;
      velY =-cos(velAngle)*vel;
    }else{
      velX=0;
      velY=0;
    }
    if(x > room.sizeX){x=room.sizeX;velX=0;}
    if(y > room.sizeY){y=room.sizeY;velY=0;}
    if(x < 0){x = 0;velX=0;}
    if(y < 0){y = 0;velY=0;}
    
    long fireDelay = millis()-fireTimer;
    if(fireDelay > 1000){
      fireTimer = millis();
      room.entities.add(new Bullet(x, y, sin(0)      *bulletSpeed, -cos(0)      *bulletSpeed, false, attackDamage, 3));
      room.entities.add(new Bullet(x, y, sin(HALF_PI)*bulletSpeed, -cos(HALF_PI)*bulletSpeed, false, attackDamage, 3));
      room.entities.add(new Bullet(x, y, sin(PI)     *bulletSpeed, -cos(PI)     *bulletSpeed, false, attackDamage, 3));
      room.entities.add(new Bullet(x, y, sin(HALF_PI+PI)*bulletSpeed, -cos(HALF_PI+PI)*bulletSpeed, false, attackDamage, 3));
    }
  }
  
  public boolean isDone(){
    return health<=0;
  }
  
  public boolean isShootable(boolean isPlayerBullet){
    return isPlayerBullet;
  }
  void onShoot(Bullet b){
    health-=b.damage;
    lastHit = millis();
  }
  public void onRemove(Room room){
    
  }
  boolean collides(float x, float y, float r){
    return getDistance(x, y, this.x, this.y) < 10+r;
  }
}