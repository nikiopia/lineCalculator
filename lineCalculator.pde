// Global Variables
PImage image;

int buttonWidth;
int imageX, imageY, movementSize, MAX_IMAGE_STEP;
float magnificationFactor;

int edgeX[] = new int[100];
int edgeY[] = new int[100];
float slope, intercept, angle, ZERO_TOLERANCE;

// Setups
void setup()
{
  size(1000,1000);
  background(0);
  
  textSize(15);
  textAlign(CENTER);
  stroke(0);
  
  buttonWidth = 40;
  
  imageX = 0;
  imageY = 0;
  magnificationFactor = 1.0;
  movementSize = 10;
  MAX_IMAGE_STEP = 100;
  
  slope = 0;
  intercept = 0;
  angle = 0;
  ZERO_TOLERANCE = 0.0001;
  
  for (int i = 0; i < 100; i++)
  {
    edgeX[i] = -1;
    edgeY[i] = -1;
  }
  
  // IMAGE GOES HERE VVV
  image = loadImage("20250404_113958_sobel.jpg");
  // IMAGE GOES HERE ^^^
}

void calculateLine()
{
  // Compute necessary sums
  int N = 0;
  float A_x = 0;
  float A_x2 = 0;
  float A_xy = 0;
  float A_y = 0;
  //float A_y2 = 0;
  int currX, currY;
  for (int i = 0; i < 100; i++)
  {
    currX = edgeX[i];
    currY = image.height - edgeY[i];
    if (currX < 0)
    {
      continue;
    }
    
    N += 1;
    
    A_x += currX;
    A_x2 += pow(currX, 2);
    A_xy += currX * currY;
    A_y += currY;
    //A_y2 += pow(currY, 2);
  }
  
  // Calculate slope and intercept (If possible)
  if (abs(N * A_x2 - pow(A_x, 2)) < ZERO_TOLERANCE ||
      abs(A_x) < ZERO_TOLERANCE)
  {
    return;
  }
  
  intercept = (A_x2 * A_y - A_x * A_xy) / (N * A_x2 - pow(A_x, 2));
  slope = (A_y - N * intercept) / A_x;
  
  angle = atan(slope) * 180 / PI;
}

void mousePressed()
{
  // Stop button
  if (mouseX > (width - buttonWidth) && mouseY < buttonWidth)
  {
    exit();
  }
  
  if (mouseButton == LEFT)
  {
    // TODO: Abort if click location isn't on image
    
    // Find first empty spot in array
    int writeIndex = -1;
    for (int i = 0; i < 100; i++)
    {
      if (edgeX[i] >= 0)
      {
        continue;
      }
      
      writeIndex = i;
    }
    if (writeIndex < 0)
    {
      return;
    }
    
    // Write to empty spot
    edgeX[writeIndex] = round((mouseX - imageX) / magnificationFactor);
    edgeY[writeIndex] = round((mouseY - imageY) / magnificationFactor);
  }
  else if (mouseButton == RIGHT)
  {
    // Find last filled spot in array
    int writeIndex = -1;
    for (int i = 99; i >= 0; i--)
    {
      if (edgeX[i] < 0)
      {
        continue;
      }
      
      writeIndex = i;
    }
    if (writeIndex < 0)
    {
      return;
    }
    
    // Empty that spot
    edgeX[writeIndex] = -1;
    edgeY[writeIndex] = -1;
  }
}

void keyPressed()
{
  switch(key)
  {
    case 'w':
      imageY += movementSize;
      break;
    case 'a':
      imageX += movementSize;
      break;
    case 's':
      imageY -= movementSize;
      break;
    case 'd':
      imageX -= movementSize;
      break;
    case 'q':
      // TODO: Fix zoom so that it stays centered on current region
      //       when zooming in / out
      imageX *= 2;
      imageY *= 2;
      magnificationFactor *= 2.0;
      break;
    case 'e':
      imageX /= 2;
      imageY /= 2;
      magnificationFactor /= 2.0;
      break;
    case 'c':
      calculateLine();
      break;
  }
}

void draw()
{
  background(0);
  
  // Draw image given parameters
  image(image, imageX, imageY, image.width * magnificationFactor, 
    image.height * magnificationFactor);
  
  // Draw edge locations
  fill(0, 0, 255);
  for (int i = 0; i < 100; i++)
  {
    if (edgeX[i] < 0)
    {
      continue;
    }
    
    circle(edgeX[i] * magnificationFactor + imageX, edgeY[i] * magnificationFactor + imageY, 10);
  }
  
  // Draw GUI
  fill(255, 0, 0);
  rect(width - buttonWidth, 0, buttonWidth, buttonWidth); // Exit Button
  fill(150);
  rect(width / 2 - 100, height - 70, 200, 70); // Slope/Intercept Data
  rect(0, height - 50, 100, 50); // XY data
  fill(0);
  text("Slope: " + str(slope), width / 2, height - 50);
  text("Intercept: " + str(intercept), width / 2, height - 30);
  text("Angle: " + str(angle), width / 2, height - 10);
  text("X: " + str(imageX), 50, height - 30);
  text("Y: " + str(imageY), 50, height - 10);
}
