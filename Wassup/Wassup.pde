/*
 *  vocal_ivy -> Demonstration with ivy middleware
 * v. 1.2
 * 
 * (c) Ph. Truillet, October 2018-2019
 * Last Revision: 22/09/2020
 * Gestion de dialogue oral
 */
 
import fr.dgac.ivy.*;

public static final int WAIT_MSG = 1;
public static final int SEND_FEEDBACK = 2;
public static final int NO_RECO = 3;

int state; // Feedback engine finite states machine
String userFeed;
Ivy bus;
PFont f;
String message= "";
boolean recieved;
PImage img; 
int sx = 525;
int sy = 890;
void setup()
{
  // display
  userFeed = "";
  size(1020, 1010); 
  surface.setTitle("ShapeIt - Welcome page");
  surface.setLocation(890,0);
  surface.setResizable(true);
  img = loadImage("welcome33.png");
  // init 
  state = WAIT_MSG;
  recieved = false;
  
  // binding to Ivy messages
  try
  {
    bus = new Ivy("Wassup", "Wassup is ready", null);
    bus.start("127.255.255.255:2010");
    
    // message subscriptions
    bus.bindMsg("^mfe state=(.*)", new IvyMessageListener()
    {
      public void receive(IvyClient client,String[] args)
      {
        userFeed = args[0];
      }        
    });
    
    bus.bindMsg("OneDollarIvy exit", new IvyMessageListener()
    {
      public void receive(IvyClient client, String[] args)
      {
        exit();
      }        
    });
    
    // feedback of execution
    bus.bindMsg("^mfe result of execution:(.*)", new IvyMessageListener()
    {
      public void receive(IvyClient client,String[] args)
      {
        recieved = true;
        message = args[0];
        state = SEND_FEEDBACK;
      }        
    });
    
    // speech rejection event
    bus.bindMsg("^mfe event=abort", new IvyMessageListener()
    {
      public void receive(IvyClient client,String[] args)
      {
        message = "";// "Could not recognise speech, could you repeat please?"; 
        state = NO_RECO;
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

    case WAIT_MSG: // listening to messages
       if(recieved)
         {
           state = SEND_FEEDBACK;
           recieved = false;
         }
      break;
      
    case SEND_FEEDBACK: // sending text to ppilot
      try {
          bus.sendMsg("ppilot5 Say=" + message); 
      }
      catch (IvyException e) {}
      state = WAIT_MSG;
      break;
       
     case NO_RECO: // unrecognized speech
       try {
          bus.sendMsg("ppilot5 Say=" + message); 
       }
       catch (IvyException e) {}
       state = WAIT_MSG;
       break;
  }
  
  //image(img, -200.0, -10.0);
  image(img, -250,0,1400,1010);
  textSize(20);
  fill(0, 0, 0);
  text(userFeed, 600,450,350,300);
}
