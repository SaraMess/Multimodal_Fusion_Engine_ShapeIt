public class FusionData {
  /** Data strucutre for multimodal inputs and outputs management
    */
  
  int numIn; // number of modalities 
  // internal flags
  boolean start; // initiate or not the fusion
  boolean recieved; // check complete speech reception
  boolean speCase; // indicate special cases (cf. report)
  boolean keepW; // keep waiting missing data
  boolean noMatch; // faulty input scenario
  // recieved data
  float[] confi; // confidence array for each input source [for this use case 0->Speech, 1-> One$, 2-> Palette]
  String[] shape; // shape array for each input source
  String[] c_rec; // color array for each input source 
  boolean locate; // location indication 
  boolean  pointing; // shape designation
  List<String> from_palette_s; // recieved shapes (speech - 1$Ivy - palette)
  List<String> from_palette_c; // recieved colors 
  // data to send 
  String shape2send; // shape to send to the palette
  String loca2send; //index of coordinates to send
  String c; // color to send to the palette 
  String result; // result of execution from palette
  String action;
  String exactShape; 
  String colorN;
  String feedUser;
  boolean allIn;
  boolean shapeIn;
 
  
  public FusionData(int numInput) {
    numIn = numInput;
    
    // init data
    noMatch = true;
    from_palette_s = new ArrayList<String>();
    from_palette_c = new ArrayList<String>();
    action="undefined";
    c="undefined";
    shape2send = "undefined";
    start = false;
    recieved = false;
    pointing = false;
    loca2send = "-9";
    exactShape = "";
    locate = false;
    result = "";  
    colorN = "";
    feedUser = "";
    shape = new String[numIn];
    confi = new float[numIn];
    c_rec = new String[numIn];
    keepW = true;
    speCase = false;
    allIn = false;
    shapeIn = false;
    for(int i=0; i<numIn; i++)
       {
        confi[i] = 0.0f;
        shape[i] = "undefined";
        c_rec[i] = "undefined";
       }
  }
  
  void reset() {
    /** reset data
    */
      recieved = false;
       for(int i=0; i<numIn; i++)
       {
        confi[i] = 0.0f;
        shape[i] = "undefined";
        c_rec[i] = "undefined";
       }
      from_palette_s.clear();
      from_palette_c.clear();
      shape2send = "undefined";
      c = "undefined";
      speCase = false;
      allIn = false;
      shapeIn = false;
      keepW = true;
      loca2send = "-9";
  }
  
  Boolean doIListen()
   /** is the engine intaking messages
  */
    {  return start;
     }
 
   void stopListening()
   /** block messages reception
  */
   {  start  = false;
   }
 
   void startListen()
   /** enable messages reception
  */
   {  start  = true;
   }
 
   void dataWait(int order) 
   /** collect data from the multiple channels
  */{
   if(keepW)
   {  
     keepW = false;
     noMatch = false;
     if(!data.action.equals("o"))
     // studying cases when action != coloring 
     {
       if(data.pointing)
     // indicating a shape -- shape comes either from palette or from the 1$Ivy
     {  
        if(data.locate)
        {
          if(c_rec[0].equals("palette"))
          // color indicated in the palette
          {
            // cases depending of number of clicks in the palette
           switch(data.from_palette_s.size())
           {
             case 3:
            // color and shape from palette send localisation order
                 shape[2] = from_palette_s.get(0);
                 if(order == 1)
                 {
                   c_rec[2] = from_palette_c.get(1);
                   loca2send = "2";
                 }
                 else
                 {
                   c_rec[2] = from_palette_c.get(2);
                   loca2send = "1"; // the click to consider for the localisation
                 }
                 break;
            case 2:
                 
                 if(order == 1)
                 {
                   c_rec[2] = from_palette_c.get(0);
                   loca2send = "1";
                 }
                 else
                 {
                   c_rec[2] = from_palette_c.get(1);
                   loca2send = "0"; // the click to consider for the localisation
                 }
                 break;
             case 1:
                keepW = true;
                feedUser = "J attends que tu m'indiques la couleur ou la position. Encore un click !";
                println("stuck 1");
                break;
             case 0:
                keepW = true;
                feedUser = "J attends que tu m'indiques la couleur et la position. Encore 2 clicks !";
                println("stuck 1");
                break;
             default:
               keepW = false;
               noMatch = true;
               break;
          }
          }
        else 
          {  
           switch(from_palette_s.size()){
             case 2:
               shape[2] = from_palette_s.get(0);
               if(c_rec[0].equals("undefined"))
                 c_rec[2] = from_palette_c.get(0);
               loca2send = "1"; // the location
               if(!from_palette_s.get(0).equals("undefined") && !data.action.equals("c") && c_rec[0].equals("undefined"))
               {
                 speCase = true;
                 exactShape = "0";
                 println("special2");
               }
               break;
             case 1:
             loca2send = "0"; // the location
             break;
             case 0:
               keepW = true;
               println("stuck 2");
               feedUser = "J attends que tu m'indiques la position. Encore un click !";
               break;
             default:
               keepW = false;
               noMatch = true;
               feedUser = "Trop de clicks ! Je ne comprends pas, voulez vous recommencer ?";
               break;
          }
         }
        }
       else 
       {
         // location not indicated
      
          if(c_rec[0].equals("palette"))
          {
           switch(data.from_palette_s.size())
             {
             case 2:
               shape[2] = from_palette_s.get(0);
               c_rec[2] = from_palette_c.get(1);
               loca2send = "-9"; //random localisation
               break;
             case 1:
                c_rec[2] = from_palette_c.get(0);
                loca2send = "-9"; // random
                break;
             case 0:
               keepW = true;
               feedUser = "J attends la couleur. Encore un click !";
               println("stuck 3");
               break;
             default:
               keepW = false;
               noMatch = true;
               feedUser = "Trop de clicks ! Je ne comprends pas, je dois recommence.";
               break;
          }
          }
           else // pointing no color and no localisation
           {
             switch(data.from_palette_s.size())
             {
               case 1:
                  shape[2] = from_palette_s.get(0);
                  if(c_rec[0].equals("undefined"))
                    c_rec[2] = from_palette_c.get(0);
                  print("added");
                  loca2send = "-9"; // random
                  if(!from_palette_s.get(0).equals("undefined") && !data.action.equals("c") &&  c_rec[0].equals("undefined"))
                   {
                     speCase = true;
                     exactShape = "0";
                   }
                   break;
               case 0:
                 keepW = false;
                 break;
               default:
                 keepW = false;
                 noMatch = true;
                 feedUser = "Trop de clicks ! Je ne comprends pas, je dois recommence.";
                 break;
           }
        }
     }
     }
     else
     { // not pointing an object
       // shape given from 1$Ivy or speech only  
       if(data.locate)
       {  // not pointing and location indicated
           if(data.c_rec[0].equals("palette"))
           {
             switch(from_palette_s.size())
             {
               case 2:
                 if(order == 1)
                 {
                  c_rec[2] = from_palette_c.get(0);
                  loca2send = "1";
                 }
                 if(order == 2)
                 {
                  c_rec[2] = from_palette_c.get(1);
                  loca2send = "0";
                 }
                 break;
               case 1:
                  keepW = true;
                  println("stuck 5");
                  feedUser = "J attends que vous m indiquiez la localisation ou la couleur. Encore un click !";
                  break;
               case 0:
                  keepW = true;
                  feedUser = "J attends que vous m indiquiez la localisation et la couleur. Encore 2 clicks !";
                  println("stuck 5");
                  break;
               default:
                 keepW = false;
                 noMatch = true;
                 feedUser = "Trop de clicks ! Je dois recommencer.";
                 break;
              }
           }
           else
           {
             println(from_palette_s.size());
             if(from_palette_s.size()<1)
              { 
                keepW = true;
                feedUser = "J attends la localisation. Encore un click !";
              }
             else
               {
                loca2send = "0";
               }
           }
         }
         else
              // not pointing and no location indicated
             {
                 loca2send = "-9";
                 if(data.c_rec[0].equals("palette"))
                 {
                   if(from_palette_s.size()<1)
                    { keepW = true;
                    println("special 1");
                    feedUser = "J attends que vous m indiquiez la couleur. Encore un click !";
                    }
                   else
                    {
                      c_rec[2] = from_palette_c.get(0);
                     }
                   }
                 }
               }
     } 
     else
     // studying cases when action = coloring 
     {
       println("coloring");
       if(data.pointing) // pointing an exact shape 
       {
          if(colorN.equals("palette")) // Poiting a color
          {
            // no pointing pointed color
           switch(data.from_palette_s.size())
             {
             case 2:
               colorN = from_palette_c.get(1);
               shape[2] = from_palette_s.get(0);
               speCase = true;
               exactShape = "0";
               println("spe col");
               break;
             case 1:
               keepW = true; 
               feedUser = "J attends que vous m indiquiez la nouvelle couleur. Encore un click !";             
               break;
             case 0:
               feedUser = "J attends que vous m indiquiez la forme et la nouvelle couleur. Encore 2 clicks !";
               keepW = true;
               break;
             default:
               noMatch = true;
               feedUser = "Trop de clicks ! Je ne comprends pas, je vais recommancer...";
               break;
             }
       }
         else
         {
           switch(data.from_palette_s.size()) // not pointing a color
             {
             case 1:
               shape[2] = from_palette_s.get(0);
               speCase = true;
               exactShape = "0";
               break;
             case 0:
               keepW = true;
               feedUser = "J attends que vous m indiquiez la forme. Encore un click !";
               break;
             default:
               noMatch = true;
               feedUser = "Trop de clicks ! Je ne comprends pas, je vais recommancer...";
               break;
             }
         }
       }
       else // not pointing a shape
       {
         if(colorN.equals("palette"))
          {
            // pointing a color
           switch(data.from_palette_s.size())
             {
             case 1:
               colorN = from_palette_c.get(0);
               break;
             case 0:
               keepW = true;
               feedUser = "J attends que vous m indiquiez la nouvelle couleur. Encore un click !";
               break;
             default:
               noMatch = true;
               feedUser = "Trop de clicks ! Je ne comprends pas, je vais recommancer...";
               break;
             }
          }
       }
     }
     }
       
       println("end of click testing");
       // waiting to get at least one input on shape
       if((shape[0].equals("undefined") && shape[1].equals("undefined") && shape[2].equals("undefined"))) {
            shapeIn = false; 
            keepW = true;
            feedUser = "J attends que vous m indiquiez une forme par le geste. On y est presque !";
          } // wait for at least one shape input
       else
       {
        shapeIn = true;
      // waiting 2.4s to get more inputs on shape for robustness
        if(shape[0].equals("undefined") || shape[1].equals("undefined") || shape[2].equals("undefined"))
          {
            println("another shape maybe");
            //delay(2400); // waiting for other shape input for robustness
          }
       }
        allIn = !keepW && shapeIn;
        println(keepW);
    }
 
   void dataFuse() {
     /** fusion the input data and generate output data
    */
       if(c_rec[0].equals("palette"))
       {
         c = c_rec[2];
         println("here");
         println(c_rec[2]);
       }
      println("in fusion");
      println(c_rec[0]);
           float max = -1; 
           int index = 0;
           // maximize output's confidence
           for(int i=0;i<numIn;i++) 
           {
             if(max<confi[i] && !shape[i].equals("undefined"))
             {
               max = confi[i];
               index = i;
               println(index);
             }
              if(!(c_rec[i].equals("undefined")) && !(c_rec[0].equals("palette")))
                 c = c_rec[i];
             }
           shape2send = shape[index];   // choosing the most confident shape
           if(!(c_rec[index].equals("undefined")) && !(c_rec[0].equals("palette")))
                 c = c_rec[index];

   }
   
  void dataSend(){
    /** publishing messages on Ivy bus
    */
    if(data.speCase)
      {
        if(!data.action.equals("o"))
        {
        try {
          bus.sendMsg("mfe action=" + data.action + " shape=" + data.shape2send + " color=" + data.c + " eShape=" + data.exactShape + " local=" + data.loca2send ); 
          }
        catch (IvyException e) {}
        }
        else
        {
        try {
          bus.sendMsg("mfe action=o" +" shape=" + data.shape2send + " color=" + data.c + " eShape=" + data.exactShape + " colorN=" + data.colorN); 
          }
        catch (IvyException e) {}
        }
        }
        
      else {
        if(!data.action.equals("o"))
        {
      try {
          bus.sendMsg("mfe action=" + data.action + " shape=" + data.shape2send + " color=" + data.c + " end local=" + data.loca2send); 
          println(data.loca2send);  
        }
      catch (IvyException e) {}
      }
      else
      {
        try {
          bus.sendMsg("mfe action=o" +" shape=" + data.shape2send + " color=" + data.c + " eShape=-1"  + " colorN=" + data.colorN); 
          }
        catch (IvyException e) {}
        }
      }
      
  }
  
}
