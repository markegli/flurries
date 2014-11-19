import java.util.*;
import processing.pdf.*;
import java.text.*;

import java.awt.Polygon;
import java.awt.geom.*;

boolean line = false;
boolean square = false;
boolean reflect = true;
boolean bg = true;
Poly inProgress = null;
int rotations = 6;
int saveVal = 0;
String saveId;
Flake editFlake;
Vector<Flake> bgFlakes;

PFont spartanBold;

void setup() {
  size(800,800);
  
  editFlake = new Flake();
  bgFlakes = new Vector<Flake>();
  DateFormat fileIdDate = new SimpleDateFormat("yyyyMMdd.HHmm"); 
  saveId = fileIdDate.format(new Date());
  
  spartanBold = createFont("leaguespartan-bold.ttf", 64);
  textFont(spartanBold);
  textAlign(LEFT, BASELINE);
}

void draw() {
  resetMatrix();
  background(0);
  translate(width / 2.0, height / 2.0);
  
  if (bg)
  {
    noStroke();
    fill(96);
    for(Flake bgFlake : bgFlakes)
    {
      bgFlake.draw();
    }
  }
    
  stroke(255,255,255,192);
  fill(255);
  strokeWeight(1);

  editFlake.draw();
  
  for(int i = rotations - 1; i >= 0; i--)
  {
    if (inProgress != null)
    {
      rotate(2.0 * PI / rotations);
      if (i == 0)
      {
        fill(234,234,255);
      }
      else
      {
        fill(255,255,255,192);
      }
      
      inProgress.draw();
      
      if (reflect)
      {
        pushMatrix();
        scale(-1,1);
        fill(255,255,255,192);
        inProgress.draw();
        popMatrix();
      }
    }
  }
  
  if (bg)
  {
    fill(255,255,255,16);
    noStroke();
    ellipse(0, 0, width * 0.98, height *0.98);
    
    if (rotations > 2)
    {
      fill(255,255,255,32);
      beginShape();
      vertex(0, -1 * height / 2.0);
      vertex(0, 0);
      float angle = PI / rotations;
      if (!reflect) angle = angle * 2.0;
      vertex(width / 2.0, -1 * (width / 2.0) / tan(angle));
      vertex(width / 2.0, -1 * height / 2.0);
      endShape();
    }
    
    fill(255,255,255,128);
    textSize(18);
    text(
      "" + rotations + "-sided"
      + (reflect ? ", mirrored":""),
      -width * 0.48, height * 0.48
    );
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
    if (mouseButton == RIGHT)
    {
      line = false;
      //square = true;
      
      editFlake.addShape(inProgress);
      inProgress = null;
    }
    else
    {
      // set the second point
      inProgress.add(clickPoint);
    }
  }
  else if (square)
  {
    // math :(
  }
}

void keyPressed() {
  if (key == 'i' || key == 'I')
  {
    bg = false;
    draw();
    
    save("flurry" + saveId + "-" + (++saveVal) + ".png");
    
    bg = true;
  }
  else if (key == 'o' || key == 'O')
  {
    editFlake.saveOutline("flurry" + saveId + "-" + (++saveVal) + ".pdf");
  }
  else if (key == 'p' || key == 'P')
  {
    editFlake.savePDF("flurry" + saveId + "-" + (++saveVal) + ".pdf");
  }
  else if (key == 'm' || key == 'M') // mirror
  {
    reflect = !reflect;
  }
  else if (key == '+')
  {
    rotations++;
  }
  else if (key == '-' && rotations > 1)
  {
    rotations--;
  }
  else if (key == 'n' || key == 'N')
  {
    bgFlakes.add(editFlake);

    key = 'r';
  }
  
  if (key == 'r' || key == 'R')
  {
    if (editFlake.addShapes.size() == 0) bgFlakes = new Vector<Flake>();
    
    editFlake = new Flake();
    line = false;
    square = false;
    inProgress = null;
  }
  
  if (keyCode == ESC)
  {
    keyCode = DELETE;
    key = ' ';
    line = false;
    square = false;
    inProgress = null;    
  }
}
