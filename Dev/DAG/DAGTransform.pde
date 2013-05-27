class DAGTransform
// Element in a DAG hierarchy
{
  private DAGTransform parent;
  private boolean hasParent;
  private ArrayList children;
  
  
  DAGTransform()
  {
    hasParent = false;
    children = new ArrayList();
  }
  
  
  public void setParent(DAGTransform p)
  // Sets up a parent relationship
  {
    if( !p.isChildOf(this) )
    {
      // That is, p isn't already above this node
      // Prevent cycling, this is an acyclic graph
      if(parent != null)
      {
        parent.removeChild(this);
      }
      parent = p;
      hasParent = true;
      
      parent.addChild(this);
      // Update transforms
      /**/
    }
  }
  // setParent
  
  
  public void setParentToWorld()
  // Puts the node into world space
  {
    // Update transforms
    /**/
    
    // Update relationships
    if(parent != null)
    {
      parent.removeChild(this);
    }
    parent = null;
    hasParent = false;
  }
  // setParentToWorld
  
  
  public void addChild(DAGTransform c)
  // Adds a child to the node
  // This shouldn't go recursive more than one loop...
  {
    if( !isChildOf(c) )
    {
      // Prevent cycling
      
      // Add child
      if( !children.contains(c) )
      {
        // That is, it's not already a child
        children.add(c);
      }
      
      // Ascertain parent relationship
      if( c.getParent() != this )
      {
        // That is, parent isn't set correctly
        if( c.getParent() != null )
        {
          c.getParent().removeChild(c);
        }
        c.setParent(this);
      }
    }
  }
  // addChild
  
  
  public void removeChild(DAGTransform c)
  // Removes a child from the node
  {
    children.remove(c);
  }
  // removeChild
  
  
  public DAGTransform getParent()
  // Returns the sole parent of this node
  {
    return( parent );
  }
  // getParent
  
  
  public boolean isChildOf(DAGTransform dag)
  // Returns true if node "dag" is above this node
  // This also counts grandchildren, etc
  {
    if( parent == null )
    {
      // We've reached the top without finding the node in question
      return( false );
    }
    
    else if( parent == dag )
    {
      // We've found the node we're looking for
      return( true );
    }
    
    else
    {
      // Check the parent
      // Recursion!
      return( parent.isChildOf(dag) );
    }
  }
  // isChildOf
}
// DAGTransform
