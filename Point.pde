class Point {
  double x;
  double y;
  
  Point(double xVal, double yVal) {
    x = xVal;
    y = yVal;
  }
  
  boolean equals(Point that) {
    // Compare using an epsilon. Since 1 is an interface pixel, 0.001 is perfectly acceptable.
    double epsilon = 0.001;
    return that != null && Math.abs(this.x - that.x) < epsilon && Math.abs(this.y - that.y) < epsilon;
  }
}