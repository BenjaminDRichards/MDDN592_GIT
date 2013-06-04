import java.util.*;

class DAGWorld
// Contains top-level DAGTransforms
// These can be used to build accurate full-scene population lists on demand
{
  private ArrayList topDags;
  
  
  DAGWorld()
  {
    topDags = new ArrayList();
  }
  
  
  public void addNode(DAGTransform d)
  // Adds a DAG node to the world
  // Doesn't duplicate references
  // Also includes parents to preserve valid trees
  {
    DAGTransform dTop = d.getGrandparent();
    if( !topDags.contains(dTop) )
    {
      topDags.add(dTop);
    }
  }
  // addNode
  
  
  public void addNodeCollection(ArrayList list)
  // Adds all the DAGs in an arraylist
  {
    Iterator i = list.iterator();
    while( i.hasNext() )
    {
      DAGTransform d = (DAGTransform) i.next();
      addNode(d);
    }
  }
  // addNodeCollection
  
  
  public ArrayList getAllDags()
  // Returns all DAGTransform nodes parented to this world or children thereof
  {
    ArrayList allDags = new ArrayList();
    Iterator i = topDags.iterator();
    while( i.hasNext() )
    {
      DAGTransform d = (DAGTransform) i.next();
      allDags.add(d);
      allDags.addAll( d.getAllChildren() );
    }
    return( allDags );
  }
  // getAllDags
  
  
  public ArrayList getTopDags()
  // Returns the top dags
  {
    return( topDags );
  }
  // getTopDags
}
// DAGWorld
