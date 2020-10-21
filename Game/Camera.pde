/**
* The camera renders a small portion of the world to the screen.
*/
public class Camera {
  
  protected float x = 0;
  protected float y = 0;
  protected boolean fullBright = false;
  
  public static final int CHUNK_WIDTH = TerrainManager.W * BlockState.BLOCK_SIZE;
  
  /**
  * Pan the camera (instantly) to look at another area of the world.
  */
  public void pan(float x, float y) {
    this.x = x;
    this.y = y;
  }
  
  public void setFullBright(boolean fullBright) {
    this.fullBright = fullBright;
  }
  
  /**
  * Clear the screen and output the camera's contents to it.
  */
  public void render() {
    background(sky.getTopGradientColour());
    
    float xChunk = this.x / (float)CHUNK_WIDTH;
    int nextChunk = floor(xChunk) * TerrainManager.W;
    int startY = ceil(this.y / BlockState.BLOCK_SIZE);
    int endY = min(startY + ceil(height / BlockState.BLOCK_SIZE), TerrainManager.H - 1);
    float xPos = -1 * ((xChunk - floor(xChunk)) * CHUNK_WIDTH);
    boolean drawing = true;
    
    // Load appropriate chunks
    
    terrainManager.loadChunksAround(nextChunk);
    
    // Draw blocks
    while (drawing) {
      ArrayList<BlockState>[][] chunk = terrainManager.chunks.get(terrainManager.chunkKey(nextChunk));
      nextChunk += TerrainManager.W;
      if (chunk == null) break;
      for (int x = 0; x < chunk.length; x++) {
        for (int y = startY - 1; y <= endY; y++) {
          if (y < 0) continue;
          
          ArrayList<BlockState> cell = chunk[x][y];
          BlockState bg = cell.get(0);
          BlockState fg = cell.get(1);
          
          float yPos = floor((y * BlockState.BLOCK_SIZE) - this.y);
          
          Light light = lightMap.getLightAt(new PVector(fg.getPosition().x, fg.getPosition().y));
          
          noStroke();
          
          if (!fullBright && (light == null || light.getLevel() == 0)) {
            fill(0);
            rect(xPos, yPos, BlockState.BLOCK_SIZE, BlockState.BLOCK_SIZE);
            continue;
          }
          
          if (!fullBright) {
            color colour = light.getColour();
            tint(red(colour), blue(colour), green(colour));
          }
          
          if (!bg.getBlock().isOpaque(bg) && !fg.getBlock().isOpaque(fg)) {
            color top = sky.getTopGradientColour();
            color bot = sky.getBottomGradientColour();
            float botPerc = (float)y / TerrainManager.H;
            float topPerc = 1 - botPerc;
            fill(color((red(top) * topPerc) + (red(bot) * botPerc), (green(top) * topPerc) + (green(bot) * botPerc), (blue(top) * topPerc) + (blue(bot) * botPerc)));
            rect(xPos, yPos, BlockState.BLOCK_SIZE, BlockState.BLOCK_SIZE);
          }
          if (!fg.getBlock().isOpaque(fg) && !bg.isAir()) {
            bg.render(xPos, yPos);
            fill(0, 0, 0, 128);
            rect(xPos, yPos, BlockState.BLOCK_SIZE, BlockState.BLOCK_SIZE);
          }
          fg.render(xPos, yPos);
          
          // Lighting
          if (!fullBright && light.getLevel() < 16) {
            fill(0, 0, 0, 255 - map(light.getLevel(), 0, 16, 0, 255));
            rect(xPos, yPos, BlockState.BLOCK_SIZE, BlockState.BLOCK_SIZE);
          }
          
        }
        xPos += BlockState.BLOCK_SIZE;
        if (xPos >= width) { drawing = false; break; }
      }
    }
    
    noTint();
    
    // Draw entities
    for (Entity entity : terrainManager.entities) {
      PVector pos = entity.getPosition();
      if (pos.x >= this.x && pos.x <= this.x + width && pos.y >= this.y && pos.y <= this.y + height) {
        entity.render(pos.x - this.x, pos.y - this.y); 
      }
    }
    
  }
  
}

public class FollowCamera extends Camera {
  
  private Entity target;
  
  private float halfTargetWidth;
  private float halfTargetHeight;
  
  public FollowCamera(Entity target) {
    if (target == null) return;
    this.target = target;
    float[] bb = target.getBoundingBox();
    halfTargetWidth = (bb[2] - bb[0]) * BlockState.BLOCK_SIZE;
    halfTargetHeight = (bb[3] - bb[1]) * BlockState.BLOCK_SIZE;
  }
  
  public void render() {
    PVector pos = target.getPosition();
    pan(pos.x - (width / 2) + halfTargetWidth, pos.y - (height / 2) + halfTargetHeight);
    super.render();
  }
  
  public void changeTarget(Entity target) {
    this.target = target; 
  }
  
}

public class GUICamera extends FollowCamera {
  
  public boolean guiOnlyMode = false;
 
  public GUICamera(Entity target) {
    super(target);
  }
  
  public void render() {
    if (!guiOnlyMode) super.render();
    
    // Copy the gui list as it currently is, so that adding / removing guis doesn't take effect until next render
    Object[] guis = guiScreens.toArray();
    for (Object gui : guis) {
      ((GUI)gui).render();
    }
    
    if (guiUtils.heldItem != null) {
      int size = guiUtils.SLOT_SIZE - 2;
      guiUtils.drawItem(mouseX - (size / 2), mouseY - (size / 2), size, guiUtils.heldItem, false);
    }
    
    guiUtils.cleanup();
    
  }
  
  public PVector getOffset() {
    return new PVector(x, y); 
  }
  
}
