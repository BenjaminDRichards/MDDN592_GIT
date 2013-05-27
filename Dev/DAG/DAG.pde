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
  dg1 = new DAGTransform();
  dg2 = new DAGTransform();
  dg3 = new DAGTransform();
  
  dg2.addChild(dg3);
  dg2.setParent(dg1);
  dg3.setParentToWorld();
  
  println(dg1.getParent() + " " + dg2.getParent() + " " + dg3.getParent());
}

void draw()
{
  
}
