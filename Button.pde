class Button {
  String label;
  int x, y, width, height;
  Callback callback;
  
  private float textScale = 0.667;
  
  Button(String label, int x, int y, int width, int height, Callback callback) {
    this.label = label;
    this.x = x;
    this.y = y;
    this.width = width;
    this.height = height;
    this.callback = callback;
  }
  
  void draw() {
    noStroke();
    
    if (callback != null) {
      fill(48);
      rect(x, y, width, height, 10);
    }
    
    fill(192);
    textSize(textScale * height);
    textAlign(CENTER, TOP);
    text(label, (float)x + width / 2.0, (float)y + ((1.0 - textScale) * height / 2.0));
  }
  
  void click(int mouseX, int mouseY) {
    if (!contains(mouseX, mouseY)) {
      return;
    }
    
    // process click.
    if (callback != null) {
      callback.callback(this);
    }
  }
  
  boolean contains(int mouseX, int mouseY) {
    return !(mouseX < x || mouseX > x + width || mouseY < y || mouseY > y + height);
  }
}

abstract class Callback {
  abstract void callback(Button button);
}