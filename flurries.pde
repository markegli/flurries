/* draw a rect at an arbitrary angle */

import java.util.Vector;

boolean line = false;
boolean square = false;
Poly inProgress = null;
int rotations = 6;
Vector<Poly> addShapes;

class Point {
  double x;
  double y;
  
  Point(double xVal, double yVal)
  {
    x = xVal;
    y = yVal;
  }
}

class Poly {
  Vector<Point> points;
  
  Poly()
  {
    points = new Vector<Point>();
  }
  
  void add(Point newPoint)
  {
    points.add(newPoint);
  }
  
  void draw()
  {
    if (points.size() == 1)
    {
      ellipse((float)points.get(0).x, (float)points.get(0).y, 3.0, 3.0);
    }
    else if (points.size() == 2)
    {
      line((float)points.get(0).x, (float)points.get(0).y, (float)points.get(1).x, (float)points.get(1).y);
    }
    else if (points.size() > 2)
    {
      // draw the shape
      // draw the lines over it
    }
  }
}

void setup() {
  size(800,800);
  
  addShapes = new Vector<Poly>();
}

void draw() {
  background(0);
  stroke(255);
  fill(192);
  strokeWeight(1.5);
  
  translate(width / 2.0, height / 2.0);
  
  for(int i = 0; i < rotations; i++)
  {
    for(Poly drawShape : addShapes)
    {
      drawShape.draw();
      pushMatrix();
      scale(-1,1);
      drawShape.draw();
      popMatrix();
    }
    if (inProgress != null)
    {
      inProgress.draw();
      pushMatrix();
      scale(-1,1);
      inProgress.draw();
      popMatrix();
    }
    rotate(2.0 * PI / rotations);
  }
}

void mousePressed() {  
  Point clickPoint = new Point((double)(mouseX - width / 2.0), (double)(mouseY - height / 2.0));
  //if (modifier isn't down) clickPoint = snapPoint(clickPoint);

  if (!line && !square)
  {
    // set the first point    
    inProgress = new Poly();
    inProgress.add(clickPoint);
    
    line = true;
  }
  else if (line)
  {
    // set the second point
    inProgress.add(clickPoint);
    
    line = false;
    //square = true;
    
    addShapes.add(inProgress);
    inProgress = null;
  }
  else if (square)
  {
    // math :(
  }
}
