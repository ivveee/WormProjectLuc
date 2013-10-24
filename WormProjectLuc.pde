// The Nature of Code
// <http://www.shiffman.net/teaching/nature>
// Spring 201
// PBox2D example

// Example demonstrating distance joints 
// A bridge is formed by connected a series of particles with joints

import pbox2d.*;
import org.jbox2d.common.*;
import org.jbox2d.dynamics.joints.*;
import org.jbox2d.collision.shapes.*;
import org.jbox2d.collision.shapes.Shape;
import org.jbox2d.common.*;
import org.jbox2d.dynamics.*;
import org.jbox2d.dynamics.contacts.*;

// A reference to our box2d world
PBox2D box2d;

// A list we'll use to track fixed objects
ArrayList<Boundary> boundaries;


// A list for all of our rectangles
//ArrayList<Pair> pairs;

ArrayList<Worm> worms;


void setup() {
  size(700,300);
  smooth();

  // Initialize box2d physics and create the world
  box2d = new PBox2D(this);
  box2d.createWorld();
  box2d.world.setGravity(new Vec2(0,-9));
  // Create ArrayLists	
 // pairs = new ArrayList<Pair>();
  
  boundaries = new ArrayList<Boundary>();
worms = new ArrayList<Worm>();
  // Add a bunch of fixed boundaries
  boundaries.add(new Boundary(0,height-10,width,10));
  boundaries.add(new Boundary(100,height-10-30,60,60));
  boundaries.add(new Boundary(100-60,height-10-60*2,60,60*2));
  boundaries.add(new Boundary(100+60,height-10-30-60-120,60,60));
  boundaries.add(new Boundary(100+60,height-10-30-120,60,60));
  boundaries.add(new Boundary(100+60*3,height-10-30-120,60,60));


  boundaries.add(new Boundary(width-200,height-200,20,400));
  //boundaries.add(new Boundary(width-200,height-100,width/2-300,70));

}

void draw() {
  background(255);

  // We must always step through time!
  box2d.step();

  // When the mouse is clicked, add a new Box object
  // Display all the boundaries
  for (Boundary wall: boundaries) {
    wall.display();
  }
  // Display all the boxes
  for (Worm w: worms) {
    w.move();
    w.display();
  }


  
 //saveFrame("a.tiff");
}

void mousePressed() {
   //Pair p = new Pair(mouseX,mouseY);
   //pairs.add(p);
   Worm w = new Worm(mouseX,mouseY);
   worms.add(w);

}









