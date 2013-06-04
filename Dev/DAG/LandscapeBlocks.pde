class LandscapeBlocks
{
  private ArrayList nodes, nodesFilled;
  private float startX, startY, endX, endY, step;
  private float noiseScale, nstep;
  Story story;
  
  LandscapeBlocks(float startX, float startY, float endX, float endY, float step, Story story)
  {
    nodes = new ArrayList();
    nodesFilled = new ArrayList();
    this.startX = startX;
    this.startY = startY;
    this.endX = endX;
    this.endY = endY;
    this.step = step;
    this.story = story;
    
    noiseScale = 4.0;
    nstep = 0.008 * step;
    
    setupField();
  }
  
  
  public ArrayList getNodes()
  {
    return( nodes);
  }
  // getNodes
  
  
  public ArrayList getFilledNodes()
  {
    return( nodesFilled );
  }
  // getFilledNodes
  
  
  public DAGTransform getNearestNode(float x, float y)
  // Gets a node near the specified coordinates
  {
    PVector cursor = new PVector(x, y, 0);
    // Placeholder nearest node
    DAGTransform nearest = (DAGTransform) nodes.get(0);
    float nearness = PVector.dist(nearest.getWorldPosition(), cursor);
    // Step through nodes
    Iterator i = nodes.iterator();
    while( i.hasNext() )
    {
      DAGTransform d = (DAGTransform) i.next();
      float dDist = PVector.dist(d.getWorldPosition(), cursor);
      if(dDist < nearness)
      {
        nearest = d;
        nearness = dDist;
      }
    }
    // Return nearest match
    return( nearest );
  }
  // getNearestNode
  
  
  public DAGTransform getNearestFilledNode(float x, float y)
  // Mostly a copy of getNearestNode, but on a different array
  {
    PVector cursor = new PVector(x, y, 0);
    // Placeholder nearest node
    DAGTransform nearest = (DAGTransform) nodesFilled.get(0);
    float nearness = PVector.dist(nearest.getWorldPosition(), cursor);
    // Step through nodes
    Iterator i = nodesFilled.iterator();
    while( i.hasNext() )
    {
      DAGTransform d = (DAGTransform) i.next();
      float dDist = PVector.dist(d.getWorldPosition(), cursor);
      if(dDist < nearness)
      {
        nearest = d;
        nearness = dDist;
      }
    }
    // Return nearest match
    return( nearest );
  }
  // getNearestFilledNode
  
  
  public void setNodeFilled(DAGTransform d)
  {
    if( !nodesFilled.contains(d) )
    {
      nodesFilled.add(d);
    }
  }
  // setNodeFilled
  
  
  public void removeNodeFilled(DAGTransform d)
  {
    if( nodesFilled.contains(d) )
    {
      nodesFilled.remove(d);
    }
  }
  // setNodeFilled
  
  
  private void setupField()
  // Creates the field, ordered in X-rows from top left
  {
    for(float y = startY;  y < endY;  y += step)
    {
      for(float x = startX;  x < endX;  x += step)
      {
        // Create positions without and with noise
        PVector pos0 = new PVector(x, y, 0);
        PVector pos1 = getNoiseCounterpart(pos0, step, nstep);
        
        // Create and position node
        // This is an ADAGR because we can't directly slide a DAG
        AnimatorDAGRecord node = new AnimatorDAGRecord(pos0.x, pos0.y, pos0.z,  0,  1,1,1,  0,0,0);
        node.usePX = true;  node.usePY = true;  node.usePZ = true;  node.useR = true;  // This needs to be set
        nodes.add(node);
        
        // Predict orthogonal neighbour positions
        PVector n00 = new PVector(x - step, y - step, 0);
        PVector n01 = new PVector(x - step, y + step, 0);
        PVector n10 = new PVector(x + step, y - step, 0);
        PVector n11 = new PVector(x + step, y + step, 0);
        // Create noise versions
        PVector n00n = getNoiseCounterpart(n00, step, nstep);
        PVector n01n = getNoiseCounterpart(n01, step, nstep);
        PVector n10n = getNoiseCounterpart(n10, step, nstep);
        PVector n11n = getNoiseCounterpart(n11, step, nstep);
        
        // Predict angles to all noisy neighbours
        float angTo00 = bearingFrom(pos0, n00);
        float angTo01 = bearingFrom(pos0, n01);
        float angTo10 = bearingFrom(pos0, n10);
        float angTo11 = bearingFrom(pos0, n11);
        float angTo00n = bearingFrom(pos1, n00n);
        float angTo01n = bearingFrom(pos1, n01n);
        float angTo10n = bearingFrom(pos1, n10n);
        float angTo11n = bearingFrom(pos1, n11n);
        // Set own angle to match neighbour mutation
        float dAng00 = angTo00n - angTo00;
        float dAng01 = angTo01n - angTo01;
        float dAng10 = angTo10n - angTo10;
        float dAng11 = angTo11n - angTo11;
        float dAng = (dAng00 + dAng01 + dAng10 + dAng11) / 4.0;
        
        // Create slider to alter position and rotation
        AnimatorDAGRecord key1 = new AnimatorDAGRecord(pos0.x, pos0.y, pos0.z,  0,  1,1,1,  0,0,0);     // Rest
        key1.usePX = true;  key1.usePY = true;  key1.usePZ = true;  key1.useR = true;
        AnimatorDAGRecord key2 = new AnimatorDAGRecord(pos1.x, pos1.y, pos1.z,  dAng,  1,1,1,  0,0,0);  // Noise
        key2.usePX = true;  key2.usePY = true;  key2.usePZ = true;  key2.useR = true;
        story.makeSlider(node, key1, key2);
      }
    }
  }
  // setupField
  
  
  private PVector getNoiseCounterpart(PVector pv, float step, float nstep)
  // Returns a distorted version of pv using universal parameters
  {
    float dx = step * noiseScale * (noise(pv.x * nstep, pv.y * nstep, 0) - 0.5);
    float dy = step * noiseScale * (noise(0, pv.x * nstep, pv.y * nstep) - 0.5);
    return( new PVector(pv.x + dx,  pv.y + dy,  0) );
  }
  // getNoiseCounterpart
  
  
  private float bearingFrom(PVector a, PVector b)
  // What's the angle from position a to position b?
  {
    PVector diff = PVector.sub(b, a);
    float ang = atan2(diff.y, diff.x);
    return( ang );
  }
  // bearingFrom
  
  
  public ArrayList getCornersFromNode(DAGTransform dag)
  // Gets corners for a square with upper left corner "dag"
  {
    int xLen = floor( (endX - startX) / step );
    int yLen = floor( (endY - startY) / step );
    int dagIndex = nodes.indexOf(dag);
    int dag10 = dagIndex + 1;
    int dag01 = dagIndex + xLen;
    int dag11 = dagIndex + xLen + 1;
    
    // Sanitise
    dag10 = constrain(dag10, 0, nodes.size() - 1);
    dag01 = constrain(dag01, 0, nodes.size() - 1);
    dag11 = constrain(dag11, 0, nodes.size() - 1);
    // On too-distant connections, collapse to a point
    DAGTransform dagRight = (DAGTransform) nodes.get(dag10);
    DAGTransform dagBelow = (DAGTransform) nodes.get(dag01);
    float threshold = step * 4.0;
    PVector dagPos = dag.getWorldPosition();
    if( threshold < dagPos.dist( dagRight.getWorldPosition() )  ||  threshold < dagPos.dist( dagBelow.getWorldPosition() ) )
    {
      dag01 = dagIndex;
      dag10 = dagIndex;
      dag11 = dagIndex;
    }
    
    ArrayList list = new ArrayList();
    list.add( dag );
    list.add( nodes.get(dag10) );
    list.add( nodes.get(dag11) );
    list.add( nodes.get(dag01) );
    
    return( list );
  }
  // getCornersFromNode
  
}
// LandscapeBlocks
