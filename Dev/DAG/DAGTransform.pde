import java.util.*;

class DAGTransform
// Element in a DAG hierarchy
{
  // Hierarchy data
  private DAGTransform parent;
  private boolean hasParent;
  private ArrayList children;
  
  // Local transform data
  // This is relative to parent
  private PVector localPos;
  private PVector localRot;
  private PVector localScale;
  
  // World transform data
  // This is relative to origin
  private PVector worldPos;
  private PVector worldRot;
  private PVector worldScale;
  
  // Center data
  private PVector center;
  
  
  DAGTransform(float wpX, float wpY, float wpZ,
               float wrX, float wrY, float wrZ,
               float wsX, float wsY, float wsZ,
               float cX, float cY, float cZ)
  {
    // Setup hierarchy
    parent = null;
    hasParent = false;
    children = new ArrayList();
    
    // Set world transform
    worldPos = new PVector(wpX, wpY, wpZ);
    worldRot = new PVector(wrX, wrY, wrZ);
    worldScale = new PVector(wsX, wsY, wsZ);
    center = new PVector(cX, cY, cZ);
    
    // Set initial local transform
    updateLocal();
  }
  
  
  public void moveWorld(float x, float y, float z)
  // Move the node in world space
  {
    worldPos.add( new PVector(x, y, z) );
    // Change own local position
    updateLocal();
  }
  // moveWorld
  public void moveWorld(float x, float y)
  // Helper
  {
    moveWorld(x, y, 0);
  }
  // moveWorld
  
  
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
  
  
  public void updateLocal()
  // Updates local transforms based on current world transform and hierarchy
  {
    // Get world transforms of parent
    PVector pwPos = new PVector(0,0,0);
    PVector pwRot = new PVector(0,0,0);
    PVector pwScale = new PVector(1,1,1);
    if( parent != null )
    {
      pwPos = parent.getWorldPosition();
      pwRot = parent.getWorldRotation();
      pwScale = parent.getWorldScale();
    }
    
    // Subtract parent world from this world
    PVector tempPos = PVector.sub(worldPos, pwPos);
    float tempPosX = tempPos.x;
    float tempPosY = tempPos.y;
    float tempPosZ = tempPos.z;
    
    // Unrotate (using reverse YXZ)
    // Unrotate Z
    float thetaZ = atan2(tempPosY, tempPosX);
    float lenZ = sqrt(tempPosX * tempPosX + tempPosY * tempPosY);
    thetaZ -= pwRot.z;
    tempPosX = lenZ * cos(thetaZ);
    tempPosY = lenZ * sin(thetaZ);
    // Unrotate X
    float thetaX = atan2(tempPosZ, tempPosY);
    float lenX = sqrt(tempPosY * tempPosY + tempPosZ * tempPosZ);
    thetaX -= pwRot.x;
    tempPosY = lenX * cos(thetaX);
    tempPosZ = lenX * sin(thetaX);
    // Unrotate Y
    float thetaY = atan2(tempPosZ, tempPosX);
    float lenY = sqrt(tempPosX * tempPosX + tempPosZ * tempPosZ);
    thetaY -= pwRot.y;
    tempPosX = lenY * cos(thetaY);
    tempPosZ = lenY * sin(thetaY);
    // Compile
    tempPos.set(tempPosX, tempPosY, tempPosZ);
    
    // Unscale
    tempPos.set( tempPos.x / pwScale.x,  tempPos.y / pwScale.y,  tempPos.z / pwScale.z);
    
    // Set local transforms
    // Set position
    localPos = tempPos;
    // Set rotations
    //localRot = new PVector( atan2(localPos.y, localPos.z),  atan2(localPos.z, localPos.x),  atan2(localPos.x, localPos.y) );
    localRot = PVector.sub(worldRot, pwRot);
    // Set scale
    localScale = new PVector( worldScale.x / pwScale.x,  worldScale.y / pwScale.y,  worldScale.z / pwScale.z );
    
    
    // Update children world transforms
    // Local transforms are always preserved
    Iterator i = children.iterator();
    while( i.hasNext() )
    {
      DAGTransform c = (DAGTransform) i.next();
      c.updateWorld();
    }
  }
  // updateLocal()
  
  
  public void updateWorld()
  // Update world transform from local transform
  {
    // Get world transforms of parent
    PVector pwPos = new PVector(0,0,0);
    PVector pwRot = new PVector(0,0,0);
    PVector pwScale = new PVector(1,1,1);
    if( parent != null )
    {
      pwPos = parent.getWorldPosition();
      pwRot = parent.getWorldRotation();
      pwScale = parent.getWorldScale();
    }
    
    // Add some angles
    // Remember, use YXZ rotation
    worldRot = PVector.add(pwRot, localRot);
    
    // Update position
    // This uses only the angles of the parent
    float dist = localPos.mag();
    // Unrotate (using reverse YXZ)
    float tempPosX = localPos.x;
    float tempPosY = localPos.y;
    float tempPosZ = localPos.z;
    // Unrotate Z
    float thetaZ = atan2(tempPosY, tempPosX);
    // Unrotate X
    float thetaX = atan2(tempPosZ, tempPosY);
    // Unrotate Y
    float thetaY = atan2(tempPosZ, tempPosX);
    // Get new total rotation
    PVector newRot = new PVector(thetaX, thetaY, thetaZ);
    newRot.add(pwRot);
    // Get new world offset from parent
    // In Y...
    
    // ... in X...
    // ... and in Z.
  }
  // updateWorld
  
  
  public PVector getWorldPosition()  {  return( worldPos );  }
  public PVector getWorldRotation()  {  return( worldRot );  }
  public PVector getWorldScale()  {  return( worldScale );  }
  
  public void setWorldPosition(float x, float y, float z)
  {
    worldPos.set(x,y,z);
    updateLocal();
  }
  public void setWorldRotation(float x, float y, float z)
  {
    worldRot.set(x,y,z);
    updateLocal();
  }
  public void setWorldScale(float x, float y, float z)
  {
    worldScale.set(x,y,z);
    updateLocal();
  }
  
  public PVector getLocalPosition()  {  return( localPos );  }
  public PVector getLocalRotation()  {  return( localRot );  }
  public PVector getLocalScale()  {  return( localScale );  }
  
  public void setLocalPosition(float x, float y, float z)
  {
    localPos.set(x,y,z);
    updateWorld();
  }
  public void setLocalRotation(float x, float y, float z)
  {
    localRot.set(x,y,z);
    updateWorld();
  }
  public void setLocalScale(float x, float y, float z)
  {  
    localScale.set(x,y,z);
    updateWorld();
  }
  
  public PVector getCenter()  {  return( center );  }
  public void setCenter(float x, float y, float z)  {  center.set(x,y,z);  }
}
// DAGTransform
