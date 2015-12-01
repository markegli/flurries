class TextBox {
  String text;
  int x, y, width, height;
  
  private float textScale = 1.0/20;
  
  TextBox(int x, int y, int width, int height, String text) {
    this.text = text;
    this.x = x;
    this.y = y;
    this.width = width;
    this.height = height;
  }
  
  void draw() {
    fill(48);
    noStroke();
    rect(x, y, width, height, 10);
    
    fill(192);
    textSize(textScale * width);
    textAlign(CENTER, CENTER);
    text(text, x + 5, y + 5, width - 10, height - 10);
  }
}