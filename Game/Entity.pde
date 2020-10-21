public abstract class Entity implements Collider {
  
  public static final float GRAVITY = 0.3;
  
  protected String dimension;
  protected PVector position;
  protected PVector velocity = new PVector(0, 0);
  protected ArrayList<BlockState> bottomBlocks = new ArrayList<BlockState>();
  protected int health;
  protected int maxHealth;
  
  private boolean justHitGround = false;
  
  public Entity(PVector position, String dimension, int maxHealth) {
    this.position = position;
    this.dimension = dimension;
    this.health = maxHealth;
    this.maxHealth = maxHealth;
  }
  
  public Entity() {}
  
  public String toXML() {
    return "<entity name=\"" + registeredName() + "\" health=\"" + health + "\" x=\"" + position.x + "\" y=\"" + position.y + "\" d=\"" + dimension + "\" vx=\"" + velocity.x + "\" vy=\"" + velocity.y + "\">" + additionalXMLAttributes().toXML() + "</entity>";
  }
  
  public StateData additionalXMLAttributes() {
    return new StateData();
  }
  
  public abstract Entity createInstance(PVector position, String dimension, PVector velocity, int health, StateData data);
  
  /**
  * Get the name used to register this entity in the game registry.
  * @return The registed name for the entity.
  */
  public abstract String registeredName();
  
  /**
  * Get the amount of health this entity has. Every 1i = half a heart.
  * @return Our health
  */
  public int getHealth() {
    return health;
  }
  
  /**
  * Get the maximum amount of health this entity can have. Every 1i = half a heart.
  * @return Our maximum health
  */
  public int getMaxHealth() {
    return maxHealth;
  }
  
  /**
  * Add health to this entity. This can be used to either hurt (e.g. by adding negative health) or heal this entity.
  * <p>Will not allow attempts to "overheal" (e.g. above max health). Will also despawn the entity if it goes below 0 health.</p>
  * @param The amount of health to add.
  */
  public void addHealth(int health) {
    this.health += health;
    if (this.health > maxHealth) this.health = maxHealth;
    else if (this.health <= 0) {
      onBeforeDeath();
      terrainManager.despawnEntity(this);
    }
  }
  
  /**
  * Called when the player right-clicks this entity to interact with it.
  * @param shift <code>true</code> if the SHIFT key was pressed down.
  * @return A boolean. When <code>true</code>, blocks the <code>onInteract</code> event from firing on the held item or the block behind.
  */
  @SuppressWarnings("unused")
  public boolean onInteract(boolean shift) { return false; }
  
  /**
  * Called when the player left-clicks this entity to attack it.
  * @param shift <code>true</code> if the SHIFT key was pressed down.
  * @return A boolean. When <code>true</code>, blocks the <code>onAttack</code> event from firing on the held item or the block behind.
  */
  @SuppressWarnings("unused")
  public boolean onAttack(boolean shift) { return false; }
  
  /**
  * Kill this entity (regardless of how much health it has).
  */
  public void kill() {
    addHealth(getMaxHealth() * -1);
  }
  
  /**
  * This is called after the entity dies (e.g reaches 0 health or less), but before it gets despawned by the terrain manager. Useful for cleanup, dropping items, etc.
  * @return A boolean. If this is <code>true</code>, then the entities death is cancelled (terrain manager never gets notified). This could be used in conjunction with adding more health to keep the entity alive.
  */
  public boolean onBeforeDeath() { return false; }
 
  public void update() {
    velocity.y += shouldApplyGravity() ? GRAVITY : 0;
    
    // Check if there are any objects around us that we have collided with
    
    position.x += velocity.x;
    position.y += velocity.y;
    
    float origYPos = position.y;
    float origYVel = velocity.y;
    
    float[] ourBB = getBoundingBox();
    
    int size = BlockState.BLOCK_SIZE;
    
    if (isCollidable()) {
      bottomBlocks.clear();
      for (int i = 0; i < 3; i++) {
        // Collide with blocks around this entity
        int columnLeft   = floor((position.x / size) + ourBB[0]);
        int columnRight  = floor((position.x / size) + ourBB[2]);
        int columnTop    = floor((position.y / size) + ourBB[1]);
        int columnBottom = floor((position.y / size) + ourBB[3]);
        boolean collided = false;
        for (int x = columnLeft; x <= columnRight; x++) {
          for (int y = columnTop; y <= columnBottom; y++) {
            BlockState state = terrainManager.getBlockStateAt(x, y, 1);
            if (state == null) continue;
            float[] othBB = state.getBoundingBox();
            
            if (i == 0 && y == columnBottom) {
              bottomBlocks.add(state);
            }
            
            if (state.getBlock().isCollidable(state)) {
              float[] pos = new float[]{
                (x * BlockState.BLOCK_SIZE) + (ourBB[0] * BlockState.BLOCK_SIZE), // our left       0
                (x * BlockState.BLOCK_SIZE) + (ourBB[2] * BlockState.BLOCK_SIZE), // our right      1
                (y * BlockState.BLOCK_SIZE) + (ourBB[1] * BlockState.BLOCK_SIZE), // our top        2
                (y * BlockState.BLOCK_SIZE) + (ourBB[3] * BlockState.BLOCK_SIZE), // our bottom     3
                (x * BlockState.BLOCK_SIZE) + (othBB[0] * BlockState.BLOCK_SIZE), // other left     4
                (x * BlockState.BLOCK_SIZE) + (othBB[2] * BlockState.BLOCK_SIZE), // other right    5
                (y * BlockState.BLOCK_SIZE) + (othBB[1] * BlockState.BLOCK_SIZE), // other top      6
                (y * BlockState.BLOCK_SIZE) + (othBB[3] * BlockState.BLOCK_SIZE), // other bottom   7
              };
              if ((i == 0 || i == 2) && pos[6] >= pos[2] && pos[7] <= pos[3]) { // Y Collision
                collided = true;
                position.y -= velocity.y;
                justHitGround = velocity.y > 0;
                velocity.y = velocity.y * state.getBlock().getPhysicsMaterial(state).getBounciness();
              }
              if (i == 1 && pos[1] > pos[4] && pos[0] < pos[5]) { // X Collision
                collided = true;
                position.x -= velocity.x;
                velocity.x = velocity.x * state.getBlock().getPhysicsMaterial(state).getBounciness();
                position.y = origYPos;
                velocity.y = origYVel;
                justHitGround = false;
              }
            }
            if (collided) break;          
          }
          if (collided) break;
        }
      }
    }
  }
  
  public abstract void render(float leftX, float topY);
  
  public boolean collides(Collider obj) {
    float[] ourBB = getBoundingBox();
    float[] otherBB = obj.getBoundingBox();
    return isCollidable() && otherBB[0] >= ourBB[0] && otherBB[0] <= ourBB[2] && otherBB[1] >= ourBB[1] && otherBB[1] <= ourBB[3];
  }
  
  public abstract float[] getBoundingBox();
  
  /**
  * @return Does this entity collide with anything (blocks, entities, etc)?
  */
  public boolean isCollidable() { return true; }
  
  /**
  * @return Does this entity check for collisions against other entities?
  */
  public boolean isEntityCollidable() { return true; }
  
  public boolean shouldApplyGravity() { return true; }
  
  public PVector getPosition() { return position; }
  
  public PVector getVelocity() { return velocity; }
  
  public String getDimension() { return dimension; }
  
  public boolean isFallDamageApplied() { return true; }
  
  protected void moveX(float amt) {
    float slipperiness = 0;
    float speediness = 1;
    if (bottomBlocks.size() > 0) {
      speediness = 0;
      for (BlockState state : bottomBlocks) {
        PhysicsMaterial phys = state.getBlock().getPhysicsMaterial(state);
        slipperiness += phys.getSlipperiness();
        speediness += phys.getSpeediness();
      }
      slipperiness /= bottomBlocks.size();
      speediness /= bottomBlocks.size();
    }
    if (amt == 0) velocity.x = velocity.x * slipperiness;
    else velocity.x = amt * speediness;
  }
  
  public boolean isOnGround() {
    if (justHitGround) {
      justHitGround = false;
      return true;
    }
    return velocity.y == 0 && 1 / velocity.y > 0; // +0 when on the ground, -0 when hitting the bottom of a block
  }
  
}

public interface Collider {
  public float[] getBoundingBox();
}

public class PhysicsMaterial {
  
  private float slipperiness;
  private float bounciness;
  private float speediness;
  
  public PhysicsMaterial(float slipperiness, float bounciness, float speediness) {
    this.slipperiness = abs(slipperiness);
    this.bounciness = (bounciness > 0) ? bounciness * -1 : bounciness;
    this.speediness = speediness;
  }
  
  public float getSlipperiness() {
    return slipperiness;
  }
  
  public float getBounciness() {
    return bounciness;
  }
  
  public float getSpeediness() {
    return speediness;
  }
  
}

public class EntityItem extends Entity {
  
  private ItemStack item;
  private int bob = 20;
  private int bobVel = 1;
  private int spawnTime;
  private boolean visible = true;
  private int flashCounter;
  
  public EntityItem(PVector position, String dimension, ItemStack item) {
    super(position, dimension, 2);
    this.item = item;
    spawnTime = millis() / 1000;
  }
  
  public EntityItem() {}
  
  public Entity createInstance(PVector position, String dimension, PVector velocity, int health, StateData data) {
    EntityItem entity = new EntityItem(position, dimension, (ItemStack)data.get("Item"));
    entity.velocity = velocity;
    entity.spawnTime = (millis() / 1000) - ((int)data.get("TimeAlive"));
    return entity;
  }
  
  public StateData additionalXMLAttributes() {
    return new StateData("TimeAlive", (millis() / 1000) - spawnTime, "Item", item); 
  }
  
  public String registeredName() {
    return "Item"; 
  }
  
  public void update() {
    super.update();
    bob += bobVel;
    if (bob == 21 || bob == 10) bobVel *= -1;
    
    for (SuctionBox suctionBox : terrainManager.getSuctionBoxes()) {
      if (position.x >= suctionBox.rect[0] &&
          position.x <= suctionBox.rect[2] &&
          position.y >= suctionBox.rect[1] &&
          position.y <= suctionBox.rect[3] &&
          suctionBox.suck(item)) {
        terrainManager.despawnEntity(this);
        return;
      }
    }
    
    if (secondsBeforeDespawn() != -1) {
      int secondsUntilDespawn = secondsBeforeDespawn() - ((millis() / 1000) - spawnTime);
      if (secondsUntilDespawn < 5) {
        flashCounter += deltaTime;
        if (flashCounter > 250) {
          flashCounter = 0;
          visible = !visible;
        }
      }
      if (secondsUntilDespawn == 0) {
        kill();
      }
    }
  }
  
  public boolean isFallDamageApplied() { return false; }
   
  public void render(float leftX, float topY) {
    if (visible && item.getItem() != null) item.getItem().render(item, leftX, topY + bob, round(BlockState.BLOCK_SIZE * 0.5));
  }
  
  public float[] getBoundingBox() {
    return new float[]{ 0.25, 0, 0.75, 1 };
  }
  
  public int secondsBeforeDespawn() {
    return 60;
  }
  
}

public class EntityFallingBlock extends Entity {
  
  private Block block;
  private StateData state;
  private PVector pos;
  
  public EntityFallingBlock(PVector position, String dimension, Block block, StateData state, PVector pos) {
    super(position, dimension, 1);
    this.block = block;
    this.state = state;
    this.pos = pos;
  }
  
  public EntityFallingBlock() {}
  
  public Entity createInstance(PVector position, String dimension, PVector velocity, int health, StateData data) {
    BlockState bs = (BlockState)data.get("Block");
    EntityFallingBlock entity = new EntityFallingBlock(position, dimension, bs.block, bs.state, bs.pos);
    entity.velocity = velocity;
    return entity;
  }
  
  public StateData additionalXMLAttributes() {
    return new StateData("Block", new BlockState(block, pos, state)); 
  }
  
  public String registeredName() {
    return "Falling Block"; 
  }
  
  public void addHealth(int amt) {}
  public void render(float leftX, float topY) {
    BlockState newState = new BlockState(block, pos, state);
    newState.render(leftX, topY);
    if (pos.z == 0) {
      fill(0, 0, 0, 128);
      rect(leftX, topY, BlockState.BLOCK_SIZE, BlockState.BLOCK_SIZE); 
    }
  }
  public float[] getBoundingBox() { return new float[]{ 0, 0, 0, 0 }; }
  
  public void update() {
    velocity.y += GRAVITY;
    position.y += velocity.y;
    pos.y = floor(position.y / BlockState.BLOCK_SIZE);
    BlockState below = terrainManager.getBlockStateAt((int)pos.x, (int)pos.y + 1, (int)pos.z);
    if (!below.isAir()) {
      if (below.getBlock().canSupportFallingBlock(below)) {
        terrainManager.getBlockStateAt((int)pos.x, (int)pos.y, (int)pos.z).setBlock(block, state);
      }
      else {
        terrainManager.spawnItemEntity(new BlockState(block, pos, state), getBlockIS(block.getName(), 1, state)); 
      }
      terrainManager.despawnEntity(this);
      terrainManager.requestLightingRecalc();
    }
  }
  
}

public Entity makeEntity(XML kv) {
  Entity templater = gr.entities.get(kv.getString("name"));
  return templater.createInstance(new PVector(kv.getFloat("x"), kv.getFloat("y")), kv.getString("d"), new PVector(kv.getFloat("vx"), kv.getFloat("vy")), kv.getInt("health"), new StateData(kv));
}
