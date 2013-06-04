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
  LandscapeBlocks landscape;
  DAGWorld dagWorld;
  AnimatorManager animatorManager;
  ArrayList sliders;
  float masterSlider;
  
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
    sliders = new ArrayList();
    masterSlider = 0;
    
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
  
  
  
  public void slide(float amt)
  // Adjust sliders
  {
    // Adjust master slider
    masterSlider = constrain(masterSlider + amt, 0, 1);
    
    // Adjust all registered sliders
    Iterator i = sliders.iterator();
    while( i.hasNext() )
    {
      Animator a = (Animator) i.next();
      a.setSlider(masterSlider);
      a.run(0);
    }
  }
  // slide
  
  
  
  void setupStory()
  // Script the sequence of events
  {
    // Create the landscape
    landscape = new LandscapeBlocks(-100, -20, 100, 120, 5, this);
    dagWorld.addNodeCollection( landscape.getNodes() );
    setupLandscapeA(landscape);
    
    // Test tree code
    DAGTransform anchor = landscape.getNearestNode(0, 75);
    DAGTransform tree = birthTree(8, 3.0);
    tree.snapTo(anchor);
    tree.setParent(anchor);
  }
  // setupStory
  
  
  public DAGTransform birthTree(int segs, float delay)
  // Creates a tree to animate into being
  {
    // Create a root
    DAGTransform root = new DAGTransform(0, 0, 0,  0,  1,1,1,  0,0,0);
    
    // Add initial animation
    AnimatorDAGRecord root_key1 = new AnimatorDAGRecord(0,0,0, 0, 0,0,0, 0,0,0);
    root_key1.useSX = true;  root_key1.useSY = true;  root_key1.useSZ = true;
    AnimatorDAGRecord root_key2 = new AnimatorDAGRecord(0,0,0, 0, 1,1,1, 0,0,0);
    Animator root_anim = new Animator(root, root_key1, root_key2, Animator.ANIM_TWEEN_SMOOTH, 60);
    root_anim.setDelay(delay);
    animatorManager.addAnimator(root_anim);
    
    // Register last joint
    DAGTransform lastJoint = root;
    
    // Setup some constants
    PVector spacing = new PVector(0, -3, 0);
    float taperFactor = random(0.8, 1.0);
    PVector taper = new PVector(taperFactor, taperFactor, taperFactor);
    
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
      
      // Make a scale slider to taper joints
      // I'm just using one key in key1/key2 here to keep it constant
      // I'm also adding the joint offset here, so as to keep scale and offset linked
      AnimatorDAGRecord cycle_scale = new AnimatorDAGRecord(spacing.x, spacing.y, spacing.z, 0, 1,1,1, 0,0,0);
      cycle_scale.usePX = true;  cycle_scale.usePY = true;  cycle_scale.usePZ = true;
      cycle_scale.useSX = true;  cycle_scale.useSY = true;  cycle_scale.useSZ = true;
      Animator cycle_scale_anim = new Animator(jointCycler, cycle_scale, cycle_scale, Animator.ANIM_CONSTANT, 1);
      animatorManager.addAnimator(cycle_scale_anim);
      // Set a slider on the scale animator
      AnimatorDAGRecord cycle_scale_slideKey1 = new AnimatorDAGRecord(
        cycle_scale.getUsedPosition().x, cycle_scale.getUsedPosition().y, cycle_scale.getUsedPosition().y,
        cycle_scale.getUsedRotation(),
        cycle_scale.getUsedScale().x, cycle_scale.getUsedScale().y, cycle_scale.getUsedScale().y,
        0,0,0);
      cycle_scale_slideKey1.usePX = true;  cycle_scale_slideKey1.usePY = true;  cycle_scale_slideKey1.usePZ = true;
      cycle_scale_slideKey1.useSX = true;  cycle_scale_slideKey1.useSY = true;  cycle_scale_slideKey1.useSZ = true;
      AnimatorDAGRecord cycle_scale_slideKey2 = new AnimatorDAGRecord(
        spacing.x * taper.x, spacing.y * taper.y, spacing.z * taper.z,
        cycle_scale.getUsedRotation(),
        taper.x, taper.y, taper.y,
        0,0,0);
      cycle_scale_slideKey2.usePX = true;  cycle_scale_slideKey2.usePY = true;  cycle_scale_slideKey2.usePZ = true;
      cycle_scale_slideKey2.useSX = true;  cycle_scale_slideKey2.useSY = true;  cycle_scale_slideKey2.useSZ = true;
      makeSlider(cycle_scale, cycle_scale_slideKey1, cycle_scale_slideKey2);
      
      // Add phased behaviour to joints
      float flex = 0.25 * i / (float)segs;
      AnimatorDAGRecord cycle_key1 = new AnimatorDAGRecord(0,0,0, -flex, 1,1,1, 0,0,0);
      cycle_key1.useR = true;
      makeZeroSlider(cycle_key1);
      AnimatorDAGRecord cycle_key2 = new AnimatorDAGRecord(0,0,0, flex, 1,1,1, 0,0,0);
      cycle_key2.useR = true;
      makeZeroSlider(cycle_key2);
      Animator cycle_anim = new Animator(jointCycler, cycle_key1, cycle_key2, Animator.ANIM_OSCILLATE, 180);
      cycle_anim.setDelay( i / (float)segs );
      animatorManager.addAnimator(cycle_anim);
      
      // Add growth behaviour to joints
      AnimatorDAGRecord grow_key1 = new AnimatorDAGRecord(0,0,0, PI, 0,0,0, 0,0,0);
      grow_key1.useR = true;  grow_key1.useSX = true;  grow_key1.useSY = true;  grow_key1.useSZ = true;
      AnimatorDAGRecord grow_key2 = new AnimatorDAGRecord(0,0,0, 0, 1,1,1, 0,0,0);
      grow_key2.useR = true;  grow_key2.useSX = true;  grow_key2.useSY = true;  grow_key2.useSZ = true;
      Animator grow_anim = new Animator(jointGrower, grow_key1, grow_key2, Animator.ANIM_TWEEN_FLOP_OUT, 60);
      float growDelay = delay + i * 0.25;
      grow_anim.setDelay(growDelay);
      animatorManager.addAnimator(grow_anim);
      
      // Possibly put a branch on here
      if( (random(1.0) < 0.3)  &&  (i < segs - 1) )
      {
        // That is, branches away from the top have a 30% chance of happening
        DAGTransform branch = birthTree( floor( segs - random(i + 1) ), growDelay + 0.25);
        branch.snapTo(jointCycler);
        // Determine side
        float side = 1;
        if(random(1.0) < 0.5)
        {
          side = -1;
        }
        // Build rotation and slider assets
        AnimatorDAGRecord branch_slideKey1 = new AnimatorDAGRecord(0,0,0, HALF_PI * side, 1,1,1, 0,0,0);
        branch_slideKey1.useR = true;
        float actualAngle = HALF_PI - random(1.0);
        AnimatorDAGRecord branch_slideKey2 = new AnimatorDAGRecord(0,0,0, actualAngle * side, 1,1,1, 0,0,0);
        branch_slideKey2.useR = true;
        // Attach via animation proxy
        AnimatorDAGRecord branchAnimMaster = new AnimatorDAGRecord(0,0,0, 0, 1,1,1, 0,0,0);
        branchAnimMaster.useR = true;
        branchAnimMaster.snapTo(jointCycler);
        branchAnimMaster.setParent(jointCycler);
        branch.setParent(branchAnimMaster);
        makeSlider(branchAnimMaster, branch_slideKey1, branch_slideKey2);
      }
      else
      {
        // Add leaves towards the end
        if( 0.5 < i / (float) segs )
        {
          // Add leaves on both sides
          for(int j = -1;  j < 2;  j += 2)
          {
            DAGTransform leaf = new DAGTransform(0,0,0, 0, 1,1,1, 0,0,0);
            leaf.snapTo(jointCycler);
            leaf.setParent(jointCycler);
            leaf.rotate(HALF_PI * j);
            leaf.moveLocal(spacing.y * j, 0, 0);
          }
        }
      }
      
      // Update last joint
      lastJoint = jointCycler;
    }
    
    return root;
  }
  // birthTree
  
  
  public void birthTreeAt(float x, float y)
  // Create tree at specified coordinates
  {
    DAGTransform anchor = landscape.getNearestFilledNode(x, y);
    DAGTransform tree = birthTree(8, 0.0);
    tree.snapTo(anchor);
    tree.setParent(anchor);
  }
  // birthTreeAt
  
  
  public void setupLandscapeA(LandscapeBlocks lb)
  // Sets some filled-in blocks according to a pattern
  {
    ArrayList list = landscape.getNodes();
    Iterator i = list.iterator();
    while( i.hasNext() )
    {
      DAGTransform dag = (DAGTransform) i.next();
      PVector pos = dag.getWorldPosition();
      float fillThresholdY = 71.0;
      
      // Height mapping
      if(pos.x < -26)
      {
        fillThresholdY = 66;
        if(pos.x < -51)  fillThresholdY = 61;
        if(pos.x < -56)  fillThresholdY = 31;
      }
      if(21 < pos.x)
      {
        fillThresholdY = 51 + 15 * sin(pos.x * 0.1) - 15 * sin(pos.x * 0.3);
      }
      if( fillThresholdY < pos.y  &&  pos.y < 110.0 )
      {
        landscape.setNodeFilled(dag);
      }
    }
    
    // Individual settings
    list = new ArrayList();
    // Nearby knob
    list.add( new PVector(21, 46) );
    list.add( new PVector(21, 51) );
    list.add( new PVector(26, 46) );
    // Rocky spar
    list.add( new PVector(56, 36) );
    list.add( new PVector(56, 41) );
    list.add( new PVector(61, 36) );
    list.add( new PVector(66, 36) );
    list.add( new PVector(66, 41) );
    list.add( new PVector(70, 36) );
    list.add( new PVector(70, 41) );
    // Left knob
    list.add( new PVector(-56, 36) );
    list.add( new PVector(-56, 31) );
    list.add( new PVector(-61, 31) );
    // Implement
    i = list.iterator();
    while( i.hasNext() )
    {
      PVector pv = (PVector) i.next();
      DAGTransform d = landscape.getNearestNode(pv.x, pv.y);
      landscape.setNodeFilled(d);
    }
  }
  // setupLandscapeA
  
  
  public void makeSlider(AnimatorDAGRecord adagr, AnimatorDAGRecord key1, AnimatorDAGRecord key2)
  // Creates a slider for "adagr", between key1 and key2
  {
    // Comply flags from adagr
    key1.useWorldSpace = adagr.useWorldSpace;
    key1.usePX = adagr.usePX;    key1.usePY = adagr.usePY;    key1.usePZ = adagr.usePZ;
    key1.useR = adagr.useR;
    key1.useSX = adagr.useSX;    key1.useSY = adagr.useSY;    key1.useSZ = adagr.useSZ;
    key2.useWorldSpace = adagr.useWorldSpace;
    key2.usePX = adagr.usePX;    key2.usePY = adagr.usePY;    key2.usePZ = adagr.usePZ;
    key2.useR = adagr.useR;
    key2.useSX = adagr.useSX;    key2.useSY = adagr.useSY;    key2.useSZ = adagr.useSZ;
    
    // Create slider
    Animator slider = new Animator(adagr, key1, key2, Animator.ANIM_TWEEN_SMOOTH, 1);
    slider.useSlider(true);
    slider.setSlider(masterSlider);
    slider.run(0);
    // Register slider
    sliders.add(slider);
  }
  // makeSlider
  
  
  public void makeZeroSlider(AnimatorDAGRecord adagr)
  // Creates keys and registers sliders to turn "adagr" on or off smoothly
  // "Off" here refers to origin values (0,0,0, 0, 1,1,1)
  {
    // Create zero key
    AnimatorDAGRecord key1 = new AnimatorDAGRecord(0,0,0, 0, 1,1,1, 0,0,0);
    // Create max key
    PVector pos = adagr.getUsedPosition();
    float r = adagr.getUsedRotation();
    PVector scale = adagr.getUsedScale();
    AnimatorDAGRecord key2 = new AnimatorDAGRecord(pos.x, pos.y, pos.z,  r,  scale.x, scale.y, scale.z,  0,0,0);
    // Make slider
    makeSlider(adagr, key1, key2);
  }
  // makeZeroSlider
}
// Story
