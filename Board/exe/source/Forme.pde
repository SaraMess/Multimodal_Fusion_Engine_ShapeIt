/*****
 * Création d'un nouvelle classe objet : Forme (Cercle, Rectangle, Triangle
 * 
 * Date dernière modification : 28/10/2019
 */

abstract class Forme {
 Point origin;
 color c;
 char type;
 
 Forme(Point p) {
   this.origin=p;
   this.c = color(127);
   this.type ='_';
 }
 
 void setColor(color c) {
   this.c=c;
 }
 
 color getColor(){
   return(this.c);
 }
 
 String getColorString(){
   String col = hex(this.c);
   int r = unhex(col.substring(2,4));
   int v = unhex(col.substring(4,6));
   int b = unhex(col.substring(6,8));
   return String.valueOf(r)+'-'+String.valueOf(v)+'-'+String.valueOf(b);
 }
 
  char getType(){
   return(this.type);
 }
 
 abstract void update();
 
 Point getLocation() {
   return(this.origin);
 }
 

 
 void setLocation(Point p) {
   this.origin = p;
 }
 
 abstract boolean isClicked(Point p);
 
 // Calcul de la distance entre 2 points
 protected double distance(Point A, Point B) {
    PVector AB = new PVector( (int) (B.getX() - A.getX()),(int) (B.getY() - A.getY())); 
    return(AB.mag());
 }
 
 protected abstract double perimetre();
 protected abstract double aire();
}
