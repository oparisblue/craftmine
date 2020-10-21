public class Container {
  
  protected ItemStack[] items;
  
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
  
  public void setAtSlot(ItemStack stack, int i) {
    if (i < 0 || i > getSize()) throw new Error("Invalid slot ID!");
    items[i] = stack;
  }
  
  /**
  * Add a stack to the first avaliable slot in the container. Will split the item over several slots if required.
  * @param stack The stack to add.
  * @returns <code>true</code> if the stack was fully added. <code>false</code> if the stack was added only partially or not at all.
  */
  public boolean addItem(ItemStack stack, boolean fullAdd) {
    for (int i = 0; i < getSize(); i++) {
      ItemStack slot = getAtSlot(i);
      if (slot.hasSameMetadata(stack)) {
        int combined = slot.getStackSize() + stack.getStackSize();
        int maxStackSize = stack.getItem().getMaxStackSize(stack.getState());
        // Can all be added onto this stack
        if (combined <= maxStackSize) {
          slot.setStackSize(combined);
          return true;
        }
        // We have some items left over
        else {
          slot.setStackSize(maxStackSize);
          stack.setStackSize(maxStackSize - combined);
        }
      }
    }
    if (fullAdd) {
      for (int i = 0; i < getSize(); i++) {
        ItemStack slot = getAtSlot(i);
        if (slot.isEmpty()) {
          setAtSlot(stack, i);
          return true;
        }
      }
    }
    return false;
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
    if (stack.isEmpty()) {
      grid.getCurrentRecipe().crafted(grid);
      grid.doPossibleCraft();
    }
  }
  
}
