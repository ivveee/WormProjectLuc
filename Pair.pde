// The Nature of Code
// <http://www.shiffman.net/teaching/nature>
// Spring 2011
// PBox2D example
float Pix = 80;
// Series of Particles connected with distance joints
import org.jbox2d.collision.*;


class WormPart{
    float atg(float x, float y){
    if (abs(x) < 0.00001){
      if (y < 0) 
        return -PI/2.f;
      else 
        return PI/2.f;
    }
    if (abs(y) < 0.00001){
      if( x < 0 ) 
        return PI;
      else 
        return 0.f;
    }
    return atan(y/x);
  }
  
  Particle bPrism;
  Particle bRev;
  RevoluteJoint jRev;
  WeldJoint jWeld;
  Fixture desire;
    
  WormPart(float x, float y){
    Filter filtPrism;
    Filter filtRotation;
    bPrism = new Particle(x,y);
    bRev = new Particle(x,y);
     //bPrism.body.setLinearDamping(5);
    //bRev.body.setAngularDamping(10);    
    //bRev.body.setFixedRotation(true);
    filtPrism = new Filter();
    filtPrism.categoryBits = 0;
    filtPrism.maskBits = 0;
    bPrism.body.getFixtureList().setFilterData(filtPrism);
    
   filtRotation = new Filter();
    filtRotation.categoryBits = FilterMask;
    filtRotation.maskBits = FilterCategory;
    bRev.body.getFixtureList().setFilterData(filtRotation);
   
    RevoluteJointDef rjd = new RevoluteJointDef();
    rjd.initialize(bPrism.body, bRev.body, bRev.body.getWorldCenter());
    rjd.motorSpeed = PI/20;      
    rjd.maxMotorTorque = 700.0;
    rjd.enableMotor = false;
    jRev = (RevoluteJoint) box2d.world.createJoint(rjd);
    
    // Setting desire sensor
    CircleShape cs = new CircleShape();
    cs.m_radius = box2d.scalarPixelsToWorld(30*2);
    FixtureDef fd = new FixtureDef();
    fd.shape = cs;
    fd.isSensor = true;
    fd.filter = filtRotation;
    desire = bPrism.body.createFixture(fd);
  }
  
  
  
  boolean Weld(float beginAngle, float endAngle){
      ContactEdge ce = bRev.body.getContactList(); 
      //Unweld();
      boolean welded = false;
      if (ce == null) 
        return false;
      while(ce != null){
        if (!ce.contact.isTouching()){
          ce = ce.next;
          continue;
        }
        Contact c = ce.contact;
        Manifold man = c.getManifold();
        WorldManifold wman  = new WorldManifold();
        c.getWorldManifold(wman);
        float angleNorm = atg((wman.normal.x),(wman.normal.y));
        println(angleNorm);
        if (angleNorm > beginAngle && angleNorm < endAngle){
          Fixture f1 = c.getFixtureA();
          Fixture f2 = c.getFixtureB();
          Body b1 = f1.getBody();
          Body b2 = f2.getBody();
          //println(wman.normal.y + " " + wman.normal.x + " "+atg(wman.normal.x,wman.normal.y)*57.3);
          Body bToWeldTo = null;
          if(b1 == bRev.body)
            bToWeldTo = b2;
          else if(b2 == bRev.body) 
            bToWeldTo = b1;
          fill(255,0,0);
          rect(box2d.getBodyPixelCoord(bToWeldTo).x,box2d.getBodyPixelCoord(bToWeldTo).y,10,10);
          Unweld();
          WeldJointDef wjd = new WeldJointDef();
          wjd.initialize(bRev.body,bToWeldTo,new Vec2(0,0));
          jWeld = (WeldJoint)box2d.world.createJoint(wjd);
          welded = true;
          break;
        }
        ce = ce.next;
      }    
      return welded;
  }
  
  void Unweld(){
    if(jWeld != null){
      box2d.world.destroyJoint(jWeld);
      jWeld = null;
    }
  }

}

/**
* Worm class
*/
class Worm{
  WormPart Front;
  WormPart Back;
  PrismaticJoint jPrism;
  float maxLength = 80;
  float speed = 5f;
  float motorForce = 200.0f;
  float transientLimit = box2d.scalarPixelsToWorld(30); // Relative to limit
  float reverseLimit = box2d.scalarPixelsToWorld(3);
  float motorSpeed = PI/3.f;

  
Worm(float x, float y){
  Front = new WormPart(x,y);
  Back = new WormPart(x + maxLength,y);
  PrismaticJointDef djd = new PrismaticJointDef();
  djd.bodyA = Front.bPrism.body;
  djd.bodyB = Back.bPrism.body;
  djd.referenceAngle = PI;
  djd.enableLimit = true;
  djd.lowerTranslation =  box2d.scalarPixelsToWorld(60-10);
  djd.upperTranslation =  box2d.scalarPixelsToWorld(maxLength - djd.lowerTranslation);
  djd.enableMotor = true;
  djd.motorSpeed = speed;
  djd.maxMotorForce = motorForce; // how powerful?
  jPrism = (PrismaticJoint) box2d.world.createJoint(djd);  
}
  
Vec2 getBodyVec(){
   Vec2 vecRFront = Front.bPrism.body.getPosition();
   Vec2 vecRBack = Back.bPrism.body.getPosition();   
   Vec2 body = vecRFront.sub(vecRBack);
  return body;
}  
  
void move(){
  //MotorSpeed /----
  //          / 
  //         /
  //        /
  //       /|
  //      / |
  //  o--|--|--|--o
  //     lower limit
  //        lower limit + reverse limit
  //           lower limit + reverse limit + transientLimit  
    float length = getBodyVec().length();//sqrt(pow(pos1.x-pos2.x,2)+pow(pos1.y-pos2.y,2));
    float deltaLLower = length - jPrism.getLowerLimit();
    float deltaLUpper = jPrism.getUpperLimit() - length;
    // Stretch-Lenghten switch
    if(jPrism.getMotorSpeed() > 0){
      // begin to shrink
      if(deltaLUpper < reverseLimit){
        jPrism.setMotorSpeed(-speed); 
        Back.jRev.setMotorSpeed(0);
        Back.jRev.enableMotor(false);
      }
      else
        stretch(deltaLLower,deltaLUpper);
    }
    // 
    else if (jPrism.getMotorSpeed()<0){
      if(deltaLLower < reverseLimit){
        jPrism.setMotorSpeed(speed);
      }
      else
        shrink(deltaLLower);
    }
}
/**
* 
*/
void stretch(float deltaLLower, float deltaLUpper){
     if(deltaLLower < transientLimit){
       jPrism.setMotorSpeed(speed*deltaLLower/transientLimit); 
     }
     if(deltaLUpper < transientLimit){
       jPrism.setMotorSpeed(speed*deltaLUpper/transientLimit); 
     }
     if(Back.jWeld == null){
        Back.bRev.body.setFixedRotation(false);
        Back.Weld(-PI-0.1,PI+0.1);
     }
     if (Back.jWeld != null){
        lean(box2d.coordPixelsToWorld(mouseX,mouseY));
        Front.Unweld();
        Front.bRev.body.setFixedRotation(true);
     }
}

void shrink(float deltaLLower){
      if(deltaLLower < transientLimit){
       jPrism.setMotorSpeed( - speed*deltaLLower/transientLimit);     
      }
      //If we are not welded try to weld
      if(Front.jWeld ==null){
        Front.Weld(-PI-0.1,PI+0.1);  
        Front.bRev.body.setFixedRotation(false);
      }     
      // If we are succesfuly welded - unweld back
      if(Front.jWeld !=null){
        Back.Unweld();
        Back.bRev.body.setFixedRotation(true);
      }
}

void lean(Vec2 whereTo){
       Back.jRev.enableMotor(true);
       Vec2 bodyCoord = (Back.bRev.body.getPosition());
       Vec2 dMouse = whereTo.sub(bodyCoord);
       dMouse.normalize();
       Vec2 vecBody = getBodyVec();
       vecBody.normalize();
       float factor = Vec2.cross(dMouse,vecBody);
       float fFactor = 0.1;
       if (abs(factor)<fFactor)
          Back.jRev.setMotorSpeed(0);
       else if (factor < -fFactor)
         Back.jRev.setMotorSpeed(-motorSpeed);
       else if (factor > fFactor)
         Back.jRev.setMotorSpeed(motorSpeed);
          //Back.jRev.setMotorSpeed(factor*PI/3);
}

void display(){
  Front.bRev.display(true); 
  Back.bRev.display(false);  
}

}


