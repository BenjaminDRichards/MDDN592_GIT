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
  The screen is 1.0 tall, and (width / height) wide.
  While this makes little difference to the DAG, I want it explicit.
*/


DAGTransform dg1, dg2, dg3;


void setup()
{
  size(1024, 768, JAVA2D);
  
  // Test DAG
  dg1 = new DAGTransform(400,100,0,  0,  1,1,1,  0,0,0);
  dg2 = new DAGTransform(400,120,0,  0,  1,1,1,  0,0,0);
  dg3 = new DAGTransform(400,140,0,  0,  1,1,1,  0,0,0);
  
  dg2.addChild(dg3);
  dg2.setParent(dg1);
  dg3.setParentToWorld();
  
  println(dg1.getParent() + " " + dg2.getParent() + " " + dg3.getParent());
}

void draw()
{
  background(255);
  
  // Diagnose dags
  dg1.moveWorld( sin(frameCount * 0.1), 0, 0 );
  dg1.rotate( 0.1 * sin(frameCount * 0.1) );
  dg1.scale( 1 + 0.01 * sin(frameCount * 0.01) );
  dg2.moveLocal( 0, sin(frameCount * 0.1), 0 );
  dg2.rotate( 0.1 * cos(frameCount * 0.1) );
  dg3.rotate( 0.1 * sin(frameCount * 0.1) );
  
  PVector pos1 = dg1.getWorldPosition();
  PVector pos2 = dg2.getWorldPosition();
  PVector pos3 = dg3.getWorldPosition();
  float rot1 = dg1.getWorldRotation();
  float rot2 = dg2.getWorldRotation();
  float rot3 = dg3.getWorldRotation();
  PVector scale1 = dg1.getWorldScale();
  PVector scale2 = dg2.getWorldScale();
  PVector scale3 = dg3.getWorldScale();
  
  pushMatrix();
  translate(pos1.x, pos1.y);
  rotate(rot1);
  fill(255,0,0,64);
  rect(0,0, 8 * scale1.x, 8 * scale1.y);
  popMatrix();
  
  pushMatrix();
  translate(pos2.x, pos2.y);
  rotate(rot2);
  fill(0,255,0,64);
  rect(0,0, 8 * scale2.x, 8 * scale2.y);
  popMatrix();
  
  pushMatrix();
  translate(pos3.x, pos3.y);
  rotate(rot3);
  fill(0,0,255,64);
  rect(0,0, 8 * scale3.x, 8 * scale3.y);
  popMatrix();
}
