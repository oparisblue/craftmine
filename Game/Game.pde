/**
* Initialises the game, loads mods and deals with user input.
* @author Orlando
*/

import java.util.Set;
import java.util.HashSet;

public GameRegistry gr;
public TerrainManager terrainManager;
public ArrayList<Mod> mods;
public EntityPlayer player;
public GUICamera camera;
public ArrayList<GUI> guiScreens = new ArrayList<GUI>();
public GUIUtils guiUtils = new GUIUtils();

private int deltaTime;
private int lastMillis = millis();

public StructureBlockDefinition STRUCT_AIR;

void setup() {
  
  // Processing Settings
  fullScreen();
  noSmooth();
  
  //size(800, 800);
  
  // Register required blocks, items and entities
  
  gr = new GameRegistry();
  
  gr.blocks.register("Air", new BlockAir());
  gr.items.register("ItemBlock", new ItemBlock());
  STRUCT_AIR = new StructureBlockDefinition("Air");
  
  gr.entities.register("Item", new EntityItem());
  gr.entities.register("Falling Block", new EntityFallingBlock());
  gr.entities.register("Player", new EntityPlayer());
  
  // Load mods
  
  mods = new ArrayList<Mod>();
  
  // Reflection trickery here only possible because Processing wraps _all_ our code into a single class that extends PApplet
  // You can reflect your own inner classes like this, but not outer ones....
  for (Class c : this.getClass().getDeclaredClasses()) {
    for (Class i : c.getInterfaces()) {
      if (i.getSimpleName().equals("Mod")) {
        try {
          mods.add((Mod)c.getDeclaredConstructor(this.getClass()).newInstance(this));
        } catch (Exception e) { }
        break;
      }
    }
  }
  
  for (int i = 0; i < 2; i++) {
    for (Mod mod : mods) {
      if      (i == 0) mod.preInit();
      else if (i == 1) mod.init();
    }
  }
  
  // Create the terrain manager
  
  terrainManager = new TerrainManager();
  camera = new GUICamera(null);
  camera.guiOnlyMode = true;
  /*
  terrainManager.setDimension(gr.dimensions.get("Overworld"));
  
  //noiseSeed(101);
  player = new EntityPlayer(new PVector(64, 200), "Overworld");
  camera = new GUICamera(player);
  
  terrainManager.entities.add(player);*/
  
  guiUtils.openGui(new GUIMainMenu());
}

public String debugText = "";

void draw() {
  
  int newMillis = millis();
  deltaTime = newMillis - lastMillis;
  lastMillis = newMillis;
  
  for (Animation ani : gr.animations.all()) ani.nextFrame();
  
  terrainManager.updateLoadedChunks();
  camera.render();
  terrainManager.updateEntities();
  
  if (isKeyDown('p')) guiUtils.drawText(20, 20, "FPS: " + nf(frameRate, 2, 2), 255, 255, 0, true, false);
  guiUtils.drawText(20, 20, debugText, 255, 0, 0, true, false);
  debugText = "";
  
  for(Mod mod : mods) {
    mod.tick();
  }
  
  firstClickFrame = false;  
  
}

public int getDeltaTime() {
  return deltaTime;
}

public interface Mod {
  
  public void preInit();
  
  public void init();
  
  public void tick();
  
}

ArrayList<String> keysDown = new ArrayList<String>();
boolean lMouseDown = false;
boolean firstClickFrame = false;
boolean rMouseDown = false;
boolean shiftKeyDown = false;

void mousePressed() {
  if      (mouseButton == LEFT)  { lMouseDown = true; firstClickFrame = true; }
  else if (mouseButton == RIGHT) { rMouseDown = true; firstClickFrame = true; }
}

void mouseReleased() {
  if      (mouseButton == LEFT)  lMouseDown = false;
  else if (mouseButton == RIGHT) rMouseDown = false;
}

void keyPressed() {
  if (key == CODED && keyCode == SHIFT) shiftKeyDown = true;
  else if (key == ESC) {
    key = 0; //Don't quit the program
    if (!onMenuScreen) { // Playing the game...
      if (guiUtils.isGuiOpen()) { // GUI -> Close GUI
        guiUtils.closeGui();
      }
      else { // No GUI -> Save and quit to title
        saveWorld(null);
        backToMenu();
      }
    }
    else { // Title screen -> quit to desktop
      exit();
    }
  }
  else if (!keysDown.contains(String.valueOf(key))) keysDown.add(String.valueOf(key));
}

void keyReleased() {
  if (key == CODED && keyCode == SHIFT) shiftKeyDown = false;
  else if (keysDown.contains(String.valueOf(key))) keysDown.remove(String.valueOf(key));
}

public boolean isKeyDown(char k) {
  return keysDown.contains(String.valueOf(k)); 
}

public void clearInput() {
  lMouseDown = false;
  rMouseDown = false;
}

public enum Direction {
  NONE,
  NORTH,
  EAST,
  SOUTH,
  WEST,
  ALL
}
