public class TerrainManager {
  
  public static final int W = 16;
  public static final int H = 128;
  public static final int LOAD_PER_SIDE = 2;
  
  public HashMap<ArrayList<Integer>, ArrayList<BlockState>[][]> chunks = new HashMap<ArrayList<Integer>, ArrayList<BlockState>[][]>();
  private int chunkLeftMost = 0;
  private int chunkRightMost = 0;
  
  public ArrayList<Entity> entities = new ArrayList<Entity>();
  private ArrayList<Entity> entitiesToAdd = new ArrayList<Entity>();
  private ArrayList<Entity> entitiesToRemove = new ArrayList<Entity>();
  private ArrayList<SuctionBox> suctionBoxes = new ArrayList<SuctionBox>();
  
  public ArrayList<DimPos> blocksToSave = new ArrayList<DimPos>();
  public XML world;
  public String saveName;
  
  private Dimension dimension;
  private int dimensionId;
  private boolean shouldRecalcLighting = false;
  
  public void requestLightingRecalc() {
    shouldRecalcLighting = true;
  }
  
  /**
  * Spawn an item as an entity in the world.
  * @param state This defines where to spawn the item. It will be spawned in the same position as the block.
  * @param stack This is the ItemStack to spawn in the world.
  */
  public void spawnItemEntity(BlockState state, ItemStack stack) {
    PVector pos = state.getPosition();
    terrainManager.spawnEntity(new EntityItem(
      new PVector((pos.x * BlockState.BLOCK_SIZE) + random(0, BlockState.BLOCK_SIZE / 4), pos.y * BlockState.BLOCK_SIZE),
      terrainManager.getDimension().getName(),
      stack
    ));
  }
  
  public void spawnItemEntity(int x, int y, ItemStack stack) {
    terrainManager.spawnEntity(new EntityItem(new PVector(x, y), terrainManager.getDimension().getName(), stack));
  }
  
  public void setDimension(Dimension dimension) {
    this.dimension = dimension;
    dimensionId = gr.dimensions.all().indexOf(dimension);
  }
  
  public Dimension getDimension() {
    return dimension;
  }
  
  public int getDimensionId() {
    return dimensionId; 
  }
  
  public ArrayList<SuctionBox> getSuctionBoxes() {
    return suctionBoxes;
  }
  
  public void addSuctionBox(SuctionBox suctionBox) {
    suctionBoxes.add(suctionBox);
  }
  
  public void removeSuctionBox(SuctionBox suctionBox) {
    suctionBoxes.remove(suctionBox); 
  }
  
  public ArrayList<BlockState>[][] getChunkAt(int x) {
    for (ArrayList<BlockState>[][] chunk : chunks.values()) {
      int xOffset = (int)chunk[0][0].get(0).getPosition().x;
      if (x >= xOffset && x <= xOffset + W - 1) {
        return chunk;
      }
    }
    return null;
  }
  
  public ArrayList<BlockState> getBlockStatesAt(int x, int y) {
    if (y < 0 || y >= H) return null;
    for (ArrayList<BlockState>[][] chunk : chunks.values()) {
      int xOffset = (int)chunk[0][0].get(0).getPosition().x;
      if (x >= xOffset && x <= xOffset + W - 1) {
        return chunk[x - xOffset][y];
      }
    }
    return new ArrayList<BlockState>();
  }
  
  public BlockState getBlockStateAt(int x, int y, int z) {
    if (y < 0 || y >= H) return null;
    for (ArrayList<BlockState>[][] chunk : chunks.values()) {
      int xOffset = (int)chunk[0][0].get(0).getPosition().x;
      if (x >= xOffset && x <= xOffset + W - 1) {
        for (BlockState state : chunk[x - xOffset][y]) {
          if ((int)state.getPosition().z == z) return state; 
        }
        break;
      }
    }
    return null;
  }
  
  @SuppressWarnings("null")
  public void updateLoadedChunks() {
    
    HashMap<PVector, Light> newLights = new HashMap<PVector, Light>();
    
    for (ArrayList<BlockState>[][] chunk : chunks.values()) {
      for (ArrayList<BlockState>[] x : chunk) {
        for (ArrayList<BlockState> y : x) {
          for (int z = 0; z < y.size(); z++) {
            BlockState obj = y.get(z);
            obj.update();
            Light light = obj.getBlock().getLight(obj);
            if (light != null) {
              PVector pos = obj.getPosition();
              newLights.put(new PVector(pos.x, pos.y), light);
            }
          }
        }
      }
    }
    
    boolean sourcesDifferent = newLights.values().size() != lightMap.lightSources.values().size();
    
    if (!sourcesDifferent) {
      for (HashMap.Entry<PVector, Light> entry : newLights.entrySet()) {
        Light one = lightMap.lightSources.get(entry.getKey());
        Light two = entry.getValue();
        if (!(one == null && two == null) && (
          (one == null && two != null) || (one != null && two == null) || one.getLevel() != two.getLevel() || one.getColour() != two.getColour()
        )) {
          sourcesDifferent = true;
          break;
        }
      }
    }
    
    if (sourcesDifferent || shouldRecalcLighting) {
      lightMap.lightSources = newLights;
      lightMap.recalculateLighting();
      shouldRecalcLighting = false;
    }
    
  }
  
  public void spawnEntity(Entity entity) {
    entitiesToAdd.add(entity); 
  }
  
  public void despawnEntity(Entity entity) {
    entitiesToRemove.add(entity); 
  }
  
  public void updateEntities() {
    
    for (int i = entitiesToAdd.size() - 1; i >= 0; i--) {
      entities.add(entitiesToAdd.get(i));
      entitiesToAdd.remove(i);
    }
    
    for (int i = entitiesToRemove.size() - 1; i >= 0; i--) {
      entities.remove(entitiesToRemove.get(i));
      entitiesToRemove.remove(i);
    }
    
    for (Entity entity : entities) {
      // If the entity is in an area of the game which is loaded; update it
      if (entity.position.x >= chunkLeftMost && entity.position.x < chunkRightMost) entity.update();
    }
  }
  
  public void generateChunk(int xOffset) {
     ArrayList<BlockState>[][] chunk = (ArrayList<BlockState>[][]) new ArrayList[W][H];
     
     randomSeed((long)(noise((float)xOffset / (float)W, xOffset < 0 ? 0.1 : 0) * 100000000));
     
     Biome biome = chooseBiome(xOffset);
     
     for (int x = 0; x < W; x++) {
       chunk[x] = biome.generateColumn(x + xOffset, W, H);
     }
     
     biome.generateOres(chunk, xOffset, W, H);
     
     biome.generateCaves(chunk, xOffset, W, H);
     
     biome.generateVegetation(chunk, xOffset, W, H);
     
     loadFromSave(chunk, xOffset);
     
     chunks.put(chunkKey(xOffset), chunk);
  }
  
  private void loadFromSave(ArrayList<BlockState>[][] chunkData, int xOffset) {
    for (XML chunk : world.getChild("chunks").getChildren()) {
      if (chunk.getName().equals("#text")) continue;
      if (chunk.getInt("x") == xOffset && chunk.getInt("d") == dimensionId) {
        for (XML block : chunk.getChildren()) {
          if (block.getName().equals("#text")) continue;
          BlockState newState = new BlockState(block);
          BlockState oldState = chunkData[(int)(newState.getPosition().x - xOffset)][(int)newState.getPosition().y].get((int)newState.getPosition().z);
          oldState.setBlock(gr.blocks.get(newState.getBlock().getName()), newState.getState(), true);
        }
      }
    }
  }
  
  public Biome chooseBiome(int xOffset) {
    String[][] whittakerDiagram = dimension.getWhittakerDiagram();
    float nx = (float)xOffset / (float)W;
    float ny = (1000f + (xOffset < 0 ? 0.1 : 0)) / (float)H;
    float altitude = noise(nx, xOffset < 0 ? 0.1 : 0);
    int precipitation = floor(map(noise(nx, ny), 0, 1, 0, whittakerDiagram.length));
    int temperature = floor(map(1 - altitude, 0, 1, 0, whittakerDiagram[0].length)); // Colder at higher altitudes
    return gr.biomes.get(whittakerDiagram[precipitation][temperature]);
  }
  
  private int currentChunk = Integer.MAX_VALUE;
  
  public void loadChunksAround(int xOffset) {
    if (xOffset == currentChunk) return;
    currentChunk = xOffset;
    
    chunkLeftMost = Integer.MAX_VALUE;
    chunkRightMost = Integer.MIN_VALUE;
    
    ArrayList<ArrayList<Integer>> keys = new ArrayList<ArrayList<Integer>>();
    
    for (int x = xOffset - (LOAD_PER_SIDE * W); x <= xOffset + (LOAD_PER_SIDE * W); x += W) {
      ArrayList<Integer> k = chunkKey(x);
      if (chunks.get(k) == null) generateChunk(x); 
      keys.add(k);
      chunkLeftMost = min(chunkLeftMost, k.get(0));
      chunkRightMost = max(chunkRightMost, k.get(0) + W);
    }
    
    chunkLeftMost *= BlockState.BLOCK_SIZE;
    chunkRightMost *= BlockState.BLOCK_SIZE;
    
    ArrayList<ArrayList<Integer>> allKeys = new ArrayList<ArrayList<Integer>>(chunks.keySet());
    
    for (ArrayList<Integer> k : allKeys) {
      // Unload chunks which aren't in the new set of keys
      if (!keys.contains(k)) {
        saveWorld(k); // Save the chunk first!
        chunks.remove(k);
      }
      
      // Unload Suction Boxes which are out of range
      for (int j = suctionBoxes.size() - 1; j >= 0; j--) {
        SuctionBox suctionBox = suctionBoxes.get(j);
        if (suctionBox.chunk != null && suctionBox.chunk.equals(k)) {
          suctionBoxes.remove(j);
        }
      }
    }
    
    requestLightingRecalc();
    
  }
  
  public ArrayList<Integer> chunkKey(int x) {
    ArrayList<Integer> k = new ArrayList<Integer>();
    k.add(x);
    k.add(dimensionId);
    return k;
  }
  
}

public interface Biome {
  
  public ArrayList<BlockState>[] generateColumn(int x, int w, int h);
  
  public void generateOres(ArrayList<BlockState>[][] chunk, int xOffset, int w, int h);
  
  public void generateCaves(ArrayList<BlockState>[][] chunk, int xOffset, int w, int h);
  
  public void generateVegetation(ArrayList<BlockState>[][] chunk, int xOffset, int w, int h);
  
}

public class BiomeSuperflat implements Biome {
  
  private String[] blocks;
  private int[] levels;
  
  public BiomeSuperflat(String[] blocks, int[] levels) {
    if (blocks.length != levels.length) throw new Error("BiomeSuperflat: blocks array must 1-1 match the size of the levels array.");
    this.blocks = blocks;
    this.levels = levels;
  }
  
  public ArrayList<BlockState>[] generateColumn(int x, int w, int h) {
    ArrayList<BlockState>[] column = (ArrayList<BlockState>[]) new ArrayList[h];
    int current = 0;
    for (int y = 0; y < h; y++) {
      if (y == levels[current]) current++;
      if (current >= levels.length) throw new Error("BiomesSuperflat: levels defined not enough to cover a full 128 high column.");
      column[y] = new ArrayList<BlockState>();
      Block b = gr.blocks.get(blocks[current]);
      column[y].add(new BlockState(b, new PVector(x, y, 0), b.getDefaultState()));
      column[y].add(new BlockState(b, new PVector(x, y, 1), b.getDefaultState()));
    }
    return column;
  }
  
  public void generateOres(ArrayList<BlockState>[][] chunk, int x, int w, int h) {}
  public void generateCaves(ArrayList<BlockState>[][] chunk, int x, int w, int h) {}
  public void generateVegetation(ArrayList<BlockState>[][] chunk, int x, int w, int h) {}
  
}

public class BiomeBasic implements Biome {
  
  private String name;
  private float minTerrainHeight;
  private float maxTerrainHeight;
  private String topLayer;
  private float oreRarity;
  private Vegetation[] surfaceVegetation;
  private float vegetationRarity;
  private Structure[] trees;
  
  public BiomeBasic(String name, float minTerrainHeight, float maxTerrainHeight, String topLayer, float oreRarity, Vegetation[] surfaceVegetation,
                    float vegetationRarity, Structure[] trees) {
    this.name = name;
    this.minTerrainHeight = minTerrainHeight;
    this.maxTerrainHeight = maxTerrainHeight;
    this.topLayer = topLayer;
    this.oreRarity = oreRarity;
    this.surfaceVegetation = surfaceVegetation;
    this.vegetationRarity = vegetationRarity;
    this.trees = trees;
  }
  
  public ArrayList<BlockState>[] generateColumn(int x, int w, int h) {
    ArrayList<BlockState>[] column = (ArrayList<BlockState>[]) new ArrayList[h];
    float nx = (float)x / (float)w;
    float n0 = noise(nx, x < 0 ? 0.1 : 0);
    float n = n0 + (0.5 * noise(2 * nx, x < 0 ? 0.1 : 0));
    float e = pow(n, 2);
    int y = (int)map(e, 0, 3.0625, h * minTerrainHeight, h * maxTerrainHeight);
    int amtOfDirt = (int)map(n0, 0, 1, h * minTerrainHeight, h * maxTerrainHeight);
    for (int i = 0; i < h; i++) {
      String block;
      if (i < y)               block = "Air";     // Air layer
      else if (i == y)         block = topLayer;  // Top Grass layer
      else if (i <= amtOfDirt) block = "Dirt";    // Top Dirt layer
      else if (i == h - 1)     block = "Bedrock"; // Bottom Bedrock layer
      else                     block = "Stone";   // Otherwise, Stone layer
      ArrayList<BlockState> blocks = new ArrayList<BlockState>();
      Block b = gr.blocks.get(block);
      blocks.add(new BlockState(b, new PVector(x, i, 0), b.getDefaultState()));
      blocks.add(new BlockState(b, new PVector(x, i, 1), b.getDefaultState()));
      column[i] = blocks;
    }
    return column;
  }
  
  public void generateOres(ArrayList<BlockState>[][] chunk, int xOffset, int w, int h) {
    // Get a list of suitable ores, and calculate where the dice must roll to generate them
    ArrayList<OreSeam> ores = gr.ores.all();
    PickList<OreSeam> oreChooser = new PickList<OreSeam>();
    
    for (int i = ores.size() - 1; i >= 0; i--) {
      OreSeam ore = ores.get(i);
      boolean inWhitelist = false;
      for (String biome : ore.getBiomeWhitelist()) {
        if (biome.equals(name)) {
          inWhitelist = true;
          break;
        }
      }
      if (inWhitelist || ore.getBiomeWhitelist().length == 0) {
        boolean inDimWhitelist = false;
        for (String dim : ore.getDimensionWhitelist()) {
          if (dim.equals(terrainManager.getDimension().getName())) {
            inDimWhitelist = true;
            break;
          }
        }
        if (inDimWhitelist) {
          oreChooser.add(ore, ore.getRarity());
          continue;
        }
      }
    }
    
    // Generate each seam
    int amtOfSeams = (int)(random(0, 20) * oreRarity);
    
    for (int i = 0; i < amtOfSeams; i++) {
      // Choose an ore
      OreSeam ore = oreChooser.get();
      if (ore != null) generateOreSeam(chunk, w, ore);
    }
  }
  
  public void generateOreSeam(ArrayList<BlockState>[][] chunk, int w, OreSeam ore) {
    int amt = (int)(ore.getSize() * random(0, 10));
    int square = ceil((float)amt / 2);
    int currentAmt = square * square;
    String[][] seam = new String[square][square];
    for (int x = 0; x < square; x++) {
      for (int y = 0; y < square; y++) {
        seam[x][y] = ore.getBlock(); 
      }
    }
    while (currentAmt > amt) {
      seam[(int)random(0, square)][(int)random(0, square)] = "";
      currentAmt--;
    }
    int x1 = (int)random(0, w - square);
    int y1 = (int)random(ore.getMinYLevel(), ore.getMaxYLevel() - square);
    for (int x = x1; x < x1 + square; x++) {
      for (int y = y1; y < y1 + square; y++) {
        if (!seam[x - x1][y - y1].equals("")) {
          for (BlockState state : chunk[x][y]) {
            if (!state.isAir()) state.setBlock(gr.blocks.get(seam[x - x1][y - y1]), true); 
          }
        }
      }
    }
    
  }
  
  public void generateCaves(ArrayList<BlockState>[][] chunk, int xOffset, int w, int h) {
    int caveWidth = 16;
     int caveHeight = (int)random(70, 100);
     int steps = 3;
     int deathLimit = 3;
     int birthLimit = (int)random(5, 7);
     float startAlive = random(0.35, 0.45);
     
     boolean[][] caves = new boolean[caveHeight][caveWidth];
     
     for (int x = 0; x < caveWidth; x++) {
       for (int y = 0; y < caveHeight; y++) {
         caves[y][x] = random(0, 1) <= startAlive;
       }
     }
     
     for (int i = 0; i < steps; i++) {
       boolean[][] newCaves = new boolean[caveHeight][caveWidth];
       for (int x = 0; x < caveWidth; x++) {
         for (int y = 0; y < caveHeight; y++) {
           int neighbours = countEnabledNeighbours(x, y, caves);
           newCaves[y][x] = neighbours > birthLimit || caves[y][x];
           if (neighbours < deathLimit) newCaves[y][x] = false;
         }
       }
       caves = newCaves;
     }
     
     for (int x = 0; x < caveWidth; x++) {
       for (int y = 0; y < caveHeight; y++) {
         if (caves[y][x]) chunk[x][(h - caveHeight - 1) + y].get(1).setBlock(gr.blocks.get("Air"), true);
       }
     }
  }
  
  public void generateVegetation(ArrayList<BlockState>[][] chunk, int xOffset, int w, int h) {
    PickList<Vegetation> allVegetation = new PickList<Vegetation>();
    
    for (Vegetation vegetation : surfaceVegetation) {
      allVegetation.add(vegetation, vegetation.getRarity()); 
    }
    int amt = (int)(random(0, 15) * vegetationRarity);
    
    int[] treePlacements = new int[trees.length];
    
    for (int i = 0; i < amt; i++) {
      Vegetation vegetation = allVegetation.get();
      int x = (int)random(0, w);
      for (int y = 0; y < h; y++) {
        if (chunk[x][y].get(1).getBlock().getName().equals(topLayer)) {
          
          // Trees
          
          boolean placedTree = false;
          
          for (int j = 0; j < trees.length; j++) {
            Structure tree = trees[j];
            int left = x - floor(tree.getWidth() / 2);
            if (treePlacements[j] < tree.getMaxPerChunk() && left >= 0 && left + tree.getWidth() < w && y - tree.getHeight() >= 0) {
              int dice = (int)random(0, tree.getRarity() + 1);
              if (dice == 1) {
                treePlacements[j] += 1;
                tree.placeAt(left, y - tree.getHeight(), chunk);
                break;
              }
            }
          }
          
          if (placedTree) break;
          
          // Vegetation
          
          if (chunk[x][y - 1].get(0).getBlock().getName().equals("Air")) {
            int blocks = (int)random(1, vegetation.getMaxHeight());
            for (int j = 0; j < blocks; j++) {
              y = y - 1;
              chunk[x][y].get(0).setBlock(gr.blocks.get("Air"), true);
              chunk[x][y].get(1).setBlock(gr.blocks.get(vegetation.getBlock()), true);
            }
           
          }
          
          break;
          
        }
      }
    }
  }
  
  private int countEnabledNeighbours(int posX, int posY, boolean[][] grid) {
    int neighbours = 0;
    for (int y = posY - 1; y <= posY + 1; y++) {
      for (int x = posX - 1; x <= posX + 1; x++) {
        if (y < 0 || y >= grid.length || x < 0 || x >= grid[0].length || (!(x == posX && y == posY) && grid[y][x])) neighbours++; 
      }
    }
    return neighbours;
  }
  
}

public class OreSeam {
  
  private String block;
  private float rarity;
  private float size;
  private int minYLevel;
  private int maxYLevel;
  private String[] biomeWhitelist;
  private String[] dimensionWhitelist;
  
  public OreSeam(String block, float rarity, float size, int minYLevel, int maxYLevel, String[] biomeWhitelist, String[] dimensionWhitelist) {
    this.block = block;
    this.rarity = rarity;
    this.size = size;
    this.minYLevel = minYLevel;
    this.maxYLevel = maxYLevel;
    this.biomeWhitelist = biomeWhitelist;
    this.dimensionWhitelist = dimensionWhitelist;
  }
  
  public String getBlock() {
    return block;
  }
  
  public float getRarity() {
    return rarity; 
  }
  
  public float getSize() {
    return size;
  }
  
  public int getMinYLevel() {
    return minYLevel;
  }
  
  public int getMaxYLevel() {
    return maxYLevel;
  }
  
  public String[] getBiomeWhitelist() {
    return biomeWhitelist;
  }
  
  public String[] getDimensionWhitelist() {
    return dimensionWhitelist;
  }
  
}

public class PickList<T> {

  private ArrayList<Float> ranges = new ArrayList<Float>();
  private HashMap<Integer, T> items = new HashMap<Integer, T>();
  private float maxRoll;
  
  public void add(T item, Float rarity) {
    maxRoll += rarity;
    ranges.add(maxRoll);
    items.put(ranges.size() - 1, item);
  }
  
  public T get() {
     float roll = random(0, maxRoll);
     float current = 0;   
     for (int i = 0; i < ranges.size(); i++) {
       float range = ranges.get(i);
       if (roll >= current && roll <= range) return items.get(i);
       current = range;
     }
     return null;
  }
  
}

public class Vegetation {
  
  private String block;
  private float rarity;
  private int maxHeight;
  
  public Vegetation(String block, float rarity, int maxHeight) {
     this.block = block;
     this.rarity = rarity;
     this.maxHeight = maxHeight;
  }
  
  public String getBlock() {
    return block; 
  }
  
  public float getRarity() {
    return rarity; 
  }
  
  public int getMaxHeight() {
    return maxHeight;
  }
  
}

/**
* A dimension represents a world the player can visit. Each dimension has its own coordinate set, so that the chunk at
* X = 0 in one dimension may look different to X = 0 in another one. Dimensions are responsible for providing the
* Whittaker Diagram used to determine the biome for a specific chunk within them. Players can travel between dimensions
* using portals or other devices.
*/
public interface Dimension {
  
  /**
  * Get the name of this dimension. Used internally for comparision (e.g. ore whitelist, etc).
  * @returns The Dimension name.
  */
  public String getName();
  
  /**
  * A Whittaker Diagram shows the distribution of biomes on a 2d grid, with the X axis as Average Temperature,
  * and the Y axis as Annual Percipitation. We try to follow this model when choosing where to place biomes.
  * <p>For any given chunk, the TerrainManager will procedurally calculate the temperature and percipitation.
  * It will then use the Wittaker diagram produced by this function to map those values to a biome.</p>
  * <p>The Whittaker Diagram can be any shape of 2d-array, and may have gaps in it (represented by empty strings).
  * The only rule is that every row must specify at least one biome. If the temperature lands within one of the
  * gaps, it will be set to the closest biome on its row.</p>
  * <p>The strings represent biomes registered in the biome registry.</p>
  * @returns The Whittaker Diagram for this Dimension.
  * @see <a href="http://pcg.wikidot.com/pcg-algorithm:whittaker-diagram">Whittaker Diagram</a>
  */
  public String[][] getWhittakerDiagram();
  
}

public abstract class SuctionBox {
  
  public float[] rect;
  public ArrayList<Integer> chunk;
  
  public SuctionBox(float[] rect) {
    this(rect, null); 
  }
  
  public SuctionBox(float[] rect, ArrayList<Integer> chunk) {
    this.rect = rect;
    this.chunk = chunk;
  }
  
  public abstract boolean suck(ItemStack item);
  
}

public class Structure {
  
  private ArrayList<StructureBlockDefinition> def;
  private int w;
  private int rarity;
  private int maxPerChunk;
  
  public Structure(ArrayList<StructureBlockDefinition> def, int w, int rarity, int maxPerChunk) {
    this.def = def;
    this.w = w;
    this.rarity = rarity;
    this.maxPerChunk = maxPerChunk;
  }
  
  public void placeAt(int x, int y, ArrayList<BlockState>[][] chunk) {
    int leftX = x;
    int widthCount = 0;
    
    for (int i = 0; i < def.size(); i += 2) {
      ArrayList<BlockState> states = chunk[x][y];
      if (!def.get(i).block.getName().equals("Air"))     states.get(0).setBlock(def.get(i).block, def.get(i).state, true);
      if (!def.get(i + 1).block.getName().equals("Air")) states.get(1).setBlock(def.get(i + 1).block, def.get(i + 1).state, true);
      widthCount++;
      x++;
      if (widthCount >= w) {
        x = leftX;
        widthCount = 0;
        y++;
      }
    }
  }
  
  public int getRarity() {
    return rarity;
  }
  
  public int getMaxPerChunk() {
    return maxPerChunk;
  }
  
  public int getWidth() {
    return w;
  }
  
  public int getHeight() {
    return (def.size() / 2) / w; 
  }
  
}

public class StructureBlockDefinition {
  
  public Block block;
  public StateData state; 
 
  public StructureBlockDefinition(String name) {
    block = gr.blocks.get(name);
    state = block.getDefaultState();
  }
  
  public StructureBlockDefinition(String name, StateData state) {
    block = gr.blocks.get(name);
    this.state = state;
  }
  
}

/**
* Allows for the easy definition of a structure.
* <p>Define all of the squares you want to use in your structure in <code>defs</code>. A square should be made up of <strong>two</strong>
* entries: the background layer block, and the foreground layer block (in that order). Each entry can be either a string which is the
* registered name of the block (an empty string is short for Air), or a StructureBlockDefinition object if state is required.</p>
* <p>The map string defines the placement of the squares. From top to bottom, you write space-seperated numbers, where each number corresponds
* to the position of a square in the <code>defs</code> list. Note that these numbers begin at 1; as 0 is short for Air. At the end of each row,
* write a semi-colon ; to indicate that the next row is beginning. No semi-colon should appear on the last row. All rows must be of the same size.
* Here is an example:</p><code>
* <p>0 0 1 0 0;</p>
* <p>0 1 1 1 0;</p>
* <p>1 1 1 1 1</p></code>
* <p>Here are the corrisponding <code>defs</code> entries:</p>
* <p><code>"", "Gold Block"</code></p>
* <p>So overall, the call looks like:</p>
* <code>makeStructure("0 0 1 0 0;0 1 1 1 0;1 1 1 1 1", 10, 1, "", "Gold Block");</code>
* <p>And this would make a pyramid of gold blocks on the foreground layer, with air behind them on the background layer, appearing at most once per chunk
* with a 1/10 chance per roll.</p>
* @param map The description of where to place the squares.
* @param rarity How rare structure is. When a dice gets rolled for this structure, it has this many sides, and if it lands on 1 the structure is built.
* @param maxPerChunk Roll this many dice per chunk.
* @param defs The definitions of each square.
* @returns The resulting structure object.
*/
public Structure makeStructure(String map, int rarity, int maxPerChunk, Object... defs) {
  
  ArrayList<ArrayList<StructureBlockDefinition>> definitions = new ArrayList<ArrayList<StructureBlockDefinition>>();
  definitions.add(new ArrayList<StructureBlockDefinition>());
  definitions.get(0).add(STRUCT_AIR);
  definitions.get(0).add(STRUCT_AIR);
  
  for (int i = 0; i < defs.length; i += 2) {
    ArrayList<StructureBlockDefinition> definition = new ArrayList<StructureBlockDefinition>();
    for (int j = 0; j < 2; j++) {
      Object obj = defs[i + j];
      if (obj instanceof StructureBlockDefinition) definition.add((StructureBlockDefinition)obj);
      else if (obj instanceof String) {
        String str = (String)obj;
        if (str.equals("")) definition.add(STRUCT_AIR);
        else definition.add(new StructureBlockDefinition(str));
      }
      else definition.add(STRUCT_AIR);
    }
    definitions.add(definition);
  }

  String[] rows = map.split(";");
  
  ArrayList<StructureBlockDefinition> result = new ArrayList<StructureBlockDefinition>();
  int w = 0;
  for (int i = 0; i < rows.length; i++) {
    String[] row = rows[i].split(" ");
    w = row.length;
    for (int j = 0; j < row.length; j++) {
      ArrayList<StructureBlockDefinition> block = definitions.get(Integer.parseInt(row[j]));
      result.add(block.get(0));
      result.add(block.get(1));
    }
  }
  
  return new Structure(result, w, rarity, maxPerChunk);
  
}
