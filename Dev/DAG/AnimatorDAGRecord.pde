class AnimatorDAGRecord extends DAGTransform
// DAG node, not for geometry, but for selective animation parameters
{
  public boolean useWorldSpace, usePX, usePY, usePZ, useR, useSX, useSY, useSZ;
  
  AnimatorDAGRecord(float wpX, float wpY, float wpZ,
                    float wr,
                    float wsX, float wsY, float wsZ,
                    float cX, float cY, float cZ)
  {
    super(wpX, wpY, wpZ, wr, wsX, wsY, wsZ, cX, cY, cZ);
    useWorldSpace = false;
    usePX = false;    usePY = false;    usePZ = false;
    useR = false;
    useSX = false;    useSY = false;    useSZ = false;
  }
  
  public PVector getUsedPosition()
  // Returns the world or local position
  {
    return( useWorldSpace  ?  getWorldPosition()  :  getLocalPosition() );
  }
  // getUsedPosition
  
  public float getUsedRotation()
  // Returns the appropriate rotation
  {
    return( useWorldSpace  ?  getWorldRotation()  :  getLocalRotation() );
  }
  // getUsedRotation
  
  
  public PVector getUsedScale()
  // Returns the appropriate scale
  {
    return( useWorldSpace  ?  getWorldScale()  :  getLocalScale() );
  }
  // getUsedScale
}
// AnimatorDAGRecord
