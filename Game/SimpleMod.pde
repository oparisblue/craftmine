public class SimpleMod implements Mod {
  
  /**
  * First init pass - for registering new things
  */
  public void preInit() {
    
    // Load the mod spritesheet
    PImage spritesheet = loadImage("mod.png");
    gr.beginSmartRegistry(spritesheet);
    
    // Register a Block
    gr.sr(new BlockSemiSolid("Red Torch") {
      public Light getLight(BlockState state) { return new Light(16, color(255, 0, 0)); }
    });
    
    // Register a Crafting Recipe
    gr.cr(new ShapelessRecipe(getBlockIS("Red Torch"), getBlockIS("Torch")));
    
  }
  
  /**
  * Second init pass - for changing things registered by other mods, etc
  */
  public void init(){}
  
  /**
  * Called every tick
  */
  public void tick(){}
}
