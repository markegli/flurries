import java.util.*;
import processing.pdf.*;
import java.text.*;

import java.awt.Polygon;
import java.awt.geom.*;

boolean reflect = true;
boolean bg = true;
Poly inProgress = null;
int rotations = 6;
int saveVal = 0;
float centerX, centerY, circleSize;
String saveId;
Flake editFlake;
Stack<Flake> bgFlakes;
List<Button> buttons;

Callback increaseCallback, decreaseCallback, mirrorCallback;
Callback clearCallback, layerCallback;
Callback undoCallback, redoCallback;
Callback pdfCallback, svgCallback, pngCallback;

PFont spartanBold;

void setup() {
  size(900,600);
  
  centerY = circleSize = height / 2.0;
  centerX = width - centerY;
  
  editFlake = new Flake();
  bgFlakes = new Stack<Flake>();
  DateFormat fileIdDate = new SimpleDateFormat("yyyyMMdd.HHmm"); 
  saveId = fileIdDate.format(new Date());
  
  spartanBold = createFont("leaguespartan-bold.ttf", 64);
  textFont(spartanBold);
  textAlign(LEFT, BASELINE);
  
  increaseCallback = new Callback() {
    public void callback(Button button) {
      rotations++;
      if (rotations > 18) {
        rotations = 18;
      }
    }
  };
  
  decreaseCallback = new Callback() {
    public void callback(Button button) {
      rotations--;
      if (rotations < 1) {
        rotations = 1;
      }
    }
  };
  
  mirrorCallback = new Callback() {
    public void callback(Button button) {
      reflect = !reflect;
      if (button != null) {
        button.label = reflect ? "Unmirror" : "Mirror";
      }
    }
  };
  
  clearCallback = new Callback() {
    public void callback(Button button) {
      commitShape();
      if (bgFlakes.size() > 0) {
        editFlake = bgFlakes.pop();
      } else {
        editFlake.clear();
      }
      inProgress = null;
    }
  };
  
  layerCallback = new Callback() {
    public void callback(Button button) {
      commitShape();
      if (editFlake.isEmpty()) {
        return;
      }
      
      bgFlakes.push(editFlake);
      editFlake = new Flake();
      inProgress = null;
    }
  };
  
  undoCallback = new Callback() {
    public void callback(Button button) {
      // Do we need to finalize the current shape first?
      commitShape();
      editFlake.undo();
    }
  };
  
  redoCallback = new Callback() {
    public void callback(Button button) {
      inProgress = null;
      editFlake.redo();
    }
  };
  
  pdfCallback = new Callback() {
    public void callback(Button button) {
      String flakeId = "flurry" + saveId + "-" + (++saveVal);
      if (bgFlakes.size() == 0) {
        editFlake.saveOutline(flakeId + ".pdf");
      } else {
        int layerNumber = 0;
        Flake combinationFlake = new Flake();

        for(Flake bgFlake : bgFlakes) {
          bgFlake.saveOutline(flakeId + "-layer" + (++layerNumber) + ".pdf");
          combinationFlake.addFlake(bgFlake);
        }
        editFlake.saveOutline(flakeId + "-layer" + (++layerNumber) + ".pdf");
        
        combinationFlake.addFlake(editFlake);
        combinationFlake.saveOutline(flakeId + "-combined.pdf");
      }
    }
  };
  
  buttons = new ArrayList<Button>();
  
  int symmetryButtonGroupY = height - 50;
  buttons.add(new Button("+", 10, symmetryButtonGroupY, 40, 40, increaseCallback));
  buttons.add(new Button("-", 60, symmetryButtonGroupY, 40, 40, decreaseCallback));
  buttons.add(new Button("Unmirror", 110, symmetryButtonGroupY, 180, 40, mirrorCallback));

  int saveButtonGroupY = symmetryButtonGroupY - 100;
  buttons.add(new Button("Save (PDF)", 10, saveButtonGroupY, 280, 40, pdfCallback));
  
  int layersButtonGroupY = saveButtonGroupY - 200;
  buttons.add(new Button("New Layer", 10, layersButtonGroupY, 280, 40, layerCallback));
  buttons.add(new Button("Clear Layer", 10, layersButtonGroupY + 50, 280, 40, clearCallback));
  buttons.add(new Button("Undo", 10, layersButtonGroupY + 100, 135, 40, undoCallback));
  buttons.add(new Button("Redo", 155, layersButtonGroupY +100, 135, 40, redoCallback));
  
}

void draw() {
  resetMatrix();
  background(0);
  
  for(Button button : buttons) {
    button.draw();
  }
  
  translate(centerX, centerY);
  
  if(bg) {
    noStroke();
    fill(96);
    for(Flake bgFlake : bgFlakes) {
      bgFlake.draw();
    }
  }
    
  stroke(255,255,255,192);
  fill(255);
  strokeWeight(1);

  editFlake.draw();
  
  for(int i = rotations - 1; i >= 0; i--) {
    if (inProgress != null) {
      rotate(2.0 * PI / rotations);
      if (i == 0) {
        fill(234,234,255);
      } else {
        fill(255,255,255,192);
      }
      
      inProgress.draw();
      
      if (reflect) {
        pushMatrix();
        scale(-1,1);
        fill(255,255,255,192);
        inProgress.draw();
        popMatrix();
      }
    }
  }
  
  if (bg) {
    fill(255,255,255,16);
    noStroke();
    ellipse(0, 0, 1.95 * circleSize, 1.95 * circleSize);
    
    if (rotations > 2 || reflect) {
      fill(255,255,255,32);
      beginShape();
      vertex(0, -circleSize);
      vertex(0, 0);
      float angle = PI / rotations;
      if (!reflect) angle = angle * 2.0;
      float tanY = circleSize / tan(angle);
      float tanX = circleSize;
      if (tanY > circleSize) {
        tanX *= circleSize / tanY;
        tanY = circleSize;
        vertex(tanX, -tanY);
      } else {
        vertex(tanX, -tanY);
        vertex(circleSize, -circleSize);
      }
      endShape();
    }
    
    fill(128);
    textSize(18);
    textAlign(LEFT, BOTTOM);
    text(
      "" + rotations + "-sided"
      + (reflect ? ", mirrored":""),
      -circleSize, circleSize
    );
  }
}

void mousePressed() {  
  Point clickPoint = new Point((double)(mouseX - centerX), (double)(mouseY - centerY));
  //if (modifier isn't down) clickPoint = snapPoint(clickPoint);

  if (clickPoint.x * clickPoint.x + clickPoint.y * clickPoint.y > circleSize * circleSize) {
    for (Button button : buttons) {
      button.click(mouseX, mouseY);
    }
    
    return;
  }
  
  if (inProgress == null) {
    // set the first point    
    inProgress = new Poly();
    inProgress.add(clickPoint);
  } else {
    if (mouseButton == RIGHT) {
      commitShape();
    } else {
      // set the next point
      inProgress.add(clickPoint);
    }
  }
}

void keyPressed() {
  if (key == 'i' || key == 'I') {
    bg = false;
    draw();
    
    save("flurry" + saveId + "-" + (++saveVal) + ".png");
    
    bg = true;
  } else if (key == 's' || key == 'S') {
    editFlake.saveSVG("flurry" + saveId + "-" + (++saveVal) + ".svg");
  } else if (key == 'n' || key == 'n') {
    layerCallback.callback(null);
  } else if (key == 'c' || key == 'C') {
    clearCallback.callback(null);
  }
}

void commitShape() {
  if (inProgress != null) {
    editFlake.addShape(inProgress);
    inProgress = null;
  }
}