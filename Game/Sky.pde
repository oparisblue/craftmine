/**
* Represents a skybox. Currently, this is pretty minimal, but eventually we may add a day-night cycle, weather, clouds, etc here.
* @author Orlando
*/
public class Sky {
  
  private color topColour;
  private color bottomColour;
  private Light sunlight;
  
  public Sky(color topColour, color bottomColour, int lightLevel) {
    this.topColour    = topColour;
    this.bottomColour = bottomColour;
    this.sunlight     = new Light(lightLevel);
  }
 
  public Light getSunlight() {
    return sunlight;
  }
  
  public color getTopGradientColour() {
     return topColour;
  }
  
  public color getBottomGradientColour() {
    return bottomColour;
  }
  
}
