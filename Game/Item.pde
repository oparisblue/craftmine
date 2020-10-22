@SuppressWarnings("unused")
public class Item {
  
  private String name = "";
  
  public Item() {}
  
  public Item(String name) {
    this.name = name; 
  }
  
  /**
  * Get the name of this item. This is used to refer to the block within the game's code. Should remain constant.
  * @param stack The containing ItemStack.
  * @returns The name of the item.
  */
  public String getName() { return name; } // Return the name given in the constructor.
  
  /**
  * Get the name of this item, as shown to the player (e.g. on tooltips). Typically identital to getName(), but this
  * can be changed depending on state, etc.
  * @param stack The containing ItemStack.
  * @returns The item's visible name.
  */
  public String getVisibleName(ItemStack stack) { return getName(); }
  
  /**
  * Get the thesaurusised name for this item. This is used to fuzzily match it when crafting or smelting, e.g. so that
  * coal and charcoal can both be used to make torches.
  * @param stack The containing ItemStack.
  * @returns The recipe thesaurus name for this item. 
  */
  public String getThesaurusName(ItemStack stack) { return getName(); }
  
  /**
  * Get the name of a registered texture which will be used to draw the item.
  * @param stack The containing ItemStack.
  * @returns The item's texture.
  */
  public String getTexture(ItemStack stack) { return name; } // The texture will usually be registered under the same name as the item.
  
  /**
  * Called to render this item in a custom way using the Processing drawing functions, rather than relying on the default renderer.
  * @param stack The containing ItemStack.
  * @param leftX The position (from the left of the screen) where drawing should commence.
  * @param topX The position (from the top of the screen) where drawing should commence.
  * @param defaultSize The default width & height of an item.
  * @returns A PImage which could be used as a mask for rendering the enchantment glow on this item. This image's pixels do not need to be colour accurate;
  * and such an image need not be returned if hasEnchantmentEffect always returns false (just return null instead).
  */
  public PImage render(ItemStack stack, float leftX, float topY, int defaultSize) {
    PImage img = gr.sprites.get(getTexture(stack));
    image(img, leftX, topY, defaultSize, defaultSize); // Render the texture at the given location.
    return img;
  }
  
  /**
  * Used to draw the durability bar. -1 means no durability bar. Otherwise, values range from 0f to 1f, where 0f is empty and 1f is full.
  * @param stack The containing ItemStack.
  * @return The durability amount.
  */
  public float getDurabilityAmount(ItemStack stack) { return -1; } // Most items don't have a durability bar.
  
  /**
  * There are certain item types which have special behaviour associated with them. An item is associated with its type here. Possible values
  * include "Pickaxe", "Axe", "Shovel", "Helmet", and so on. As these values are strings, it is very easy to create a new item type without
  * writing any additional code.
  * @param stack The containing ItemStack.
  * @returns The type of this item.
  */
  public String getItemType(ItemStack stack) {
    return "None"; // Most items have no type
  }
  
  /**
  * Some blocks require a certain mining level before they can be broken to yield their drops. This integer defines what level this item mines at.
  * @param stack The containing ItemStack.
  * @returns The mining level for this item.
  */
  public int getMiningLevel(ItemStack stack) {
    return 0; // Most items are not pickaxes
  }
  
  /**
  * Defines how much faster (or slower) you mine when using this item.
  * @param stack The containing ItemStack.
  * @returns The mining speed multiplier.
  */
  public float getSpeedMultiplier(ItemStack stack) {
    return 1; // Most items are not mining tools
  }
  
  /**
  * How much damage a single hit with this item does to an entity.
  * @param stack The containing ItemStack.
  * @return The damage multiplier.
  */
  public int getBaseDamage(ItemStack stack) { return 1; } // Most items deal 1 damage.
  
  /**
  * Get the maximum amount of this item that can be in a single stack.
  * @param state The item's array of state objects..
  * @return The maximum stack size.
  */
  public int getMaxStackSize(StateData state) { return ItemStack.MAX_STACK_SIZE; } // Most items stack to the max stack size.
  
  /**
  * Called every tick. Useful for some items which change (e.g. compass, clock, etc).
  * @param stack The containing ItemStack.
  */
  public void onUpdate(ItemStack stack) { } // Most items don't need updates.
  
  /**
  * Called when the item is right-clicked.
  * @param stack The containing ItemStack.
  * @param target The block or entity which was being targeted when the item was used. Can be null.
  */
  public void onUse(ItemStack stack, Object target) {
    if (target instanceof ArrayList<?>) ((BlockState)(((ArrayList)target).get(0))).dealDamage(stack); // By default, right-clicking breaks blocks on the background layer
  }
  
  /**
  * Called when the item is left-clicked.
  * @param stack The containing ItemStack.
  * @param target The block or entity which was being targeted when the item was used. Can be null.
  */
  public void onAttack(ItemStack stack, Object target) {
    if (target instanceof ArrayList<?>) ((BlockState)(((ArrayList)target).get(1))).dealDamage(stack); // By default, left-clicking breaks blocks on the foreground layer
    else if (target instanceof Entity && !(target instanceof EntityItem) && target != player && firstClickFrame) ((Entity)target).addHealth(getBaseDamage(stack)); // Hurt the entity
  }
  
  /**
  * If this is true, then the enchantment glow is rendered on-top of the item.
  * @param stack The containing ItemStack.
  * @return <code>true</code> if the glow effect is desired, <code>false</code> if it is not.
  */
  public boolean hasEnchantmentEffect(ItemStack stack) { return false; } // Most items don't have the enchantment glow.
  
  /**
  * Used to add extra information to an item's tooltip. Each line is a new array item.
  * @param stack The containing ItemStack.
  * @return The array of extra tooltip info.
  */
  public String[] getTooltip(ItemStack stack) { return new String[]{}; } // Most items do not need extra tooltip info. 
  
  /**
  * Used to define the colour of the name of a item's tooltip. Subsequent lines (e.g. those added with <code>getTooltip()</code>) are always gray.
  * @param stack The containing ItemStack.
  * @return The colour to use for its name in the tooltip.
  */
  public color getTooltipColour(ItemStack stack) { return color(255, 255, 255); } // Most items have a white title
  
  /**
  * Get the item state to use when creating a new stack of this item.
  * @param This item's default state.
  */
  public StateData getDefaultState() { return new StateData(); }
  
  /**
  * Returns the colour of the enchantment glint used when hasEnchantmentEffect returns <code>true</code>.
  * @param stack The containing ItemStack.
  * @return The tint colour.
  */
  public color getEnchantmentTintColour(ItemStack stack) { return color(255, 0, 255, 64); }
  
  /**
  * Returns how many ticks this item will burn for in a furnace. If this value is -1 then the item will not burn.
  * @param stack The containing ItemStack.
  * @return This item's burn time.
  */
  public int getBurnTime(ItemStack stack) { return -1; }
  
  /**
  * Should this item appear in the creative menu? Most items should, but this lets you turn it off for e.g. technical items.
  * @return <code>true</code> if it appears in the menu, <code>false</code> otherwise.
  */
  public boolean canShowInCreative() { return true; } // Most items should be shown in creative
  
}

public class ItemBlock extends Item {
  
  public String getName() {
    return "ItemBlock"; 
  }
  
  public boolean canShowInCreative() { return false; }
  
  public String getVisibleName(ItemStack stack) {
    BlockState state = getBlock(stack);
    return state.getBlock().getVisibleName(state);
  }
  
  public String getThesaurusName(ItemStack stack) {
    BlockState state = getBlock(stack);
    return state.getBlock().getThesaurusName(state);
  }
  
  public String getTexture(ItemStack stack) {
    BlockState state = getBlock(stack);
    return state.getBlock().getItemTexture(state);
  }
  
  public PImage render(ItemStack stack, float leftX, float topY, int defaultSize) {
    BlockState state = getBlock(stack);
    // Render using the block's in-world code
    if (state.getBlock().itemHasBlockRender()) {
      state.getBlock().render(state, leftX, topY, defaultSize);
      return null;
    }
    // Use the built-in item renderer instead
    return super.render(stack, leftX, topY, defaultSize);
  }
  
  public String[] getTooltip(ItemStack stack) {
    BlockState state = getBlock(stack);
    return state.getBlock().getTooltip(state);
  }
  
  public color getTooltipColour(ItemStack stack) {
    BlockState state = getBlock(stack);
    return state.getBlock().getTooltipColour(state);
  }
  
  public int getBurnTime(ItemStack stack) {
    BlockState state = getBlock(stack);
    return state.getBlock().getBurnTime(state);
  }
  
  public int getMaxStackSize(Object[] itemState) {
    BlockState state = (BlockState)itemState[0];
    return state.getBlock().getMaxStackSize(state);
  }
  
  public BlockState getBlock(ItemStack stack) {
    return (BlockState)stack.getState().get("Block"); 
  }
  
  /**
  * Place blocks on the background layer
  */
  public void onUse(ItemStack stack, Object target) {
    placeBlock(stack, target, 0);
  }
  
  /**
  * Place blocks on the foreground layer
  */
  public void onAttack(ItemStack stack, Object target) {
    placeBlock(stack, target, 1);
  }
  
  private void placeBlock(ItemStack stack, Object target, int layer) {
    BlockState state = getBlock(stack);
    int sortLayer = state.getBlock().getRequiredSortLayer();
    if ((sortLayer == -1 || sortLayer == layer) && target instanceof ArrayList<?>) {
      BlockState pos = ((BlockState)(((ArrayList)target).get(layer)));
      if (pos.isAir() || pos.getBlock().isOverridable(pos)) {
        StateData data = state.getBlock().doesPreserveState(state) ? state.getState() : state.getBlock().getDefaultState();
        // Rotate directional blocks
        if (state.getBlock().placeBlockDirectionally()) {
          data.set("direction", player.blockHover.direction);
        }
        pos.setBlock(state.getBlock(), data);
        if (!terrainManager.isCreative()) stack.addStackSize(-1);
      }
    }
  }
  
}

public class ItemStack {
  
  public static final int MAX_STACK_SIZE = 64;
  
  private int size;
  private Item item;
  private StateData state;
  
  public ItemStack(ItemStack stack) {
    this.size = stack.getStackSize();
    this.item = stack.getItem();
    this.state = stack.getState();
  }
  
  public ItemStack(Item item, int size, StateData state) {
    this.item = item;
    this.size = item == null ? size : min(MAX_STACK_SIZE, item.getMaxStackSize(state), size);
    this.state = state;
  }
  
  public ItemStack(XML xml) {
    if (xml.getName().equals("emptyItem")) {
      item = null;
      state = null;
      size = 0;
    }
    else {
      item = gr.items.get(xml.getString("name"));
      size = xml.getInt("amt");
      state = new StateData(xml);
    }
  }
  
  public String toXML() {
    if (isEmpty()) return "<emptyItem></emptyItem>";
    else           return "<item name=\"" + item.getName() + "\" amt=\"" + size + "\">" + ((state == null) ? "<null></null>" : state.toXML()) + "</item>"; 
  }
  
  public int getStackSize() {
    return size;
  }
  
  public void addStackSize(int add) {
    setStackSize(getStackSize() + add); 
  }
  
  public void setStackSize(int size) {
    if (size <= 0) {
      item = null;
      state = null;
      size = 0;
    }
    this.size = min(MAX_STACK_SIZE, item == null ? Integer.MAX_VALUE : item.getMaxStackSize(state), size);
  }
  
  public Item getItem() {
    return item;
  }
  
  public StateData getState() {
    return state;
  }
  
  public void setState(StateData state) {
    this.state = state;
  }
  
  public boolean couldMerge(ItemStack other) {
    return hasSameMetadata(other) && (size + other.getStackSize() <= item.getMaxStackSize(state));
  }
  
  public boolean hasSameMetadata(ItemStack other) {
    if (other.isEmpty() || isEmpty() || !item.getName().equals(other.getItem().getName())) return false;
    return stateMatches(other);
  }
  
  public boolean fuzzyMatch(ItemStack other) {
    if (isEmpty() && other.isEmpty()) return true;
    if ((isEmpty() && !other.isEmpty()) || (!isEmpty() && other.isEmpty())) return false;
    if (!item.getName().equals(other.getItem().getName())) return false;
    return stateMatches(other);
  }
  
  public boolean stateMatches(ItemStack other) {
    return other.getState().getMap().equals(getState().getMap());
  }
  
  public boolean isEmpty() {
    return item == null && state == null && size == 0; 
  }
  
  public String toString() {
    return isEmpty() ? "Empty" : item.getName() + " x " + size;
  }
  
}

public class ItemDurable extends Item {
  
  private float durability;
  
  public ItemDurable(String name, float durability) {
    super(name);
    this.durability = durability;
  }
  
  public int getMaxStackSize(StateData state) {
    return 1;
  }
  
  public float getDurabilityAmount(ItemStack stack) {
    return (float)stack.getState().get("Durability") / durability;
  }
  
  public void damageItem(ItemStack stack, float amount) {
    if (stack.getItem() instanceof ItemDurable) {
      float newDamage = ((float)stack.getState().get("Durability")) - amount;
      if (newDamage < 0) {
        stack.addStackSize(-1);
      }
      else {
        stack.getState().set("Durability",newDamage);
      }
    }
  }
  
  public StateData getDefaultState() {
    return new StateData("Durability", durability); 
  }
  
}

public class FuzzyItemStack extends ItemStack {
  
  private String name;
  private StateData state;
  
  public FuzzyItemStack(String name, StateData state) {
    super(null, 1, state);
    this.name = name;
    this.state = state;
  }
  
  public boolean fuzzyMatch(ItemStack other) {
    if (other.isEmpty()) return false;
    if (!name.equals(other.getItem().getThesaurusName(other))) return false;
    if (state == null) return true;
    return stateMatches(other);
  }
  
}

public class ItemTool extends ItemDurable {
  
  private String toolType;
  private int miningLevel;
  private float speedMultiplier;
  
  public ItemTool(String name, float durability, String toolType, int miningLevel, float speedMultiplier) {
    super(name, durability);
    this.toolType = toolType;
    this.miningLevel = miningLevel;
    this.speedMultiplier = speedMultiplier;
  }
  
  public String getItemType(ItemStack stack) {
    return toolType;
  }
  
  public int getMiningLevel(ItemStack stack) {
    return miningLevel;
  }
  
  public float getSpeedMultiplier(ItemStack stack) {
    return speedMultiplier;
  }
  
}

public ItemStack getEmptyIS() {
  return new ItemStack(null, 0, null);
}

public ItemStack getIS(String name) {
  Item item = gr.items.get(name);
  return new ItemStack(item, 1, item.getDefaultState()); 
}

public ItemStack getIS(String name, int amount) {
  Item item = gr.items.get(name);
  return new ItemStack(item, amount, item.getDefaultState());
}

public ItemStack getIS(String name, int amount, StateData state) {
  return new ItemStack(gr.items.get(name), amount, state);
}

public ItemStack getBlockIS(String name) {
  return getBlockIS(name, 1, new StateData());
}

public ItemStack getBlockIS(String name, int amount) {
  return getBlockIS(name, amount, new StateData());
}

public ItemStack getBlockIS(String name, int amount, StateData state) {
  return new ItemStack(gr.items.get("ItemBlock"), amount, new StateData("Block", new BlockState(gr.blocks.get(name), new PVector(0, 0, 0), state)));
}

public ItemStack getFuzzyIS(String name) {
  return new FuzzyItemStack(name, null);
}

public ItemStack getFuzzyIS(String name, StateData state) {
  return new FuzzyItemStack(name, state);
}

public ItemStack cloneIS(ItemStack stack) {
  return new ItemStack(stack.getItem(), stack.getStackSize(), stack.getState().clone());
}

public ArrayList<ItemStack> getStacks(ItemStack... stacks) {
  ArrayList<ItemStack> list = new ArrayList<ItemStack>();
  for (ItemStack stack : stacks) list.add(stack);
  return list;
}
