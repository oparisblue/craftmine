public Sky sky = new Sky();

public class Sky {
  
  private Light sunlight = new Light(16);
 
  public Light getSunlight() {
    return sunlight;
  }
  
  public color getTopGradientColour() {
     return color(220,240,250);
  }
  
  public color getBottomGradientColour() {
    return color(1,87,155);
  }
  
}
