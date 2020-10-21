public class GUIMainMenu extends GUI {
  
  private GUIScrollbar scrollbar = null;
  
  private boolean newWorld = false;
  private String seed = "";
  private boolean creative = false;
  private boolean superflat = false;
  
  GUIAction quitGame;
  GUIAction createWorld;
  GUIAction makeSeed;
  GUIAction goBack;
  GUIAction beginGame;
  GUIAction toggleCreative;
  GUIAction toggleSuperflat;
  
  public GUIMainMenu() {
    quitGame        = new GUIAction(){ public void action() { exit(); }};
    createWorld     = new GUIAction(){ public void action() { makeSeed(); newWorld = true; creative = false; superflat = false; }};
    makeSeed        = new GUIAction(){ public void action() { makeSeed(); }};
    toggleCreative  = new GUIAction(){ public void action() { creative  = !creative; }};
    toggleSuperflat = new GUIAction(){ public void action() { superflat = !superflat; }};
    goBack          = new GUIAction(){ public void action() { newWorld = false; }};
    beginGame       = new GUIAction(){ public void action() { newWorld(Integer.parseInt(seed), creative, superflat); }};
  }
  
  public void render() {
    background(55);
    PVector tl = guiUtils.drawTexturedModalRect(486, 516);
    
    color green = color(139, 195, 74);
    color greenHover = color(104, 159, 56);
    
    if (newWorld) {
      guiUtils.drawPanel(tl.x + 16, tl.y + 16, 450, 420, MID_GREY, MID_GREY, true);
      guiUtils.drawText(tl.x + 32, tl.y + 32, "Seed:", 255, 255, 255, true, false);
      guiUtils.drawPanel(tl.x + 32, tl.y + 64, 360, 48, MID_GREY, MID_GREY, true);
      guiUtils.drawText(tl.x + 48, tl.y + 80, seed, 255, 255, 255, true, false);
      
      guiUtils.button(tl.x + 404, tl.y + 64, 48, 48, makeSeed, "©", green, greenHover);
      
      guiUtils.button(tl.x + 32, tl.y + 128, 201, 48, toggleCreative, "Creative", creative ? green : LIGHT_GREY, creative ? greenHover : LIGHT_BLUE);
      guiUtils.button(tl.x + 249, tl.y + 128, 201, 48, toggleSuperflat, "Superflat", superflat ? green : LIGHT_GREY, superflat ? greenHover : LIGHT_BLUE);
      
      guiUtils.button(tl.x + 16, tl.y + 452, 217, 48, goBack, "Go Back");
      guiUtils.button(tl.x + 249, tl.y + 452, 217, 48, beginGame, "Begin Game", green, greenHover);
    }
    else {
      
      guiUtils.drawPanel(tl.x + 16, tl.y + 16, 403, 420, MID_GREY, MID_GREY, true);
      
      File[] files = new File(sketchPath() + "/saves/").listFiles();
      
      final ArrayList<String> saves = new ArrayList<String>();
      
      for (File file : files) {
        String name = file.getName();
        if (name.charAt(0) != '.' && name.toLowerCase().substring(name.length() - 4).equals(".xml")) {
          saves.add(name.substring(0, name.length() - 4));
        }
      }
      
      int visibleRows = 5;
      
      if (scrollbar == null) scrollbar = new GUIScrollbar(tl.x + 417, 49, 49, tl.y + 16, 420, max(0, saves.size() - visibleRows));
      scrollbar.render();
      
      for (int i = 0; i < visibleRows; i++) {
        final int pos = i + scrollbar.getTopRow();
        if (pos == saves.size()) break;
        float posFromTop = tl.y + 18 + ((416 / visibleRows) * i);
        guiUtils.drawPanel(tl.x + 18, posFromTop, 399, 420 / visibleRows, MID_GREY, MID_GREY, false);
        guiUtils.drawText(tl.x + 35, posFromTop + 17, saves.get(pos), 255, 255, 255, true, false);
        guiUtils.button(tl.x + 352, posFromTop + 17, 48, 48, new GUIAction(){
          public void action() { loadWorld("saves/" + saves.get(pos) + ".xml"); } 
        }, "¬", green, greenHover);
        guiUtils.button(tl.x + 292, posFromTop + 17, 48, 48, new GUIAction(){
          public void action() { new File(sketchPath() + "/saves/" + saves.get(pos) + ".xml").delete(); } 
        }, "ø", color(239, 83, 80), color(211, 47, 47));
      }    
      
      guiUtils.button(tl.x + 16, tl.y + 452, 217, 48, quitGame, "Quit Game");
      guiUtils.button(tl.x + 249, tl.y + 452, 217, 48, createWorld, "Create World", green, greenHover);
    }
    
    guiUtils.drawText(16, height - 32, "Craftmine Version 1.1");
  }
  
  public void makeSeed() {
    seed = "";
    String[] numbers = new String[]{"0", "1", "2", "3", "4", "5", "6", "7", "8", "9"};
    for (int i = 0; i < 9; i++) {
      seed += numbers[(int)random(0, numbers.length)];
    }
  }
  
}

public boolean onMenuScreen = true;

public void backToMenu() {
  terrainManager = new TerrainManager();
  camera.guiOnlyMode = true;
  camera.changeTarget(null);
  player = null;
  guiScreens.clear();
  guiUtils = new GUIUtils();
  onMenuScreen = true;
  guiUtils.openGui(new GUIMainMenu());
}
