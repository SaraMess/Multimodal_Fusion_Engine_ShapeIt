public class Instruction {
  /** Data strucutre for the instruction managment
    */
  
  int shape_id; // index of the pointed shape
  char action_server; // target action
  char shape_server; // target shape
  String c_server; // target color in string
  String[] c_server_list; // target R G B fields
  color current_c; // pointed color
  boolean start; // start signal
  boolean recieved; // recieved instruction from server
  boolean result; // excution feedback
  String message; // message to publish
  int locate; // shape localisation 
  int elocate; // exact shape to modify
  String newColor; // new color to assign
  
  public Instruction() {
    shape_id = -1;
    start = false; //start of execution
    recieved=false;
    result = false;
    locate = -9;
    elocate = -1;
    message = "";
    newColor = "";
    c_server_list = new String[3];
    action_server = shape_server = ' ';
    c_server = "";
  }
  
  void reset()
  /* reset the data
  */
  {
    shape_id = -1;
    start = false; //start of execution
    recieved=false;
    result = false;
    locate = -9;
    elocate = -1;
    message = "";
    newColor = "";
    c_server_list = new String[3];
    action_server = shape_server = ' ';
    c_server = "";
  }
  
  int lookForShape(int x,int y) {
    /* search a shape either with coordinates or with geometry and color
    */
    if(data.elocate <0)
    {
    if(!c_server.equals("undefined"))
       {
           c_server_list = c_server.split("-");
           current_c = color(Integer.valueOf(c_server_list[0]), Integer.valueOf( c_server_list[1]), Integer.valueOf(c_server_list[2]));
           for (int i=0; i<formes.size(); i++) { // we're trying every object in the list        
            if ((formes.get(i)).getType() == shape_server && (formes.get(i)).c == current_c) {
              shape_id = i;
            }         
           }
       }
       else
       {
         for (int i=0; i<formes.size(); i++) { // we're trying every object in the list        
            if ((formes.get(i)).getType() == shape_server) {
              shape_id = i;
            }  
         }
       }
    }
    else
    {
      Point p = new Point(x, y);
      // send pointed shape to server
      for (int i=0;i<formes.size();i++) { // we're trying every object in the list
        if ((formes.get(i)).isClicked(p)) {
          data.shape_id = i;
        }
      }
    }
    
    return shape_id;
    
  }


}
