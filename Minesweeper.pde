import de.bezier.guido.*;
static public int NUM_ROWS = 20;
static public int NUM_COLS = 20;
static public int NUM_BOMBS = 100;
private MSButton[][] buttons; //2d array of minesweeper buttons
private ArrayList <MSButton> bombs; //ArrayList of just the minesweeper buttons that are mined
public boolean isLoss = false; //Track Whether or not the game is over
static public int numFlags = NUM_BOMBS; //Track amount of flags used at any single time
public boolean isFirstClick = true;
public int numClicks = 0;


void setup ()
{
    size(400, 450);
    textAlign(CENTER,CENTER);
    
    // make the manager
    Interactive.make( this );
    
    //your code to initialize buttons goes here
    buttons = new MSButton[NUM_ROWS][NUM_COLS];
    for (int i = 0; i < NUM_ROWS; i++){
      for (int j = 0; j < NUM_COLS; j++){
        buttons[i][j] = new MSButton(i, j);
      }
    }
    
    bombs = new ArrayList<MSButton>();
    for (int n = 0; n < NUM_BOMBS; n++){
      setBombs();
    }
    
    for (int i = 0; i < NUM_ROWS; i++){
      for (int j = 0; j < NUM_COLS; j++){
        if (buttons[i][j].countBombs(i, j) > 0)
          buttons[i][j].setLabel("" + buttons[i][j].countBombs(i, j));
      }
    }
}
public void setBombs()
{
    int ranRow = (int)(Math.random() * NUM_ROWS);
    int ranCol = (int)(Math.random() * NUM_COLS);
    if (!bombs.contains(buttons[ranRow][ranCol])){
      bombs.add(buttons[ranRow][ranCol]);
    }
}

public void draw ()
{
    background( 255 );
    trackFlags();
    drawInfo();
    if(isWon()){
        noLoop();
        displayWinningMessage();
    }
    
    if(isLoss){
      displayLosingMessage();
    }
}
public boolean isWon()
{
    for (int i = 0; i < NUM_ROWS; i++){
      for (int j = 0; j < NUM_COLS; j++){
        if (bombs.contains(buttons[i][j]) == false){
          if (buttons[i][j].isClicked() == false || buttons[i][j].isMarked() == true)
            return false;
        }
        if (bombs.contains(buttons[i][j]) == true)
          if (buttons[i][j].isMarked() == false)
            return false;
      }
    }
    return true;
}
public void displayLosingMessage()
{
  turnOffButtons();
  noLoop();
  background(0);
  textSize(48);
  fill(255, 0, 0);
  text("Game Over Yeah!", 200, 200 - 16);
  textSize(24);
  fill(255);
  text("Bombs Marked: " + numMarkedBombs(), 200, 200 + 32);
}
public void displayWinningMessage()
{
   turnOffButtons();
   noLoop();
   background(255);
   textSize(48);
   fill(0);
   text("Congratulations!", 200, 200 - 16);
   textSize(24);
   text("You Clicked " + numClicks + " Times", 200, 232);
}

public void turnOffButtons(){
  for (int i = 0; i < NUM_ROWS; i++){
    for (int j = 0; j < NUM_COLS; j++){
      buttons[i][j].removeButton();
    }
  }
}

public void drawInfo(){
  textSize(32);
  fill(0);
  text("# of Flags: " + numFlags, 200, 425);
}

public void trackFlags(){
  int numMarked = 0;
  
  if(buttons.length == NUM_ROWS){
    for(int i = 0; i < NUM_ROWS; i++){
      for (int j = 0; j < NUM_COLS; j++){
        if (buttons[i][j].isValid(i, j)){
          if (buttons[i][j].isMarked())
            numMarked++;
        }
      }
    }
  }
  
  numFlags = NUM_BOMBS - numMarked;
}

public int numMarkedBombs(){
  int sum = 0;
  
  for(int i = 0; i < NUM_ROWS; i++){
      for (int j = 0; j < NUM_COLS; j++){
        if (buttons[i][j].isValid(i, j)){
          if (bombs.contains(buttons[i][j]) && buttons[i][j].isMarked())
            sum++;
        }
      }
    }
    return sum;
}

public void mousePressed(){
  numClicks++;
}

public class MSButton
{
    private int r, c;
    private float x,y, width, height;
    private boolean clicked, marked;
    private String label;
    private boolean isShowing;
    
    public MSButton ( int rr, int cc )
    {
        width = 400/NUM_COLS;
        height = 400/NUM_ROWS;
        r = rr;
        c = cc; 
        x = c*width;
        y = r*height;
        label = "";
        marked = clicked = false;
        isShowing = true;
        Interactive.add( this ); // register it with the manager
    }
    
    public void removeButton(){Interactive.setActive(this, false);}
    
    public boolean isMarked()
    {
        return marked;
    }
    public boolean isClicked()
    {
        return clicked;
    }
    // called by manager
    
    public void mousePressed () 
    {
        if (clicked == true && marked == false)
          return;
        if (marked == true && mouseButton == LEFT)
          return;
         
        clicked = true;
        isFirstClick = false;
          
        
        if (mouseButton == RIGHT){
            marked = !marked;
 
            if (marked == false)
              clicked = false;
        }
        
        
        else if (bombs.contains(this)){
          isLoss = true;
        }
        
        else if (countBombs(r, c) > 0)
          label = "" + countBombs(r, c);
          
        else{
          for (int i = r - 1; i <= r + 1; i++){
            for (int j = c - 1; j <= c + 1; j++){
              if (isValid(i, j) && buttons[i][j].clicked == false){
                if (!(i == r && j == c))
                  buttons[i][j].mousePressed();
              }
            }
          }
        }
    }

    public void draw () 
    {    
        if(isShowing == false){
          fill(0, 0, 0, 0);
          noStroke();
        }
        else
          stroke(0);
      
        if (marked)
            fill(0);
        else if( clicked && bombs.contains(this) ) 
            fill(255,0,0);
        else if(clicked)
            fill(255);
        else if(isFirstClick && bombs.contains(this) == false && label.equals(""))
            fill(#009BFF);
        else 
            fill(150);

        rect(x, y, width, height);
        fill(0);
        textSize(16);
        if (clicked)
          text(label,x+width/2,y+height/2);
    }
    public void setLabel(String newLabel)
    {
        label = newLabel;
    }
    public boolean isValid(int r, int c)
    {
        if (r >= 0 && r < NUM_ROWS && c >= 0 && c < NUM_COLS)
          return true;
        return false;
    }
    public int countBombs(int row, int col)
    {
        int numBombs = 0;
        for (int i = row - 1; i <= row + 1; i++){
          for (int j = col - 1; j <= col + 1; j++){
            if (isValid(i, j)){
              if (!(i == row && j == col)){
                if (bombs.contains(buttons[i][j]))
                 numBombs++;
              }
            }
          }
        }
        return numBombs;
    }
}
