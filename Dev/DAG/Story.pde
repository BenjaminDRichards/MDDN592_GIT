import java.util.*;

class Story
/*

Control system for the events that occur.

A way to hide all the complex setup from the main program,
then schedule interesting things to happen.

Includes time management.

*/
{
  // Scene
  DAGWorld dagWorld;
  AnimatorManager animatorManager;
  
  // Event manager
  ArrayList storyEvents;
  
  // Time parameters
  int timeMode;      // 0 = realtime, 1 = render every frame
  float lastTickCount, thisTickCount;
  float idealFrameRate;
  float tick;
  float tickTotal;
  boolean pause;
  
  float TIMESKIP = 1;           // Number of frames to advance per iteration
                                //  Don't set to 0!
  float START_OFFSET = 0;       // Fast-forward the beginning
  
  // Asset tracking
  
  // Graphics
  
  
  
  Story()
  {
    storyEvents = new ArrayList();
    
    // Setup scene
    animatorManager = new AnimatorManager();
    dagWorld = new DAGWorld();
    
    // Setup story
    setupStory();
    
    // Setup time
    timeMode = 0;
    idealFrameRate = 60;
    thisTickCount = 0.0;
    lastTickCount = -1.0;
    tick = 1;
    tickTotal = START_OFFSET;
    pause = false;
  }
  
  
  
  void run()
  // Execute decisions and animation
  {
    // Manage time
    if(timeMode == 0)
    {
      // Use realtime tick
      lastTickCount = thisTickCount;
      thisTickCount = millis() * idealFrameRate / 1000.0;
      tick = thisTickCount - lastTickCount;
    }
    else if(timeMode == 1)
    {
      // Use unitary tick
      thisTickCount += TIMESKIP;
      lastTickCount += TIMESKIP;
      tick = TIMESKIP;
    }
    
    // Track time spent running
    tickTotal += tick;
    // Give it some time to settle down
    if(frameCount < 4)  tickTotal = frameCount + START_OFFSET;
    
    // Check story events
    Iterator i = storyEvents.iterator();
    while( i.hasNext() )
    {
      StoryEvent se = (StoryEvent) i.next();
      if( se.isTriggered(tickTotal) )
      {
        // Update time and check if time trigger occurs
        command(se.commandCode);
        i.remove();
      }
    }
    
    // Run animation
    animatorManager.run(tick);
  }
  // run
  
  
  
  void makeEvent(float time, int code)
  // Make and register story event
  {
    StoryEvent se = new StoryEvent(time, code);
    storyEvents.add(se);
  }
  // makeEvent
  
  
  
  void command(int code)
  // Runs a predefined command code
  {
    println("Code " + code + " triggered at " + tickTotal);
    
    
    
    // Program control
    if(code == 999)  cmd_program_end();
  }
  // command
  
  
  
  void cmd_program_end()
  // CODE 999
  // Ends the program at the appointed time
  {
    exit();
  }
  // cmd_program_end
  
  
  
  void setupStory()
  // Script the sequence of events
  {
    DAGTransform dg1 = new DAGTransform(400,100,0,  0,  1,1,1,  0,0,0);
    DAGTransform dg2 = new DAGTransform(400,120,0,  0,  1,1,1,  0,0,0);
    DAGTransform dg3 = new DAGTransform(400,140,0,  0,  1,1,1,  0,0,0);
    
    dg2.addChild(dg3);
    dg2.setParent(dg1);
    dg3.setParentToWorld();
    
    println(dg1.getParent() + " " + dg2.getParent() + " " + dg3.getParent());
    
    dagWorld.addNode(dg1);
    dagWorld.addNode(dg2);
    dagWorld.addNode(dg3);
    
    println( "All dags: " + dagWorld.getAllDags().toArray() );
    println( "Top dags: " + dagWorld.getTopDags().size() );
    
    // Test Animator
    
    AnimatorDAGRecord key1 = new AnimatorDAGRecord(0,0,0, 1, 1,1,1, 0,0,0);
    key1.useR = true;
    AnimatorDAGRecord key2 = new AnimatorDAGRecord(0,0,0, -1, 1,1,1, 0,0,0);
    key2.useR = true;
    Animator anim1 = new Animator(dg1, key1, key2, Animator.ANIM_OSCILLATE, 180);
    
    key1 = new AnimatorDAGRecord(100,100,0, 0, 1,1,1, 0,0,0);
    key1.usePX = true;
    key2 = new AnimatorDAGRecord(600,100,0, 0, 1,1,1, 0,0,0);
    key2.usePX = true;
    Animator anim2 = new Animator(dg3, key1, key2, Animator.ANIM_TWEEN_FLOP, 180);
    
    animatorManager.addAnimator(anim1);
    animatorManager.addAnimator(anim2);
    
    dagWorld.addNode( birthTree(8, 3) );
  }
  // setupStory
  
  
  public DAGTransform birthTree(int segs, float delay)
  // Creates a tree to animate into being
  {
    // Create a root
    DAGTransform root = new DAGTransform(0, 75, 0,  0,  1,1,1,  0,0,0);
    
    // Add initial animation
    AnimatorDAGRecord root_key1 = new AnimatorDAGRecord(0,0,0, 0, 0,0,0, 0,0,0);
    root_key1.useSX = true;  root_key1.useSY = true;  root_key1.useSZ = true;
    AnimatorDAGRecord root_key2 = new AnimatorDAGRecord(0,0,0, 0, 1,1,1, 0,0,0);
    Animator root_anim = new Animator(root, root_key1, root_key2, Animator.ANIM_TWEEN_SMOOTH, 60);
    root_anim.setDelay(delay);
    animatorManager.addAnimator(root_anim);
    
    // Register last joint
    DAGTransform lastJoint = root;
    
    // Add a number of joints
    for(int i = 0;  i < segs;  i++)
    {
      // Create joints
      DAGTransform jointGrower = new DAGTransform(0,0,0, 0, 1,1,1, 0,0,0);
      jointGrower.snapTo(lastJoint);
      jointGrower.setParent(lastJoint);
      DAGTransform jointCycler = new DAGTransform(0,0,0, 0, 1,1,1, 0,0,0);
      jointCycler.snapTo(lastJoint);
      jointCycler.setParent(jointGrower);
      DAGTransform joint = new DAGTransform(0,0,0, 0, 1,1,1, 0,0,0);
      joint.snapTo(lastJoint);
      joint.setParent(jointCycler);
      // Offset joints
      jointGrower.moveLocal(0, -3, 0);
      
      // Add phased behaviour to joints
      float flex = 0.25 * i / (float)segs;
      AnimatorDAGRecord cycle_key1 = new AnimatorDAGRecord(0,0,0, -flex, 1,1,1, 0,0,0);
      cycle_key1.useR = true;
      AnimatorDAGRecord cycle_key2 = new AnimatorDAGRecord(0,0,0, flex, 1,1,1, 0,0,0);
      Animator cycle_anim = new Animator(jointCycler, cycle_key1, cycle_key2, Animator.ANIM_OSCILLATE, 180);
      cycle_anim.setDelay( i / (float)segs );
      animatorManager.addAnimator(cycle_anim);
      
      // Add growth behaviour to joints
      AnimatorDAGRecord grow_key1 = new AnimatorDAGRecord(0,0,0, 0, 0,0,0, 0,0,0);
      grow_key1.useSX = true;  grow_key1.useSY = true;  grow_key1.useSZ = true;
      AnimatorDAGRecord grow_key2 = new AnimatorDAGRecord(0,0,0, 0, 1,1,1, 0,0,0);
      Animator grow_anim = new Animator(jointGrower, grow_key1, grow_key2, Animator.ANIM_TWEEN_SMOOTH, 60);
      float growDelay = delay + i * 0.25;
      grow_anim.setDelay(growDelay);
      animatorManager.addAnimator(grow_anim);
      
      // Possibly put a branch on here
      if( (random(1.0) < 0.3)  &&  (i < segs - 1) )
      {
        // That is, branches away from the top have a 30% chance of happening
        DAGTransform branch = birthTree( floor( segs - random(i + 1) ), growDelay + 0.25);
        branch.snapTo(joint);
        branch.rotate( random(-1,1) );
        joint.addChild(branch);
      }
      
      // Update last joint
      lastJoint = joint;
    }
    
    return root;
  }
  // birthTree
  
  
  void birthTreeAt(float x, float y)
  // Create tree at specified coordinates
  {
    DAGTransform root = birthTree(8, 0);
    dagWorld.addNode(root);
    root.setWorldPosition(x, y, 0);
  }
  // birthTreeAt
}
// Story
