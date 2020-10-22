/**
* Represents an inventory container that holds items. Each container is visualised in the game GUI as a group of slots.
* @author Orlando
*/
public class Container {
  
  protected ItemStack[] items;
  
  // This empty constructor provided to help subclasses, but be sure to make the items array by the end of your constructor!!! 
  protected Container() {}
  
  public Container(ItemStack[] items) {
    this.items = items;
  }
  
  public Container(int size) {
    items = new ItemStack[size];
    for (int i = 0; i < size; i++) items[i] = getEmptyIS();
  }
  
  public Container(XML xml) {
    XML[] xmlItems = xml.getChildren();
    ArrayList<ItemStack> tmpItems = new ArrayList<ItemStack>();
    for (int i = 0; i < xmlItems.length; i++) {
      if (!xmlItems[i].getName().equals("#text")) tmpItems.add(new ItemStack(xmlItems[i]));
    }
    items = new ItemStack[tmpItems.size()];
    for (int i = 0; i < tmpItems.size(); i++) items[i] = tmpItems.get(i);
  }
  
  public String toXML() {
    String result = "<items>";
    for (ItemStack item : items) {
      result += item.toXML();
    }
    return result + "</items>";
  }
  
  public int getSize() {
    return items.length; 
  }
  
  public ItemStack getAtSlot(int i) {
    if (i < 0 || i > getSize()) throw new Error("Invalid slot ID!");
    return items[i];
  }
  
  /**
  * Provider slots can't swap items, and always merge their item to the held item, rather than vis versa.
  */
  public boolean isProviderSlot() {
    return false; 
  }
  
  public void setAtSlot(ItemStack stack, int i) {
    if (i < 0 || i > getSize()) throw new Error("Invalid slot ID!");
    items[i] = stack;
  }
  
  /**
  * Add a stack to the first avaliable slot in the container. Will split the item over several slots if required.
  * @param stack The stack to add.
  * @returns The amount of items that were added.
  */
  public int addItem(ItemStack stack) {
    int amtToAdd = stack.getStackSize();
    int addedSoFar = 0;
    
    // Try merging with existing stacks before adding to a new slot
    for (int i = 0; i < getSize(); i++) {
      ItemStack slot = getAtSlot(i);
      // If this slot is the same type of item, has the same metadata, and is not full...
      if (slot.hasSameMetadata(stack) && slot.getStackSize() < slot.getItem().getMaxStackSize(stack.getState())) {
        int combined = slot.getStackSize() + stack.getStackSize();
        int maxStackSize = stack.getItem().getMaxStackSize(stack.getState());
        // Can all be added onto this stack
        if (combined <= maxStackSize) {
          slot.setStackSize(combined);
          return amtToAdd; // Added them all :)
        }
        // We have some items left over
        else {
          addedSoFar += maxStackSize - slot.getStackSize();
          slot.setStackSize(maxStackSize);
          stack.setStackSize(maxStackSize - combined);
        }
      }
    }
    
    // Couldn't merge it all, put the remainder into an empty slot
    for (int i = 0; i < getSize(); i++) {
      ItemStack slot = getAtSlot(i);
      if (slot.isEmpty()) {
        setAtSlot(stack, i);
        return amtToAdd; // Added them all :)
      }
    }
    
    // Couldn't add all the items
    return addedSoFar;
  }
  
  @SuppressWarnings("unused")
  public boolean slotCanAcceptItem(ItemStack stack, int i) {
    return true; 
  }
  
}

public class CraftingGrid extends Container {
 
  private CraftingResult resultSlot;
  private CraftingRecipe currentRecipe;
  private int tableSize;
  
  public CraftingGrid(int size, CraftingResult resultSlot) {
    super(size * size);
    tableSize = size;
    this.resultSlot = resultSlot;
    resultSlot.setGrid(this);
  }
  
  public void setAtSlot(ItemStack stack, int i) {
    super.setAtSlot(stack, i);
    doPossibleCraft();
  }
  
  public void doPossibleCraft() {
    currentRecipe = null;
    for (CraftingRecipe recipe : gr.crafting) {
      if (recipe.getMinTableSize() <= tableSize) {
        ItemStack result = recipe.getFromTable(this);
        if (!result.isEmpty()) {
          currentRecipe = recipe;
          resultSlot.setResult(result);
          return;
        }
      }
    }
    
    resultSlot.setResult(getEmptyIS());
  }
  
  public CraftingRecipe getCurrentRecipe() {
    return currentRecipe; 
  }
  
}

public class CraftingResult extends Container {
  
  private CraftingGrid grid;
  
  public CraftingResult() {
    super(1); 
  }
  
  public void setGrid(CraftingGrid grid) {
    this.grid = grid;
  }
  
  public void setResult(ItemStack result) {
    items[0] = new ItemStack(result);
  }
  
  public boolean slotCanAcceptItem(ItemStack stack, int i) {
    return false; 
  }
  
  public void setAtSlot(ItemStack stack, int i) {
    if (stack.isEmpty() && grid.getCurrentRecipe() != null) {
      grid.getCurrentRecipe().crafted(grid);
      grid.doPossibleCraft();
    }
  }
  
}

public class CreativeInventory extends Container {
  
  public CreativeInventory() {
    // Find all registered (and participating!) blocks and items from the game registry and add them
    
    ArrayList<ItemStack> participatingItems = new ArrayList<ItemStack>();
    
    for (Block block : gr.blocks.all()) {
      if (block.canShowInCreative()) participatingItems.add(getBlockIS(block.getName()));
    }
    
    for (Item item : gr.items.all()) {
      if (item.canShowInCreative()) participatingItems.add(getIS(item.getName()));
    }
    
    // Make the smallest list of items possible (yet still divisible by 9)
    items = new ItemStack[(ceil(participatingItems.size() / 9) + 1) * 9];
    
    for (int i = 0; i < items.length; i++) {
      if   (i < participatingItems.size()) items[i] = participatingItems.get(i);
      else items[i] = getEmptyIS();
    }
  }
  
  public ItemStack getAtSlot(int i) {
    if (i < 0 || i > getSize()) return getEmptyIS();
    if (items[i].isEmpty()) return items[i];
    return cloneIS(items[i]);
  }
  
  public void setAtSlot(ItemStack stack, int i) {} // Can't override items in the creative inventory
  public boolean isProviderSlot() { return true; } // Opt in for the alternate slot behaviour
  
}
