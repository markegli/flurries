class Poly {
  Vector<Point> points;
  
  Poly() {
    points = new Vector<Point>();
  }
  
  void add(Point newPoint) {
    points.add(newPoint);
  }
  
  Polygon getShape() {
    Polygon polyShape = new Polygon();
    for (Point shapePoint : points) {
      polyShape.addPoint((int)shapePoint.x,(int)shapePoint.y);
    }
    return polyShape;
  }
  
  void draw() {
    draw(g);
  }
  
  void draw(PGraphics pg) {
    if (points.size() == 1) {
      pg.ellipse((float)points.get(0).x, (float)points.get(0).y, 3.0, 3.0);
    } else if (points.size() == 2) {
      pg.line((float)points.get(0).x, (float)points.get(0).y, (float)points.get(1).x, (float)points.get(1).y);
    } else if (points.size() > 2) {
      // draw the shape
      pg.beginShape();
      Point previousPoint = null;
      for (Point shapePoint : points) {
        // Avoid drawing lines with no length for Silhouette DXF import.
        if (!shapePoint.equals(previousPoint)) {
          pg.vertex((float)shapePoint.x, (float)shapePoint.y);
        }
        previousPoint = shapePoint;
      }
      if (previousPoint == null || !previousPoint.equals(points.get(0))) {
          pg.vertex((float)points.get(0).x, (float)points.get(0).y);
      }
      pg.endShape();
    }
  }
}