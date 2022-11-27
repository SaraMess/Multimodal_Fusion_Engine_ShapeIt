

/*
 * Adapted from Palette Graphique - prélude au projet multimodal 3A SRI  28/04/2020
 * (c) Author: Sara Messara
 * Last Revision: 27.11.2022
 */
 
import java.awt.Point;
import fr.dgac.ivy.*;
import java.io.*;
import java.util.*;

ArrayList<Forme> formes; // liste de formes stockées
FSM mae; // Finite Sate Machine
Ivy bus;

PImage sketch_icon; 
PImage img; 

boolean selected_here; // ?
boolean sent;
Instruction data; // instruction data container
int xpos;
int ypos;

List<Integer> x_pos; // stacking the clicks coordinates
List<Integer> y_pos;

void setup() {
  // display
  size(900,1010);
  surface.setResizable(true);
  surface.setTitle("Board");
  surface.setLocation(-10,0);
  sketch_icon = loadImage("Palette.jpg");
  surface.setIcon(sketch_icon);
  img = loadImage("coq.PNG");
  
  // init
  data = new Instruction();
  formes= new ArrayList(); // nous créons une liste vide
  noStroke();
  mae = FSM.INIT;
  selected_here = false;
  xpos = -1;
  ypos = -1;
  x_pos = new ArrayList<Integer>();
  y_pos = new ArrayList<Integer>();

  try {
    bus = new Ivy("Board", "Board is ready", null);
    bus.start("127.255.255.255:2010");
    
    
    // subscribe to Ivy messages
    // color message
    bus.bindMsg("^mfe action=o shape=(.*) color=(.*) eShape=(.*) colorN=(.*)", new IvyMessageListener()
    {
      public void receive(IvyClient client, String[] args)
      {
        if(data.start)
        {
          data.recieved = true; 
          data.action_server = 'o';
          data.shape_server = args[0].charAt(0);
          data.c_server = args[1];
          data.locate = -9;
          data.elocate = Integer.valueOf(args[2]);
          if(data.elocate>y_pos.size()-1)
            {
              mae = FSM.DISPLAY_SHAPE;
              data.message = "Un erreur est survenue lors de l'execution. Je dois recommencer.";
            }
          data.newColor= args[3];
        }
      }        
    });
    
    // other actions
    bus.bindMsg("^mfe action=(.*) shape=(.*) color=(.*) eShape=(.*) local=(.*)", new IvyMessageListener()
    {
      public void receive(IvyClient client, String[] args)
      {
        if(data.start)
        {
          data.recieved = true; 
          data.action_server = args[0].charAt(0);
          data.shape_server = args[1].charAt(0);
          data.c_server = args[2];
          data.locate = Integer.valueOf(args[4]);
          data.elocate = Integer.valueOf(args[3]);
          
          if(data.elocate>y_pos.size()-1 || data.locate>y_pos.size())
            {
              mae = FSM.DISPLAY_SHAPE;
              data.message = "Un erreur est survenue lors de l'execution. Je dois recommencer.";
            }
        }
      }        
    });
    
    bus.bindMsg("^mfe action=(.*) shape=(.*) color=(.*) end local=(.*)", new IvyMessageListener()
    {
      public void receive(IvyClient client, String[] args)
      {
        if(data.start)
        {
          data.recieved = true; 
          data.action_server = args[0].charAt(0);
          data.shape_server = args[1].charAt(0);
          data.c_server = args[2];
          data.locate = Integer.valueOf(args[3]);
          if(data.locate>y_pos.size()-1 )
            {
              mae = FSM.DISPLAY_SHAPE;
              data.message = "Un erreur est survenue lors de l'execution. Je dois recommencer.";
            }
        }
      }        
    });
    
    // start  signal
    bus.bindMsg("^sra5 Parsed=1 start=1 (.*)", new IvyMessageListener()
    {
      public void receive(IvyClient client, String[] args)
      {
        data.reset();
        x_pos.clear();
        y_pos.clear();
        data.start = true;  
        mae = FSM.INIT;
      }        
    });
    
    // cocorico
    bus.bindMsg("^mfe cocorico", new IvyMessageListener()
    {
      public void receive(IvyClient client, String[] args)
      {
        if(data.start)
        {
          data.recieved = true; 
          data.action_server = 'q';
          sent = false;
        }
      }        
    });
    
    // exit signal
    bus.bindMsg("OneDollarIvy exit", new IvyMessageListener()
    {
      public void receive(IvyClient client, String[] args)
      {
        exit();
      }        
    });
    
    bus.bindMsg("^mfe event=abort", new IvyMessageListener()
    {
      public void receive(IvyClient client, String[] args)
      {
        if(data.start)
        {
          mae = FSM.INIT;
          data.reset();
          data.recieved = false;}
      }
    });
    
  }
  catch (IvyException ie) {}
}

void draw() {
  background(0);
  switch (mae) {
      
    case INIT:
      // waiting the start signal
      data.result = false;
      x_pos.clear();
      y_pos.clear();
      if(data.start)
        mae = FSM.HOLD;
      affiche();
        break;
    
    case HOLD:
      // waiting message from server
        if(data.recieved){
          data.start = false;
          mae = FSM.MAP_ACTION;
          data.recieved = false;
          if(data.locate ==-9)
            {
              xpos = int(random(1) * width);
              ypos = int(random(1) * height);
            }
          else
            {
              xpos = x_pos.get(data.locate);
              ypos = y_pos.get(data.locate);
            }
        }
       affiche();
        break;
    
    case MAP_ACTION:
      // map action to state
      switch(data.action_server){
        case 'c':
          // map to create
          mae = FSM.CREATE_SHAPE;
          break;
        
        case 'd':
          // map to delete shape
          mae = FSM.DELETE_SHAPE;
          break;
          
        case 'm':
          // map to move shape
          mae = FSM.MOVE_SHAPE_PROC;
          break;
          
        case 'o':
          // map to move shape
          mae = FSM.COLOR_SHAPE;
          break;
          
        case 'q':
          // map to move shape
          mae = FSM.COCORICO;
          break;
          
        default:
          mae = FSM.DISPLAY_SHAPE;
          //data.message = "action not recognised";
          data.message = "L action n est pas repertoriee.";
          break;
      }
      
      affiche();
      break;
    
    case CREATE_SHAPE:
      // target shape creation
      if(!data.c_server.equals("undefined"))
         {  
           data.c_server_list = data.c_server.split("-");
           data.current_c = color(Integer.valueOf(data.c_server_list[0]), Integer.valueOf(data.c_server_list[1]), Integer.valueOf(data.c_server_list[2]));
           }
       else
       { 
         data.current_c = color(random(0,255),random(0,255),random(0,255)); // assign random color if not specified
       }
     Point p;
     p = new Point(xpos, ypos);
     switch(data.shape_server) {
      case 'r':
        Forme f= new Rectangle(p);
        f.setColor(data.current_c);
        formes.add(f);
        data.result = true;
        //data.message = "Rectangle created successfully!";
        data.message = "Rectangle cree avec succes !";
        break;
      
      case 'c':
        Forme f2=new Cercle(p);
        formes.add(f2);
        f2.setColor(data.current_c);
        data.result = true;
        //data.message = "Circle created successfully!";
        data.message = "Cercle cree avec succes !";
        break;
    
      case 't':
        Forme f3=new Triangle(p);
        formes.add(f3);
        f3.setColor(data.current_c);
        data.result = true;
        //data.message = "Triangle created successfully!";
        data.message = "Triangle cree avec succes !";
        break;  
      
      case 'l':
        Forme f4=new Losange(p);
        formes.add(f4);
        f4.setColor(data.current_c);
        data.result = true;
        //data.message = "Diamond created successfully!";
        data.message = "Losange cree avec succes !";
        break;    
      
      default : 
        data.result = false;
        //data.message = "Shape not recognised. could not draw. Would you want to try again?";
        data.message = "Je ne connais pas cette forme. Voulez vous reessayer?";
        break;
     }
     mae=FSM.DISPLAY_SHAPE;  
     affiche();
     break;
     
    case MOVE_SHAPE_PROC: 
      // search for shape to move or abort moving
       if(data.elocate >-1)
       data.lookForShape(x_pos.get(data.elocate), y_pos.get(data.elocate));
       else
       data.lookForShape(0,0);
     if (data.shape_id == -1)
     {
       mae = FSM.DISPLAY_SHAPE;
       //data.message = "Indicated shape not found.";
       data.message = "La forme voulue n existe pas. Je n ai rien pu deplacer.";
       data.result = false;
     }
     else {
       mae = FSM.MOVE_SHAPE;
     }
     break;
     
    case MOVE_SHAPE:
      // move found shape
        Point pp;
        pp = new Point(xpos, ypos);
       (formes.get(data.shape_id)).setLocation(pp); // current location of the mouse
       data.shape_id=-1; // reset
       mae=FSM.DISPLAY_SHAPE;
       data.result = true;
       //data.message = "Shape moved succesfully.";
       data.message = "Forme deplacee avec succes !";
       affiche();
       break;
     
     case DELETE_SHAPE:
         // delete target shape
         if(data.elocate >-1)
         data.lookForShape(x_pos.get(data.elocate), y_pos.get(data.elocate));
         else
         data.lookForShape(0,0);
         // prepare feedback
         if (data.shape_id == -1)
         {
           data.result = false;
           //data.message = "Indicated shape not found. No action was performed.";
           data.message = "La forme voulue n existe pas. Je n ai rien pu supprimer.";
         }
         else {
           formes.remove(data.shape_id);
           //data.message = "Shape deleted succesfully";
           data.message = "La forme a ete supprimee avec succes ! ";
         }
         mae = FSM.DISPLAY_SHAPE;
         break;
         
    case COLOR_SHAPE:
         if(data.elocate >-1)
           data.lookForShape(x_pos.get(data.elocate), y_pos.get(data.elocate));
         else
           data.lookForShape(0,0);
         // prepare feedback
         if (data.shape_id == -1)
         {
           data.result = false;
           //data.message = "Indicated shape not found. No action was performed.";
           data.message = "La forme voulue n existe pas. Je n ai rien pu colorier.";
         }
         else {
         String[] newCol;
         color coul;
         if(!data.newColor.equals("undefined"))
         {
           newCol = data.newColor.split("-");
           coul = color(Integer.valueOf(newCol[0]), Integer.valueOf( newCol[1]), Integer.valueOf(newCol[2]));
         }
         else
           coul = color(random(0,255),random(0,255),random(0,255));
           formes.get(data.shape_id).setColor(coul);
           //data.message = "Shape colored succesfully";
           data.message = "La forme a ete coloriee avec succes !";
         }
         mae = FSM.DISPLAY_SHAPE;
         break;
         
     case COCORICO:   // shape update made by the drawing function
        //mae = FSM.INIT;
        data.shape_id = -1;
        data.reset();
        x_pos.clear();
        y_pos.clear();
        if(!sent)
        {
          try {
          bus.sendMsg("Board result=cocorico Allez les bleus !");
        }
        catch (IvyException ie) {}
        sent = true;
        }
         break;
   
    case DISPLAY_SHAPE:   // shape update made by the drawing function
      try {
          bus.sendMsg("Board result="+data.message);
        }
        catch (IvyException ie) {}
        mae = FSM.INIT;
        data.shape_id = -1;
        data.reset();
        x_pos.clear();
        y_pos.clear();
         break;
        
    default:
      break;
  }
  if(mae == FSM.COCORICO)
  {
   image(img, 250,250,200,200);
     //mae = FSM.INIT;
  }
    text("** ETAT COURANT **", 20,20);
  if(mae == FSM.INIT)
    text(0, 20, 50);
  if(mae == FSM.HOLD)
    text(1, 20, 50);
  if(mae == FSM.MAP_ACTION)
    text(2, 20, 50);
  if(mae == FSM.CREATE_SHAPE)
    text(3, 20, 50);
  if(mae == FSM.DISPLAY_SHAPE)
    text(-1, 20, 50);
}

// fonction d'affichage des formes m
void affiche() {
  background(255);
  /* afficher tous les objets */
  for (int i=0;i<formes.size();i++) // on affiche les objets de la liste
    (formes.get(i)).update();
}

void mousePressed() { // sur l'événement click
  
  switch (mae) {
    case HOLD: 
      x_pos.add(mouseX);
      y_pos.add(mouseY);
      int index = -1;
      Point p = new Point(x_pos.get(x_pos.size()-1), y_pos.get(y_pos.size()-1));
      // send pointed shape to server
      for (int i=0;i<formes.size();i++) { // we're trying every object in the list
        if ((formes.get(i)).isClicked(p)) {
          index = i;
        }
      } 
      if( index != -1) {
        selected_here = true;
        try {
          bus.sendMsg("Board shape=" + (formes.get(index)).getType() + " color="+(formes.get(index)).getColorString()+ " Confidence=" + String.format("%.2f", 1.0f));
        }
        catch (IvyException ie) {}
       }
      else {
        selected_here = true;
        try {
          bus.sendMsg("Board shape=undefined color=undefined Confidence=" + String.format("%.2f", 1.0f));
        }
        catch (IvyException ie) {}
       }
      break;
  
    default:
      break;
  }
}
