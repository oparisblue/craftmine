/**
* The lightmap stores and calculates lighting values for every block position.
* @author Orlando
*/
public class LightMap {
 
  public HashMap<PVector, Light> lights = new HashMap<PVector, Light>();
  public HashMap<PVector, Light> lightSources = new HashMap<PVector, Light>();
  
  /**
  * Get the light level at a given location.
  * @param The location.
  * @returns The light level. This may range between 0 and 16, with 0 being the darkest and 16 being the brightest.
  */
  public Light getLightAt(PVector pos) {
    return lights.get(pos);
  }
  
  /**
  * Recalculate <strong>every</strong> light source recursively. This function is very expensive, and you should avoid calling it as much as possible
  * (for example, set up / update all light sources and then call this, rather than calling it for each light source).
  */
  public void recalculateLighting() {
    lights.clear();
    // Light Sources
    for (PVector pos : lightSources.keySet()) {
      recalculateLighting(pos, lightSources.get(pos), Direction.NONE);
    }
    surfaceLighting();
  }
  
  /**
  * Recursive function which makes light spread out from light sources.
  * <ul>
  * <li>Light spreads out in the four cardinal directions from each position.
  * <li>Every time the light spreads, the light level goes down by one.</li>
  * <li>If the light reaches a position which has already been visited, the higher light level wins (note: this also stops one of the recursive calls).</li>
  * <li>The recursive function ends when its light level reaches 0.</li>
  * </ul>
  * @param pos The position at which to recalculate lighting.
  * @param level The new light level for this position.
  */
  private void recalculateLighting(PVector pos, Light light, Direction from) {
    Light old = getLightAt(pos);
    if (old == null || light.getLevel() > old.getLevel()) {
      lights.put(pos, light);
      Light next = light.next(old);
      BlockState state = terrainManager.getBlockStateAt((int)pos.x, (int)pos.y, 1);
      if (next != null && state != null && !state.getBlock().doesBlockLight(state)) {
        if (from != Direction.NORTH) recalculateLighting(new PVector(pos.x,     pos.y - 1), next, Direction.SOUTH);
        if (from != Direction.EAST)  recalculateLighting(new PVector(pos.x + 1, pos.y),     next, Direction.WEST);
        if (from != Direction.SOUTH) recalculateLighting(new PVector(pos.x,     pos.y + 1), next, Direction.NORTH);
        if (from != Direction.WEST)  recalculateLighting(new PVector(pos.x - 1, pos.y),     next, Direction.EAST);
      }
    }
  }
  
  /**
  * Although the regular lighting works fine for caves, the top of the world should get lit up by the sun.
  * <p>One approach would be to create columns of light sources for every single column in every single chunk,
  * stopping when you hit a solid block. However, this would require you to clean up those light sources when 
  * loading / unloading, and to change / regenerate them all when, for example, a new block is placed down.</p>
  * <p>This method simulates that approach, but simply spawns lights as needed, instead of adding them as sources.</p>
  */
  private void surfaceLighting() {
    Sky sky = terrainManager.getDimension().getSky();
    for (ArrayList<BlockState>[][] chunk : terrainManager.chunks.values()) {
      int tlX = (int)chunk[0][0].get(0).getPosition().x; // Top-Left x position
      for (int x = 0; x < TerrainManager.W; x++) {
        for (int y = 0; y < TerrainManager.H; y++) {
          lights.put(new PVector(tlX + x, y), sky.getSunlight());
          BlockState state = chunk[x][y].get(1);
          if (state.getBlock().doesBlockLight(state)) break;
          recalculateLighting(new PVector(tlX + x + 1, y), sky.getSunlight(), Direction.WEST);
          recalculateLighting(new PVector(tlX + x - 1, y), sky.getSunlight(), Direction.EAST);
        }
      }
    }
  }
  
}

public class Light {
  
  private int level;
  private color colour;
  
  public Light(int level) {
    this(level, color(255)); 
  }
  
  public Light(int level, color colour) {
    this.level = min(max(0, level), 16);
    this.colour = colour;
  }
  
  /**
  * Get the colour of the light to be emitted by this light.
  * @returns The colour.
  */
  public color getColour() {
    return colour;
  }
  
  /**
  * Get the current light level to be emitted by this light.
  * @returns The light level. 
  */
  public int getLevel() {
    return level;
  }
  
  /**
  * Get the next light value used when this light spreads into adjacent squares.
  * @param other The value of another light on the same square as this one (if any). Mixes this light's colour with it if such a light exists.
  * @returns The light to be used when spreading to adjacent squares.
  */
  public Light next(Light other) {
    if (level - 1 == 0) return null;
    if (other == null) return new Light(level - 1, colour);
    return new Light(level - 1, color(
      (red(colour)   + red(other.getColour()))   / 2,
      (green(colour) + green(other.getColour())) / 2,
      (blue(colour)  + blue(other.getColour()))  / 2
    ));
  }
  
}

public LightMap lightMap = new LightMap();
