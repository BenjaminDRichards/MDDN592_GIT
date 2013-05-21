/*

Ecology Test 1

In which maps are used to simulate an ecosystem.

Let's do a three-way. There are three types of growth, and three types of nutrient.
Each growth eats one type and deposits another semi-randomly nearby.

To add randomness, each growth has a quirk.
One reproduces quickly, but eats very little.
One reproduces at a greater distance.
One lives a very long time.

We will use buffers as follows:

NutrientMap buffers hold single numeric values rather than tripartate values.
The ecomap uses R for species ID, G for maturity, and B for food reserves.

*/


PGraphics nutrientMapA, nutrientMapB, nutrientMapC;
PGraphics ecoMap;
int targetMap;

PVector RES = new PVector(400, 400);
float maxAge = 128;
float probeDepositRange = 8;
float probeDepositAmount = 8;
float probeReduceRange = 8;
float probeReduceAmount = 1;
float probeSeedRange = 16;
PVector nutrientInitialRange = new PVector(-0, 255);


void setup()
{
  size((int)RES.x, (int)RES.y, JAVA2D);
  
  targetMap = 0;
  
  // Setup ecomap
  ecoMap = createGraphics((int)RES.x, (int)RES.y, JAVA2D);
  // Create seed populations
  ecoMap.beginDraw();
  ecoMap.background(0);
  ecoMap.noStroke();
  ecoMap.noSmooth();
  float initAreaDiv = 10.0;
  // Create rapidoids
  ecoMap.fill(10, 0, 128);
  ecoMap.rect(ecoMap.width * 0.33, ecoMap.height * 0.33,  ecoMap.height / initAreaDiv, ecoMap.height / initAreaDiv);
  // Create telerim
  ecoMap.fill(20, 0, 128);
  ecoMap.rect(ecoMap.width * 0.66, ecoMap.height * 0.5,  ecoMap.height / initAreaDiv, ecoMap.height / initAreaDiv);
  // Create chronota
  ecoMap.fill(30, 0, 128);
  ecoMap.rect(ecoMap.width * 0.33, ecoMap.height * 0.66,  ecoMap.height / initAreaDiv, ecoMap.height / initAreaDiv);
  
  ecoMap.endDraw();
  
  // Setup nutrient maps
  nutrientMapA = createGraphics((int)RES.x, (int)RES.y, JAVA2D);
  nutrientMapA.beginDraw();
  for(int x = 0;  x < nutrientMapA.width;  x++)
  {
    for(int y = 0;  y < nutrientMapA.height;  y++)
    {
      float nutrients = map( noise(x * 0.1, y * 0.1, 0), 0, 1, nutrientInitialRange.x, nutrientInitialRange.y );
      color c = color( nutrients );
      nutrientMapA.set(x, y, c);
    }
  }
  nutrientMapA.endDraw();
  
  nutrientMapB = createGraphics((int)RES.x, (int)RES.y, JAVA2D);
  nutrientMapB.beginDraw();
  for(int x = 0;  x < nutrientMapB.width;  x++)
  {
    for(int y = 0;  y < nutrientMapB.height;  y++)
    {
      float nutrients = map( noise(x * 0.1, y * 0.1, 1024), 0, 1, nutrientInitialRange.x, nutrientInitialRange.y );
      color c = color( nutrients );
      nutrientMapB.set(x, y, c);
    }
  }
  nutrientMapB.endDraw();
  
  nutrientMapC = createGraphics((int)RES.x, (int)RES.y, JAVA2D);
  nutrientMapC.beginDraw();
  for(int x = 0;  x < nutrientMapC.width;  x++)
  {
    for(int y = 0;  y < nutrientMapC.height;  y++)
    {
      float nutrients = map( noise(x * 0.1, y * 0.1, 1025), 0, 1, nutrientInitialRange.x, nutrientInitialRange.y );
      color c = color( nutrients );
      nutrientMapC.set(x, y, c);
    }
  }
  nutrientMapC.endDraw();
}
// setup


void draw()
{
  ecoMap.beginDraw();
  nutrientMapA.beginDraw();
  nutrientMapB.beginDraw();
  nutrientMapC.beginDraw();
  
  
  
  
  
  
  
  // Run ecology
  ecoMap.loadPixels();
  nutrientMapA.loadPixels();
  nutrientMapB.loadPixels();
  nutrientMapC.loadPixels();
  for(int x = 0;  x < ecoMap.width;  x++)
  {
    for(int y = 0;  y < ecoMap.height;  y++)
    {
      // Determine coords
      int i = x + y * ecoMap.width;
      PVector pos = new PVector(x, y);
      
      // Get species
      color c = ecoMap.pixels[i];
      int speciesID = (int)red(c);
      float age = green(c);
      float food = blue(c);
      
      if(speciesID != 0)
      {
        // Age
        age += 1;
        
        // Increase nearby fertility by species
        PVector probeDeposit = PVector.random2D();
        probeDeposit.normalize();
        float probeDepositLength = random(probeDepositRange);
        probeDeposit.set(probeDeposit.x * probeDepositLength,  probeDeposit.y * probeDepositLength);
        probeDeposit.add(pos);
        probeDeposit = wrapVector(probeDeposit, ecoMap.width - 1, ecoMap.height - 1);
        int probeDepositIndex = floor(probeDeposit.x) + floor(probeDeposit.y) * ecoMap.width;
        // Determine map
        PGraphics depositMap = nutrientMapB;
        if(speciesID == 20)  depositMap = nutrientMapC;
        if(speciesID == 30)  depositMap = nutrientMapA;
        // Access color
        color colDep = depositMap.pixels[probeDepositIndex];
        // Increase color
        float newColDepValue = red(colDep) + probeDepositAmount;
        // Reapply color
        depositMap.pixels[probeDepositIndex] = color( constrain(newColDepValue, 0, 255) );
        
        // Deplete local fertility by species
        PVector probeReduce = PVector.random2D();
        probeReduce.normalize();
        float probeReduceLength = random(probeReduceRange);
        probeReduce.set(probeReduce.x * probeReduceLength,  probeReduce.y * probeReduceLength);
        probeReduce.add(pos);
        probeReduce = wrapVector(probeReduce, ecoMap.width - 1, ecoMap.height - 1);
        int probeReduceIndex = floor(probeReduce.x) + floor(probeReduce.y) * ecoMap.width;
        // Determine map
        PGraphics reduceMap = nutrientMapA;
        if(speciesID == 20)  reduceMap = nutrientMapB;
        if(speciesID == 30)  reduceMap = nutrientMapC;
        // Access color
        color colReduce = reduceMap.pixels[probeReduceIndex];
        // Reduce color
        float reduceAmt = probeReduceAmount;
        if(speciesID == 10)  reduceAmt *= 0.5;  // This species eats very little
        float newColReduceValue = red(colReduce) - reduceAmt;
        // Reapply color
        reduceMap.pixels[probeReduceIndex] = color( constrain(newColReduceValue, 0, 255) );
        
        // Emit seeds
        float chanceEmitSeed = random(1);
        float emitThreshold = 0.1;
        if(speciesID == 10)  emitThreshold = 0.15;  // Species 10 emits frequently
        if(chanceEmitSeed < emitThreshold)
        {
          PVector probeSeed = PVector.random2D();
          probeSeed.normalize();
          float probeSeedLength = random(probeSeedRange);
          if(speciesID == 20)  probeSeedLength *= 2;  // This species reproduces far afield
          probeSeed.set(probeSeed.x * probeSeedLength,  probeSeed.y * probeSeedLength);
          probeSeed.add(pos);
          probeSeed = wrapVector(probeSeed, ecoMap.width - 1, ecoMap.height - 1);
          int probeSeedIndex = floor(probeSeed.x) + floor(probeSeed.y) * ecoMap.width;
          // Access color
          color colSeed = ecoMap.pixels[probeSeedIndex];
          // Check for occupation
          if(red(colSeed) == 0)
          {
            // Empty cell
            // Check for nutrients
            // Determine map
            PGraphics seedProbeMap = nutrientMapA;
            if(speciesID == 20)  seedProbeMap = nutrientMapB;
            if(speciesID == 30)  seedProbeMap = nutrientMapC;
            color colSeedNutrientProbe = seedProbeMap.pixels[probeSeedIndex];
            if( 64 <= red(colSeedNutrientProbe) )
            {
              // Generate new plant
              color newPlant = color(speciesID, 0, 128);
              ecoMap.pixels[probeSeedIndex] = newPlant;
            }
          }
        }
        
        // Check for death by total depletion or age
        float ageThreshold = maxAge;
        if(speciesID == 30)  ageThreshold *= 2;  // This species lives a long time
        if( newColReduceValue < 1  ||  ageThreshold < age )
        {
          ecoMap.pixels[i] = color(0,0,0);
        }
        
      }
      
    }
    
  }
  ecoMap.updatePixels();
  nutrientMapA.updatePixels();
  nutrientMapB.updatePixels();
  nutrientMapC.updatePixels();
  nutrientMapA.endDraw();
  nutrientMapB.endDraw();
  nutrientMapC.endDraw();
  
  
  // Visualise ecology
  // Because the ecomap itself is an awful visualiser
  for(int x = 0;  x < ecoMap.width;  x++)
  {
    for(int y = 0;  y < ecoMap.height;  y++)
    {
      color colData = ecoMap.get(x, y);
      // Analyse data, set draw style
      color c = color(0);
      if(red(colData) == 10)
      {
        // Species rapidoid
        c = color(255, 0, 0);
      }
      if(red(colData) == 20)
      {
        // Species telerim
        c = color(0, 255, 0);
      }
      if(red(colData) == 30)
      {
        // Species chronota
        c = color(0, 0, 255);
      }
      // Draw pixel
      set(x, y, c);
    }
  }
  
  
  
  
  // Perform interaction
  PGraphics drawPane = nutrientMapA;
  color brushCol = color(255,0,0);
  if(targetMap == 1)
  {
    drawPane = nutrientMapB;
    brushCol = color(0,255,0);
  }
  if(targetMap == 2)
  {
    drawPane = nutrientMapC;
    brushCol = color(0,0,255);
  }
  
  // Draw cursor
  float CURSOR_R = width / 8.0;
  pushStyle();
  stroke(brushCol);
  fill(brushCol, 64);
  ellipse(mouseX, mouseY, CURSOR_R, CURSOR_R);
  popStyle();
  
  // Draw mouse data
  if(mousePressed)
  {
    if(mouseButton == LEFT)
    {
      drawPane.noStroke();
      drawPane.fill(255);
      drawPane.ellipse(mouseX, mouseY, CURSOR_R, CURSOR_R);
    }
    else if(mouseButton == RIGHT)
    {
      drawPane.noStroke();
      drawPane.fill(0);
      drawPane.ellipse(mouseX, mouseY, CURSOR_R, CURSOR_R);
    }
  }
  
  
  
  
  // Terminate ecoMap access
  ecoMap.endDraw();
  
  // Visualise nutrient maps
  tint(255,0,0, 64);
  image(nutrientMapA, 0,0);
  noTint();
  tint(0,255,0, 64);
  image(nutrientMapB, 0,0);
  noTint();
  tint(0,0,255, 64);
  image(nutrientMapC, 0,0);
  noTint();
}
// draw


void keyPressed()
{
  if(key == '1')
  {
    targetMap = 0;
  }
  if(key == '2')
  {
    targetMap = 1;
  }
  if(key == '3')
  {
    targetMap = 2;
  }
}


PVector wrapVector(PVector pv, float xBound, float yBound)
// Wraps a 2D PVector into the space ( (0,xBound-1), (0,yBound-1) )
{
  float x = pv.x;
  float y = pv.y;
  // Modulo
  x %= xBound;
  y %= yBound;
  // Now that the range is restricted to +- xBound/yBound,
  // check and conform negatives
  if(x < 0)  x += xBound;
  if(y < 0)  y += yBound;
  
  return( new PVector(x, y) );
}
// wrapVector
