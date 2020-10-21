public class EntityPlayer extends Entity {
  
  public HotbarGUI hotbarGUI;
  public BlockHoverGUI blockHover;
  public InventoryGUI inventoryGui;
  
  private SuctionBox suctionBox;
  
  private boolean isEDown = false;
  private boolean isInventoryOpen = false;
  
  public Container inventory;
  public Container armour;
  public Container hotbar;
  public int hotbarSlot = 0;
  
  public EntityPlayer(PVector pos, String dimension) {
    this(pos, dimension, true); 
  }
  
  public EntityPlayer(PVector pos, String dimension, boolean doGUI) {
    super(pos, dimension, 20);
    hotbarGUI = new HotbarGUI();
    if (doGUI) guiScreens.add(hotbarGUI);
    blockHover = new BlockHoverGUI();
    if (doGUI) guiScreens.add(blockHover);
    inventoryGui = new InventoryGUI();
    
    inventory = new Container(9 * 3);
    hotbar = new Container(9);
    armour = new Container(4){
      public boolean slotCanAcceptItem(ItemStack stack, int i) {
        return stack.getItem().getItemType(stack).equals(new String[] { "Helmet", "Chestplate", "Leggings", "Boots" }[i]);
      }
    };
    
    suctionBox = new SuctionBox(new float[]{ pos.x, pos.y, pos.x + BlockState.BLOCK_SIZE, pos.y + BlockState.BLOCK_SIZE }){
      public boolean suck(ItemStack item) {
        boolean success       = inventory.addItem(item, false);
        if (!success) success = hotbar.addItem(item, false);
        if (!success) success = inventory.addItem(item, true);
        if (!success) success = hotbar.addItem(item, true);
        return success;
      }
    };
    terrainManager.addSuctionBox(suctionBox);
    
    inventory.setAtSlot(getIS("Gold Pickaxe"), 0);
    inventory.setAtSlot(getIS("Gold Shovel"), 1);
    inventory.setAtSlot(getIS("Stick", 64), 2);
    inventory.setAtSlot(getIS("Coal", 64), 3);
    inventory.setAtSlot(getBlockIS("Iron Ore", 64), 4);
    inventory.setAtSlot(getBlockIS("Furnace", 64), 5);
    inventory.setAtSlot(getBlockIS("Slime", 64), 6);
    inventory.setAtSlot(getBlockIS("Ice", 64), 7);
    inventory.setAtSlot(getBlockIS("Path", 64), 8);
    inventory.setAtSlot(getBlockIS("Chest", 64), 9);
    inventory.setAtSlot(getBlockIS("Sand", 64), 10);
    inventory.setAtSlot(getBlockIS("Item Frame", 64), 11);
    inventory.setAtSlot(getBlockIS("TNT", 64), 12);
  }
  
  public EntityPlayer() {}
  
  public Entity createInstance(PVector position, String dimension, PVector velocity, int health, StateData data) {
    EntityPlayer entity = new EntityPlayer(position, dimension);
    entity.velocity = velocity;
    entity.health = health;
    entity.inventory  = (Container)data.get("Inventory");
    entity.armour     = (Container)data.get("Armour");
    entity.hotbar     = (Container)data.get("Hotbar");
    entity.hotbarSlot = (int)data.get("Hotbar Slot");
    return entity;
  }
  
  public StateData additionalXMLAttributes() {
    return new StateData("Inventory", inventory, "Armour", armour, "Hotbar", hotbar, "Hotbar Slot", hotbarSlot); 
  }
  
  public String registeredName() {
    return "Player"; 
  }
  
  public void render(float leftX, float topY) {
    noStroke();
    fill(255, 0, 0);
    float[] bb = getBoundingBox();
    int s = BlockState.BLOCK_SIZE;
    float x1 = s * bb[0];
    float y1 = s * bb[1];
    rect(leftX + x1, topY + y1, ((s * bb[2]) - x1) + 1, ((s * bb[3]) - y1));
  }
  
  public void update() {
    super.update();
    
    if (!isInventoryOpen && isKeyDown('a')) moveX(-4.5);
    else if (!isInventoryOpen && isKeyDown('d')) moveX(4.5);
    else moveX(0);
    
    if (!isInventoryOpen && isOnGround() && isKeyDown(' ')) velocity.y -= 8;
    
    if (!isEDown && isKeyDown('e')) {
      if (guiUtils.isGuiOpen()) guiUtils.closeGui();
      else                      guiUtils.openGui(inventoryGui);
      isEDown = true;
    }
    
    if (!isKeyDown('e')) isEDown = false;
    
    if (isKeyDown('g')) {
      velocity.x = 0;
      velocity.y = 0;
      position.y -= Entity.GRAVITY;
    }
    
    camera.setFullBright(isKeyDown('f'));
    
    for (int i = 1; i <= 9; i++) {
      if (isKeyDown(String.valueOf(i).charAt(0))) {
        hotbarSlot = i - 1; 
      }
    }
    
    blockHover.update();
    
    if (!guiUtils.isGuiOpen() && (lMouseDown || rMouseDown)) {
      
      Entity entity = null;
      ArrayList<BlockState> states = blockHover.getStates();
      if (states.size() == 0) return;
      ItemStack selected = hotbar.getAtSlot(hotbarSlot);
      
      PVector offset = camera.getOffset();
      float x = offset.x + mouseX;
      float y = offset.y + mouseY;
      
      for (Entity e : terrainManager.entities) {
        PVector pos = e.getPosition();
        float[] bb = e.getBoundingBox();
        
        if (x >= pos.x + (bb[0] * BlockState.BLOCK_SIZE) && x <= pos.x + (bb[2] * BlockState.BLOCK_SIZE) && y >= pos.y + (bb[1] * BlockState.BLOCK_SIZE) && y <= pos.y + (bb[3] * BlockState.BLOCK_SIZE)) {
          entity = e;
          break;
        }
      }
      
      boolean clickComplete = false;
      
      // Fire event on entities
      if (entity != null) {
        if (rMouseDown) clickComplete = entity.onInteract(shiftKeyDown); 
        else if (lMouseDown) clickComplete = entity.onAttack(shiftKeyDown); 
      }
      
      // Fire event on blocks
      for (int i = 1; i >= 0; i--) {
        if (!clickComplete) {
          if (rMouseDown) clickComplete = states.get(i).getBlock().onInteract(states.get(1), shiftKeyDown);
          else if (lMouseDown) clickComplete = states.get(i).getBlock().onAttack(states.get(1), shiftKeyDown);
        }
      }
      
      // Fire event on held item
      if (!clickComplete) {
        if (selected.isEmpty()) {
          if (entity == null) {
            states.get((lMouseDown) ? 1 : 0).dealDamage(selected);
          }
          else if (entity != this && !(entity instanceof EntityItem) && firstClickFrame) {
            entity.addHealth(-1);
          }
        }
        else {
          if (rMouseDown) selected.getItem().onUse(selected, (entity == null) ? states : entity);
          else if (lMouseDown) selected.getItem().onAttack(selected, (entity == null) ? states : entity);
        }
      }
    }
    
    suctionBox.rect = new float[]{ position.x, position.y, position.x + BlockState.BLOCK_SIZE, position.y + BlockState.BLOCK_SIZE };
    
  }
  
  public float[] getBoundingBox() {
    return new float[]{ 0.25, 0, 0.75, 1.5 };
  }
  
  public ItemStack getHeldItem() {
    return hotbar.getAtSlot(hotbarSlot); 
  }
  
}

public class InventoryGUI extends GUI {
  
  private CraftingResult craftingResult = new CraftingResult();
  private CraftingGrid crafting = new CraftingGrid(2, craftingResult);
  
  
  public void render() {
    guiUtils.drawModalOverlay();
    PVector corner = guiUtils.drawTexturedModalRect(486, 532);
    
    guiUtils.drawContainer(corner.x + 16, corner.y + 16, player.armour, 1, true);
    
    fill(0);
    rect(corner.x + 16 + guiUtils.SLOT_SIZE, corner.y + 16, 132, 200);
    
    player.render(corner.x + guiUtils.SLOT_SIZE + 32, corner.y + 32);
    
    guiUtils.drawText(corner.x + guiUtils.SLOT_SIZE + 164, corner.y + 16, "Crafting", 64, 64, 64, false, false);
    guiUtils.drawContainer(corner.x + guiUtils.SLOT_SIZE + 164, corner.y + 48, crafting, 2, true);
    guiUtils.sprite("GUI Arrow", corner.x + (guiUtils.SLOT_SIZE * 3) + 180 , corner.y + 48 + (guiUtils.SLOT_SIZE / 2), 60, 48);
    guiUtils.drawContainer(corner.x + (guiUtils.SLOT_SIZE * 3) + 256 , corner.y + 48 + (guiUtils.SLOT_SIZE / 2), craftingResult, 1, true);
    guiUtils.drawText(corner.x + 16, corner.y + 232, "Inventory", 64, 64, 64, false, false);
    guiUtils.drawPlayerInventory(corner.x + 16, corner.y + 264);
  }
  
}

public class BlockHoverGUI extends GUI {
  
  public int x;
  public int y;
  public boolean visible = true;
  private ArrayList<BlockState> states;
  
  public void update() {
    PVector offset = camera.getOffset();
    
    int xOffset = -floor(offset.x - (floor(offset.x / BlockState.BLOCK_SIZE) * BlockState.BLOCK_SIZE));
    int yOffset = -floor(offset.y - (floor(offset.y / BlockState.BLOCK_SIZE) * BlockState.BLOCK_SIZE));    
    
    x = xOffset + (floor((float)(mouseX - xOffset) / BlockState.BLOCK_SIZE) * BlockState.BLOCK_SIZE);
    y = yOffset + (floor((float)(mouseY - yOffset) / BlockState.BLOCK_SIZE) * BlockState.BLOCK_SIZE);
    
    states = terrainManager.getBlockStatesAt(floor((offset.x + x) / BlockState.BLOCK_SIZE), floor((offset.y + y) / BlockState.BLOCK_SIZE));
    
    visible = states != null && states.size() > 0 && !(states.get(0).isAir() && states.get(1).isAir());
    
  }
 
  public void render() {
    if (visible) {
      stroke(255);
      fill(255, 255, 255, 32);
      rect(x - 1, y - 1, BlockState.BLOCK_SIZE, BlockState.BLOCK_SIZE);
    }
  }
  
  public ArrayList<BlockState> getStates() {
    return states;
  }
  
}

public class HotbarGUI extends GUI {
  
  private float x = (width / 2) - (((guiUtils.SLOT_SIZE + 2) * 9) / 2);
  private float y = height - 64;
 
  public void render() {
    
    guiUtils.drawContainer(x, y, player.hotbar, 9, false);
    noFill();
    stroke(255);
    strokeWeight(2);
    rect(x + (player.hotbarSlot * (guiUtils.SLOT_SIZE + 2)), y, guiUtils.SLOT_SIZE + 2, guiUtils.SLOT_SIZE + 2);
    strokeWeight(1);
    
  }
  
}
