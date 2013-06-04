/*
  DAG tree development
  
  A DAGTransform is a transformation node designed for parent-child relationships.
  Each node has a field for a parent.
  It also has a flag for parentless state, world-child.
  
  DAG stands for Directional Acyclic Graph.
  This means each node can be connected in such a way that it has only one parent.
  
  Transformations can propagate up the graph to derive world space coordinates.
  
  This version will contain a "center" parameter.
  This is a simple corner offset for graphics.
  It doesn't affect the propagation at all.
  
  It would be useful to incorporate a proper scale function.
  Because of forward kinetics, it will of course affect all children.
  We can override this later if it proves troublesome,
  but for now it's all good.
  
  I'd like to work in normalized coordinates.
  While 0-1 is a poor range, 0-100 seems to work pretty well.
  I've defined the origin as the center top of the screen.
  While this makes little difference to the DAG, I want it explicit.
*/


import java.util.*;


Story story;
PGraphics pgNull;


void setup()
{
  size(1024, 768, P2D);
  
  // Setup story
  story = new Story();
  
  // Setup null graphics
  pgNull = createGraphics(64,64,P2D);
  pgNull.beginDraw();
  pgNull.clear();
  pgNull.endDraw();
}
// setup


void draw()
{
  background(255);
  
  // Start percentile coordinates
  pushMatrix();
  scale(height * 0.01, height * 0.01);          // Percentile coordinate system
  translate( 50.0 * width / height, 0 );       // Go to middle of screen
  
  
  // Manage story
  story.run();
  
  
  // Render dags
  noStroke();
  fill(127);
  ArrayList dags = story.dagWorld.getAllDags();
  Iterator i = dags.iterator();
  while( i.hasNext() )
  {
    DAGTransform d = (DAGTransform) i.next();
    pushMatrix();
    translate(d.getWorldPosition().x, d.getWorldPosition().y);
    rotate(d.getWorldRotation());
    scale(d.getWorldScale().x, d.getWorldScale().y);
    //rect(0,0, 2,2);
    rect(-1,-1, 1,1);
    //image(pgNull, 0,0, 2,2);
    popMatrix();
  }
  
  
  // Render terrain
  ArrayList filledLandscape = story.landscape.getFilledNodes();
  fill(0,64);
  i = filledLandscape.iterator();
  while( i.hasNext() )
  {
    DAGTransform d = (DAGTransform) i.next();
    ArrayList corners = story.landscape.getCornersFromNode(d);
    
    // Render fill
    beginShape();
    PVector v0 = ( (DAGTransform)corners.get(0) ).getWorldPosition();
    PVector v1 = ( (DAGTransform)corners.get(1) ).getWorldPosition();
    PVector v2 = ( (DAGTransform)corners.get(2) ).getWorldPosition();
    PVector v3 = ( (DAGTransform)corners.get(3) ).getWorldPosition();
    vertex(v0.x, v0.y);
    vertex(v1.x, v1.y);
    vertex(v2.x, v2.y);
    vertex(v3.x, v3.y);
    vertex(v0.x, v0.y);
    endShape();
  }
  
  
  // End percentile coordinates
  popMatrix();
  
  
  // Diagnostics
  if(frameCount % 60 == 0)  println("FPS " + frameRate);
}
// draw


void mouseReleased()
{
  // Convert mouse coordinates to screen space
  float mx = (mouseX - width * 0.5) * 100.0 / height;
  float my = mouseY * 100.0 / height;
  
  if(mouseButton == RIGHT)
  {
    // Create a tree at clicked locus
    story.birthTreeAt(mx, my);
  }
}
// mouseReleased


void keyPressed()
{
  if(key == '+'  ||  key == '=')
  {
    // Increase story eccentricity slider
    story.slide(1.0/60);
  }
  
  if(key == '-')
  {
    // Increase story eccentricity slider
    story.slide(-1.0/60);
  }
}
// keyPressed
