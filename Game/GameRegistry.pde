public class GameRegistry {
  
  public Registry<Biome>     biomes     = new Registry<Biome>("Biome");
  public Registry<Block>     blocks     = new Registry<Block>("Block");
  public Registry<Item>      items      = new Registry<Item>("Item");
  public Registry<Entity>    entities   = new Registry<Entity>("Entity");
  public Registry<PImage>    sprites    = new Registry<PImage>("Sprite");
  public Registry<OreSeam>   ores       = new Registry<OreSeam>("Ore");
  public Registry<Dimension> dimensions = new Registry<Dimension>("Dimension");
  public Registry<Structure> structures = new Registry<Structure>("Structure");
  
  public ArrayList<CraftingRecipe> crafting = new ArrayList<CraftingRecipe>();
  public ArrayList<SmeltingRecipe> smelting = new ArrayList<SmeltingRecipe>();
  
  public GameRegistry() {
    blocks.register("Missing Block", new Block("Missing Block", 0) {
      public void render(BlockState state, float leftX, float topY, int defaultSize) {
        noStroke();
        fill(255, 0, 255);
        rect(leftX, topY, defaultSize, defaultSize);
        fill(0);
        int halfSize = defaultSize / 2;
        rect(leftX, topY, halfSize, halfSize);
        rect(leftX + halfSize, topY + halfSize, halfSize, halfSize);
      }
      public ArrayList<ItemStack> getDroppedItems(BlockState state) { return getStacks(); }
    });
    biomes.register("Missing Biome", new BiomeSuperflat(new String[]{ "Air", "Missing Block", "Bedrock" }, new int[] { 32, 127, 128 }));
  }

  
  public static final int SPRITE_SIZE = 16;
  
  private int nextX;
  private int nextY;
  private PImage spritesheet;
  
  public void beginSmartRegistry(PImage spritesheet) {
    this.spritesheet = spritesheet;
    this.spritesheet.loadPixels();
    nextX = 0;
    nextY = 0;
  }
  
  public void sr(Object obj) {
    if (obj instanceof Block) {
      Block block = (Block)obj;
      blocks.register(block.getName(), block);
      sprites.register(block.getName(), sprite(nextX, nextY, spritesheet));
    }
    else if (obj instanceof Item) {
      Item item = (Item)obj;
      items.register(item.getName(), item);
      sprites.register(item.getName(), sprite(nextX, nextY, spritesheet));
    }
    else if (obj instanceof String) {
       sprites.register((String) obj, sprite(nextX, nextY, spritesheet));
    }
    else {
      throw new Error("GameRegistry: Can only smart-register blocks, items and sprites!"); 
    }
    nextX++;
    if (nextX * SPRITE_SIZE >= spritesheet.width) {
      nextX = 0;
      nextY++;
    }
  }
  
  public void srSkip(int amt) {
    for (int i = 0; i < amt; i++) { 
      nextX++;
      if (nextX * SPRITE_SIZE > spritesheet.width) {
        nextX = 0;
        nextY++;
      }
    }
  }
  
  public void cr(ItemStack result, String placement, int w, int h, ItemStack... items) { crafting.add(new ShapedRecipe(result, placement, w, h, items)); }
  public void cr(ItemStack result, ItemStack... items) { crafting.add(new ShapelessRecipe(result, items)); }
  public void cr(CraftingRecipe recipe) { crafting.add(recipe); }
  public void sm(ItemStack output, ItemStack input) { smelting.add(new SmeltingRecipe(input, output)); }
  public void sm(SmeltingRecipe recipe) { smelting.add(recipe); }
  
}

public class Registry<T> {
  
  private ArrayList<T> objList = new ArrayList<T>();
  private HashMap<String, Integer> nameLookup = new HashMap<String, Integer>();
  private String name;
  
  public Registry(String name) {
    this.name = name;
  }
  
  public void register(String name, T obj) {
    objList.add(obj);
    nameLookup.put(name, objList.size() - 1);
  }
  
  public T get(int i) {
    return objList.get(i);
  }
  
  public T get(String name) {
    try {
      return objList.get(nameLookup.get(name)); 
    } catch (Exception e) {
      if      (this.name.equals("Block")) return this.get("Missing Block");
      else if (this.name.equals("Biome")) { println(name); return this.get("Missing Biome"); }
      
      throw new Error("GameRegistry: \"" + name + "\" has not been registered in the \"" + this.name + "\" Registry.");
    }    
  }
  
  public ArrayList<T> all() {
    return objList; 
  }
  
}

public PImage sprite(int x, int y, PImage spritesheet) {
  int size = GameRegistry.SPRITE_SIZE;
  return spritesheet.get(x * size, y * size, size, size);
}

public interface CraftingRecipe {
  
  /**
  * Gets the smallest possible table size required to complete this recipe.
  * @returns The smallest table size.
  */
  public int getMinTableSize();
  
  /**
  * Called on every recipe every time the crafting table changes. Gets an ItemStack for the current
  * contents.
  * @param table The crafting table container.
  * @returns The item created from the table contents (if any).
  */
  public ItemStack getFromTable(Container table);
  
  /**
  * Called if the recipe succeeds. Should decrease the count of everything in the table.
  * @param table The crafting table container.
  */
  public void crafted(Container table);
  
}

/**
* A shaped recipe requires that the contents of the table match a specific shape.
*/
public class ShapedRecipe implements CraftingRecipe {
  
  private ItemStack result;
  private ArrayList<ItemStack> recipe;
  private int w;
  private int h;
  
  public ShapedRecipe(ItemStack result, String placement, int w, int h, ItemStack... items) {
    this.result = result;
    this.w = w;
    this.h = h;
    
    recipe = new ArrayList<ItemStack>();
    for (int i = 0; i < w * h; i++) {
      char token = placement.charAt(i);
      if (token == ' ') recipe.add(getEmptyIS());
      else recipe.add(items[Integer.parseInt(String.valueOf(token)) - 1]);
    }
    
  }
  
  public int getMinTableSize() {
    return max(w, h);
  }
  
  public ItemStack getFromTable(Container table) {
    ArrayList<ItemStack> tableItems = new ArrayList<ItemStack>();
    for (int i = 0; i < table.getSize(); i++) {
      tableItems.add(table.getAtSlot(i));
    }
    
    int size = (int)sqrt(table.getSize());
    int tW = size;
    int tH = size;
    
    // Resize the table to have w columns
    while (tW > w) {
      // See which column is empty
      boolean left = true;
      boolean right = true;
      for (int i = 0; i < tableItems.size(); i++) {
        int x = i % tW;
        if (x == 0 && !tableItems.get(i).isEmpty()) left = false;
        if (x == tW - 1 && !tableItems.get(i).isEmpty()) right = false;
      }
      // If neither is empty, then can't match size = no match
      if (!left && !right) return getEmptyIS();
      // Remove all items in one of the columns, resizing the table down by 1
      for (int i = tableItems.size() - 1; i >= 0; i--) {
        int x = i % tW;
        if ((right && x == tW - 1) || (!right && x == 0)) tableItems.remove(i);
      }
      // The table is 1 less column wide
      tW--;
    }
    
    // Resize the table to have h rows
    while (tH > h) {
      // See which row is empty
      boolean top = true;
      boolean bottom = true;
      for (int i = 0; i < tableItems.size(); i++) {
        int y = i / tW;
        if (y == 0 && !tableItems.get(i).isEmpty()) top = false;
        if (y == tH - 1 && !tableItems.get(i).isEmpty()) bottom = false;
      }
      // If neither is empty, then can't match size = no match
      if (!top && !bottom) return getEmptyIS();
      // Remove all items in one of the rows, resizing the table down by 1
      for (int i = tableItems.size() - 1; i >= 0; i--) {
        int y = i / tW;
        if ((bottom && y == tH - 1) || (!bottom && y == 0)) tableItems.remove(i);
      }
      // The table is 1 less row wide
      tH--;
    }
    
    // Check if every item in the resized table matches
    for (int i = 0; i < tableItems.size(); i++) {
      ItemStack a = recipe.get(i);
      ItemStack b = tableItems.get(i);
      if (!a.fuzzyMatch(b)) return getEmptyIS(); 
    }
    
    // Table matches fully
    
    return result;
    
  }
  
  public void crafted(Container table) {
    for (int i = 0; i < table.getSize(); i++) {
      ItemStack stack = table.getAtSlot(i);
      if (!stack.isEmpty()) stack.addStackSize(-1);
    }
  }
  
}

public class ShapelessRecipe implements CraftingRecipe {
  
  ItemStack result;
  ItemStack[] recipe;
 
  public ShapelessRecipe(ItemStack result, ItemStack... recipe) {
    this.result = result;
    this.recipe = recipe;    
  }
  
  public int getMinTableSize() {
    return ceil(sqrt(recipe.length));
  }
  
  public ItemStack getFromTable(Container table) {
    ArrayList<ItemStack> testRecipe = new ArrayList<ItemStack>();
    for (ItemStack stack : recipe) {
      testRecipe.add(stack); 
    }
    for (int i = 0; i < table.getSize(); i++) {
      ItemStack item = table.getAtSlot(i);
      if (item.isEmpty()) continue;
      boolean done = false;
      for (ItemStack stack : testRecipe) {
        if (stack.fuzzyMatch(item)) {
          testRecipe.remove(stack);
          done = true;
          break;
        }
      }
     if (!done) return getEmptyIS();
    }
    return testRecipe.size() == 0 ? new ItemStack(result) : getEmptyIS();
  }
  
  public void crafted(Container table) {
    for (int i = 0; i < table.getSize(); i++) {
      ItemStack stack = table.getAtSlot(i);
      if (!stack.isEmpty()) stack.addStackSize(-1);
    }
  }
  
}

public class SmeltingRecipe {
  
  private ItemStack input;
  private ItemStack output;
 
  public SmeltingRecipe(ItemStack input, ItemStack output) {
    this.input = input;
    this.output = output;
  }
  
  public ItemStack getOutput() {
    return output;
  }
  
  public boolean accepts(ItemStack other) {
    return input.fuzzyMatch(other);
  }
  
  public void smelted() {}
  
}
