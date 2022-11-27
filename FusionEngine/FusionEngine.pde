/*
 *  Multimodal fusion engine
 * v. 1.0
 * 
 * (c) Author: Sara Messara
 * Last Revision: 27.11.2022
 */
 
import fr.dgac.ivy.*;
import java.io.*;
import java.util.*;
// data

Ivy bus;
PFont f;
String message= "";
String userFeed="";
FSM state; // Fusion Engine finite states machine
FusionData data; // I/O data structure
int order;
void setup()
{ 
  size(525,100);
  surface.setLocation(1390,880);
  surface.setResizable(true);
  // graphical display
  fill(0,0,0);
  surface.setTitle("Multimodalities Fusion Engine");
  // init 
  data = new FusionData(3);
  state = FSM.INIT;
  order = -1;
  try
  {
    bus = new Ivy("FusionEngine", "Multimodalities Fusion Engine (MFE) ready", null);
    bus.start("127.255.255.255:2010"); // Ip and port number
    
    // Ivy message subscriptions
    // Speech recognition
    // speech rejection
    bus.bindMsg("^sra5 Event=Speech_Rejected", new IvyMessageListener()
    {
      public void receive(IvyClient client,String[] args)
      {
        if(data.doIListen()){
        state = FSM.REJECTION;
        data.feedUser = "Je suis dure d'oreille, pourriez vous répéter ?";
        }
        
      }        
    });
    
    // start signal
    bus.bindMsg("^sra5 Parsed=1 start=1 .*", new IvyMessageListener()
    {
      public void receive(IvyClient client, String[] args)
      {
        order = 0;
        data.reset();
        data.startListen();  
        state = FSM.INIT;
        data.feedUser = "J attends que tu me dise \"Commence\" !";
        
      }        
    });
    
    bus.bindMsg("OneDollarIvy exit", new IvyMessageListener()
    {
      public void receive(IvyClient client, String[] args)
      {
        exit();
      }        
    });
    
    // shutdown 
    bus.bindMsg("^sra5 Parsed=1 cocorico", new IvyMessageListener()
    {
      public void receive(IvyClient client, String[] args)
      {
        if(data.doIListen())
        {
        data.stopListening();
        order = 0;
        data.reset();  
        state = FSM.EXECUTION;
        data.feedUser = "COCORICO !";
        try {
          bus.sendMsg("mfe cocorico"); 
          }
        catch (IvyException e) {}
        }
      }        
    });
    
    // coloring action
    bus.bindMsg("^sra5 Parsed=1 pointage=(.*) action=(.*) shape=(.*) color=(.*) colorN=(.*) Confidence=(.*) NP.*", new IvyMessageListener()
    {
      public void receive(IvyClient client,String[] args)
      {
        if(data.doIListen())
        {
        order = 1;
        data.pointing = Boolean.valueOf(args[0]);
        data.recieved = true;
        data.action = args[1];
        data.shape[0]= args[2]; 
        data.c_rec[0] = args[3]; // color from speec 
        data.colorN = args[4];
        data.locate = false;
        data.confi[0] = Float.valueOf(args[5]);
        }
      }        
    });
    
    // actions apart from coloring
    bus.bindMsg("^sra5 Parsed=1 pointage=(.*) action=(.*) shape=(.*) color=(.*) localisation=(.*) Confidence=(.*) NP.*", new IvyMessageListener()
    {
      public void receive(IvyClient client,String[] args)
      {
        if(data.doIListen())
        {
        order = 1;
        data.pointing = Boolean.valueOf(args[0]);
        data.recieved = true;
        data.action = args[1];
        data.shape[0]= args[2]; 
        data.c_rec[0] = args[3]; // color from speec 
        data.locate = Boolean.valueOf(args[4]);
        data.confi[0] = Float.valueOf(args[5]);
        }
      }        
    });
    
    bus.bindMsg("^sra5 Parsed=1 pointage=(.*) action=(.*) shape=(.*) localisation=(.*) color=(.*) Confidence=(.*) NP.*", new IvyMessageListener()
    {
      public void receive(IvyClient client,String[] args)
      {
        if(data.doIListen())
        {
        order = 2;
        data.pointing = Boolean.valueOf(args[0]);
        data.recieved = true;
        data.action = args[1];
        data.shape[0]= args[2]; 
        data.c_rec[0] = args[4]; // color from speec 
        data.locate = Boolean.valueOf(args[3]);
        data.confi[0] = Float.valueOf(args[5]);
        
        }
      }        
    });
    
    
    // 1$ recognition
    bus.bindMsg("^OneDollarIvy Template=(.*) Confidence=(.*)", new IvyMessageListener()
    {
      public void receive(IvyClient client,String[] args)
      {
        if(data.doIListen())
        {
        data.shape[1] = args[0];
        data.confi[1] = Float.valueOf(args[1]);
        }
      }        
    });
    
    // Board 
    bus.bindMsg("^Board shape=(.*) color=(.*) Confidence=(.*)", new IvyMessageListener()
    {
      public void receive(IvyClient client,String[] args)
      {
        if(data.doIListen())
        {
        data.from_palette_s.add(args[0]); // input shape
        data.from_palette_c.add(args[1]); // input color
        data.confi[2] = Float.valueOf(args[2]);
        }
      }        
    }); 
    
    // palette execution feedback
    bus.bindMsg("^Board result=(.*)", new IvyMessageListener()
    {
      public void receive(IvyClient client,String[] args)
      {
        data.result = args[0];
      }        
    });
    
  }
  catch (IvyException ie)
  {
  }
}

void draw()
{
  background(0);
  
  switch(state) {
    case INIT:
      // waiting start signal
      data.feedUser = "J attends que tu me dise \"Commence\" !";
      text(data.feedUser, 20, 50);
      if(data.doIListen())
        {state = FSM.LISTENING;
        data.feedUser = "Je suis de toute ouie et de toute vue. Let's ShapeIt !";
        }
      break;
      
    case LISTENING:
      // listening to channels 
      data.feedUser = "Je suis de toute ouie et de toute vue. Let's ShapeIt !";
      text(data.feedUser, 20, 50);
      if(data.recieved) // wait reception from speech
        {
        data.dataWait(order); // blocking function
        if(data.allIn)
        {
          data.stopListening();
          if(data.noMatch)
            state = FSM.REJECTION;
          else 
            state = FSM.PROCESSING;
        }
        }
      break;
      
    case PROCESSING :
      // perform fusion
      data.feedUser = "J essaye de comprendre votre demande...";
      text(data.feedUser, 20, 50);
      data.dataFuse();
      text(data.feedUser, 20, 50);
      // send instruction to Board
      data.dataSend();
      state = FSM.EXECUTION;
      break;
      
     case EXECUTION:
       // waiting feedback from Board
       data.feedUser = "J ai compris ! Je m exécute";
       text(data.feedUser, 20, 50);
       if(data.result !=""){
         data.reset();
         state = FSM.INIT;
         // send results of execution
          try {
            bus.sendMsg("mfe result of execution: " + data.result); 
            }
          catch (IvyException e) {}
          data.result = "";
       }
       break; 
       
     case REJECTION:
       // reset engine after speech rejection event
       data.feedUser = "Je n'ai pas compris... Je dois recommencer.";
       text(data.feedUser, 20, 50);
       data.reset();
       state = FSM.INIT; // need to say "commence" again
       try {
          bus.sendMsg("mfe event=abort"); 
       }
       catch (IvyException e) {}
       break;
  }
  background(232,232,232);
  text("** Mon état courant **", 100,20);
  text(data.feedUser, 20, 50);
  if(!data.feedUser.equals(userFeed))
  {
    userFeed = data.feedUser;
  try {
          bus.sendMsg("mfe state="+data.feedUser); 
          }
        catch (IvyException e) {}  
  }
}
