/**
* Defines a block which can be placed in the world.
*
* This application uses a singleton design pattern - each Block is only instantiated once.
* In the world, the BlockState class represents each block, and has a reference to the Block singleton for that block type.
*
* The methods defined here are called elsewhere at appropriate times, to determine how this block behaves under some particular
* scenario. They all are passed the Block State, so that which we can change behaviour in accordance with it's value.
*
* @author Orlando
*/
@SuppressWarnings("unused")
public class Block {
  
  private String name;
  private float hardness;
  private int miningLevel;
  private String toolType;
  private boolean requireToolType;
  
  public Block() {
    this("", 0f);
  }
  
  public Block(String name, float hardness) {
    this(name, hardness, 0, "None", false);
  }
  
  public Block(String name, float hardness, int miningLevel, String toolType, boolean requireToolType) {
    this.name = name; 
    this.hardness = hardness;
    this.miningLevel = miningLevel;
    this.toolType = toolType;
    this.requireToolType = requireToolType;
  }
  
  /**
  * Get the name of this block. This is used to refer to the block within the game's code. Should remain constant.
  * @returns The name of the block.
  */
  public String getName() { return name; } // Return the name given in the constructor.
  
  /**
  * Get the name of this block, as shown to the player (e.g. on tooltips). Typically identital to getName(), but this
  * can be changed depending on state, etc.
  * @param state The state (position and state object) of the block.
  * @returns The block's visible name.
  */
  public String getVisibleName(BlockState state) { return getName(); }
  
  /**
  * Get the thesaurusised name for this block. This is used to fuzzily match it when crafting or smelting, e.g. so that
  * oak wood planks and jungle wood planks can both be used to make crafting tables.
  * @param state The state (position and state object) of the block.
  * @returns The recipe thesaurus name for this block. 
  */
  public String getThesaurusName(BlockState state) { return getName(); }
  
  /**
  * Get the name of a registered texture which will be used to draw the block.
  * @param state The state (position and state object) of the block.
  * @returns The block's texture.
  */
  public String getTexture(BlockState state) { return name; } // The texture will usually be registered under the same name as the block.
  
  /**
  * Get the name of a registered texture which will be used on the block's item.
  * @param state The state (position and state object) of the block.
  * @returns The block's item's texture.
  */
  public String getItemTexture(BlockState state) { return name; } // The item texture will usually just be the block texture.
  
  /**
  * Use the <code>render()</code> method for this block to also render its item, or simply draw the defined texture instead?
  * <p>Using <code>render()</code> has many advantages, however it can cause nasty errors if your block doesn't have its
  * expected state while in item form.</p>
  */
  public boolean itemHasBlockRender() { return !placeBlockDirectionally(); } // It's fine to all non-directional blocks using their render method 
  
  /**
  * Called to render this block in a custom way using the Processing drawing functions, rather than relying on the default
  * renderer.
  * <p><strong>NOTE:</strong> If this block will render in a space bigger than one square, it would make sense to return
  * a layer greater than 1 in <code>getRequiredSortLayer()</code> so that this block draws above other ones.</p>
  * @param state The state (position and state object) of the block.
  * @param leftX The position (from the left of the screen) where drawing should commence.
  * @param topX The position (from the top of the screen) where drawing should commence.
  * @param defaultSize The default width & height of a block.
  */
  public void render(BlockState state, float leftX, float topY, int defaultSize) {
    // If the block has a direction, render it rotated in that direction
    if (placeBlockDirectionally()) {
      pushMatrix();
        switch ((int)state.getState().get("direction")) {
          case 1: // North
            translate(leftX, topY);
            break;
          case 2: // East
            translate(leftX + defaultSize, topY);
            rotate(radians(90));
            break;
          case 3: // South
            translate(leftX + defaultSize, topY + defaultSize);
            rotate(radians(180));
            break;
          case 4: // West
            translate(leftX, topY + defaultSize);
            rotate(radians(270));
            break;
        }
        image(gr.sprites.get(getTexture(state)), 0, 0, defaultSize, defaultSize);
      popMatrix();
    }
    else {
      image(gr.sprites.get(getTexture(state)), leftX, topY, defaultSize, defaultSize); // Render the texture at the given location.
    }
  }
  
  /**
  * Get how hard the block is to break. The number corrisponds to seconds required - e.g. 2f means 2 seconds.
  * -1f means that the block cannot be broken.
  * @param state The state (position and state object) of the block.
  * @returns This block's hardness.
  */
  public float getHardness(BlockState state) { return hardness; } // Return the hardness given in the constructor.
  
  /**
  * Get the mining level required to break this block. Any tool above or equal to this level is capable of breaking it.
  * Tools below this level can also break the block, but it will not drop anything.
  * @param state The state (position and state object) of the block.
  * @return One of the possible tool levels.
  */
  public int getMiningLevel(BlockState state) { return miningLevel; } // Return the tool level given in the constructor.
  
  /**
  * Get the type of tool which should be used to break this block. For example, a shovel should be used on
  * sand, a pickaxe should be used on ore, etc.
  * <p>By default, this just slows down other tools. Return true in <code>isToolTypeForced()</code> to
  * prevent the block from dropping anything if the incorrect tool is used.</p>
  * @param state The state (position and state object) of the block.
  * @return One of the possible tool types.
  */
  public String getToolType(BlockState state) { return toolType; } // Return the tool type given in the constructor.
  
  /**
  * If this returns true, then the tool type defined in <code>getToolType()</code> must be used when
  * breaking this block if it is to return anything.
  * @param state The state (position and state object) of the block.
  * @return <code>true</code> if the tool type should be forced, <code>false</code> if it should not be.
  */
  public boolean isToolTypeForced(BlockState state) { return requireToolType; } // Return the tool type given in the constructor.
  
  /**
  * Require that this block be sorted onto a specific layer:<ul>
  * <li>-1 -> Any sort layer the user puts it on is fine - either 0 or 1.</li>
  * <li> 0 -> Can only be on the background layer.</li>
  * <li> 1 -> Can only be on the foreground layer.</li></ul>
  * <p><strong>NOTE:</strong> this should be consistant across all blocks of a given type.</p>
  * @return The resulting sort layer.
  */
  public int getRequiredSortLayer() { return -1; } // Most blocks can go on both layers and do not need to be on a higher layer than 1.
  
  /**
  * Called when the player right-clicks this block to interact with it. Only blocks on the foreground layer can be interacted with.
  * @param state The state (position and state object) of the block.
  * @param shift <code>true</code> if the SHIFT key was pressed down.
  * @return A boolean. When <code>true</code>, blocks the <code>onUse</code> event from firing on the held item.
  */
  public boolean onInteract(BlockState state, boolean shift) { return false; } // Most blocks do nothing when interacted with.
  
  /**
  *Called when the player left-clicks this block to attack it. Only blocks on the foreground layer can be attacked.
  * @param state The state (position and state object) of the block.
  * @param x The position of the mouse on the X axis, relative to the block, at the time of interaction.
  * @param y The position of the mouse on the Y axis, relative to the block, at the time of interaction.
  * @param size The maximum x / y position for this block.
  * @param shift <code>true</code> if the SHIFT key was pressed down.
  * @return A boolean. When <code>true</code>, blocks the <code>onAttack</code> event from firing on the held item.
  */
  public boolean onAttack(BlockState state, boolean shift) { return false; } // Most blocks do nothing when attacked.
  
  /**
  * Get the bounding box for this block. This box is used for detecting when the mouse is over the box (to hit / interact with it), and
  * for physics collisions.
  * <p>The box should be returned as a float array with 4 values, representing two coordinates: <code>[x1,y1,x2,y2]</code>. (x1,y1) is
  * the position at the top left corner of the bounding box. (x2, y2) is the position at the bottom right corner of the bounding box.</p>
  * <p>1f in this array represents a full block width. <strong>NOTE:</strong> No value should be greater than 1f!</p>
  * @param state The state (position and state object) of the block.
  * @param unitSize The size of one unit (1f / one normal block width) in pixels. This might be helpful for calculations.
  * @return The bounding box description.
  */
  public float[] getBoundingBox(BlockState state, int unitSize) { return new float[]{0f, 0f, 1f, 1f}; } // Default bounding box fills the whole block.
  
  /**
  * Get the chance that this block should be randomly ticked.  Returning 0 = ticked 100% of the time, 1 = 50%, 2 = 33.33%, etc.
  * <p>Returning -1 means that this block will not be randomly ticked (i.e. 0%).</p>
  * <p>When ticked, <code>onTick()</code> gets called.</p>
  * @param state The state (position and state object) of the block.
  * @return The tick chance.
  */
  public int getTickChance(BlockState state) { return -1; } // Most blocks do not need to be ticked.
  
  /**
  * Called when this block gets randomly ticked. The tick chance (and thus the frequency of calls to this function) can be changed in
  * <code>getTickChance()</code>.
  * <p>Useful for plants / grass (random grow tick), Tile Entities like furnaces (which would return a chance of 0 to always get ticked),
  * etc.</p>
  * @param state The state (position and state object) of the block.
  */
  public void onTick(BlockState state) { } // By default, this function will never be called (we set 0% tick chance), so no body.
  
  /**
  * The default state for this block. Called whenever a new block of this type is created.
  * @return The new state.
  */
  public StateData getDefaultState() { return new StateData(); } // Most blocks do not need a state.
  
  /**
  * Get the colour and brightness of the light emitted by this block. If this block should not emit light, should return null.
  * @param state The state (position and state object) of the block.
  * @return The light information for this block.
  */
  public Light getLight(BlockState state) { return null; } // Most blocks do not emit light.
  
  /**
  * If this block acts as a collider, then objects (such as the player) cannot walk or fall through it.
  * @param state The state (position and state object) of the block.
  * @return <code>true</code> if objects cannot move through this block, <code>false</code> if they can.
  */
  public boolean isCollidable(BlockState state) { return true; } // Most blocks prevent objects falling through them.
  
  /**
  * If the block is not targetable, then the player cannot remove or interact with it.
  * <p>Very few blocks need to return <code>false</code> here. One example would be Air.</p>
  * @param state The state (position and state object) of the block.
  * @return <code>true</code> if the player can target this block, <code>false</code> if they can't.
  */
  public boolean isTargetable(BlockState state) { return true; } // Most blocks can be targeted.
  
  /**
  * If this block has Physics applied to it, e.g. if it can fall.
  * @param state The state (position and state object) of the block.
  * @return <code>true</code> if this block falls due to gravity, <code>false</code> if it does not.
  */
  public boolean isPhysicsApplied(BlockState state) { return false; } // Most blocks do not fall.
  
  /**
  * Used to add extra information to a block's tooltip. Each line is a new array item.
  * @param state The state (position and state object) of the block.
  * @return The array of extra tooltip info.
  */
  public String[] getTooltip(BlockState state) { return new String[]{}; } // Most blocks do not need extra tooltip info.
  
  /**
  * Used to define the colour of the name of a block's tooltip. Subsequent lines (e.g. those added with <code>getTooltip()</code>) are always gray.
  * @param state The state (position and state object) of the block.
  * @return The colour to use for its name in the tooltip.
  */
  public color getTooltipColour(BlockState state) { return color(255, 255, 255); } // Most blocks have a white title
  
  /**
  * Get all of the items which should drop when this block is broken. <code>getAsItem();</code> gets the item for this block.
  * @param state The state (position and state object) of the block.
  * @return The array of items to drop.
  */
  public ArrayList<ItemStack> getDroppedItems(BlockState state) {
    // Return ourselves; preserving state if that flag is true
    return getStacks(getBlockIS(getName(), 1, doesPreserveState(state) ? state.getState() : new StateData()));
  }
  
  /**
  * Get the maximum amount of times this block can stack as an item.
  * @param state The state (position and state object) of the block.
  * @return The maximum stack size.
  */
  public int getMaxStackSize(BlockState state) { return ItemStack.MAX_STACK_SIZE; } // Most blocks stack to the max stack size.
  
  /**
  * The Physics Material defines friction and mass. Friction determines how fast objects can traverse the block and how quickly
  * they come to rest. Bounce determines what happens to an object's momentum upon collision.
  * @param state The state (position and state object) of the block.
  * @return The Physics Material.
  */
  public PhysicsMaterial getPhysicsMaterial(BlockState state) { return new PhysicsMaterial(0, 0, 1); } // Standard friction and standard bounce.
  
  /**
  * Called just before this block is removed from the world - e.g. via setBlock in BlockState.
  * <p>Could be useful for farmland breaking it's crops, chests dropping all of their items, etc.</p> 
  * @param state The state (position and state object) of the block.
  */
  public void onBeforeDestroy(BlockState state) { } // Most blocks do nothing here
  
  /**
  * Called just as the block has been set at a new block state.
  * @param state The state (position and state object) of the block to get the name for.
  * @param isLoad Is the creation caused by a level load?
  */
  public void onCreate(BlockState state, boolean isLoad) { } // Most blocks do nothing here
  
  /**
  * Can you see the background layer behind this block?
  * @param state The state (position and state object) of the block.
  * @return <code>true</code> if you cannot see the background layer, <code>false</code> if you can.
  */
  public boolean isOpaque(BlockState state) { return true; } // Most blocks are fully opaque.
  
  /**
  * Does this block allow light to pass through it?
  * @param state The state (position and state object) of the block.
  * @return <code>true</code> if it stops light, <code>false</code> if it does not.
  */
  public boolean doesBlockLight(BlockState state) { return true; } // Most blocks are solid.
  
  /**
  * Called whenever one of this block's immediant neighbours (diagonals do not count) is changed.
  * <p>Note that in this context, change means that the actual block type changed, not just its state.</p>
  * @param state The state (position and state object) of the block.
  * @param neighbour The state (position and state object) of the neighbour which got changed.
  */
  public void onNeighbourChanged(BlockState state, BlockState neighbour) { } // Most blocks do nothing here
  
  /**
  * Can a new block be placed directly over the top of this one, overriding it?
  * <p>This behaviour is used by some plants, e.g. tall grass and dead bushes.</p>
  * @param state The state (position and state object) of the block.
  * @returns <code>true</code> if the block is overridable.
  */
  public boolean isOverridable(BlockState state) { return false; } // Most blocks are not overridable.
  
  /**
  * If this block cannot support falling blocks, they pop off upon hitting it.
  * @param state The state (position and state object) of the block.
  * @returns <code>true</code> if the block can support falling blocks, <code>false</code> if it can not.
  */
  public boolean canSupportFallingBlock(BlockState state) { return true; } // Most blocks can support falling blocks.
  
  /**
  * Returns how many ticks this block will burn for in a furnace. If this value is -1 then the block will not burn.
  * @param state The state (position and state object) of the block.
  * @return This block's burn time.
  */
  public int getBurnTime(BlockState state) { return -1; }
  
  /**
  * Should this block preserve its state when picked up and then placed back down in the world by the player?
  * @param state The state (position and state object) of the block.
  * @return <code>true</code> if placement should preserve state.
  */
  public boolean doesPreserveState(BlockState state) { return false; }
  
  /**
  * If true, this block is marked (on chunk load), meaning that when the chunk is unloaded it will get saved.
  * <p>This method is only checked when the chunk is first loaded - you shouldn't change its return value to try and save the block.</p>
  * <p>If you need to request that a block be saved, use the markDirty BlockState method.</p>
  * @return <code>true</code> if this block is always marked dirty.
  */
  public boolean requiresSaveOnUnload() { return false; }
  
  /**
  * Can redstone be connected to the given side of this block?
  * @param state The state (position and state object) of the block.
  * @param side The side of the block to attempt to connect.
  * @return <code>true</code> if redstone can be connected to that side.
  */
  public boolean canConnectRedstone(BlockState state, Direction side) { return false; } // Most blocks can't connect to redstone
  
  /**
  * Get the redstone output for the given side.
  * @param state The state (position and state object) of the block.
  * @param side The side of the block to attempt to connect.
  * @return A value between 0 (off) and 15 (full power), which represents the amount of power being emitted on the given side.
  */
  public int getRedstoneOutput(BlockState state, Direction side) { return 0; } // Most blocks don't output a redstone signal
  
  /**
  * Should this block appear in the creative menu? Most blocks should, but this lets you turn it off for e.g. technical blocks.
  * @return <code>true</code> if it appears in the menu, <code>false</code> otherwise.
  */
  public boolean canShowInCreative() { return true; } // Most blocks should be shown in creative
  
  /**
  * Get the container accessible from a given side. This allows e.g. pipes to move items in and out of inventories.
  * @param state The state (position and state object) of the block.
  * @param side The side of the block to attempt to get a container for.
  * @return <code>null</code> if there is no container; otherwise the container which can be accessed from that side.
  */
  public Container getContainerForSide(BlockState state, Direction side) { return null; } // Most blocks don't have a container
  
  /**
  * Should this block be placed directionally? If this is true, the direction arrow will appear when placing the block, and it's state
  * will gain a "direction" value upon placement, containing a number 1, 2, 3, or 4 corresponding to North, East, South and West.
  * @return <code>true</code> if this block should be placed directionally, <code>false</code> if it shouldn't
  */
  public boolean placeBlockDirectionally() { return false; } // Most blocks do not account for direction
  
}

public class BlockState implements Collider {
  
  public static final int BLOCK_SIZE = 64;
  
  private PVector pos;
  private StateData state;
  private Block block;
  private int breakAmount = 0;
  private int damaged = -1;
  
  public BlockState(Block block, PVector pos, StateData state) {
    this.block = block;
    this.pos = pos;
    this.state = state;
  }
  
  public BlockState(XML xml) {
    block = gr.blocks.get(xml.getString("name"));
    pos = new PVector(xml.getFloat("x"), xml.getFloat("y"), xml.getFloat("z"));
    state = new StateData(xml);
  }
  
  public String toXML() {
    return "<block name=\"" + block.getName() + "\" x=\"" + pos.x + "\" y=\""+ pos.y +"\" z=\"" + pos.z + "\">" + ((state == null) ? "<null></null>" : state.toXML()) + "</block>"; 
  }
  
  public PVector getPosition() {
    return pos;
  }
  
  public StateData getState() {
    return state;
  }
  
  public void setState(StateData state) {
    this.state = state;
    // Save changes
    markDirty();
  }
  
  public Block getBlock() {
    return block; 
  }
  
  public String toString() {
    return "[" + block.getName() + ", " + pos + ", " + (state == null ? "null" : state.getMap()) + "]"; 
  }
  
  public void setBlock(Block block) {
    setBlock(block, block.getDefaultState(), false);
  }
  
  public void setBlock(Block block, boolean safeMode) {
    setBlock(block, block.getDefaultState(), safeMode);
  }
  
  public void setBlock(Block block, StateData state) {
    setBlock(block, state, false);
  }
  
  public void setBlock(Block block, StateData state, boolean safeMode) {
    boolean recalcLighting = this.block.getLight(this) == null;
    if (!safeMode) this.block.onBeforeDestroy(this);
    this.block = block;
    this.state = state;
    this.block.onCreate(this, safeMode);
    
    // If this block needs to always get saved (e.g. like a furnace), mark it dirty now.
    if (block.requiresSaveOnUnload()) markDirty();
    
    // Only bother recalculating the lighting if neither of the blocks involved are lights, because otherwise
    // the lighting will end up just getting recalculated automatically anyways.
    // Also, blocks on the background layer do not affect lighting (e.g. by blocking it), so we never need to
    // recalculate in that case.
    if (recalcLighting && block.getLight(this) == null && pos.z == 1) terrainManager.requestLightingRecalc();
    
    // Update the neighbours
    if (!safeMode) {
      if (pos.y - 1 >= 0) updateNeighbour(pos.x, pos.y - 1);               // Top
      updateNeighbour(pos.x + 1, pos.y);                                   // Right
      if (pos.y + 1 < TerrainManager.H) updateNeighbour(pos.x, pos.y - 1); // Bottom
      updateNeighbour(pos.x - 1, pos.y);                                   // Left
      
      // We're not safe mode, so this action wasn't done while loading -> save 
      markDirty();
    }
  }
  
  /**
  * Call this if the block here needs to be saved when the chunk is unloaded.
  */
  public void markDirty() {
    terrainManager.blocksToSave.add(new DimPos(pos.x, pos.y, pos.z, terrainManager.dimensionId));
  }
  
  private void updateNeighbour(float x, float y) {
    ArrayList<BlockState> states = terrainManager.getBlockStatesAt((int)x, (int)y);
    if (states != null) {
      for (BlockState state : states) {
        if (state != null) state.getBlock().onNeighbourChanged(state, this); 
      }
    }
  }
  
  public void update() {
    // Tick the block
    int tickChance = this.block.getTickChance(this);
    if (tickChance != -1 && (tickChance == 0 || (int)random(0, tickChance + 1) == 0)) {
      this.block.onTick(this);
    }
    
    // Reset damage
    if (damaged > -1) {
      damaged++;
      if (damaged == 2) {
        damaged = -1;
        breakAmount = 0;
      }
    }
  }
  
  public void render(float leftX, float topY) {
    this.block.render(this, leftX, topY, BLOCK_SIZE);
    if (damaged > -1) {
      float hardness = (block.getHardness(this) * 1000) / 7;
      String type = "1";
      for (int i = 1; i < 7; i++) {
        if (breakAmount >= hardness * i && breakAmount < hardness * (i + 1)) type = String.valueOf(i + 1);
      }
      image(gr.sprites.get("Crack " + type), leftX, topY, BLOCK_SIZE, BLOCK_SIZE);
    }
  }
  
  public float[] getBoundingBox() {
    return this.block.getBoundingBox(this, BLOCK_SIZE);
  }
  
  public boolean isAir() {
    return block instanceof BlockAir; 
  }
  
  public void dealDamage(ItemStack stack) {
    
    // Always break the block if in creative mode
    if (terrainManager.isCreative()) {
      setBlock(gr.blocks.get("Air"));
      return;
    }
    
    float hardness = block.getHardness(this);
    
    // Unbreakable blocks need not bother with anything else
    if (hardness == -1) return;
    
    float increment = getDeltaTime();
    
    String toolType = "None";
    int miningLevel = 0;
    float speedMultiplier = 1;
    
    if (!stack.isEmpty()) {
      toolType = stack.getItem().getItemType(stack);
      miningLevel = stack.getItem().getMiningLevel(stack);
      speedMultiplier = stack.getItem().getSpeedMultiplier(stack);
    }
    
    if (toolType.equals(block.getToolType(this))) {
      increment *= speedMultiplier * (miningLevel >= block.getMiningLevel(this) ? 1 : -1);
    }
    else {
      increment *= 0.5;
    }
    
    breakAmount += increment;
    damaged = 0;
    
    // /Break the block if we're over the amount of damage required
    
    if (breakAmount > hardness * 1000) {
      
      if (!stack.isEmpty() && ((block.getToolType(this).equals("Pickaxe") && toolType.equals("Pickaxe")) || (block.getToolType(this).equals("Shovel") && toolType.equals("Shovel"))) && stack.getItem() instanceof ItemTool) {
        ((ItemTool)stack.getItem()).damageItem(stack, 1);
      }
      
      // If the block wasn't broken using the wrong tool, drop its items
      if (miningLevel >= block.getMiningLevel(this) && (toolType.equals(block.getToolType(this)) || !block.isToolTypeForced(this))) dropItems();
      
      setBlock(gr.blocks.get("Air"));
    }
  }
  
  public void dropItems() {
    ArrayList<ItemStack> items = block.getDroppedItems(this);
    for (ItemStack item : items) {
      terrainManager.spawnItemEntity(this, item);
    }
  }
  
  public boolean equals(Object o) {
    if (o == null) return false;
    if (o == this) return true;
    if (!(o instanceof BlockState)) return false;
    BlockState other = (BlockState)o;
    StateData otherState = other.getState();
    if (!other.getBlock().equals(getBlock()) || !other.getPosition().equals(getPosition())) return false;
    if ((state == null && other.getState() != null) || (state != null && other.getState() == null)) return false;
    if (state != null) {
      return state.getMap().equals(otherState.getMap());
    }
    return true;
  }
  
}

public class BlockAir extends Block {

  public BlockAir() {
    super("Air", -1); 
  }
  
  public void render(BlockState state, float leftX, float topY, int defaultSize) {}
  public boolean isCollidable(BlockState state) { return false; }
  public boolean isTargetable(BlockState state) { return false; }
  public boolean isOpaque(BlockState state) { return false; }
  public boolean doesBlockLight(BlockState state) { return false; }
  public boolean canShowInCreative() { return false; }
  
}

public class BlockSemiSolid extends Block {
  
  private boolean noDrops;
  private boolean overridable;
  
  public BlockSemiSolid(String name) {
    this(name, false, false); 
  }
 
  public BlockSemiSolid(String name, boolean noDrops, boolean overridable) {
    super(name, 0);
    this.noDrops = noDrops;
    this.overridable = overridable;
  }
  
  public void onCreate(BlockState state, boolean isLoad) { clearInput(); }
  public boolean isCollidable(BlockState state) { return false; }
  public boolean isOpaque(BlockState state) { return false; }
  public boolean doesBlockLight(BlockState state) { return false; }
  public int getRequiredSortLayer() { return 1; }
  public boolean isOverridable(BlockState state) { return overridable; }
  public boolean canSupportFallingBlock(BlockState state) { return false; }
  
  public void onNeighbourChanged(BlockState state, BlockState neighbour) {
    PVector ourPos = state.getPosition();
    PVector neighbourPos = neighbour.getPosition();
    if (neighbourPos.z == 1 && neighbourPos.y == ourPos.y + 1 && neighbour.isAir()) {
      state.dropItems();
      state.setBlock(gr.blocks.get("Air")); 
    }
  }
  
  public ArrayList<ItemStack> getDroppedItems(BlockState state) {
    if (!noDrops) return super.getDroppedItems(state);
    return getStacks();
  }
  
}

public class BlockTransparentSpecial extends Block {
  
   public BlockTransparentSpecial(String name, float hardness) {
     super(name, hardness);
   }
  
   public BlockTransparentSpecial(String name, float hardness, int miningLevel, String toolType, boolean requireToolType) {
     super(name, hardness, miningLevel, toolType, requireToolType);
   }
  
   public int getRequiredSortLayer() { return 1; }
   public boolean isOpaque(BlockState state) { return false; }
   public boolean doesBlockLight(BlockState state) { return false; }
   public boolean isCollidable(BlockState state) { return false; }  
}

public class BlockFalling extends Block {
  
  public BlockFalling(String name, float hardness) {
    super(name, hardness);
  }
 
  public BlockFalling(String name, float hardness, int miningLevel, String toolType, boolean requireToolType) {
    super(name, hardness, miningLevel, toolType, requireToolType);
  }
  
  public void onCreate(BlockState state, boolean isLoad) { clearInput(); fall(state); }
  public void onNeighbourChanged(BlockState state, BlockState neighbour) { fall(state); }
  
  public void fall(BlockState state) {
    PVector pos = state.getPosition();
    BlockState below = terrainManager.getBlockStateAt((int)pos.x, (int)pos.y + 1, (int)pos.z);
    
    if (below != null && below.isAir()) {
      terrainManager.spawnEntity(
        new EntityFallingBlock(
          new PVector(pos.x * BlockState.BLOCK_SIZE, pos.y * BlockState.BLOCK_SIZE),
          terrainManager.getDimension().getName(),
          state.getBlock(),
          state.getState(),
          new PVector(pos.x, pos.y, pos.z)
        )
      );
      state.setBlock(gr.blocks.get("Air"));
    }
  }
  
}

/**
* Redstone works on a "push based" system --- that is, redstone inputs need to check if the blocks around them are inputting
* signals, and keep track of this data. This class contains most of that logic, so that it is easy to implement new components.
*/
public class BlockRedstoneInput extends Block {
  
  public BlockRedstoneInput(String name, float hardness) {
    super(name, hardness);
  }
 
  public BlockRedstoneInput(String name, float hardness, int miningLevel, String toolType, boolean requireToolType) {
    super(name, hardness, miningLevel, toolType, requireToolType);
  }
  
  public int getTickChance(BlockState state) { return 0; } // Tick every frame
  public StateData getDefaultState() { return new StateData("north", 0, "east", 0, "south", 0, "west", 0, "hasChanged", true); } // The input values on each side, initially all off
  public boolean itemHasBlockRender() { return false; }
  
  public int getInputOnSide(BlockState state, Direction side) {
    StateData data = state.getState();
    // If all, find the largest redstone signal across all sides
    if      (side == Direction.ALL)   return max(new int[]{(int)data.get("north"), (int)data.get("east"), (int)data.get("south"), (int)data.get("west")});
    // Otherwise, get the signal for the given side
    else {
      switch (side) {
        case NORTH: return (int)data.get("north");
        case EAST:  return (int)data.get("east");
        case SOUTH: return (int)data.get("south");
        case WEST:  return (int)data.get("west");
        default:    return 0;
      }
    }
  }
  
  public void onTick(BlockState state) {
    StateData data = state.getState();
    data.set("north", findInputForSide(state, Direction.NORTH,  0, -1, (int)data.get("north")));
    data.set("east",  findInputForSide(state, Direction.EAST,   1,  0, (int)data.get("east")));
    data.set("south", findInputForSide(state, Direction.SOUTH,  0,  1, (int)data.get("south")));
    data.set("west",  findInputForSide(state, Direction.WEST,  -1,  0, (int)data.get("west")));
  }
  
  protected int findInputForSide(BlockState state, Direction side, int xOff, int yOff, int previous) {
    // If we can't connect redstone on the given side, turn it off
    if (!canConnectRedstone(state, side)) { return 0; }
    
    BlockState other = getBlockInDirection(state, xOff, yOff);
    
    // If there is no block there, turn it off
    if (other == null) { return 0; }
    
    // If the other block can't connect redstone, turn it off
    if (!other.getBlock().canConnectRedstone(other, side)) { return 0; }
    
    int signalIn = other.getBlock().getRedstoneOutput(other, side);
    
    // Check if something's changed
    if (signalIn != previous) state.getState().set("hasChanged", true);
    
    // Return the other block's redstone output level
    return signalIn;
  }
  
  protected BlockState getBlockInDirection(BlockState state, int xOff, int yOff) {
    PVector pos = state.getPosition();
    return terrainManager.getBlockStateAt((int)pos.x + xOff, (int)pos.y + yOff, (int)pos.z);
  }
  
}
