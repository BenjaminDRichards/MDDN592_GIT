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
  LandscapeBlocks landscape, landscape2;
  DAGWorld dagWorld;
  AnimatorManager animatorManager;
  ArrayList sliders;
  float masterSlider;
  float transitionSpeed;
  ArrayList sprites, spritesBack;
  boolean recording;
  
  float WIND_PERIOD = 360;
  
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
  PImage img_connector = loadImage("Connector1.png");
  PImage img_leaf = loadImage("Leaf1.png");
  PImage img_clutter = loadImage("Clutter1.png");
  PImage img_fog = loadImage("Fog1.png");
  
  
  Story()
  {
    storyEvents = new ArrayList();
    
    // Setup scene
    animatorManager = new AnimatorManager();
    dagWorld = new DAGWorld();
    sliders = new ArrayList();
    masterSlider = 0;
    transitionSpeed = 0;
    sprites = new ArrayList();
    spritesBack = new ArrayList();
    recording = false;
    
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
    // Refresh sliders
    slide(transitionSpeed);
    
    
    // Render graphics
    render();
  }
  // run
  
  
  void render(PGraphics pg)
  {
    pg.background(0,32,64);
    
    // Render rear terrain
    renderTerrain(pg, landscape2);
    // Render rear sprites
    Iterator iSprBak = spritesBack.iterator();
    while( iSprBak.hasNext() )
    {
      Sprite sprite = (Sprite) iSprBak.next();
      sprite.render(pg);
    }
    
    // Distance fog
    float smoothSlider = 3 * pow(masterSlider, 2) - 2 * pow(masterSlider, 3);
    color fogCol = lerpColor(color(192), color(127, 192, 255), smoothSlider);
    pg.pushStyle();
    pg.noStroke();
    pg.tint( fogCol, 255 * (1 - smoothSlider) );
    pg.pushMatrix();
    pg.translate(0, 100 * smoothSlider);
    pg.rotate(-smoothSlider);
    pg.image(img_fog, -50.0 * pg.width / (float)pg.height, 0,  100 * pg.width / (float)pg.height, 100);
    pg.popMatrix();
    pg.pushMatrix();
    pg.translate(0, 100 * (1 - smoothSlider) );
    pg.scale(1, -1);
    pg.image(img_fog, -50.0 * pg.width / (float)pg.height, 0,  100 * pg.width / (float)pg.height, 100);
    pg.popMatrix();
    pg.fill( fogCol, 255 - 128 * pow(smoothSlider, 0.5) );
    pg.rect(-50.0 * pg.width / (float)pg.height, 0,  100 * pg.width / (float)pg.height, 100);
    pg.popStyle();
    
    // Render sprites
    pg.pushStyle();
    pg.tint(0);
    Iterator iSpr = sprites.iterator();
    while( iSpr.hasNext() )
    {
      Sprite sprite = (Sprite) iSpr.next();
      sprite.render(pg);
    }
    pg.popStyle();
    
    // Render front terrain
    renderTerrain(pg, landscape);
    
    
    // Recording
    if(recording)
    {
      String filename = "render" + nf(frameCount, 5) + ".png";
      save("renders/" + filename);
    }
  }
  // render
  
  void render()
  // Renders to g (default graphics)
  {
    render(g);
  }
  // render
  
  
  private void renderTerrain(PGraphics pg, LandscapeBlocks land)
  {
    ArrayList filledLandscape = land.getFilledNodes();
    pg.fill(0);
    Iterator iTer = filledLandscape.iterator();
    while( iTer.hasNext() )
    {
      DAGTransform d = (DAGTransform) iTer.next();
      ArrayList corners = land.getCornersFromNode(d);
      
      // Render fill
      pg.beginShape();
      PVector v0 = ( (DAGTransform)corners.get(0) ).getWorldPosition();
      PVector v1 = ( (DAGTransform)corners.get(1) ).getWorldPosition();
      PVector v2 = ( (DAGTransform)corners.get(2) ).getWorldPosition();
      PVector v3 = ( (DAGTransform)corners.get(3) ).getWorldPosition();
      pg.vertex(v0.x, v0.y);
      pg.vertex(v1.x, v1.y);
      pg.vertex(v2.x, v2.y);
      pg.vertex(v3.x, v3.y);
      pg.vertex(v0.x, v0.y);
      pg.endShape();
    }
  }
  // renderTerrain
  
  
  
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
    
    switch(code)
    {
      case 101:
        cmd_makeTreeA();
        break;
      case 102:
        cmd_makeTreeB();
        break;
      case 103:
        cmd_makeTreeC();
        break;
      case 104:
        cmd_makeTreeD();
        break;
      case 200:
        cmd_transition();
        break;
      case 201:
        cmd_unTransition();
        break;
      case 901:
        cmd_start_recording();
        break;
      case 999:
        cmd_program_end();
        break;
      default:
        break;
    }
  }
  // command
  
  
  void cmd_makeTreeA()
  // CODE 101
  // Makes the first tree
  {
    birthTreeAt(0, 75);
  }
  // cmd_makeTreeA
  
  
  void cmd_makeTreeB()
  // CODE 102
  // Puts a tree on the rocks to the right
  {
    birthTreeAt(10, 40);
  }
  // cmd_makeTreeB
  
  
  void cmd_makeTreeC()
  // CODE 103
  // Puts a tree on the rocks to the left
  {
    birthTreeAt(-30, 20);
  }
  // cmd_makeTreeC
  
  
  void cmd_makeTreeD()
  // CODE 104
  // Puts a tree on the ground to the left
  {
    birthTreeAt(-30, 60);
  }
  // cmd_makeTreeD
  
  
  void cmd_transition()
  // CODE 200
  // Initiates transition from straight to noisy mode
  {
    transitionSpeed = 1.0 / 480;
  }
  // cmd_transition
  
  
  void cmd_unTransition()
  // CODE 201
  // Initiates transition from straight to noisy mode
  {
    transitionSpeed = -1.0 / 480;
  }
  // cmd_transition
  
  
  void cmd_start_recording()
  // CODE 901
  // Sets time to no-skip and starts recording
  {
    timeMode = 1;
    recording = true;
  }
  // cmd_start_recording
  
  
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
    if(masterSlider == 1  ||  masterSlider == 0)
    {
      transitionSpeed = 0;
    }
    
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
  
  
  public float getMasterSlider()
  {
    return( masterSlider );
  }
  // getMasterSlider
  public void setMasterSlider(float s)
  {
    masterSlider = s;
  }
  // getMasterSlider
  
  
  public ArrayList getSprites()
  {
    return( sprites );
  }
  // getSprites
  
  
  
  void setupStory()
  // Script the sequence of events
  {
    // Create the landscape
    landscape = new LandscapeBlocks(-100, -20, 100, 120, 5, this);
    dagWorld.addNodeCollection( landscape.getNodes() );
    setupLandscapeA(landscape);
    
    landscape2 = new LandscapeBlocks(-105, -25, 100, 120, 10, this);
    dagWorld.addNodeCollection( landscape2.getNodes() );
    setupLandscapeB(landscape2);
    
    addClutterToLandscape(landscape);
    
    // Do recording
    makeEvent(0, 901);
    
    // Spawn trees
    makeEvent(600, 101);
    makeEvent(900, 102);
    makeEvent(1500, 103);
    makeEvent(1800, 104);
    
    // Transition
    makeEvent(1200, 200);
    makeEvent(2700, 201);
    
    // Termination
    makeEvent(3600, 999);
  }
  // setupStory
  
  
  public DAGTransform birthTree(int segs, float delay, boolean base)
  // Creates a tree to animate into being
  {
    // Create a root
    DAGTransform root = new DAGTransform(0, 0, 0,  0,  1,1,1);
    
    // Register last joint
    DAGTransform lastJoint = root;
    
    // Create sprite
    Sprite spriteRoot = new Sprite(root, img_connector, 5,5, -0.5,-0.8);
    sprites.add(spriteRoot);
    
    // Add initial animation
    AnimatorDAGRecord root_key1 = new AnimatorDAGRecord(0,0,0, 0, 0,0,0);
    root_key1.useSX = true;  root_key1.useSY = true;  root_key1.useSZ = true;
    AnimatorDAGRecord root_key2 = new AnimatorDAGRecord(0,0,0, 0, 1,1,1);
    Animator root_anim = new Animator(root, root_key1, root_key2, Animator.ANIM_TWEEN_SMOOTH, 60);
    root_anim.setDelay(delay);
    animatorManager.addAnimator(root_anim);
    
    if(base)
    {
      // Create master
      AnimatorDAGRecord adr = new AnimatorDAGRecord(0,0,0, 0, 1,1,1);
      adr.useSX = true;  adr.useSY = true;  adr.useSZ = true;
      root.setParent(adr);
      root = adr;  // This is to ensure the correct return
      // Add a scale slider to compensate for shrinkage
      AnimatorDAGRecord rootSlideKey1 = new AnimatorDAGRecord(0,0,0, 0, 1,1,1);
      AnimatorDAGRecord rootSlideKey2 = new AnimatorDAGRecord(0,0,0, 0, 2,2,2);
      makeSlider(adr, rootSlideKey1, rootSlideKey2);
    }
    
    // Setup some constants
    PVector spacing = new PVector(0, -3, 0);
    float taperFactor = random(0.8, 1.0);
    PVector taper = new PVector(taperFactor, taperFactor, taperFactor);
    
    // Add a number of joints
    for(int i = 0;  i < segs;  i++)
    {
      // Create joints
      DAGTransform jointGrower = new DAGTransform(0,0,0, 0, 1,1,1);
      jointGrower.snapTo(lastJoint);
      jointGrower.setParent(lastJoint);
      DAGTransform jointCycler = new DAGTransform(0,0,0, 0, 1,1,1);
      jointCycler.snapTo(lastJoint);
      jointCycler.setParent(jointGrower);
      
      // Create sprite
      Sprite sprite = new Sprite(jointCycler, img_connector, 5,5, -0.5,-1.0);
      sprites.add(sprite);
      
      // Make a scale slider to taper joints
      // I'm just using one key in key1/key2 here to keep it constant
      AnimatorDAGRecord cycle_scale = new AnimatorDAGRecord(0,0,0, 0, 1,1,1);
      cycle_scale.useSX = true;  cycle_scale.useSY = true;  cycle_scale.useSZ = true;
      Animator cycle_scale_anim = new Animator(jointCycler, cycle_scale, cycle_scale, Animator.ANIM_CONSTANT, 1);
      animatorManager.addAnimator(cycle_scale_anim);
      // Set a slider on the scale animator
      AnimatorDAGRecord cycle_scale_slideKey1 = new AnimatorDAGRecord(
        cycle_scale.getUsedPosition().x, cycle_scale.getUsedPosition().y, cycle_scale.getUsedPosition().y,
        cycle_scale.getUsedRotation(),
        cycle_scale.getUsedScale().x, cycle_scale.getUsedScale().y, cycle_scale.getUsedScale().z);
      cycle_scale_slideKey1.useSX = true;  cycle_scale_slideKey1.useSY = true;  cycle_scale_slideKey1.useSZ = true;
      AnimatorDAGRecord cycle_scale_slideKey2 = new AnimatorDAGRecord(0,0,0, cycle_scale.getUsedRotation(), taper.x, taper.y, taper.z);
      cycle_scale_slideKey2.usePX = true;  cycle_scale_slideKey2.usePY = true;  cycle_scale_slideKey2.usePZ = true;
      cycle_scale_slideKey2.useSX = true;  cycle_scale_slideKey2.useSY = true;  cycle_scale_slideKey2.useSZ = true;
      makeSlider(cycle_scale, cycle_scale_slideKey1, cycle_scale_slideKey2);
      
      // Add phased behaviour to joints
      float flex = 0.25 * i / (float)segs;
      AnimatorDAGRecord cycle_key1 = new AnimatorDAGRecord(0,0,0, -flex, 1,1,1);
      cycle_key1.useR = true;
      makeZeroSlider(cycle_key1);
      AnimatorDAGRecord cycle_key2 = new AnimatorDAGRecord(0,0,0, flex, 1,1,1);
      cycle_key2.useR = true;
      makeZeroSlider(cycle_key2);
      Animator cycle_anim = new Animator(jointCycler, cycle_key1, cycle_key2, Animator.ANIM_OSCILLATE, WIND_PERIOD);
      cycle_anim.setDelay( i / (float)segs );
      animatorManager.addAnimator(cycle_anim);
      
      // Add growth behaviour to joints
      // Also add the offset here
      float startAngle = random(1.0) < 0.5  ?  PI  :  -PI;
      AnimatorDAGRecord grow_key1 = new AnimatorDAGRecord(spacing.x,spacing.y,spacing.z, startAngle, 0,0,0);
      grow_key1.usePX = true;  grow_key1.usePY = true;  grow_key1.usePZ = true;
      grow_key1.useR = true;
      grow_key1.useSX = true;  grow_key1.useSY = true;  grow_key1.useSZ = true;
      AnimatorDAGRecord grow_key2 = new AnimatorDAGRecord(spacing.x,spacing.y,spacing.z, 0, 1,1,1);
      grow_key2.usePX = true;  grow_key2.usePY = true;  grow_key2.usePZ = true;
      grow_key2.useR = true;
      grow_key2.useSX = true;  grow_key2.useSY = true;  grow_key2.useSZ = true;
      Animator grow_anim = new Animator(jointGrower, grow_key1, grow_key2, Animator.ANIM_TWEEN_FLOP_OUT, 60);
      float growDelay = delay + i * 0.25;
      grow_anim.setDelay(growDelay);
      animatorManager.addAnimator(grow_anim);
      
      // Possibly put a branch on here
      if( (random(1.0) < 0.3)  &&  (i < segs - 1) )
      {
        // That is, branches away from the top have a 30% chance of happening
        DAGTransform branch = birthTree( floor( segs - random(i + 1) ), growDelay + 0.25,  false);
        branch.snapTo(jointCycler);
        // Determine side
        float side = 1;
        if(random(1.0) < 0.5)
        {
          side = -1;
        }
        // Build rotation and slider assets
        AnimatorDAGRecord branch_slideKey1 = new AnimatorDAGRecord(0,0,0, HALF_PI * side, 1,1,1);
        branch_slideKey1.useR = true;
        float actualAngle = HALF_PI - random(1.0);
        AnimatorDAGRecord branch_slideKey2 = new AnimatorDAGRecord(0,0,0, actualAngle * side, 1,1,1);
        branch_slideKey2.useR = true;
        // Attach via animation proxy
        AnimatorDAGRecord branchAnimMaster = new AnimatorDAGRecord(0,0,0, 0, 1,1,1);
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
            DAGTransform leaf = new DAGTransform(0,0,0, 0, 1,1,1);
            leaf.snapTo(jointCycler);
            leaf.setParent(jointCycler);
            leaf.rotate(HALF_PI * j);
            //leaf.moveLocal(spacing.y * j, 0, 0);
            
            // Create sprite
            Sprite spriteLeaf = new Sprite(leaf, img_leaf, 5,5, -0.5,-1.0);
            sprites.add(spriteLeaf);
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
    DAGTransform tree = birthTree(8, 0.0, true);
    tree.snapTo(anchor);
    tree.setParent(anchor);
  }
  // birthTreeAt
  
  
  private void setupLandscapeA(LandscapeBlocks land)
  // Sets some filled-in blocks according to a pattern
  {
    ArrayList list = land.getNodes();
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
        land.setNodeFilled(dag);
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
      DAGTransform d = land.getNearestNode(pv.x, pv.y);
      land.setNodeFilled(d);
    }
  }
  // setupLandscapeA
  
  
  private void setupLandscapeB(LandscapeBlocks land)
  {
    ArrayList list = land.getNodes();
    Iterator i = list.iterator();
    while( i.hasNext() )
    {
      DAGTransform dag = (DAGTransform) i.next();
      PVector pos = dag.getWorldPosition();
      float fillThresholdY = 41.0 + 20 * cos(pos.x * 0.1 + 1) - sqrt(abs(pos.x));
      //fillThresholdY = 71.0;
      
      if(fillThresholdY < pos.y)
      {
        land.setNodeFilled(dag);
      }
    }
  }
  // setupLandscapeB
  
  
  private void addClutterToLandscape(LandscapeBlocks land)
  {
    for(int i = 0;  i < 128;  i++)
    {
      float x = random(-50, 50) * width / (float)height;
      float y = random(0, 100);
      DAGTransform dHost = land.getNearestFilledNode(x, y);
      DAGTransform dTest = land.getNearestNode(x, y);
      if( 1.0 < PVector.dist( dHost.getWorldPosition(), dTest.getWorldPosition() ) )
      {
        // That is, we are not too close to or inside a filled node
        
        // Create transform
        AnimatorDAGRecord dag = new AnimatorDAGRecord(0,0,0, 0, 1,1,1);  // ADAGR for quick sliding
        dag.useSX = true;  dag.useSY = true;  dag.useSZ = true;
        dag.snapTo(dHost);
        dag.setParent(dHost);
        dag.rotate( random(TWO_PI) );
        
        // Set sliders
        AnimatorDAGRecord key1 = new AnimatorDAGRecord(0,0,0, 0, 0,0,0);
        AnimatorDAGRecord key2 = new AnimatorDAGRecord(0,0,0, 0, 1,1,1);
        makeSlider(dag, key1, key2);
        
        // Create sprite
        float rScale = pow( random(1.0), 2) * 8;
        Sprite sprite = new Sprite(dag, img_clutter, rScale, rScale, -0.5,-0.5);
        sprites.add(sprite);
      }
    }
  }
  // addClutterToLandscape
  
  
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
    AnimatorDAGRecord key1 = new AnimatorDAGRecord(0,0,0, 0, 1,1,1);
    // Create max key
    PVector pos = adagr.getUsedPosition();
    float r = adagr.getUsedRotation();
    PVector scale = adagr.getUsedScale();
    AnimatorDAGRecord key2 = new AnimatorDAGRecord(pos.x, pos.y, pos.z,  r,  scale.x, scale.y, scale.z);
    // Make slider
    makeSlider(adagr, key1, key2);
  }
  // makeZeroSlider
}
// Story
