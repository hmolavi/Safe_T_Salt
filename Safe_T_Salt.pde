
// Variables to change
int n = 60;         
float padding = 10;
int FPS = 30;
int Temprature = -5;
float SaltSpreadingIntensity = 0.06;
float AmountOfPercipitation = 0.5;

// Dont change these
float randNum;
float probDenseIceForming = 1 +  (0.07 * ((-1*float(Temprature)) - 10));
float probWater = (5 + float(Temprature))*(0.04);
String [][] cells = new String[n][n];
String [][] futureCells = new String[n][n];
int [][] ExpireCellsFrame = new int[n][n];
float [][] ChangingProb = new float[n][n];
String [] CellStage = {"Frozen1","Frozen2","Water1","Water2","Concrete"};
int [] ExpireDates =  {450       ,300     ,FPS*4   ,FPS*2       , -1};
int [] concreteI = new int[3];
int [] concreteJ = new int[3];
float cellSize;

void setup(){
  size(900,900);
  cellSize = (width-(2*padding))/n;
  frameRate( FPS );  
  setUpCanvasRandomly();
}

void setUpCanvasRandomly(){
    
  for(int i=0; i<n; i++) {
    for(int j=0; j<n; j++) { 
      
      randNum = random(0,1);
      if (randNum < AmountOfPercipitation){
        
        randNum = random(0,1);
        
        if (Temprature < 1){
          if (randNum > probDenseIceForming && probDenseIceForming>0){
            cells[i][j] = CellStage[0];
            ExpireCellsFrame[i][j] = -1;
            }
          
          else if(randNum < probWater){
            randNum = round(random(0,1));
            
            if (randNum ==0){
              cells[i][j] = CellStage[2];
              ExpireCellsFrame[i][j] = -1;
            }           
            else{
              cells[i][j] = CellStage[3];
              ExpireCellsFrame[i][j] = FPS*8;
            }
          }
            
          else{
            cells[i][j] = CellStage[1];
            ExpireCellsFrame[i][j] = -1;
          }
        }
        
        else{
          if(randNum < 0.6){
            cells[i][j] = CellStage[2];
            ExpireCellsFrame[i][j] = ExpireDates[2];}
          else{
            cells[i][j] = CellStage[3];
            ExpireCellsFrame[i][j] = ExpireDates[3];}
        }
      }
      else{
        cells[i][j] = CellStage[4];
      }
      futureCells[i][j] = cells[i][j];
      ChangingProb[i][j] = 0;
    }
  }
}

void draw() {
  background(0);
  
  float y;
  if(padding <75)
    y = 75;
  else
    y = padding;  
  float x;
  fill(50,197,206);
  textSize((width+height)/75);
  text("Salt Melting Ice in Your Driveway",(width/2 - 160),y/2+10);
  
  for (int i=0; i<n; i++) {
    for (int j=0; j<n; j++) {
      
      x = j*cellSize + padding;
      
      fill(255);
      
      if (cells[i][j]=="Frozen1")
        fill(158,224,223);
      
      else if (cells[i][j]=="Frozen2")
        fill(50,197,206);
            
      else if (cells[i][j]=="Water1")
        fill(0,0,255);
        
      else if (cells[i][j]=="Water2")
        fill(48,86,230);
        
      else if (cells[i][j]=="Salt")
        fill(200,200,0);
      
      else if (cells[i][j]=="Concrete")
        fill(156,156,156);
      
    noStroke();
    rect(x, y, cellSize, cellSize);  
    }  
    y += cellSize;  
  }    
  NextCellGen();
}

void NextCellGen(){
  for(int i=0; i<n; i++) {
    for(int j=0; j<n; j++) {
      
      int index;
      if ( (cells[i][j] == "Salt") && (ExpireCellsFrame[i][j] <= frameCount) ){        
          int cellsLowered = 0;
          
          for(int u=-1;u<=1;u++){
            for(int h=-1;h<=1;h++){
              
            try{
              if (cells[i+u][j+h] == "Frozen1"){
                index = 0;}
              else if (cells[i+u][j+h] == "Frozen2"){
                index = 1;}
              else if (cells[i+u][j+h] == "Water1"){
                index = 2;}
              else if (cells[i+u][j+h] == "Water2"){
                index = 3;}
              else{
                index = 4;}
                
              if (cellsLowered <= 5) {
                try {
                  futureCells[i+u][j+h] = CellStage[index];
                  ExpireCellsFrame[i+u][j+h] = frameCount + (-10);}
                catch(Exception e){}
                cellsLowered++;
              }
            }
            catch (Exception e){}  
          }
        }   
        futureCells[i][j] = "Concrete";
      }
      else{
        futureCells[i][j] = cells[i][j];
      }
            
      if (cells[i][j] == "Frozen1"){
        index = 0;}
      else if (cells[i][j] == "Frozen2"){
        index = 1;}
      else if (cells[i][j] == "Water1"){
        index = 2;}
      else if (cells[i][j] == "Water2"){
        index = 3;}
      else{
        index = 4;}
      
      if( (frameCount > ExpireCellsFrame[i][j]) && (index != 4) ){
        if (ExpireCellsFrame[i][j] != -1){
          ChangingProb[i][j] += 0.007;  
          float prob = random(0,1);
          
          if (prob <= ChangingProb[i][j]){
            futureCells[i][j] =  CellStage[index +1];
            ExpireCellsFrame[i][j] = frameCount + ExpireDates[index+1];
            ChangingProb[i][j] = 0;
          }
        }
      }
    }
  }
  
  for(int i=0; i<n; i++) {
    for(int j=0; j<n; j++) {
      cells[i][j] = futureCells[i][j];
    }
  }   
}

void mouseDragged(){
  int col = round(((mouseX - padding)/ cellSize)-0.5);
  int row = round(((mouseY - padding)/ cellSize)-0.5);
  
  if (( (row >= 0)&&(row < n)) && (( col >= 0)&&(col < n))){
    float prob = random(0,1);
    if (prob < SaltSpreadingIntensity){
      cells[row][col] = "Salt";
      ExpireCellsFrame[row][col] = frameCount + 2*FPS ;
    }
  }
  redraw();
}
