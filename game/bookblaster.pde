// Asks Processing JS to preload images
/* @pjs preload="title.png, win.png, gameOver.png, left.png, right.png, 
up.png, book.png, player.png, back.png, start.png, help.png,
instructions.png, loseLife.png, nextLevel.png, background.png"; */
// player & invader sprites from www.clker.com

Player player;
Invader [][] invaders;
Bullet bullet;
Icon leftArrow, rightArrow, upArrow, start, help; 
Icon back, loseLife, win, gameOver, nextLevel;
PImage title, instructions, bg;
int invaderRows, invaderCols, invaderTotal;
int deadCount, state, level, maxLevels;
float deadlineY;
boolean left, right, fire;

void setup()
{
  size(480, 320);
  level = 1;
  maxLevels = 10;
  state = 0;
  deadlineY = height-height/5.5;
  player = new Player();
  invaderSetup();
  bullet = new Bullet();
  left = false;
  right = false;
  fire = false;
  paused = false;
  title = loadImage("title.png");
  instructions = loadImage("instructions.png");
  bg = loadImage("background.png");
  setupIcons();
}

void draw()
{
  if (state == 0) // title screen state
  {
    resetGame();
    image(title, 0, 0, width, height);
    start.drawIcon();
    help.drawIcon();
  }
  else if (state == 1) // game state
  {
    background(200);
    image(bg, 0, 20); 
    gameUserInterface();
    updateGame();
    handleInputs();
    deadCount = 0;
  }
  else if (state == 2) // instructions state
  {
    image(instructions, 0, 0, width, height);
    back.drawIcon();
  }
  else if (state == 3) // lose a life state
  {
    if (player.lives == 0)
    {
      state = 4;
    }
    loseLife.drawIcon();
  }
  else if (state == 4) // game over state
  {
    gameOver.drawIcon();
  }
  else if (state == 5) // win state
  {
    win.drawIcon();
  }
  else if (state == 6) // next level state
  {
    if (level == maxLevels)
    {
      state = 5;
    }
    nextLevel.drawIcon();
  }
}

void keyPressed()
{
  if (state == 0) // title screen state
  {
    if (key == ENTER || key == RETURN)
    {
      state = 1;
    }
    if (key == 'h')
    {
      state = 2;
    }
  }
  if (state == 1) // game state
  {
    if (key == CODED)
    {
      if (keyCode == LEFT)
      {
        left = true;
      }
      if (keyCode == RIGHT)
      {
        right = true;
      }
    }
    if (key == ' ')
    {
      fire = true;
    }
  }
  if (state == 2 || state == 4 || state == 5) // instruction, win & game over states
  {
    if (key == ENTER || key == RETURN)
    {
      state = 0;
    }
  }
  if (state == 3) // lose a life state
  {
    if (key == ENTER || key == RETURN)
    {
      invaderSetup();
      player.lives--;
      state = 1;
    }
  }
  if (state == 6) // next level state
  {
    if (key == ENTER || key == RETURN)
    {
      invaderSetup();
      level++;
      state = 1;
    }
  }
}

void keyReleased()
{
  left = false;
  right = false;
  fire = false;
}

// this mousePressed function gets the player to tap icons 
// on the screen for player movement and shooting
void mousePressed()
{
  if (state == 0) // title screen state
  {
    if (start.pressed())
    {
      state = 1;
    }
    if (help.pressed())
    {
      state = 2;
    }
  }
  if (state == 1) // game state
  {
    if (leftArrow.pressed())
    {    
      left = true;
    }
    if (rightArrow.pressed())
    {
      right = true;
    }
    if (upArrow.pressed())
    {
      fire = true;
    }
  }
  if (state == 2) // instructions state
  {
    if (back.pressed())
    {
      state = 0;
    }
  }
  if (state == 3) // lose a life state
  {
    invaderSetup();
    player.lives--;
    state = 1;
  }
  if (state == 4) // game over state
  {
    if (gameOver.pressed())
    {
      state = 0;
    }
  }
  if (state == 5) // win state
  {
    if (win.pressed())
    {
      state = 0;
    }
  }
  if (state == 6) // next level state
  {
    if (nextLevel.pressed())
    {
      invaderSetup();
      level++;
      state = 1;
    }
  }
}

void mouseReleased()
{
  left = false;
  right = false;
  fire = false;
}
class Bullet
{
  float posX;
  float posY;
  float speed = 6;
  boolean active = false;
  boolean hit = false;
  
  void drawBullet()
  {
    fill(0);
    ellipse(posX, posY , 3, 12);
  }
  
  void make(float x, float y)
  {
    posX = x;
    posY = y - player.sprite.height*0.75;
    active = true;
  }
  
  void updateBullet()
  {
    posY -= speed;
    if (posY < 45 || hit)
    {
      active = false;
    }
  }
  
  boolean checkHit(float x, float y, float w, float h)
  {
    if (posX > x && posX < x + w && posY > y && posY < y + h)
    {
      return true;
    }
    else
    {
      return false;
    }
  }
}
class Icon
{
  PImage img;
  float posX;
  float posY;
  float sizeW;
  float sizeH;
  
  Icon(String i, float x, float y, float w, float h)
  {
    img = loadImage(i);
    posX = x;
    posY = y;
    sizeW = w;
    sizeH = h;
  }
  
  void drawIcon()
  {
    image(img, posX, posY, sizeW, sizeH);
  }

  boolean pressed()
  {
    if (mouseX > posX && mouseX < posX + sizeW && mouseY > posY && mouseY < posY + sizeH)
    {
      return true;
    }
    else
    {
      return false;
    }
  }
  
  void flash()
  {
    tint(255, 255);
    drawIcon();
  }
}
class Invader
{
  float sizeW, sizeH, posX, posY, speedX, speedY;
  boolean alive = true;
  boolean direction = true; // true - move left; false - move right
  int value;
  PImage sprite;

  Invader(int x, int y)
  {
    posX = x * 40 + 125;
    posY = y * 35 + 37.5;
    value = 50 - y * 10;
    sprite = loadImage("book.png");
    sizeW = sprite.width;
    sizeH = sprite.height;
    speedX = 1 + level/2;
    speedY = 5 + (level * 2);    
  }

  void drawInvader()
  {
    image(sprite, posX, posY, sizeW, sizeH);
  }

  void updateInvader()
  {
    if (direction)
    {
      posX -= speedX;
    }
    else
    {
      posX += speedX;
    }

    if (bullet.active)
    {
      if (bullet.checkHit(posX, posY, sizeW, sizeH))
      {
        alive = false;
        bullet.active = false;
        player.updateScore(value);
      }
    }
  }

  void dropDown()
  {
    posY += speedY;
  }
}

class Player
{
  float sizeW, sizeH, posX, posY, speed;
  int score, lives;
  PImage sprite, lifeIcon;

  Player()
  {
    posX = width/2;
    posY = height - 25;
    speed = 5;
    score = 0;
    lives = 2;
    sprite = loadImage("player.png");
    sizeW = sprite.width;
    sizeH = sprite.height;
  }

  void drawPlayer()
  {
    imageMode(CENTER);
    image(sprite, posX, posY, sizeW, sizeH);
    imageMode(CORNER);
  }

  void drawLives(float x, float y)
  {
    image(sprite, x, y, sizeW/2, sizeH/2);
  }

  void updateScore(int s)
  {
    score += s;
  }
}

void invaderSetup()
{
  invaderRows = 8;
  invaderCols = 3;
  invaderTotal = invaderRows * invaderCols;
  invaders = new Invader[invaderCols][invaderRows];
  for (int i = 0; i < invaders.length; i++)
  {
    for (int j = 0; j < invaders[i].length; j++)
    {
      invaders[i][j] = new Invader(j, i);
    }
  }
}

void updateGame()
{
  player.drawPlayer();
  for (int i = 0; i < invaders.length; i++)
  {
    for (int j = 0; j < invaders[i].length; j++)
    {
      if (!invaders[i][j].alive)
      {
        deadCount++;
      }
      else
      {
        invaders[i][j].drawInvader();
        invaders[i][j].updateInvader();
        if (invaders[i][j].posX < 0 || invaders[i][j].posX > width - invaders[i][j].sizeW)
        {
          changeDirection();
          if (invaders[i][j].posX < 0)
          {
            invaders[i][j].posX = 0;
          }
          else
          {
            invaders[i][j].posX = width - invaders[i][j].sizeW;
          }
        }
        if (invaders[i][j].posY + (invaders[i][j].sizeH/1.2) > deadlineY)
        {
          state = 3;
        }
      }
    }
  }
  if (bullet.active)
  {
    bullet.drawBullet();
    bullet.updateBullet();
  }
  if (deadCount == invaderTotal)
  {
    state = 6;
  }
}

void changeDirection()
{
  for (int i = 0; i < invaders.length; i++)
  {
    for (int j = 0; j < invaders[i].length; j++)
    {
      invaders[i][j].direction = !invaders[i][j].direction;
      invaders[i][j].dropDown();
    }
  }
}

void resetGame()
{
  invaderSetup();
  level = 1;
  player.score = 0;
  player.lives = 2;
}
void handleInputs()
{
  if (left)
  {
    if (player.posX > player.sizeW)
    {
      leftArrow.flash();
      player.posX -= player.speed;
    }
  }
  if (right)
  {
    if (player.posX < width - player.sizeW)
    {
      rightArrow.flash();
      player.posX += player.speed;
    }
  }
  if (fire)
  {
    if (!bullet.active)
    {
      upArrow.flash();
      bullet.make(player.posX, player.posY);
    }
  }
}

void gameUserInterface()
{
  drawLines();
  noStroke();
  tint(255, 100);
  leftArrow.drawIcon();
  rightArrow.drawIcon();
  upArrow.drawIcon();
  tint(255, 255);
  fill(0, 0, 255);
  textSize(12.5);
  text("SCORE: " + player.score, 5, 15);
  text("LEVEL: " + level, 200, 15);
  text("LIVES: ", width - 100, 15);
  for (int i = 0; i < player.lives; i++)
  {
    player.drawLives(width - 60 + (i * 30), 2.5);
  }
}

void setupIcons()
{
  leftArrow = new Icon("left.png", 5, 267.5, 50, 50);
  rightArrow = new Icon("right.png", 60, 266.75, 50, 50);
  upArrow = new Icon("up.png", 420, 267.5, 50, 50);
  start = new Icon("start.png", 22.5, 175, 195, 130);
  help = new Icon("help.png", 262.5, 175, 195, 130); 
  back = new Icon("back.png", 365, 10, 50, 50);
  loseLife = new Icon("loseLife.png", 0, 80, 480, 160);
  win = new Icon("win.png", 0, 80, 480, 160);
  gameOver = new Icon("gameOver.png", 0, 80, 480, 160);
  nextLevel = new Icon("nextLevel.png", 0, 80, 480, 160);
}

void drawLines()
{
  stroke(255, 0, 0);
  strokeWeight(2);
  int x = -10;
  for (int i = 0; i < 17; i++)
  {
    line(x, deadlineY, x + 20, deadlineY);
    x += 30;
  }
  stroke(0, 0, 255);
  line(0, 20, width, 20);
}

