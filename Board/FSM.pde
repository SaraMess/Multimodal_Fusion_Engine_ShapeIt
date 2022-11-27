/*
 * Enumération de a Machine à Etats (Finite State Machine)
 *
 *
 */
 
public enum FSM {
  INIT, // waiting speech to start
  HOLD, // wait instruction from server
  MAP_ACTION, // map the target action to state
  MOVE_SHAPE_PROC, // find target shape to move
  MOVE_SHAPE, // move target shape
  DISPLAY_SHAPE, // display palette
  DELETE_SHAPE, // delete shape
  CREATE_SHAPE, // create shape
  COLOR_SHAPE, // change shape color
  COCORICO // World cup
}
