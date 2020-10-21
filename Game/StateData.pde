public class StateData {
 
  private HashMap<String, Object> data = new HashMap<String, Object>();
  
  public StateData(Object... initData) {
    if (initData.length % 2 != 0) throw new Error("StateData: Initialization data must be String->Object pairs!");
    for (int i = 0; i < initData.length; i += 2) {
      if (!(initData[i] instanceof String)) throw new Error("StateData: Initialization data must be String->Object pairs!");
      data.put((String)initData[i], initData[i + 1]);
    }
  }
  
  public StateData(XML xml) {
    
    for (XML kv : xml.getChildren()) {
      
      if (!kv.getName().equals("val")) continue;
      
      String type = kv.getString("type");
      
      String value = kv.getContent();
      
      Object obj = null;
      
      XML firstChild = getFirstChild(kv);
      
      if      (type.equals("B")) obj = value.equals("T");
      else if (type.equals("S")) obj = value;
      else if (type.equals("I")) obj = Integer.parseInt(value);
      else if (type.equals("F")) obj = Float.parseFloat(value);
      else if (type.equals("V")) { String[] vals = value.split(","); obj = new PVector(Float.parseFloat(vals[0]), Float.parseFloat(vals[1]), Float.parseFloat(vals[2])); }
      else if (type.equals("s")) obj = new StateData(firstChild);
      else if (type.equals("b")) obj = new BlockState(firstChild);
      else if (type.equals("i")) obj = new ItemStack(firstChild);
      else if (type.equals("c")) obj = new Container(firstChild);
      else if (type.equals("e")) obj = makeEntity(firstChild);
      else if (type.equals("r")) obj = gr.smelting.get(Integer.parseInt(value));
      
      data.put(kv.getString("key"), obj);
    }
  }
  
  public String toXML() {
    String result = "";
    for (String k : data.keySet()) {
      String type = "";
      String value = "";
      
      Object obj = data.get(k);
      
      if      (obj instanceof Boolean)        { type = "B"; value = ((Boolean)obj) ? "T" : "F"; }
      else if (obj instanceof String)         { type = "S"; value = (String)obj; }
      else if (obj instanceof Integer)        { type = "I"; value = String.valueOf((Integer)obj); }
      else if (obj instanceof Float)          { type = "F"; value = String.valueOf((Float)obj); }
      else if (obj instanceof PVector)        { PVector v = (PVector)obj; type = "V"; value = v.x + "," + v.y + "," + v.z; }
      else if (obj instanceof StateData)      { type = "s"; value = ((StateData)obj).toXML(); }
      else if (obj instanceof BlockState)     { type = "b"; value = ((BlockState)obj).toXML(); }
      else if (obj instanceof ItemStack)      { type = "i"; value = ((ItemStack)obj).toXML(); }
      else if (obj instanceof Container)      { type = "c"; value = ((Container)obj).toXML(); }
      else if (obj instanceof Entity)         { type = "e"; value = ((Entity)obj).toXML(); }
      else if (obj instanceof SmeltingRecipe) { type = "r"; value = String.valueOf(gr.smelting.indexOf((SmeltingRecipe)obj)); }
      
      result += "<val key=\"" + k + "\" type=\"" + type + "\">" + value + "</val>";
    }
    return result;
  }
  
  public void set(String name, Object obj) {
    data.put(name, obj);
  }
  
  public Object get(String name) {
    return data.get(name);
  }
  
  public HashMap<String, Object> getMap() {
    return data;
  }
  
}

public class DimPos {
 
  public float x;
  public float y;
  public float z;
  public int d;
  
  public DimPos(float x, float y, float z, int d) {
    this.x = x;
    this.y = y;
    this.z = z;
    this.d = d;
  }
  
  public boolean equals(Object obj) {
    if (obj == null || !(obj instanceof DimPos)) return false;
    if (obj == this) return true;
    DimPos oth = (DimPos) obj;
    return oth.x == x && oth.y == y && oth.z == z && oth.d == d;
  }
  
}

public void newWorld(int seed, boolean creative, boolean superflat) {
  EntityPlayer player = new EntityPlayer(new PVector(64, 200), "Overworld", false);
  
  String levelData = "<seed>" + seed + "</seed><creative>" + (creative ? "T" : "F") + "</creative><superflat>" + (superflat ? "T" : "F") + "</superflat>";
  
  String globalData = "";
  
  // Load all of the global world data to add to the XML file from the Game Registry, and set each to their default value.
  for (String name : gr.worldData.keys()) {
    globalData += gr.worldData.get(name).toXML();
  }
  
  String template = "<?xml version=\"1.0\"?><world><data>" + levelData + "<val key=\"global\" type=\"s\">" + globalData + "</val></data><entities>" + player.toXML() + "</entities><chunks></chunks></world>";
  String saveName = "saves/" + seed + ".xml";
  saveXML(parseXML(template), saveName);
  loadWorld(saveName);
}

public void loadWorld(String saveName) {
  
  XML xml = loadXML(saveName);
  
  // Load our seed
  noiseSeed(Integer.parseInt(xml.getChild("data/seed").getContent()));
  
  // Update the terrain manager
  terrainManager.entities.clear();
  terrainManager.blocksToSave.clear();
  terrainManager.entitiesToAdd.clear();
  terrainManager.entitiesToRemove.clear();
  terrainManager.suctionBoxes.clear();
  terrainManager.worldData = new StateData(xml.getChild("data/val"));
  terrainManager.creative = xml.getChild("data/creative").getContent().equals("T");
  terrainManager.superflat = xml.getChild("data/superflat").getContent().equals("T");
  
  // Make the player
  XML[] entities = xml.getChild("entities").getChildren();
  EntityPlayer plr = null;
  for (XML entity : entities) {
    if (!entity.getName().equals("entity")) continue;
    if (entity.getName().equals("entity") && entity.getString("name").equals("Player")) {
       plr = (EntityPlayer)makeEntity(entity);
    }
    else {
      terrainManager.entities.add(makeEntity(entity)); 
    }
  }
  if (plr == null) return;
  
  terrainManager.world = xml;
  terrainManager.saveName = saveName;
  terrainManager.entities.add(plr);
  terrainManager.setDimension(gr.dimensions.get(plr.dimension));
  
  // Reset state
  guiUtils.closeGui();
  onMenuScreen = false;
  clearInput();
  
  // Add the player to the scene
  player = plr;
  camera.changeTarget(player);
  camera.guiOnlyMode = false;
  
}

/**
* @param k The key for the chunk to save. If null, all chunks will be saved.
*/
public void saveWorld(ArrayList<Integer> k) {
  
  // Remove the exisiting global data
  terrainManager.world.getChild("data").removeChild(terrainManager.world.getChild("data/val"));
  // Serialise the current global data and add it to the save file
  terrainManager.world.getChild("data").addChild(parseXML("<val key=\"global\" type=\"s\">" + terrainManager.worldData.toXML() + "</val>"));
  
  XML chunks = terrainManager.world.getChild("chunks");
  
  // Save chunk(s)
  ArrayList<DimPos> saved = new ArrayList<DimPos>();
  for (ArrayList<Integer> ck : terrainManager.chunks.keySet()) {
    if (ck == k || k == null) {
      // Find the chunk which we will save the blocks & entities to
      XML chunk = null;
      for (XML potentialChunk : chunks.getChildren()) {
        if (potentialChunk.getName().equals("chunk") && potentialChunk.getInt("x") == ck.get(0) && potentialChunk.getInt("d") == ck.get(1)) {
          chunk = potentialChunk;
          break;
        }
      }
      if (chunk == null) {
        chunk = chunks.addChild("chunk");
        chunk.setInt("x", ck.get(0));
        chunk.setInt("d", ck.get(1));
      }
      
      // Loop through all of the blocks marked dirty, to find the ones we need to save
      for (int i = terrainManager.blocksToSave.size() - 1; i >= 0; i--) {
        DimPos block = terrainManager.blocksToSave.get(i);
        // If there is a block has been marked dirty more than once, remove the duplicates
        if (saved.contains(block)) {
          terrainManager.blocksToSave.remove(i); 
        }
        // If the block is within the chunk being unloaded, save it
        else if (block.d == ck.get(1) && block.x >= ck.get(0) && block.x < ck.get(0) + TerrainManager.W) {
          // If this block is already saved in the XML file, remove the old save.
          for (XML blockState : chunk.getChildren()) {
            if (blockState.getName().equals("block") && blockState.getFloat("x") == block.x && blockState.getFloat("y") == block.y && blockState.getFloat("z") == block.z) {
              chunk.removeChild(blockState);
              break;
            }
          }
          // Add the new XMLification on this block to the chunk
          chunk.addChild(parseXML(terrainManager.getBlockStateAt((int)block.x, (int)block.y, (int)block.z).toXML()));
        }
      }
    }
  }
  
  // Save all entities
  terrainManager.world.removeChild(terrainManager.world.getChild("entities")); // Remove the old entity list
  String entities = "<entities>";
  for (Entity entity : terrainManager.entities) {
    entities += entity.toXML(); 
  }
  terrainManager.world.addChild(parseXML(entities + "</entities>"));
  
  // Write to the file
  saveXML(terrainManager.world, terrainManager.saveName);
}

public XML getFirstChild(XML xml) {
  XML[] children = xml.getChildren();
  for (XML child : children) {
    if (child.getName().equals("#text")) continue;
    return child;
  }
  return null;
}
