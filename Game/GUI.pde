public abstract class GUI {
  
  public abstract void render();
  
  public void onClosed() {}
  
}

public class GUIUtils {
  
  public final int SLOT_SIZE = 48;
  
  private int enchantmentGlintPos = 0;
  private int timeUntilGlintMove = 0;
  
  private ArrayList<GUI> modalGuis = new ArrayList<GUI>();
  
  public static final String GUI_FONT_CHARACTERS = " !\"#$%&'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_`abcdefghijklmnopqrstuvwxyz{|}~□¬©ø";
  
  public ItemStack heldItem = getEmptyIS();
  
  /**
  * Opens a modal GUI.
  * @param gui The GUI to open.
  */
  public void openGui(GUI gui) {
    guiScreens.add(gui);
    modalGuis.add(gui);
  }
  
  /**
  * Get the top-most modal GUI which is currently open.
  * @returns The top-most GUI.
  */
  public GUI getTopGui() {
    return modalGuis.size() == 0 ? null : modalGuis.get(modalGuis.size() - 1); 
  }
  
  /**
  * Closes the most recently opened modal GUI.
  */
  public void closeGui() {
    GUI gui = modalGuis.get(modalGuis.size() - 1);
    gui.onClosed();
    guiScreens.remove(gui);
    modalGuis.remove(gui);
    if (!isGuiOpen() && !heldItem.isEmpty()) {
      PVector pos = player.getPosition();
      terrainManager.spawnItemEntity(ceil(pos.x - BlockState.BLOCK_SIZE), ceil(pos.y), heldItem);
      heldItem = getEmptyIS();
    }
  }
  
  /**
  * Checks if there is at least one modal GUI open.
  * @returns <code>true</code> if there are any modal GUIs open.
  */
  public boolean isGuiOpen() {
    return modalGuis.size() > 0; 
  }
  
  /**
  * Call this after drawing each frame (e.g. from a GUICamera).
  * <p>Does tasks that should be called routinely, like increasing the enchantment glint amount, dropping held items if an inventory has been closed, etc.</p>
  */
  public void cleanup() {
    timeUntilGlintMove += deltaTime;
    if (timeUntilGlintMove >= 50) {
      timeUntilGlintMove = 0;
      enchantmentGlintPos++;
      if (enchantmentGlintPos == 16) enchantmentGlintPos = 0;
    }
    
  }
  
  /**
  * Draw a semi-transparent black overlay over everything drawn so far this frame,
  * so as to draw attention to a modal yet to be drawn.
  */
  public void drawModalOverlay() {
    noStroke();
    fill(0, 0, 0, 128);
    rect(0, 0, width, height);
  }
  
  /**
  * Draw the background image for a centered modal of any size.
  * @param w The width of the modal (in pixels)
  * @param h The height of the modal (in pixels)
  * @returns A vector containing the top-left x,y position of the modal.
  * @see GUIUtils#drawModalOverlay Useful to grey out everything behind the modal.
  */
  public PVector drawTexturedModalRect(int w, int h) {
    
    noStroke();
    
    int x = (width / 2) - ((w + 4) / 2);
    int y = (height / 2) - ((h + 4) / 2);
    
    fill(0);
    rect(x - 2, y - 2, w + 4, h + 4);
    fill(180);
    rect(x, y, w, h);
    fill(255);
    rect(x, y, w, 2);
    rect(x, y, 2, h);
    fill(136);
    rect((x + w) - 2, y, 2, h);
    rect(x, (y + h) - 2, w, 2);
    
    return new PVector(x + 2, y + 2);
  }
  
  /**
  * Draw some text to the screen, on a single line. Only basic upper and lowercase letters are supported, as well as numbers and some basic punctuation.
  * <p>Each character is 8x8 pixels wide.</p>
  * @param x The left corner of the first character to write.
  * @param y The top corner of the first character to write.
  * @param text The text to write to the screen
  */
  public void drawText(float x, float y, String text) {
    for (int i = 0; i < text.length(); i++) {
      image(gr.sprites.get(String.valueOf(text.charAt(i))), x, y, 16, 16);
      x += 16;
    }
  }
  
  /**
  * Draw text with effects applied to it. There are three effects which can be applied: colour, which draws the text in a different colour than white,
  * shadow, which draws an offset black copy of the text underneath the main copy, and garbled, which replaces each letter in the text with a random
  * one (which is different each draw call).
  * @param x The left corner of the first character to write.
  * @param y The top corner of the first character to write.
  * @param text The text to write to the screen (if using garbled, this specifies the length - you would have as many characters as you wanted garbled characters).
  * @param r The red component of the text colour.
  * @param g The green component of the text colour.
  * @param b The blue component of the text colour.
  * @param shadow <code>true</code> if the shadow effect should be applied.
  * @param garbled <code>true</code> if the garbled effect should be applied.
  * 2
  */
  public void drawText(float x, float y, String text, int r, int g, int b, boolean shadow, boolean garbled) {
    
    String output = "";
    
    if (garbled) {
      for (int i = 0; i < text.length(); i++) {
        output += String.valueOf(GUI_FONT_CHARACTERS.charAt(floor(random(0, GUI_FONT_CHARACTERS.length()))));
      }
    }
    else {
      output = text;
    }
    
    if (shadow) {
      tint(0, 0, 0);
      drawText(x + 1, y + 1, output);
    }
    tint(r, g, b);
    drawText(x, y, output);
    noTint();
  }
  
  /**
  * Draw every slot in a container to the screen.
  * @param x The left corner of the first slot.
  * @param y The top corner of the first slot.
  * @param container The container to draw the slots of.
  * @param rowSize How many slots fit on a single row before they wrap to the next line. This is typically 9.
  * @param interactable Can you move the items in the slots?
  */
  public void drawContainer(float x, float y, Container container, int rowSize, boolean interactable) {
    float startingX = x;
    noStroke();
    if (interactable) fill(255); else fill(0, 0, 0, 128);
    rect(x, y, (SLOT_SIZE + 2) * rowSize, (SLOT_SIZE + 2) * (container.getSize() / rowSize));
    for (int i = 0; i < container.getSize(); i++) {
      
      if (interactable) fill(47); else noFill();
      rect(x, y, SLOT_SIZE, SLOT_SIZE);
      if (interactable) fill(128); else fill(0, 0, 0, 64);
      rect(x + 2, y + 2, SLOT_SIZE - 2, SLOT_SIZE - 2);
      
      ItemStack item = container.getAtSlot(i);
      
      drawItem(x + 2, y + 2, SLOT_SIZE - 2, item, false);
      
      if (interactable && mouseX >= x + 2 && mouseX <= x + SLOT_SIZE && mouseY >= y + 2 && mouseY <= y + SLOT_SIZE) {
        if (firstClickFrame) {
          // No item being held -> pick up the item in the slot
          if (heldItem.isEmpty()) {
            // Right click -> split the stack in half, pick up the bigger half
            if (rMouseDown) {
              ItemStack slot = container.getAtSlot(i);
              float half = slot.getStackSize() / 2.0f;
              heldItem = new ItemStack(slot);
              heldItem.setStackSize(ceil(half));
              slot.setStackSize(floor(half));
            }
            // Left click -> pick up the whole stack
            else {
              heldItem = container.getAtSlot(i);
              container.setAtSlot(getEmptyIS(), i);
            }
          }
          // If this slot accepts items
          else if (container.slotCanAcceptItem(heldItem, i)) {
            // Items are of the same type and have the same metadata; and there is room in the stack -> merge stacks
            if (heldItem.couldMerge(item)) {
              // Right click -> merge one; Left click -> merge all
              int amt = rMouseDown ? 1 : heldItem.getStackSize();
              item.addStackSize(amt);
              heldItem.addStackSize(-amt);
            }
            // Slot is empty
            else if (item.isEmpty()) {
              // Right click -> merge one; Left click -> merge all
              int amt = rMouseDown ? 1 : heldItem.getStackSize();
              ItemStack newItem = new ItemStack(heldItem);
              newItem.setStackSize(amt);
              container.setAtSlot(newItem, i);
              heldItem.addStackSize(-amt);
            }
            // Swap held item with other item
            else {
              container.setAtSlot(heldItem, i);
              heldItem = item;
            }
          }
          // If this slot does not accept items; and the item we're holding is of the same type and has space -> add to held item
          else if (container.getAtSlot(i).hasSameMetadata(heldItem)) {
            int othAmt = container.getAtSlot(i).getStackSize();
            int currAmt = heldItem.getStackSize();
            int maxStack = heldItem.getItem().getMaxStackSize(heldItem.getState());
            if (currAmt < maxStack) {
               int amtToAdd = min(maxStack, currAmt + othAmt);
               heldItem.setStackSize(amtToAdd);
               container.getAtSlot(i).setStackSize(othAmt + (currAmt - amtToAdd));
               container.setAtSlot(container.getAtSlot(i), i); // Recalc (e.g. in a crafting table)
            }
          }
        }
        else {
          fill(180, 180, 180, 128);
          rect(x + 2, y + 2, SLOT_SIZE - 2, SLOT_SIZE - 2);
        }
      }
      
      if ((i + 1) % rowSize == 0) {
        x = startingX;
        y += SLOT_SIZE + 2;
      }
      else  x += SLOT_SIZE + 2;
    }
  }
  
  /**
  * Draw the player's inventory and hotbar to the screen.
  * @param x The left corner of the first slot.
  * @param y The top corner of the first slot.
  */
  public void drawPlayerInventory(float x, float y) {
    drawContainer(x, y, player.inventory, 9, true);
    drawContainer(x, y + ((SLOT_SIZE + 2) * 4), player.hotbar, 9, true);
  }
  
  /**
  * Draw a sprite at the given position with a given size.
  * @param name The registered name of the sprite.
  * @param x The left corner of the sprite.
  * @param y The top corner of the sprite.
  * @param w The width of the sprite.
  * @param h The height of the sprite.
  */
  public void sprite(String name, float x, float y, int w, int h) {
    image(gr.sprites.get(name), x, y, w, h);
  }
  
  /**
  * Draw a sprite at the given position with a given size.
  * @param name The registered name of the sprite.
  * @param x The left corner of the sprite.
  * @param y The top corner of the sprite.
  * @param w The width of the sprite.
  * @param h The height of the sprite.
  * @param sx The left corner of the subsection of the sprite to draw.
  * @param sy The top corner of the subsection of the sprite to draw.
  * @param sw The width of the subsection of the sprite to draw.
  * @param sh The height of the subsection of the sprite to draw.
  */
  public void sprite(String name, float x, float y, int w, int h, int sx, int sy, int sw, int sh) {
    image(gr.sprites.get(name).get(sx, sy, sw, sh), x, y, w, h);
  }
  
  /**
  * Draws an item to the screen. The drawing includes the durability bar, item count and enchantment glint.
  * @param x The left x coordinate of the item.
  * @param y The top y coordinate of the item.
  * @param size The size of the item rectangle (all items must be square).
  * @param item The itemstack to draw.
  * @param noUI Doesn't draw the amount in the stack or the durability bar (but still does the glint)
  */
  public void drawItem(float x, float y, int size, ItemStack stack, boolean noUI) {
    if (stack.isEmpty()) return; // Do nothing for empty items.
    Item item = stack.getItem();
    PImage maskImg = item.render(stack, x, y, size);    
    
    float durability = item.getDurabilityAmount(stack);
    int stackSize = stack.getStackSize();
    
    if (item.hasEnchantmentEffect(stack)) { // Draw the enchantment effect
      // Create a copy of the two images (so we do not modify the originals).
      PImage mask = maskImg.copy();
      PImage glint = gr.sprites.get("Enchantment Glint").copy();
      
      // Change the glint image, to provide the appearance that it is moving.
      glint.loadPixels();
      for (int gY = 0; gY < glint.pixels.length; gY += glint.width) { // For each row...
        color[] row = new color[glint.width];
        int i = 0;
        // Put the pixels at the back to the front
        for (int j = glint.width - enchantmentGlintPos; j < glint.width; j++) {
          row[i++] = glint.pixels[gY + j];
        }
        // From the position we now are at, add the pixels that used to be at the front
        int j = 0;
        for (; i < glint.width; i++) {
          row[i] = glint.pixels[gY + (j++)];
        }
        // Set this row's pixels to be the joint combination of those two rows
        for (int k = 0; k < glint.width; k++) {
          glint.pixels[gY + k] = row[k];
        }
      }
      glint.updatePixels();
      
      // Do a threshold to convert the mask image into an actual mask. Anywhere there is transparancy, the colour becomes black (which means not included in the mask).
      // Anywhere it is not transparent, the colour becomes white (which means it will be included in the mask).
      mask.loadPixels();
      for (int i = 0; i < mask.pixels.length; i++) {
        if (alpha(mask.pixels[i]) == 0) mask.pixels[i] = color(0, 0, 0);
        else                            mask.pixels[i] = color(255, 255, 255);
      }
      mask.updatePixels();
      // Mask the glint image so that it only remains where the item has pixels
      glint.mask(mask);
      // Tint the mask image so that appears purple, and has transparancy
      tint(item.getEnchantmentTintColour(stack));
      // Draw the enchantment glint
      image(glint, x, y, size, size);
      noTint();
    }
    if (!noUI && durability > -1) { // Draw the durability bar
      fill(0);
      rect(x + 2, y + size - 7, size - 4, 5);
      fill(255 * (1 - durability), 255 * (1.5 * durability), 0);
      rect(x + 2, y + size - 7, (size - 4) * durability, 5);
    }
    if (!noUI && stackSize > 1) { // Draw the item count
      drawText(x + size - (stackSize < 10 ? 16 : 32), y + size - 17, String.valueOf(stackSize), 255, 255, 255, true, false);
    }
    
  }
  
  public void drawPanel(float x, float y, int w, int h, color bg, color invertBg, boolean invert) {
    color light = color(255, 255, 255, 128);
    color dark = color(0, 0, 0, 128); 
    noStroke();
    fill(0);
    rect(x, y, w, h);
    fill(invert ? invertBg : bg);
    rect(x + 2, y + 2, w - 4, h - 4);
    fill(invert ? dark : light);
    rect(x + 2, y + 2, 2, h - 4);
    rect(x + 2, y + 2, w - 4, 2);
    fill(invert ? light : dark);
    rect(x + w - 4, y + 2, 2, h - 4);
    rect(x + 2, y + h - 4, w - 4, 2);
  }
  
  public void button(float x, float y, int w, int h, GUIAction clicked, String text) {
    button(x, y, w, h, clicked, text, color(171), color(129, 138, 191));
  }
  
  public void button(float x, float y, int w, int h, GUIAction clicked, String text, color bg, color hoverBg) {
    boolean hover = mouseX >= x && mouseX <= x + w && mouseY >= y && mouseY <= y + h;
    drawPanel(x, y, w, h, bg, hoverBg, hover);
    drawText(x + (w / 2) - (8 * text.length()), y + ((h - 8) / 2) - 4, text, 255, 255, 255, true, false);
    if (firstClickFrame && lMouseDown && hover) { clicked.action(); }
  }
   
  public void scrollPane() {}
  
}

public interface GUIAction {
  public void action();
}

public class GUIScrollbar {
  
  private float x;
  private float y;
  private int w;
  private int h;
  private float trackTop;
  private int trackHeight;
  private int rows;
  private boolean dragging = false;
  private float yOffset;
 
  public GUIScrollbar(float x, int w, int h, float trackTop, int trackHeight, int rows) {
     this.x = x;
     this.w = w;
     this.h = h;
     this.trackTop = trackTop;
     this.y = trackTop;
     this.trackHeight = trackHeight;
     this.rows = rows;
  }
  
  public void render() {
    boolean hover = mouseX >= x && mouseX <= x + w && mouseY >= y && mouseY <= y + h; 
    if (!lMouseDown) dragging = false;
    if (firstClickFrame && lMouseDown && hover) { dragging = true; yOffset = y - mouseY; }
    if (dragging) y = min(max(trackTop, mouseY + yOffset), trackTop + trackHeight - h);
    guiUtils.drawPanel(x, trackTop, w, trackHeight, DARK_GREY, DARK_GREY, true);
    guiUtils.drawPanel(x, y, w, h, MID_GREY, LIGHT_BLUE, hover || dragging);
  }
  
  public void setRows(int rows) {
    this.rows = rows;
  }
  
  public int getTopRow() {
    return min(floor((y - trackTop) / ((trackHeight - h) / (rows + 1))), rows);
  }
  
}

public color DARK_GREY  = color(150);
public color MID_GREY   = color(165);
public color LIGHT_GREY = color(180);
public color LIGHT_BLUE = color(129, 138, 191);
