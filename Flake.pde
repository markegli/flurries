class Flake {
  Stack<Poly> addShapes;
  Stack<Poly> redoShapes;
  
  private Area flakeArea;
  private Vector<Poly> areaShapes;
  
  private ArrayList<double[]> areaPoints;
  private double[] coords = new double[6];
  
  Flake() {
    addShapes = new Stack<Poly>();
    redoShapes = new Stack<Poly>();
  }
  
  void addShape(Poly add) {
    addShapes.push(add);
    redoShapes.clear();
  }
  
  void addFlake(Flake otherFlake) {
    addShapes.addAll(otherFlake.addShapes);
    redoShapes.clear();
  }
  
  boolean isEmpty() {
    return addShapes.size() == 0;
  }
  
  boolean undo() {
    if (isEmpty()) {
      return false;
    }
    
    redoShapes.push(addShapes.pop());
    return true;
  }
  
  boolean redo() {
    if (redoShapes.size() == 0) {
      return false;
    }
    
    addShapes.push(redoShapes.pop());
    return true;
  }
  
  void clear() {
    while(undo());
  }
  
  void draw() {
    for (int i = 0; i < rotations; i++) {
      for (Poly drawShape : addShapes) {
        drawShape.draw();
        if (reflect) {
          pushMatrix();
          scale(-1,1);
          drawShape.draw();
          popMatrix();
        }
      }
      rotate(2.0 * PI / rotations);
    }
  }
  
  void calcArea() {
    if (addShapes.size() == 0) {
      flakeArea = null;
      return;
    }
    
    flakeArea = new Area(addShapes.get(0).getShape());
    for (int i = 1; i < addShapes.size(); i++) {
      flakeArea.add(new Area(addShapes.get(i).getShape()));
    }
    
    if (reflect) {
      flakeArea.add(flakeArea.createTransformedArea(AffineTransform.getScaleInstance(-1, 1)));
    }
    
    Area rotateArea = (Area)flakeArea.clone();
    for (int i = 1; i < rotations; i++) {
      flakeArea.add(rotateArea.createTransformedArea(AffineTransform.getRotateInstance(2.0d * PI * i / rotations)));
    }
    
    areaShapes = new Vector<Poly>();

    areaPoints = new ArrayList<double[]>();
    coords = new double[6];
    
    for (PathIterator pi = flakeArea.getPathIterator(null); !pi.isDone(); pi.next()) {
        // The type will be SEG_LINETO, SEG_MOVETO, or SEG_CLOSE
        // Because the Area is composed of straight lines
        int type = pi.currentSegment(coords);
        // We record a double array of {segment type, x coord, y coord}
        double[] pathIteratorCoords = {type, coords[0], coords[1]};
        areaPoints.add(pathIteratorCoords);
    }
    
    Poly currentShape = null;
    
    for (int i = 0; i < areaPoints.size(); i++) {
      double[] currentElement = areaPoints.get(i);

      // Make the lines
      if (currentElement[0] == PathIterator.SEG_MOVETO) {
        currentShape = new Poly();
        currentShape.add(new Point(currentElement[1], currentElement[2]));
      }
  
      if (currentElement[0] == PathIterator.SEG_LINETO && currentShape != null) {
        currentShape.add(new Point(currentElement[1], currentElement[2]));
      } else if (currentElement[0] == PathIterator.SEG_CLOSE && currentShape != null) {
        areaShapes.add(currentShape);
        currentShape = null;
      }
    }
  }
  
  void saveDxfOutline(String fileName) {
    calcArea();
    if (flakeArea == null) return;
    
    EgliDXF dxfWritter = new EgliDXF();
    dxfWritter.setLayer(0);
    dxfWritter.setPath(sketchPath(fileName));
    dxfWritter.beginDraw();
    
    dxfWritter.noFill();
    dxfWritter.stroke(0);
    dxfWritter.strokeWeight(1);
    
    // draw all the line segments
    for (Poly areaShape : areaShapes) {
      areaShape.draw(dxfWritter);
    }
    
    dxfWritter.dispose();
  }
  
  void savePdfOutline(PGraphicsPDF pdf) {
    calcArea();
    if (flakeArea == null) return;
    
    pdf.resetMatrix();
    pdf.translate(pdf.width / 2, pdf.height / 2);

    pdf.noFill();
    pdf.stroke(0);
    pdf.strokeWeight(1);
    
    // draw all the line segments
    for (Poly areaShape : areaShapes) {
      areaShape.draw(pdf);
    }
  }

  public void saveSvgOutline(String fileName, int radius) {
    calcArea();
    if (flakeArea == null) return;
    
    String svg = "<?xml version=\"1.0\" standalone=\"yes\"?>";
    svg += "<!DOCTYPE svg PUBLIC \"-//W3C//DTD SVG 1.1//EN\" \"http://www.w3.org/Graphics/SVG/1.1/DTD/svg11.dtd\">";
    svg += "<svg width=\"" + (2 * radius) + "px\" height=\"" + (2 * radius) + "px\" xmlns=\"http://www.w3.org/2000/svg\" version=\"1.1\">";
    for (Poly areaShape : areaShapes) {
      if (areaShape.points.size() == 0) {
        continue;
      }
      
      svg += "<path d=\"";
      svg += "M"+areaShape.points.get(0).x+","+areaShape.points.get(0).y+" ";
      Point previousPoint = null;
      for(Point areaPoint : areaShape.points) {
        // Avoid drawing lines with no length
        if (!areaPoint.equals(previousPoint)) {
          svg += "L"+areaPoint.x+","+areaPoint.y;
        }
        previousPoint = areaPoint;
      }
      svg += "Z";
      
      svg += "\" stroke=\"#000\" fill-opacity=\"0\" transform=\"translate(" + radius + "," + radius + ")\" />";
    }
    svg +="</svg>";
    //var blob = new Blob([svg], {type: "text/plain;charset=utf-8"});
    //saveAs(blob, "snowflake.svg");
    saveStrings(fileName, new String[] { svg });
  }
}