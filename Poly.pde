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
  
  Polygon getShape()
  {
    Polygon polyShape = new Polygon();
    for(Point shapePoint : points)
    {
      polyShape.addPoint((int)shapePoint.x,(int)shapePoint.y);
    }
    return polyShape;
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
      beginShape();
      for(Point shapePoint : points)
      {
        vertex((float)shapePoint.x, (float)shapePoint.y);
      }
      endShape(CLOSE);
    }
  }
}