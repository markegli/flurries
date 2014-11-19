class Flake {
  Vector<Poly> addShapes;
  Vector<Poly> subShapes;
  
  private Area flakeArea;
  
  Flake()
  {
    addShapes = new Vector<Poly>();
    subShapes = new Vector<Poly>();
  }
  
  void addShape(Poly add)
  {
    addShapes.add(add);
  }
  
  void subShape(Poly sub)
  {
    subShapes.add(sub);
  }
  
  void draw()
  {
    for(int i = 0; i < rotations; i++)
    {
      for(Poly drawShape : addShapes)
      {
        drawShape.draw();
        if (reflect)
        {
          pushMatrix();
          scale(-1,1);
          drawShape.draw();
          popMatrix();
        }
      }
      rotate(2.0 * PI / rotations);
    }
  }
  
  void calcArea()
  {
    if (addShapes.size() == 0)
    {
      flakeArea = null;
      return;
    }
    
    flakeArea = new Area(addShapes.get(0).getShape());
    for (int i = 1; i < addShapes.size(); i++)
    {
      flakeArea.add(new Area(addShapes.get(i).getShape()));
    }
    
    if (reflect) flakeArea.add(flakeArea.createTransformedArea(AffineTransform.getScaleInstance(-1, 1)));
    
    Area rotateArea = (Area)flakeArea.clone();
    for (int i = 1; i < rotations; i++)
    {
      flakeArea.add(rotateArea.createTransformedArea(AffineTransform.getRotateInstance(2.0d * PI * i / rotations)));
    }
  }
  
  void saveOutline(String fileName)
  {
    // do the work to make the Area!!!
    calcArea();
    if (flakeArea == null) return;
    
    pushMatrix();
    resetMatrix();

    beginRecord(PDF, fileName);
    translate(width/2,height/2);

    background(255);
    noFill();
    stroke(0);
    strokeWeight(1);
    
    //noStroke();
    //fill(0);
    
    //this.draw();
    
    ArrayList<double[]> areaPoints = new ArrayList<double[]>();
    ArrayList<Line2D.Double> areaSegments = new ArrayList<Line2D.Double>();
    double[] coords = new double[6];
    
    for (PathIterator pi = flakeArea.getPathIterator(null); !pi.isDone(); pi.next()) {
        // The type will be SEG_LINETO, SEG_MOVETO, or SEG_CLOSE
        // Because the Area is composed of straight lines
        int type = pi.currentSegment(coords);
        // We record a double array of {segment type, x coord, y coord}
        double[] pathIteratorCoords = {type, coords[0], coords[1]};
        areaPoints.add(pathIteratorCoords);
    }
    
    double[] start = new double[3]; // To record where each polygon starts
    
    for (int i = 0; i < areaPoints.size(); i++) {
        // If we're not on the last point, return a line from this point to the next
        double[] currentElement = areaPoints.get(i);
    
        // We need a default value in case we've reached the end of the ArrayList
        double[] nextElement = {-1, -1, -1};
        if (i < areaPoints.size() - 1) {
            nextElement = areaPoints.get(i + 1);
        }
    
        // Make the lines
        if (currentElement[0] == PathIterator.SEG_MOVETO) {
            start = currentElement; // Record where the polygon started to close it later
        } 
    
        if (nextElement[0] == PathIterator.SEG_LINETO) {
            areaSegments.add(
                    new Line2D.Double(
                        currentElement[1], currentElement[2],
                        nextElement[1], nextElement[2]
                    )
                );
        } else if (nextElement[0] == PathIterator.SEG_CLOSE) {
            areaSegments.add(
                    new Line2D.Double(
                        currentElement[1], currentElement[2],
                        start[1], start[2]
                    )
                );
        }
    }
    
    // areaSegments now contains all the line segments
    for(Line2D.Double line : areaSegments)
    {
      line((float)line.x1,(float)line.y1,(float)line.x2,(float)line.y2);
    }
    
    endRecord();
    popMatrix();
  }

  void savePDF(String fileName)
  {
    pushMatrix();
    resetMatrix();

    beginRecord(PDF, fileName);
    translate(width/2,height/2);

    background(255);
    noStroke();
    fill(0);
    
    this.draw();
    
    endRecord();
    popMatrix();
  }
  
  /*
  public void exportSVG(Vector<Point> points) {
    String svg = "<?xml version=\"1.0\" standalone=\"yes\"?>";
    svg += "<!DOCTYPE svg PUBLIC \"-//W3C//DTD SVG 1.1//EN\" \"http://www.w3.org/Graphics/SVG/1.1/DTD/svg11.dtd\">";
    svg += "<svg width=\"640px\" height=\"640px\" xmlns=\"http://www.w3.org/2000/svg\" version=\"1.1\"><path d=\"";
    svg += "M"+points.get(0).x+","+points.get(0).y+" ";
    for(int i = 0; i < points.size(); i++) {
       svg += "L"+points.get((i+1)%points.size()).x+","+points.get((i+1)%points.size()).y;
    }
    svg += "Z";
    
    svg += "\" stroke=\"#000\" fill=\"#000\" transform=\"translate(320,320)\" /></svg>";
    //var blob = new Blob([svg], {type: "text/plain;charset=utf-8"});
    //saveAs(blob, "snowflake.svg");
    saveStrings("flurry" + saveId + "-" + (++saveVal) + ".svg", new String[] { svg });
  }
  */
}
