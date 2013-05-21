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

PVector RES = new PVector(200, 200);
float maxAge = 64;
PVector nutrientInitialRange = new PVector(-8, 16);


void setup()
{
  size(200, 200, P2D);
  
  // Setup ecomap
  ecoMap = createGraphics((int)RES.x, (int)RES.y, P2D);
  // Create seed populations
  ecoMap.beginDraw();
  ecoMap.background(0);
  ecoMap.noStroke();
  ecoMap.noSmooth();
  // Create rapidoids
  ecoMap.fill(10, 0, 5);
  ecoMap.rect(ecoMap.width * 0.33, ecoMap.height * 0.33,  ecoMap.height / 5.0, ecoMap.height / 5.0);
  // Create telerim
  ecoMap.fill(20, 0, 5);
  ecoMap.rect(ecoMap.width * 0.66, ecoMap.height * 0.5,  ecoMap.height / 5.0, ecoMap.height / 5.0);
  // Create chronota
  ecoMap.fill(30, 0, 5);
  ecoMap.rect(ecoMap.width * 0.33, ecoMap.height * 0.66,  ecoMap.height / 5.0, ecoMap.height / 5.0);
  
  ecoMap.endDraw();
  println("Generated ecomap");
  
  // Setup nutrient maps
  nutrientMapA = createGraphics((int)RES.x, (int)RES.y, P2D);
  nutrientMapA.beginDraw();
  for(int x = 0;  x < nutrientMapA.width;  x++)
  {
    for(int y = 0;  y < nutrientMapA.height;  y++)
    {
      color c = color( map( noise(x * 0.1, y * 0.1, 0), 0, 1, nutrientInitialRange.x, nutrientInitialRange.y ) );
      nutrientMapA.set(x, y, c);
    }
  }
  nutrientMapA.endDraw();
  println("Generated nutrient map A");
  
  nutrientMapB = createGraphics((int)RES.x, (int)RES.y, P2D);
  nutrientMapB.beginDraw();
  for(int x = 0;  x < nutrientMapB.width;  x++)
  {
    for(int y = 0;  y < nutrientMapB.height;  y++)
    {
      color c = color( map( noise(x * 0.1, y * 0.1, 100*PI), 0, 1, nutrientInitialRange.x, nutrientInitialRange.y ) );
      nutrientMapB.set(x, y, c);
    }
  }
  nutrientMapB.endDraw();
  println("Generated nutrient map B");
  
  nutrientMapC = createGraphics((int)RES.x, (int)RES.y, P2D);
  nutrientMapC.beginDraw();
  for(int x = 0;  x < nutrientMapC.width;  x++)
  {
    for(int y = 0;  y < nutrientMapC.height;  y++)
    {
      color c = color( map( noise(x * 0.1, y * 0.1, 201*PI), 0, 1, nutrientInitialRange.x, nutrientInitialRange.y ) );
      nutrientMapC.set(x, y, c);
    }
  }
  nutrientMapC.endDraw();
  println("Generated nutrient map C");
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
      
      // Get species
      color c = ecoMap.pixels[i];
      int speciesID = (int)red(c);
      float age = green(c);
      float food = blue(c);
      
      if(speciesID != 0)
      {
      
      // Age
      age += 1;
      
      // Consume food reserves
      food -= 1;
      
      // Probe for food
      PVector probe = PVector.random2D();
      probe.normalize();
      float probeLen = random(4);
      probe.set(probe.x * probeLen, probe.y * probeLen);
      probe.add(new PVector(x, y));
      probe = wrapVector(probe, ecoMap.width, ecoMap.height);
      PGraphics nutrientMap = nutrientMapA;
      // Species check
      if(speciesID == 20)  nutrientMap = nutrientMapB;
      if(speciesID == 30)  nutrientMap = nutrientMapC;
      // Get food
      int nutrientProbeIndex = floor(probe.x) + floor(probe.y) * nutrientMap.width;
      color nutrientProbe = nutrientMap.pixels[nutrientProbeIndex];
      float availableNutrients = red(nutrientProbe);
      if(2 <= availableNutrients)
      {
        // That is, there's enough food
        availableNutrients -= 2;
        availableNutrients = constrain(availableNutrients, 0, 255);
        food += 2;
        // Rewrite diminished foodstuffs
        // Onto different maps
        nutrientMap.pixels[nutrientProbeIndex] = color(availableNutrients);
        
        // Emit nutrients
        PGraphics depositionMap = nutrientMapC;
        if(speciesID == 20)  nutrientMap = nutrientMapA;
        if(speciesID == 30)  nutrientMap = nutrientMapB;
        color oldDeposit = depositionMap.pixels[i];
        color newDeposit = color(red(oldDeposit) + 5);  // Bonus from sunshine!
        depositionMap.pixels[nutrientProbeIndex] = newDeposit;
      }
      
      // Emit seedlings
      float seedFood = 16;
      float seedChance = 0.1;
      if(speciesID == 10)    seedChance = 0.15;  // Rapidoids seed often
      if( random(1) < seedChance  &&  seedFood <= food )
      {
        // Create a seed
        // This costs food
        food -= seedFood;
        // Send a probe
        PVector probeSeed = PVector.random2D();
        probeSeed.normalize();
        float probeSeedLen = random(2,8);
        if(speciesID == 20)    probeSeedLen *= 3;  // Telerim seed at a distance
        probeSeed.set(probe.x * probeSeedLen, probe.y * probeSeedLen);
        probeSeed.add(new PVector(x, y));
        probeSeed = wrapVector(probeSeed, ecoMap.width, ecoMap.height);
        int probeSeedIndex = floor(probe.x) + floor(probe.y) * nutrientMap.width;
        color colProbeSeed = ecoMap.pixels[probeSeedIndex];
        if( red(colProbeSeed) == 0)
        {
          // That is, ID = 0 meaning no growth
          // Therefore there is room to grow
          color colSeed = color(speciesID, 0, seedFood);
          ecoMap.pixels[probeSeedIndex] = colSeed;
        }
      }
      
      // Die if starved or aged
      if( (food < 1)  ||  (maxAge <= age) )
      {
        speciesID = 0;
        food = 0;
        age = 0;
      }
      
      // Rewrite pixel
      color cNew = color(speciesID, food, age);
      ecoMap.pixels[i] = cNew;
      }
      
    }
    
  }
  ecoMap.updatePixels();
  
  
  
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
  
  ecoMap.endDraw();
  nutrientMapA.endDraw();
  nutrientMapB.endDraw();
  nutrientMapC.endDraw();
  
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
  
  // Diagnostic
  //println("Frames: " + frameCount + " at " + frameRate);
  /*
  PGraphics pg = createGraphics(width, height, JAVA2D);
  pg.beginDraw();
  pg.image(nutrientMapA, 0,0);
  pg.filter(THRESHOLD, 0.01);
  pg.endDraw();
  image(pg,0,0);
  */
}
// draw


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
  if(x < 0)  x += xBound - 1;
  if(y < 0)  y += yBound - 1;
  
  return( new PVector(x, y) );
}
// wrapVector
