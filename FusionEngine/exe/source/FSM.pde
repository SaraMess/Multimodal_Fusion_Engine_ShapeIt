/*
 * Enumération de a Machine à Etats (Finite State Machine)
 *
 */
 
public enum FSM {
  INIT,  // waiting the start signal
  LISTENING, // listening to channels  
  PROCESSING, // data fusion
  EXECUTION, // waiting feedback from palette
  REJECTION // reinit engine after speech rejection event
   
}
