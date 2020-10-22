/**
* All of the default content -- all the blocks, items, entities, biomes, dimensions, etc in the main game are defined here.
* @author Orlando
*/
public class BaseGame implements Mod {
  
  public BaseGame() { }
  
  public void preInit() {
    
    PImage spritesheet = loadImage("sprites.png");
    gr.beginSmartRegistry(spritesheet);
    
    gr.worldData.register("nextQuantumId", new StateData("nextQuantumId", 0));
    
    // 0: None
    // 1: Wood / Gold
    // 2: Stone
    // 3: Iron
    // 4: Diamond
    
    // Blocks
    gr.sr(new Block("Dirt", 1, 0, "Shovel", false));
    gr.sr(new BlockGrass("Grass", 1000));
    gr.sr(new Block("Stone", 2, 1, "Pickaxe", true) {
      public ArrayList<ItemStack> getDroppedItems(BlockState state) { return getStacks(getBlockIS("Cobblestone")); } 
    });
    gr.sr(new Block("Bedrock", -1));
    gr.sr(new Block("Coal Ore", 2, 1, "Pickaxe", true) {
       public ArrayList<ItemStack> getDroppedItems(BlockState state) { return getStacks(getIS("Coal")); }
    });
    gr.sr(new Block("Iron Ore", 2, 2, "Pickaxe", true));
    gr.sr(new Block("Gold Ore", 1.5, 2, "Pickaxe", true));
    gr.sr(new Block("Redstone Ore", 1, 2, "Pickaxe", true) {
       public ArrayList<ItemStack> getDroppedItems(BlockState state) { return getStacks(getBlockIS("Redstone")); }
    });
    gr.sr(new Block("Diamond Ore", 2, 2, "Pickaxe", true) {
       public ArrayList<ItemStack> getDroppedItems(BlockState state) { return getStacks(getIS("Diamond")); }
    });
    gr.sr(new Block("Lapis Ore", 1, 2, "Pickaxe", true));
    gr.sr(new Block("Emerald Ore", 1, 2, "Pickaxe", true));
    gr.sr(new Block("Sandstone", 2, 0, "Pickaxe", false));
    gr.sr(new BlockSemiSolid("Rose"));
    gr.sr(new BlockSemiSolid("Dandelion"));
    gr.sr(new BlockSemiSolid("Tall Grass", true, true));
    gr.sr(new BlockSemiSolid("Dead Bush", true, true));
    gr.sr(new Block("Cactus", 2, 0, "Axe", false));
    gr.sr(new Block("Slime", 0.5) {
      public PhysicsMaterial getPhysicsMaterial(BlockState state) { return new PhysicsMaterial(0, -0.95, 1); } // Make slime bouncy
    });
    gr.sr(new Block("Ice", 0.5) {
      public PhysicsMaterial getPhysicsMaterial(BlockState state) { return new PhysicsMaterial(0.96, 0, 0.9); } // Make ice slippery
    });
    gr.sr(new Block("Path", 1, 0, "Shovel", false) {
      public PhysicsMaterial getPhysicsMaterial(BlockState state) { return new PhysicsMaterial(0, 0, 2); } // Make paths faster
    });
    gr.sr(new Block("Soul Sand", 1, 0, "Shovel", false) {
      public PhysicsMaterial getPhysicsMaterial(BlockState state) { return new PhysicsMaterial(0, 0, 0.5); } // Make soul sand slower
    });
    gr.sr("Crack 1");
    gr.sr("Crack 2");
    gr.sr("Crack 3");
    gr.sr("Crack 4");
    gr.sr("Crack 5");
    gr.sr("Crack 6");
    gr.sr("Crack 7");
    gr.sr(new BlockLog("Oak Wood Log"));
    gr.sr(new Block("Oak Wood Leaves", 1.5) {
      public String getThesaurusName(BlockState state) { return "Leaves"; }
      public ArrayList<ItemStack> getDroppedItems(BlockState state) { return random(0, 10) < 1 ? getStacks(getBlockIS("Sapling")) : getStacks(); }
    });
    gr.sr(new Block("Oak Wood Planks", 1, 0, "Axe", false) {
      public String getThesaurusName(BlockState state) { return "Planks"; } 
    });
    gr.sr(new Block("Cobblestone", 2, 1, "Pickaxe", true));
    gr.sr(new Block("Stone Bricks", 2, 1, "Pickaxe", true));
    gr.sr(new Block("Sandstone Bricks", 2, 1, "Pickaxe", true));
    gr.sr(new Block("Bricks", 2, 1, "Pickaxe", true));
    gr.sr(new Block("Clay", 1, 0, "Shovel", false));
    gr.sr(new BlockFalling("Gravel", 1, 0, "Shovel", false) {
       public ArrayList<ItemStack> getDroppedItems(BlockState state) { return getStacks(random(1) > 0.75 ? getIS("Flint") : getBlockIS("Gravel")); } // 1/4 chance to drop flint
    });
    gr.sr(new BlockFalling("Sand", 1, 0, "Shovel", false));
    gr.sr(new Block("Obsidian", 15, 4, "Pickaxe", true));
    gr.sr(new Block("Bookshelf", 1, 0, "Axe", false));
    gr.sr(new BlockCraftingTable());
    gr.sr(new BlockFurnace("Furnace", 2, 1, "Pickaxe", true, 100, 1));
    gr.sr("Furnace Lit");
    gr.sr(new BlockChest());
    gr.sr("Double Chest Left");
    gr.sr("Double Chest Right");
    gr.sr("Chest Open");
    gr.sr("Double Chest Left Open");
    gr.sr("Double Chest Right Open");
    gr.sr(new Block("Netherrack", 0.2, 0, "Pickaxe", false));
    gr.sr(new Block("Nether Bricks", 2, 1, "Pickaxe", true));
    gr.sr(new Block("Nether Quartz Ore", 0.8, 1, "Pickaxe", true));
    gr.sr(new Block("Coal Block", 1.2, 0, "Pickaxe", false) {
      public int getBurnTime(BlockState state) { return 7200; } 
    });
    gr.sr(new Block("Iron Block", 1.2, 0, "Pickaxe", false));
    gr.sr(new Block("Gold Block", 0.6, 0, "Pickaxe", false));
    gr.sr(new Block("Redstone Block", 1.2, 0, "Pickaxe", false));
    gr.sr(new Block("Diamond Block", 1.2, 0, "Pickaxe", false));
    gr.sr(new Block("Lapis Block", 1.2, 0, "Pickaxe", false));
    gr.sr(new Block("Emerald Block", 1.2, 0, "Pickaxe", false));
    gr.sr(new BlockItemFrame());
    gr.sr(new BlockSemiSolid("Torch") {
      public Light getLight(BlockState state) { return new Light(16); }
    });
     gr.sr(new Block("Glowstone", 0.2) {
      public Light getLight(BlockState state) { return new Light(16); }
      public boolean doesBlockLight(BlockState state) { return false; }
    });
    gr.sr(new Block("Enchantment Table", 5, 4, "Pickaxe", true) {
      public boolean isOpaque(BlockState state) { return false; } 
    });
    gr.sr(new Block("Glass", 0.5) {
      public ArrayList<ItemStack> getDroppedItems(BlockState state) { return getStacks(); }
      public boolean doesBlockLight(BlockState state) { return false; }
      public boolean isOpaque(BlockState state) { return false; }
    });
    gr.sr(new Block("TNT", 1){
      public boolean onInteract(BlockState state, boolean shift) {
        if (!shift) {
          state.setBlock(gr.blocks.get("Air"));
          terrainManager.spawnEntity(
          new EntityTNT(
            new PVector(state.pos.x * BlockState.BLOCK_SIZE, state.pos.y * BlockState.BLOCK_SIZE),
            terrainManager.getDimension().getName()
          )
        );
          return true;
        }
        return false;
      }
      public void onCreate(BlockState state, boolean isLoad) { clearInput(); }
      public int getRequiredSortLayer() { return 1; }
    });
    gr.sr(new Block("Brewing Stand", 0.5) {
      public boolean isOpaque(BlockState state) { return false; }
    });
    gr.sr(new Block("Cauldron", 2, 0, "Pickaxe", false) {
      public boolean isOpaque(BlockState state) { return false; }
    });
    gr.sr(new Block("Wool", 2));
    gr.sr(new BlockSemiSolid("Sapling"){
      public int getRequiredSortLayer() { return 1; }
      /*public int getTickChance(BlockState state) { return 120; }
      public void onTick(BlockState state) { 
        gr.structures.get("Oak Tree").placeAt((int)state.getPosition().x - 2, (int)state.getPosition().y - 5, terrainManager.getChunkAt((int)state.getPosition().x));
        state.setBlock(gr.blocks.get("Air"));
      }*/
    });
    gr.sr(new Block("Magma", 0.2, 0, "Pickaxe", false));
    gr.sr("Quantum Ore Shadow");
    gr.sr("Quantum Ore Mask");
    gr.sr(new Block("Quantum Ore", 0.8, 1, "Pickaxe", true){
      public void render(BlockState state, float leftX, float topY, int defaultSize) {
        super.render(state, leftX, topY, defaultSize);
        tint(random(255), random(255), random(255));
        image(gr.sprites.get("Quantum Ore Mask"), leftX, topY, defaultSize, defaultSize);
        noTint();
        image(gr.sprites.get("Quantum Ore Shadow"), leftX, topY, defaultSize, defaultSize);
      }
      public ArrayList<ItemStack> getDroppedItems(BlockState state) {
        int id = (int)terrainManager.worldData.get("nextQuantumId");
        terrainManager.worldData.set("nextQuantumId", id + 1); // Increment the ID in the global world data
        return getStacks(getIS("Quantum Shard", 2, new StateData("id", id, "r", int(random(255)), "g", int(random(255)), "b", int(random(255))))); // Drop 2 shards, coloured the same, with the same ID
      }
    });
    gr.sr(new BlockTransparentSpecial("Diamond Rod", 2, 1, "Pickaxe", true){
      public String[] getTooltip(BlockState state) { return new String[]{"Breaks blocks when pushed into them by a piston."}; }
      public color getTooltipColour(BlockState state) { return color(0, 255, 255); }
      public boolean placeBlockDirectionally() { return true; }
    });
    gr.sr(new BlockTransparentSpecial("Electromagnet", 2, 1, "Pickaxe", true));
    gr.sr(new BlockTransparentSpecial("World Anchor", 2, 1, "Pickaxe", true){
      public String[] getTooltip(BlockState state) { return new String[]{"Ensures its surrounding chunk remains loaded."}; }
      public color getTooltipColour(BlockState state) { return color(0, 255, 255); }
    });
    gr.sr(new Block("Portal", 0));
    gr.sr(new Animation("Fire", 16, 3));
    gr.sr(new BlockQuantumChest());
    gr.sr("Quantum Chest Open");
    gr.sr("Quantum Chest Core");
    gr.sr(new BlockRedstoneWire());
    gr.sr("Redstone West");
    gr.sr("Redstone East");
    gr.sr("Redstone North");
    gr.sr("Redstone South");
    gr.sr("Redstone On");
    gr.sr("Redstone On West");
    gr.sr("Redstone On East");
    gr.sr("Redstone On North");
    gr.sr("Redstone On South");
    gr.sr(new BlockTransparentSpecial("Lever", 1, 0, "Pickaxe", false){
      public StateData getDefaultState() { return new StateData("on", false); }
      public boolean canConnectRedstone(BlockState state, Direction side) { return true; }
      public boolean itemHasBlockRender() { return false; }
      public String getTexture(BlockState state) { return ((boolean)state.getState().get("on")) ? "Lever On" : "Lever"; } // Flip the lever visually when it's on
      public int getRedstoneOutput(BlockState state, Direction side) { return ((boolean)state.getState().get("on")) ? 16 : 0; } // Output a signal when on
      public boolean onInteract(BlockState state, boolean shift) {
        if (shift || !firstClickFrame) return false;
        state.getState().set("on", !((boolean)state.getState().get("on")));
        state.markDirty();
        return true;
      }
    });
    gr.sr("Lever On");
    gr.sr(new BlockRedstoneInput("Redstone Lamp", 1, 0, "Pickaxe", false){
      public Light getLight(BlockState state) {
        return getInputOnSide(state, Direction.ALL) > 0 ? new Light(16) : null;
      } 
      public String getTexture(BlockState state) { return getInputOnSide(state, Direction.ALL) > 0 ? "Redstone Lamp On" : "Redstone Lamp"; } // Light up texture when recieving a signal
      public boolean canConnectRedstone(BlockState state, Direction side) { return true; }
      public boolean doesBlockLight(BlockState state) { return false; }
      public int getRequiredSortLayer() { return 1; }
    });
    gr.sr("Redstone Lamp On");
    gr.sr(new BlockPiston(false)); // Normal
    gr.sr(new BlockPiston(true)); // Sticky
    gr.sr("Piston Base");
    gr.sr(new Block("Piston Arm", 2, 1, "Pickaxe", true){
      public boolean canShowInCreative() { return false; }
    });
    gr.sr(new Block("Sticky Piston Arm", 2, 1, "Pickaxe", true){
      public boolean canShowInCreative() { return false; }
    });
    gr.sr(new Block("Not Gate", 2, 1, "Pickaxe", true));
    gr.sr("Not Gate Indicator");
    gr.sr("Not Gate Symbol");
    gr.sr(new Block("Redstone Clock", 2, 1, "Pickaxe", true){
       public boolean canConnectRedstone(BlockState state, Direction side) { return true; }
       public int getRequiredSortLayer() { return 1; }
       public boolean itemHasBlockRender() { return false; }
       public void render(BlockState state, float leftX, float topY, int defaultSize) {
         super.render(state, leftX, topY, defaultSize);
         int pos = frameCount % 100;
         if (pos < 80) {
           if (pos >= 0)  image(gr.sprites.get("Redstone Clock Dot"), leftX,      topY, defaultSize, defaultSize); // First dot
           if (pos >= 20) image(gr.sprites.get("Redstone Clock Dot"), leftX + 16, topY, defaultSize, defaultSize); // Second dot
           if (pos >= 40) image(gr.sprites.get("Redstone Clock Dot"), leftX + 32, topY, defaultSize, defaultSize); // Third dot
         }
       }
       // Between 0 and 60: count. Between 60 and 80: on. Between 80 and 100: off.
       public int getRedstoneOutput(BlockState state, Direction side) { return frameCount % 100 >= 60 && frameCount % 100 < 80 ? 16 : 0; } 
    });
    gr.sr("Redstone Clock Dot");
    gr.sr(new BlockHopper());
    gr.sr("Waypoint Totem Core");
    
    // Blocks with no associated sprite at the current smart registry pointer
    
    gr.blocks.register("Fire", new BlockSemiSolid("Fire", true, true){
       public Light getLight(BlockState state) { return new Light(16); }
       public void render(BlockState state, float leftX, float topY, int defaultSize) {
         gr.animations.get("Fire").render(leftX, topY, defaultSize);
       }
    });
    
    gr.blocks.register("Waypoint Totem", new BlockTransparentSpecial("Waypoint Totem", 1, 1, "Axe", false){
      public String getTexture(BlockState state) { return "Inert Totem"; } 
    });
    
    gr.srSkip(6);
    
    // Items
    gr.sr(new ItemTool("Wooden Pickaxe", 32, "Pickaxe", 1, 0.5));
    gr.sr(new ItemTool("Stone Pickaxe", 64, "Pickaxe", 2, 1));
    gr.sr(new ItemTool("Iron Pickaxe", 512, "Pickaxe", 3, 1.5));
    gr.sr(new ItemTool("Gold Pickaxe", 32, "Pickaxe", 1, 4){
      public boolean hasEnchantmentEffect(ItemStack stack) { return true; }
    });
    gr.sr(new ItemTool("Diamond Pickaxe", 1024, "Pickaxe", 4, 2));
    gr.sr("Enchantment Glint");
    gr.sr(new Item("Stick"));
    gr.sr(new Item("Coal") {
      public int getBurnTime(ItemStack stack) { return 800; } 
    });
    gr.sr(new Item("Iron Ingot"));
    gr.sr(new Item("Gold Ingot"));
    gr.sr(new Item("Iron Dust"));
    gr.sr("Redstone Dust");
    gr.sr(new Item("Gold Dust"));
    gr.sr(new Item("Sugar"));
    gr.sr(new Item("Brick"));
    gr.sr(new Item("Nether Brick"));
    gr.sr(new Item("Diamond"));
    gr.sr(new ItemTool("Wooden Shovel", 32, "Shovel", 1, 0.5));
    gr.sr(new ItemTool("Stone Shovel", 64, "Shovel", 2, 1));
    gr.sr(new ItemTool("Iron Shovel", 512, "Shovel", 3, 1.5));
    gr.sr(new ItemTool("Gold Shovel", 32, "Shovel", 1, 4){
      public boolean hasEnchantmentEffect(ItemStack stack) { return true; }
    });
    gr.sr(new ItemTool("Diamond Shovel", 1024, "Shovel", 4, 2));
    gr.sr(new Item("Flint"));
    gr.sr(new ItemDurable("Flint and Steel", 10){
       public void onUse(ItemStack stack, Object target) {
         if (target instanceof ArrayList<?>) {
           BlockState pos = (BlockState)(((ArrayList)target).get(1));
           // If the block is overridable or air, it can be replaced by a fire block
           if (pos.isAir() || pos.getBlock().isOverridable(pos)) {
             // Check if nether portal
             
             
             // Otherwise, make a fire
             
             pos.setBlock(gr.blocks.get("Fire"));
             this.damageItem(stack, 1);
           }
         }
       }
    });
    gr.sr(new Item("Quantum Shard"){
      // Store the pairing + colour in state data
      public StateData getDefaultState() { return new StateData("id", -1, "r", 0, "g", 0, "b", 0); }
      public boolean canShowInCreative() { return false; }
      public PImage render(ItemStack stack, float leftX, float topY, int defaultSize) {
        tint((int)stack.getState().get("r"), (int)stack.getState().get("g"), (int)stack.getState().get("b"));
        super.render(stack, leftX, topY, defaultSize);
        noTint();
        return null; 
      }
      public String[] getTooltip(ItemStack stack) { return new String[]{"ID: " + ((int)stack.getState().get("id"))}; }
      public color getTooltipColour(ItemStack stack) { return color((int)stack.getState().get("r"), (int)stack.getState().get("g"), (int)stack.getState().get("b")); }
    });
    gr.sr(new Item("Inert Totem"));
    gr.sr(new Item("Slime Ball"));
    
    // Entities
    gr.entities.register("TNT", new EntityTNT());
    
    // Crafting
    gr.cr(getBlockIS("Torch", 4), "12", 1, 2, getIS("Coal"), getIS("Stick"));
    gr.cr(getBlockIS("Stone Bricks", 4), "1111", 2, 2, getBlockIS("Stone"));
    gr.cr(getIS("Stick", 4), "11", 1, 2, getFuzzyIS("Planks"));
    gr.cr(getBlockIS("Crafting Table"), "1111", 2, 2, getFuzzyIS("Planks"));
    gr.cr(getBlockIS("Oak Wood Planks", 4), getBlockIS("Oak Wood Log"));
    gr.cr(getBlockIS("Chest"), "1111 1111", 3, 3, getFuzzyIS("Planks"));
    gr.cr(getBlockIS("Furnace"), "1111 1111", 3, 3, getBlockIS("Cobblestone"));
    gr.cr(getBlockIS("Coal Block"), "111111111", 3, 3, getIS("Coal"));
    gr.cr(getBlockIS("Iron Block"), "111111111", 3, 3, getIS("Iron Ingot"));
    gr.cr(getBlockIS("Redstone Block"), "111111111", 3, 3, getBlockIS("Redstone Dust"));
    gr.cr(getBlockIS("Gold Block"), "111111111", 3, 3, getBlockIS("Gold Ingot"));
    gr.cr(getBlockIS("Diamond Block"), "111111111", 3, 3, getBlockIS("Diamond"));
    gr.cr(getIS("Wooden Pickaxe"), "111 2  2 ", 3, 3, getFuzzyIS("Planks"), getIS("Stick"));
    gr.cr(getIS("Stone Pickaxe"), "111 2  2 ", 3, 3, getFuzzyIS("Cobblestone"), getIS("Stick"));
    gr.cr(getIS("Iron Pickaxe"), "111 2  2 ", 3, 3, getIS("Iron Ingot"), getIS("Stick"));
    gr.cr(getIS("Gold Pickaxe"), "111 2  2 ", 3, 3, getIS("Gold Ingot"), getIS("Stick"));
    gr.cr(getIS("Diamond Pickaxe"), "111 2  2 ", 3, 3, getIS("Diamond"), getIS("Stick"));
    gr.cr(getIS("Wooden Shovel"), "122", 1, 3, getFuzzyIS("Planks"), getIS("Stick"));
    gr.cr(getIS("Stone Shovel"), "122", 1, 3, getFuzzyIS("Coblestone"), getIS("Stick"));
    gr.cr(getIS("Iron Shovel"), "122", 1, 3, getIS("Iron Ingot"), getIS("Stick"));
    gr.cr(getIS("Gold Shovel"), "122", 1, 3, getIS("Gold Ingot"), getIS("Stick"));
    gr.cr(getIS("Diamond Shovel"), "122 ", 1, 3, getIS("Diamond"), getIS("Stick"));
    gr.cr(getBlockIS("Lever"), "12", 1, 2, getIS("Stick"), getBlockIS("Cobblestone"));
    gr.cr(getBlockIS("Electromagnet"), " 1 121 1 ", 3, 3, getBlockIS("Redstone"), getIS("Iron Ingot"));
    gr.cr(getBlockIS("Diamond Rod"), "122", 1, 3, getIS("Diamond"), getIS("Iron Ingot"));
    gr.cr(getBlockIS("World Anchor"), " 1  1 111", 3, 3, getIS("Iron Ingot"));
    gr.cr(getBlockIS("Hopper"), "121111 1 ", 3, 3, getIS("Iron Ingot"), getBlockIS("Chest"));
    gr.cr(getBlockIS("Redstone Lamp"), "111121131", 3, 3, getBlockIS("Cobblestone"), getBlockIS("Torch"), getBlockIS("Redstone"));
    gr.cr(getBlockIS("Redstone Clock"), "111222111", 3, 3, getBlockIS("Cobblestone"), getBlockIS("Redstone"));
    gr.cr(getBlockIS("Not Gate"), "111232111", 3, 3, getBlockIS("Cobblestone"), getBlockIS("Redstone"), getIS("Flint"));
    gr.cr(getBlockIS("Piston"), "111232444", 3, 3, getFuzzyIS("Planks"), getBlockIS("Cobblestone"), getIS("Iron Ingot"), getBlockIS("Redstone"));
    gr.cr(getBlockIS("Inert Totem"), "111 1 111", 3, 3, getFuzzyIS("Planks"));
    
    // Shapeless Crafting / Custom Crafting
    
    gr.cr(new ShapelessRecipe(getIS("Flint and Steel"), getIS("Flint"), getIS("Iron Ingot")));
    gr.cr(new CustomRecipe(){
      public int getMinTableSize() { return 2; }
      
      public ItemStack getFromItems(ArrayList<ItemStack> items) {
        if (items.size() != 2) return null;
        
        boolean foundChest = false;
        StateData quantumState = null;
        
        for (ItemStack item : items) {
          if       (item.fuzzyMatch(getBlockIS("Chest"))             && !foundChest)          foundChest = true;
          else if  (item.getItem().getName().equals("Quantum Shard") && quantumState == null) quantumState = item.getState();
          else     return null;
        }
        
        return getBlockIS("Quantum Chest", 1, quantumState);
      }
    });
    gr.cr(new ShapelessRecipe(getBlockIS("Sticky Piston"), getBlockIS("Piston"), getIS("Slime Ball")));
    
    //Smelting
    gr.sm(getIS("Iron Ingot"), getBlockIS("Iron Ore"));
    gr.sm(getBlockIS("Stone"), getBlockIS("Cobblestone"));
    gr.sm(getBlockIS("Glass"), getBlockIS("Sand"));
    
    // Ores
    gr.ores.register("Coal",     new OreSeam("Coal Ore",     1.25, 1.5,  45,  TerrainManager.H, new String[]{},          new String[]{ "Overworld" }));
    gr.ores.register("Iron",     new OreSeam("Iron Ore",     0.75, 1,    65,  TerrainManager.H, new String[]{},          new String[]{ "Overworld" }));
    gr.ores.register("Gold",     new OreSeam("Gold Ore",     0.45, 0.75, 95,  TerrainManager.H, new String[]{},          new String[]{ "Overworld" }));
    gr.ores.register("Redstone", new OreSeam("Redstone Ore", 0.45, 0.65, 115, TerrainManager.H, new String[]{},          new String[]{ "Overworld" }));
    gr.ores.register("Diamond",  new OreSeam("Diamond Ore",  0.06, 0.5,  122, TerrainManager.H, new String[]{},          new String[]{ "Overworld" }));
    gr.ores.register("Lapis",    new OreSeam("Lapis Ore",    0.35, 1,    105, TerrainManager.H, new String[]{},          new String[]{ "Overworld" }));
    gr.ores.register("Emerald",  new OreSeam("Emerald Ore",  0.05, 0.25, 115, TerrainManager.H, new String[]{ "Hills" }, new String[]{ "Overworld" }));
    
    gr.ores.register("Magma",    new OreSeam("Magma",        1.25, 1.5,  0,   TerrainManager.H, new String[]{ "Hell" },  new String[]{ "Nether" }));
    
    // Dimensions
    gr.dimensions.register("Overworld", new DimensionOverworld());
    gr.dimensions.register("Nether", new DimensionNether());
    
    // Structures
    gr.structures.register("Oak Tree", makeStructure(
      "0 0 1 0 0;" +
      "0 1 1 1 0;" +
      "1 1 2 1 1;" +
      "0 1 2 1 0;" +
      "0 0 2 0 0;" +
      "0 0 2 0 0",
      5, 3,
      "Oak Wood Leaves", "", new StructureBlockDefinition("Oak Wood Log", new StateData("AllowFell", true)), "" 
    ));
    
    gr.structures.register("Broken Portal One", makeStructure(
      "1 0 0 0;" +
      "1 0 0 0;" +
      "1 0 0 0;" +
      "1 1 0 0",
      5, 1,
      "Obsidian", ""
    ));
    
    gr.structures.register("Broken Portal Two", makeStructure(
      "0 0 1 1;" +
      "0 0 0 1;" +
      "0 0 0 1;" +
      "0 1 0 1",
      5, 1,
      "Obsidian", ""
    ));
    
    // Biomes
    Vegetation[] typicalVegetation = new Vegetation[]{
      new Vegetation("Rose", 1, 1),
      new Vegetation("Dandelion", 1, 1),
      new Vegetation("Tall Grass", 2, 1)
    };
    gr.biomes.register("Hills",          new BiomeBasic("Hills",  0.25, 0.75, "Grass", 2, typicalVegetation, 0.4, new Structure[0]));
    gr.biomes.register("Plains",         new BiomeBasic("Plains", 0.25, 0.35, "Grass", 1, typicalVegetation, 1, new Structure[]{ gr.structures.get("Oak Tree") }));
    gr.biomes.register("Redstone Ready", new BiomeSuperflat(new String[]{ "Air", "Sandstone", "Bedrock" }, new int[] { 32, 127, 128 }));
    gr.biomes.register("Hell",           new BiomeBasic("Hell",  0.25, 0.75, "Netherrack", 2, typicalVegetation, 0.4, new Structure[]{ gr.structures.get("Broken Portal One"), gr.structures.get("Broken Portal Two") }));
    
    // GUI
    gr.sprites.register("GUI Arrow", spritesheet.get(79, 487, 12, 9));
    gr.sprites.register("GUI Arrow Filled", spritesheet.get(91, 487, 12, 9));
    gr.sprites.register("GUI Fire", spritesheet.get(103, 486, 11, 10));
    gr.sprites.register("GUI Fire Filled", spritesheet.get(114, 486, 11, 10));
    
    // Font
    int x = 0;
    int y = 496;
    for (int i = 0; i < GUIUtils.GUI_FONT_CHARACTERS.length(); i++) {
      gr.sprites.register(String.valueOf(GUIUtils.GUI_FONT_CHARACTERS.charAt(i)), spritesheet.get(x, y, 8, 8));
      x += 8;
      if (x >= 512) {
        x = 0;
        y += 8;
      }
    }
    
  }
  
  public void init() { }
  public void tick() { }
  
  
  // Custom Blocks
  
  public class BlockLog extends Block {
    
    public BlockLog(String name) {
      super(name, 1, 0, "Axe", false); 
    }
   
    public String getThesaurusName(BlockState state) { return "Log"; }
    public StateData getDefaultState() { return new StateData("AllowFell", false); }
    
    public void onBeforeDestroy(BlockState state) {
      if ((boolean)state.getState().get("AllowFell")) {
        PVector pos = state.getPosition();
        recursiveBreak((int)pos.x,     (int)pos.y - 1, Direction.SOUTH); // Up
        recursiveBreak((int)pos.x + 1, (int)pos.y,     Direction.WEST);  // Right 
        recursiveBreak((int)pos.x,     (int)pos.y + 1, Direction.NORTH); // Down
        recursiveBreak((int)pos.x - 1, (int)pos.y,     Direction.EAST);  // Left
      }
    }
    
    private void recursiveBreak(int x, int y, Direction dir) {
      BlockState state = terrainManager.getBlockStateAt(x, y, 0);
      String name = state.getBlock().getThesaurusName(state);
      if (name.equals("Log") || name.equals("Leaves")) {
        state.dropItems();
        if (name.equals("Log")) { state.setState(new StateData("AllowFell", false)); }
        state.setBlock(gr.blocks.get("Air"));
        if (dir != Direction.NORTH) recursiveBreak(x,     y - 1, Direction.SOUTH); // Up
        if (dir != Direction.EAST)  recursiveBreak(x + 1, y,     Direction.WEST);  // Right 
        if (dir != Direction.SOUTH) recursiveBreak(x,     y + 1, Direction.NORTH); // Down
        if (dir != Direction.WEST)  recursiveBreak(x - 1, y,     Direction.EAST);  // Left
      }
    }
    
  }
  
  public class BlockGrass extends Block {
    
    private int spreadRate;
    
    public BlockGrass(String name, int spreadRate) {
      super(name, 1, 0, "Shovel", false);
      
      this.spreadRate = spreadRate;
    }
    
    public ArrayList<ItemStack> getDroppedItems(BlockState state) { return getStacks(getBlockIS("Dirt")); }
    public int getTickChance(BlockState state) { return spreadRate; }
    
    public void onTick(BlockState state) {
      ArrayList<BlockState> spreadTargets = new ArrayList<BlockState>();
      PVector pos = state.getPosition();
      BlockState left = terrainManager.getBlockStateAt((int)pos.x - 1, (int)pos.y, (int)pos.z);
      BlockState right = terrainManager.getBlockStateAt((int)pos.x + 1, (int)pos.y, (int)pos.z);
      BlockState leftUp = terrainManager.getBlockStateAt((int)pos.x - 1, (int)pos.y - 1, (int)pos.z);
      BlockState rightUp = terrainManager.getBlockStateAt((int)pos.x + 1, (int)pos.y - 1, (int)pos.z);
      if (left != null && left.getBlock().getName().equals("Dirt") && (leftUp == null || leftUp.isAir()))
        spreadTargets.add(left);
      if (right != null && right.getBlock().getName().equals("Dirt") && (rightUp == null || rightUp.isAir()))
        spreadTargets.add(right);
      if (spreadTargets.size() != 0) spreadTargets.get((int)random(0, spreadTargets.size())).setBlock(gr.blocks.get("Grass"));
    }
    
  }
  
  public class BlockItemFrame extends Block {
  
    public BlockItemFrame() {
      super("Item Frame", 0); 
    }
    
    public StateData getDefaultState() { return new StateData("Item", getEmptyIS()); }
    public void onCreate(BlockState state, boolean isLoad) { clearInput(); }
    public boolean isCollidable(BlockState state) { return false; }
    public boolean isOpaque(BlockState state) { return false; }
    public boolean doesBlockLight(BlockState state) { return false; }
    public int getRequiredSortLayer() { return 1; }
    public boolean itemHasBlockRender() { return false; }
    
    public boolean onInteract(BlockState state, boolean shift) {
      ItemStack held = player.getHeldItem();
      ItemStack current = (ItemStack)state.getState().get("Item");
      if (current.isEmpty() && held.isEmpty()) return false;
      if (current.isEmpty() && !held.isEmpty()) {
        ItemStack newItem = new ItemStack(held);
        newItem.setStackSize(1);
        state.getState().set("Item", newItem);
        held.addStackSize(-1);
        state.markDirty();
        clearInput();
        return true;
      }
      if (!current.isEmpty() && held.isEmpty()) {
        terrainManager.spawnItemEntity(state, current);
        state.getState().set("Item", getEmptyIS());
        state.markDirty();
        clearInput();
        return true;
      }
      clearInput();
      return true;
    }
    
    public ArrayList<ItemStack> getDroppedItems(BlockState state) {
      ItemStack stack = (ItemStack)state.getState().get("Item");
      state.setState(null);
      ArrayList<ItemStack> drops = super.getDroppedItems(state);
      if (!stack.isEmpty()) drops.add(stack);
      return drops;
    }
    
    public void render(BlockState state, float leftX, float topY, int defaultSize) {
      super.render(state, leftX, topY, defaultSize);
      ItemStack item = (ItemStack)state.getState().get("Item");
      if (!item.isEmpty()) {
        guiUtils.drawItem(
          leftX + (0.125 * BlockState.BLOCK_SIZE),
          topY + (0.125 * BlockState.BLOCK_SIZE),
          round(0.75 * BlockState.BLOCK_SIZE),
          item,
          true
        );
      }
    }
    
  }
  
  public class BlockChest extends Block {
    
    public BlockChest() {
      super("Chest", 1, 0, "Axe", false);
    }
    
    public StateData getDefaultState() { return new StateData("Items", new Container(9 * 3), "Left", false, "Right", false); }
    public int getRequiredSortLayer() { return 1; }
    public boolean requiresSaveOnUnload() { return true; }
    public boolean itemHasBlockRender() { return false; }
    public Container getContainerForSide(BlockState state, Direction side) { return (Container)state.getState().get("Items"); }
    
    public void render(BlockState state, float leftX, float topY, int defaultSize) {
      String baseTexture = "Chest";
      if ((boolean)state.getState().get("Left")) baseTexture = "Double Chest Right";
      else if ((boolean)state.getState().get("Right")) baseTexture = "Double Chest Left";
      image(gr.sprites.get(baseTexture), leftX, topY, defaultSize, defaultSize);
      GUI topGui = guiUtils.getTopGui();
      if (topGui instanceof ChestGUI && ((ChestGUI)topGui).isMember(state)) {
        image(gr.sprites.get(baseTexture + " Open"), leftX, topY - (0.6875 * defaultSize), defaultSize, defaultSize);
      }
    }
    
    public void onNeighbourChanged(BlockState us, BlockState neighbour) {
      PVector pos = us.getPosition();
      PVector neighbourPos = neighbour.getPosition();
      StateData state = us.getState();
      if (neighbourPos.x == pos.x - 1) formDoubleChest(state, neighbour, "Left");
      if (neighbourPos.x == pos.x + 1) formDoubleChest(state, neighbour, "Right");
    }
    
    protected void formDoubleChest(StateData state, BlockState neighbour, String side) {
      String otherSide = side.equals("Left") ? "Right" : "Left";
      if (neighbour.getBlock().getName().equals("Chest")) { // If the new block is a chest
        if ((boolean)state.get(otherSide)) { // If there is a chest on the other side, we're already a double chest!
          neighbour.dropItems();
          neighbour.setBlock(gr.blocks.get("Air"));
        }
        else { // Otherwise, form a double chest!
          state.set(side, true);
          neighbour.getState().set(otherSide, true);
        }
      }
      else state.set(side, false); // Otherwise, no chest on that side
    }
    
    public boolean onInteract(BlockState block, boolean shift) {
      if (shift) return false;
      
      StateData state = block.getState();
      PVector pos = block.getPosition();
      
      Container left;
      Container right;
      
      if ((boolean)state.get("Left")) {
        left = (Container)terrainManager.getBlockStateAt((int)pos.x - 1, (int)pos.y, 1).getState().get("Items");
        right = (Container)state.get("Items");
      }
      else if ((boolean)state.get("Right")) {
        left = (Container)state.get("Items");
        right = (Container)terrainManager.getBlockStateAt((int)pos.x + 1, (int)pos.y, 1).getState().get("Items");
      }
      else {
        left = (Container)state.get("Items");
        right = null;
      }
      
      guiUtils.openGui(new ChestGUI(left, right, block.getPosition(), "Chest"));
      return true;
    }
    
    public ArrayList<ItemStack> getDroppedItems(BlockState state) {
      Container container = (Container)state.getState().get("Items");
      state.setState(null);
      ArrayList<ItemStack> items = super.getDroppedItems(state);
      for (int i = 0; i < container.getSize(); i++) {
        ItemStack item = container.getAtSlot(i);
        if (!item.isEmpty()) items.add(item);
      }
      return items;
    }
    
  }
  
  // So that when you open one quantum chest, you can see the others open
  private Set<Integer> quantumChestsOpen = new HashSet<Integer>();
  
  public class BlockQuantumChest extends Block {
    
    public BlockQuantumChest() {
      super("Quantum Chest", 1, 0, "Axe", false);
    }
    
    public StateData getDefaultState() { return new StateData("id", -1, "r", 0, "g", 0, "b", 0); }
    public int getRequiredSortLayer() { return 1; }
    public boolean doesPreserveState(BlockState state) { return true; }
    public String[] getTooltip(BlockState state) { return new String[]{"ID: " + ((int)state.getState().get("id"))}; }
    public color getTooltipColour(BlockState state) { return color((int)state.getState().get("r"), (int)state.getState().get("g"), (int)state.getState().get("b")); }
    public boolean canShowInCreative() { return false; }
    
    public void render(BlockState state, float leftX, float topY, int defaultSize) {
      image(gr.sprites.get("Quantum Chest"), leftX, topY, defaultSize, defaultSize);
      tint((int)state.getState().get("r"), (int)state.getState().get("g"), (int)state.getState().get("b"));
      image(gr.sprites.get("Quantum Chest Core"), leftX, topY, defaultSize, defaultSize);
      noTint();
      if (quantumChestsOpen.contains((int)state.getState().get("id"))) {
        image(gr.sprites.get("Quantum Chest Open"), leftX, topY - (0.6875 * defaultSize), defaultSize, defaultSize);
      }
    }
    
    public boolean onInteract(BlockState block, boolean shift) {
      if (shift) return false;
      
      final int id = (int)block.getState().get("id");
      
      // Get the container from the world data, using our ID
      Container items = (Container)terrainManager.worldData.get("quantumChest" + id);
      
      // If there is no container for this ID yet (e.g. first time opening either side), make one
      if (items == null) {
        items = new Container(9 * 3);
        terrainManager.worldData.set("quantumChest" + id, items);
      }
      
      // So that other quantum chests appear open when we open this one
      quantumChestsOpen.add(id);
      
      // Show the GUI
      guiUtils.openGui(new ChestGUI(items, null, block.getPosition(), "Quantum Chest (" + id + ")"){
        public void onClosed() { quantumChestsOpen.remove(id); }
      });
      return true;
    }
  }
  
  public class ChestGUI extends GUI {
      
    private Container left;
    private Container right;
    private PVector pos;
    private String name;
   
    public ChestGUI(Container left, Container right, PVector pos, String name) {
      this.left = left;
      this.right = right;
      this.pos = pos;
      this.name = name;
    }
    
    public void render() {
      guiUtils.drawModalOverlay();
      int offset = right == null ? 0 : 150;
      PVector tl = guiUtils.drawTexturedModalRect(486, 532 + offset);
      guiUtils.drawText(tl.x + 16, tl.y + 16, (right == null ? "" : "Double ") + name, 64, 64, 64, false, false);
      guiUtils.drawContainer(tl.x + 16, tl.y + 48, left, 9, true);
      if (right != null) guiUtils.drawContainer(tl.x + 16, tl.y + 198, right, 9, true);
      guiUtils.drawText(tl.x + 16, tl.y + 214 + offset, "Inventory", 64, 64, 64, false, false);
      guiUtils.drawPlayerInventory(tl.x + 16, tl.y + 246 + offset);
    }
    
    public boolean isMember(BlockState block) {
      return pos.equals(block.getPosition());
    }
      
  }
  
  public class BlockFurnace extends Block {
    
    private int speed;
    private float fuelEfficiency;
    
    public BlockFurnace(String name, float hardness, int miningLevel, String toolType, boolean requireToolType, int speed, float fuelEfficiency) {
      super(name, hardness, miningLevel, toolType, requireToolType);
      this.speed = speed;
      this.fuelEfficiency = fuelEfficiency;
    }
    
    public boolean requiresSaveOnUnload() { return true; }
    
    public int getRequiredSortLayer() { return 1; }
    public int getTickChance(BlockState state) { return 0; }
    public String getTexture(BlockState state) { return "Furnace" + (((float)(state.getState().get("BurnTime"))) > 0 ? " Lit" : ""); }
    public boolean itemHasBlockRender() { return false; }
    
    public StateData getDefaultState() {
      
      final StateData state = new StateData();
      
      state.set("Input", getEmptyIS());
      state.set("Output", getEmptyIS());
      state.set("Fuel", getEmptyIS());
      state.set("Recipe", null);
      state.set("Progress", 0);
      state.set("BurnTime", 0f);
      state.set("InputChanged", false);
      state.set("MaxBurnTime", 0f);
      state.set("Speed", speed);
      
      return state;
    }
    
    public void onTick(BlockState block) {
      StateData state = block.getState();
      
      ItemStack input       = (ItemStack)state.get("Input");
      ItemStack output      = (ItemStack)state.get("Output");
      ItemStack fuel        = (ItemStack)state.get("Fuel");
      SmeltingRecipe recipe = (SmeltingRecipe)state.get("Recipe");
      int progress          = (int)state.get("Progress");
      float burnTime        = (float)state.get("BurnTime");
      boolean inputChanged  = (boolean)state.get("InputChanged");
      float maxBurnTime     = (float)state.get("MaxBurnTime");
      
      // When the input item changes, progress should be reset and we need to find a new recipe
      if (inputChanged) {
        inputChanged = false;
        recipe = null;
        progress = 0;
        
        // Find a new recipe
        for (SmeltingRecipe newRecipe : gr.smelting) {
          if (newRecipe.accepts(input)) {
            recipe = newRecipe;
            break;
          }
        }
      }
      
      // If we have run out of fuel while smelting, refill or lose progress
      if (recipe != null && burnTime <= 0) {
        if (!fuel.isEmpty()) {
          burnTime = fuel.getItem().getBurnTime(fuel);
          maxBurnTime = burnTime;
          fuel.addStackSize(-1);
        }
        else {
          progress = 0;
          return;
        }
      }
      
      // Smelt the item
      if (recipe != null) {
        progress++;
        
        // When we have finished smelting
        if (progress >= speed) {
          ItemStack result = recipe.getOutput();
          
          // If there is room for the item in the output slot, add it!
          if (output.isEmpty()) output = new ItemStack(result);
          else if (output.couldMerge(result)) output.addStackSize(result.getStackSize());
          else return; // Can't finish smelting the item, hopefully it can be added next tick!
          
          input.addStackSize(-1);
          progress = 0;
          inputChanged = true;
        }
      }
      
      // Use fuel
      if (burnTime > 0) burnTime -= fuelEfficiency;
      
      // Save our state
      state.set("Input",        input);
      state.set("Output",       output);
      state.set("Fuel",         fuel);
      state.set("Recipe",       recipe);
      state.set("Progress",     progress);
      state.set("BurnTime",     burnTime);
      state.set("InputChanged", inputChanged);
      state.set("MaxBurnTime",  maxBurnTime);
    }
    
    public ArrayList<ItemStack> getDroppedItems(BlockState state) {
      ItemStack inputItems  = (ItemStack) state.getState().get("Input");
      ItemStack outputItems = (ItemStack) state.getState().get("Output");
      ItemStack fuelItems   = (ItemStack) state.getState().get("Fuel");
      
      state.setState(null);
      ArrayList<ItemStack> drops = super.getDroppedItems(state);
      
      if (!inputItems.isEmpty())  drops.add(inputItems);
      if (!outputItems.isEmpty()) drops.add(outputItems);
      if (!fuelItems.isEmpty())   drops.add(fuelItems);
      
      return drops;      
    }
    
    public boolean onInteract(BlockState state, boolean shift) {
      if (shift) return false;
      guiUtils.openGui(new GUIFurnace(state));
      return true;
    }
    
    public class GUIFurnace extends GUI {
      
      private BlockState state;
      
      private Container inputContainer;
      private Container outputContainer;
      private Container fuelContainer;
      
      public GUIFurnace(BlockState state) {
        this.state = state;
        
        inputContainer = new Container(1) {
          public void setAtSlot(ItemStack stack, int i) {
            super.setAtSlot(stack, i);
            GUIFurnace.this.state.getState().set("Input", stack);
            GUIFurnace.this.state.getState().set("InputChanged", true);
          }
        };
        inputContainer.items[0] = (ItemStack)state.getState().get("Input");
        
        outputContainer = new Container(1) {
          public boolean slotCanAcceptItem(ItemStack stack, int i) { return false; }
          public void setAtSlot(ItemStack stack, int i) {
            super.setAtSlot(stack, i);
            GUIFurnace.this.state.getState().set("Output", stack);
          }
        };
        
        fuelContainer = new Container(1) {
          public boolean slotCanAcceptItem(ItemStack stack, int i) { return stack.getItem().getBurnTime(stack) != -1; }
          public void setAtSlot(ItemStack stack, int i) {
            super.setAtSlot(stack, i);
            GUIFurnace.this.state.getState().set("Fuel", stack);
          }
        };
        fuelContainer.items[0] = (ItemStack)state.getState().get("Fuel");
      }
      
      public void render() {
        guiUtils.drawModalOverlay();
        PVector tl = guiUtils.drawTexturedModalRect(486, 532);
        StateData st = state.getState();
        outputContainer.items[0] = (ItemStack)st.get("Output");
        guiUtils.drawText(tl.x + 16, tl.y + 16, state.getBlock().getVisibleName(state), 64, 64, 64, false, false);
        guiUtils.sprite("GUI Arrow", tl.x + 96, tl.y + 48, 60, 48);
        int progress = (int)st.get("Progress");
        int speed = (int)st.get("Speed");
        if (progress > 0 && speed > 0) {
          int progressX = round((12 / (float)speed) * progress);
          guiUtils.sprite("GUI Arrow Filled", tl.x + 96, tl.y + 48, progressX * 5, 48, 0, 0, progressX, 9);
        }
        guiUtils.sprite("GUI Fire", tl.x + 34, tl.y + 110, 44, 40);
        float maxBurnTime = (float)st.get("MaxBurnTime");
        float burnTime = (float)st.get("BurnTime");
        if (maxBurnTime > 0 && burnTime > 0) {
          int fireY = round((10 / maxBurnTime) * burnTime);
          guiUtils.sprite("GUI Fire Filled", tl.x + 34, tl.y + 110 + ((10 - fireY) * 4), 44, (fireY * 4), 0, 10 - fireY, 11, fireY);
        }
        guiUtils.drawText(tl.x + 16, tl.y + 225, "Inventory", 64, 64, 64, false, false);
        
        guiUtils.drawContainer(tl.x + 172, tl.y + 48, outputContainer, 1, true);
        guiUtils.drawContainer(tl.x + 32, tl.y + 48, inputContainer, 1, true);
        guiUtils.drawContainer(tl.x + 32, tl.y + 161, fuelContainer, 1, true);
        guiUtils.drawPlayerInventory(tl.x + 16, tl.y + 257);
      }
      
    }
    
  }
  
  public class BlockCraftingTable extends Block {
    
    public BlockCraftingTable() {
      super("Crafting Table", 1, 0, "Axe", false); 
    }
    
    public int getRequiredSortLayer() { return 1; }
    
    public boolean onInteract(BlockState state, boolean shift) {
      if (shift) return false;
      guiUtils.openGui(new GUICraftingTable(state.getPosition()));
      return true;
    }
    
    public class GUICraftingTable extends GUI {
      
      private PVector pos;
      private CraftingGrid grid;
      private CraftingResult result;
      
      public GUICraftingTable(PVector pos) {
        result = new CraftingResult();
        grid = new CraftingGrid(3, result);
        this.pos = pos;
      }
     
      public void render() {
        guiUtils.drawModalOverlay();
        PVector tl = guiUtils.drawTexturedModalRect(486, 532);
        guiUtils.drawText(tl.x + 16, tl.y + 16, "Crafting", 64, 64, 64, false, false);
        guiUtils.sprite("GUI Arrow", tl.x + 176, tl.y + 96, 60, 48);
        guiUtils.drawText(tl.x + 16, tl.y + 214, "Inventory", 64, 64, 64, false, false);
        guiUtils.drawContainer(tl.x + 252, tl.y + 96, result, 1, true);
        guiUtils.drawContainer(tl.x + 16, tl.y + 48, grid, 3, true);
        guiUtils.drawPlayerInventory(tl.x + 16, tl.y + 246);
      }
      
      public void onClosed() {
        for (int i = 0; i < grid.getSize(); i++) {
          ItemStack stack = grid.getAtSlot(i);
          if (!stack.isEmpty()) terrainManager.spawnItemEntity((int)(pos.x * BlockState.BLOCK_SIZE), (int)((pos.y - 1) * BlockState.BLOCK_SIZE), stack);
        }
      }
      
    }
    
  }
  
  public class BlockRedstoneWire extends BlockRedstoneInput {
    
    public BlockRedstoneWire() {
      super("Redstone", 1, 0, "Pickaxe", false); 
    }
    
    public String getItemTexture(BlockState state) { return "Redstone Dust"; }
    public boolean itemHasBlockRender() { return false; }
    public boolean isOpaque(BlockState state) { return false; }
    public boolean doesBlockLight(BlockState state) { return false; }
    public int getRequiredSortLayer() { return 1; }
    public boolean requiresSaveOnUnload() { return true; }
    public boolean canConnectRedstone(BlockState state, Direction side) { return true; }
    public boolean isCollidable(BlockState state) { return false; }
    public void onNeighbourChanged(BlockState state, BlockState neighbour) { connectToOthers(state); }
    public void onCreate(BlockState state, boolean isLoad) { if (!isLoad) connectToOthers(state); }
    
    public void onTick(BlockState state) {
      super.onTick(state);
      
      StateData data = state.getState();
      
      if ((boolean)data.get("hasChanged")) {
        int value = 0;
        
        int north = (int)data.get("north");
        int east  = (int)data.get("east");
        int south = (int)data.get("south");
        int west  = (int)data.get("west");
        
        if (north > 0 && north - 1 > value) value = north - 1;
        if (east  > 0 && east  - 1 > value) value = east  - 1;
        if (south > 0 && south - 1 > value) value = south - 1;
        if (west  > 0 && west  - 1 > value) value = west  - 1;
        
        data.set("value", value);
      }
    }
    
    public int getRedstoneOutput(BlockState state, Direction side) { return (int)state.getState().get("value"); }
    
    public void render(BlockState state, float leftX, float topY, int defaultSize) {
      super.render(state, leftX, topY, defaultSize); // Render the middle of the block
      
      StateData data = state.getState();
      
      boolean north = (boolean)data.get("connNorth");
      boolean east  = (boolean)data.get("connEast");
      boolean south = (boolean)data.get("connSouth");
      boolean west  = (boolean)data.get("connWest");
      
      if (north) image(gr.sprites.get("Redstone North"), leftX, topY, defaultSize, defaultSize);
      if (east)  image(gr.sprites.get("Redstone East"),  leftX, topY, defaultSize, defaultSize);
      if (south) image(gr.sprites.get("Redstone South"), leftX, topY, defaultSize, defaultSize);
      if (west)  image(gr.sprites.get("Redstone West"),  leftX, topY, defaultSize, defaultSize);
      
      int value = (int)data.get("value");
      
      if (value > 0) {
        tint(255, 255, 255, 255 * (value / 16.0f));
        image(gr.sprites.get("Redstone On"), leftX, topY, defaultSize, defaultSize);
        if (north) image(gr.sprites.get("Redstone On North"), leftX, topY, defaultSize, defaultSize);
        if (east)  image(gr.sprites.get("Redstone On East"),  leftX, topY, defaultSize, defaultSize);
        if (south) image(gr.sprites.get("Redstone On South"), leftX, topY, defaultSize, defaultSize);
        if (west)  image(gr.sprites.get("Redstone On West"),  leftX, topY, defaultSize, defaultSize);
        noTint();
      }
    } 
    
    public StateData getDefaultState() {
      StateData data = super.getDefaultState();
      data.set("connNorth", false);
      data.set("connEast", false);
      data.set("connSouth", false);
      data.set("connWest", false);
      data.set("value", 0);
      return data;
    } 
    
    public void connectToOthers(BlockState state) {
      StateData data = state.getState();
      data.set("connNorth", isConnection(state, Direction.NORTH,  0, -1));
      data.set("connEast",  isConnection(state, Direction.EAST,   1,  0));
      data.set("connSouth", isConnection(state, Direction.SOUTH,  0,  1));
      data.set("connWest",  isConnection(state, Direction.WEST,  -1,  0));
    }
    
    private boolean isConnection(BlockState state, Direction side, int xOff, int yOff) {
      BlockState other = getBlockInDirection(state, xOff, yOff); 
      if (other == null) return false;
      return other.getBlock().canConnectRedstone(other, side);
    }
    
  }
  
  public class BlockHopper extends Block {
    
    public BlockHopper() {
      super("Hopper", 2, 1, "Pickaxe", true);
    }
    
    public int getRequiredSortLayer() { return 1; }
    public boolean isOpaque(BlockState state) { return false; }
    public boolean doesBlockLight(BlockState state) { return false; }
    public int getTickChance(BlockState state) { return 0; } // Tick each frame
    
    // Put item entities above into the container below
    public void onCreate(BlockState state, boolean isLoad) {
      final PVector pos = state.getPosition();
      final BlockState thisState = state;
      SuctionBox suctionBox = new SuctionBox(new float[]{
        (pos.x)     * BlockState.BLOCK_SIZE,
        (pos.y - 2) * BlockState.BLOCK_SIZE,
        (pos.x + 1) * BlockState.BLOCK_SIZE,
        (pos.y + 1) * BlockState.BLOCK_SIZE
      }){
        public int suck(ItemStack item) {
          Container container = getAdjacentContainer(thisState, Direction.SOUTH, 0, 1);
          return container.addItem(item);
        }
      };
      terrainManager.addSuctionBox(suctionBox);
      state.getState().set("suctionBox", suctionBox.id);
    }
    
    // Move items from the container above to the container below
    public void onTick(BlockState state) {
      Container above = getAdjacentContainer(state, Direction.NORTH, 0, -1);
      Container below = getAdjacentContainer(state, Direction.SOUTH, 0,  1);
      if (above == null || below == null) return;
      
      // Find an item to pull
      for (int i = 0; i < above.getSize(); i++) {
         ItemStack item = above.getAtSlot(i);
         if (item.isEmpty()) continue;
         
         // Try to add the item to the inventory below
         ItemStack clone = cloneIS(item);
         clone.setStackSize(1); // 1 item transferred per tick
         int amtMoved = below.addItem(clone);
         
         if (amtMoved > 0) {
           // If the add succeeded, decrease the size of the item in the top inventory,
           // and end for this tick.
           item.setStackSize(item.getStackSize() - 1);
           return;
         }
      }
    }
    
    // Remove the suction box if the block is manually destroyed.
    // We don't have to worry about this for chunk unloads though, as in that case it happens automatically
    public void onBeforeDestroy(BlockState state) {
      terrainManager.removeSuctionBox((int)state.getState().get("suctionBox"));
    } 
    
    private Container getAdjacentContainer(BlockState state,  Direction side, int xOff, int yOff) {
      final PVector pos = state.getPosition();
      BlockState other = terrainManager.getBlockStateAt((int)pos.x + xOff, (int)pos.y + yOff, (int)pos.z);
      if (other == null) return null;
      return other.getBlock().getContainerForSide(other, side); 
    }
  }
  
  public class BlockPiston extends BlockRedstoneInput {
    
    private boolean sticky = false;
    
    public BlockPiston(boolean sticky) {
      super(sticky ? "Sticky Piston" : "Piston", 1, 0, "Pickaxe", false); 
      
      this.sticky = sticky;
    }
    
    public boolean placeBlockDirectionally() { return true; }
    public boolean isOpaque(BlockState state) { return false; }
    public boolean doesBlockLight(BlockState state) { return false; }
    public int getRequiredSortLayer() { return 1; }
    public boolean canConnectRedstone(BlockState state, Direction side) { return true; }
    
    public StateData getDefaultState() {
      StateData data = super.getDefaultState();
      data.set("extended", false);
      return data;
    }
    
    public String getTexture(BlockState state) {
      if ((boolean)state.getState().get("extended")) return "Piston Base";
      return sticky ? "Sticky Piston" : "Piston";
    }
    
    public void onTick(BlockState state) {
      super.onTick(state);
      
      StateData data = state.getState();
      
      // Change in signal
      if ((boolean)data.get("hasChanged")) {
        boolean powered = getInputOnSide(state, Direction.ALL) > 0;
        boolean extended = (boolean)data.get("extended");
        
        // If we're getting power, but we haven't extended, we need to extend!
        if (powered && !extended) {
          data.set("extended", true);
        }
        // Otherwise, if we're not powered, but we are still extended, we need to retract!
        else if (!powered && extended) {
          data.set("extended", false);
        }
      }
    }
    
  }
  
  public class DimensionOverworld implements Dimension {
    
    private Sky sky = new Sky(color(220, 240, 250), color(1, 87, 155), 16);
    
    public String getName() {
      return "Overworld";
    }
    
    public String[][] getWhittakerDiagram() {/*
      return new String[][]{
        new String[]{"Jungle", "Jungle", "Swamp",  "Hills" }, // wettest
        new String[]{"Ocean",  "Ocean",  "Hills",  "Hills" }, //
        new String[]{"Desert", "Forest", "Plains", "Tagia" }, //
        new String[]{"Desert", "Desert", "Plains", "Tundra"}  // driest
        //           hottest                        coldest
      };*/
      return new String[][]{ new String[]{ terrainManager.isSuperflat() ? "Redstone Ready" : "Plains" } };
    }
    
    public Sky getSky() {
      return sky;
    }
    
  }
  
  public class DimensionNether implements Dimension {
    
    private Sky sky = new Sky(color(107, 27, 0), color(107, 27, 0), 16);
    
    public String getName() {
      return "Nether";
    }
    
    public String[][] getWhittakerDiagram() {
      return new String[][]{ new String[]{ "Hell" } };
    }
    
    public Sky getSky() {
      return sky;
    }
    
  }
  
  public class EntityTNT extends Entity {
    
    private int counter;
    private boolean flash = false;
    
    public EntityTNT(PVector position, String dimension) {
      super(position, dimension, 1);
    }
    
    public EntityTNT() {}
    
    public Entity createInstance(PVector position, String dimension, PVector velocity, int health, StateData data) {
      counter = (Integer)data.get("Counter");
      return new EntityTNT(position, dimension);
    }
    
    public StateData additionalXMLAttributes() {
      return new StateData("Counter", counter); 
    }
    
    public String registeredName() {
      return "TNT"; 
    }
    
    public void addHealth(int amt) {}
    
    public void render(float leftX, float topY) {
      fill(255);
      noStroke();
      if (flash) {
        rect(leftX, topY, BlockState.BLOCK_SIZE, BlockState.BLOCK_SIZE);
      }
      else {
        image(gr.sprites.get("TNT"), leftX, topY, BlockState.BLOCK_SIZE, BlockState.BLOCK_SIZE);
      }
      
    }
    
    public float[] getBoundingBox() { return new float[]{ 0, 0, 0, 0 }; }
    
    public void update() {
      counter++;
      if (counter % 15 == 0) flash = !flash;
      if (counter > 300) { // Explode
        terrainManager.despawnEntity(this);
        for (int x = 0 ; x < 10; x++) {
          for (int y = 0; y < 10; y++) {
            int mapX = x > 4 ? 9 - x : x;
            int mapY = y > 4 ? 9 - y : y;
            if (random(0, 8) < mapX + mapY) {
              ArrayList<BlockState> states = terrainManager.getBlockStatesAt((int)((position.x / BlockState.BLOCK_SIZE) + x - 5), (int)((position.y / BlockState.BLOCK_SIZE) + y - 5));
              if (states == null) continue;
              for (BlockState state : states) {
                if (state != null) state.setBlock(gr.blocks.get("Air"));
              }
            }
          }
        }
      }
    }
  }
}
