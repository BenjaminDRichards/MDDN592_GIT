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
  size(1024, 768, P2D);
  
  // Test DAG
  dg1 = new DAGTransform(100,100,0,  0,0,0,  1,1,1,  0,0,0);
  dg2 = new DAGTransform(100,120,0,  0,0,0,  1,1,1,  0,0,0);
  dg3 = new DAGTransform(100,140,0,  0,0,0,  1,1,1,  0,0,0);
  
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
  
  PVector pos1 = dg1.getWorldPosition();
  PVector pos2 = dg2.getWorldPosition();
  PVector pos3 = dg3.getWorldPosition();
  PVector rot1 = dg1.getWorldRotation();
  PVector rot2 = dg2.getWorldRotation();
  PVector rot3 = dg3.getWorldRotation();
  
  pushMatrix();
  translate(pos1.x, pos1.y);
  rotate(rot1.z);
  fill(255,0,0,64);
  rect(0,0, 8,8);
  popMatrix();
  
  pushMatrix();
  translate(pos2.x, pos2.y);
  rotate(rot2.z);
  fill(0,255,0,64);
  rect(0,0, 8,8);
  popMatrix();
  
  pushMatrix();
  translate(pos3.x, pos3.y);
  rotate(rot3.z);
  fill(0,0,255,64);
  rect(0,0, 8,8);
  popMatrix();
}
