/* laser-templates

  Copyright (C) 2016 JBR Engineering Research Ltd - www.jbrengineering.co.uk

 This program is free software: you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation, either version 3 of the License, or
 (at your option) any later version.

 This program is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.

 You should have received a copy of the GNU General Public License
 along with this program.  If not, see <http://www.gnu.org/licenses/>
*/

/// *==================================*/
// --- OBJECT DIA AND SETTINGS ---

SCALE = 1;
// DIAMENSIONS ALL INNER BOX SIZE
HEIGHT = 180/SCALE;
WIDTH = 200/SCALE;
LENGTH = 300/SCALE;

spacing = 2; // spacing between dxf export for print

// Slot
// Tweak these till it looks right
XSlots = 16; // number of slots in base
YSlots = 10; // number of slots on sides
ZSlots = 10; // number of slots on sides

// Laser cutter beam kerf (diameter)
LBD = 0.23;
// Material thickness
MAT_Z = 3.15;
// Magnet radius
MAGR = 2.5;

// --- COMPILE SETTING ----
// make export true if you want to create DXF print sheet, otherwise 3D render is created to visualise
export = false;
closed = true;
engrave = true;
engraving = "B0";

// --- SETTINGS END ---
/* ========================*/

// --- WORKING ----
H = HEIGHT + MAT_Z*2 + LBD;
W = WIDTH + MAT_Z*2 + LBD;
L = LENGTH + MAT_Z*2 + LBD;

// dent dia in each axis
DLX = (L / XSlots);
DLY = (W / YSlots);
DLZ = (H / ZSlots);
endSpace = W*2+H*2+spacing*4+MAT_Z*5;

// --- BUILD ---
// EXPORT
if (export) {
  projection() base();
  if (closed) {
    projection() translate([0,W+spacing]) base(1);
  }
  projection() translate([0,(W*2+spacing*2+MAT_Z)]) side(0);
  projection() translate([0,(W*2+spacing*3+MAT_Z*2+H+spacing)]) side(1);
  projection() translate([MAT_Z,endSpace]) end();
  projection() translate([H+MAT_Z*4+spacing,endSpace]) end(1);
  echo("L:",L);
  echo("W:",W);
  echo("H:",H);
} else {
// PREVIEW
  base();
  if (closed) {
    translate([0,0,H+MAT_Z]) base(1);
  }
  translate([MAT_Z,MAT_Z,MAT_Z]) rotate([0,270,0]) end();
  translate([L,MAT_Z,MAT_Z]) rotate([0,270,0]) end(1);
  translate([0,MAT_Z,MAT_Z]) rotate([90,0,0]) side(1);
  translate([0,W,MAT_Z]) rotate([90,0,0]) side(0);
}

// --- END BUILD ---

// Base Piece
module base(lid) {
  difference() {
    cube([L,W,MAT_Z]);
      for (x = [DLX:DLX+DLX:L-DLX+LBD*XSlots*2]) {
        if (lid) {
          translate([x,MAT_Z/2-LBD/2,+MAT_Z/2]) dent(DLX,1,-1);
          translate([x,W-MAT_Z/2+LBD/2,MAT_Z/2]) dent(DLX,1,-1);
        } else {
          translate([x,MAT_Z/2-LBD/2,+MAT_Z/2]) dent(DLX,1,LBD);
          translate([x,W-MAT_Z/2+LBD/2,MAT_Z/2]) dent(DLX,1,LBD);
        }
      }
      for (x = [DLY:DLY+DLY:W-DLY+LBD*YSlots*2]) {
        if (lid) {
          translate([-LBD/2,x,MAT_Z/2]) dent(DLY,2,-1);
          translate([L+LBD/2,x,MAT_Z/2]) dent(DLY,2,-1);
        } else {
          translate([-LBD/2,x,MAT_Z/2]) dent(DLY,2,LBD);
          translate([L+LBD/2,x,MAT_Z/2]) dent(DLY,2,LBD);
        }
      }
  }
}

// End piece
module end(face) {
  WEnd = W-MAT_Z*2;
    difference() {
      union() {
        cube([H,WEnd,MAT_Z]);
        for (x = [DLY-MAT_Z:DLY+DLY:WEnd-DLY+LBD*YSlots*2]) {
          translate([LBD/2,x,MAT_Z/2]) tooth(DLY,2,LBD);
          if (closed) {
            translate([H-LBD/2,x,MAT_Z/2]) tooth(DLY,2,LBD);
          }
        }
        for (x = [DLZ:DLZ+DLZ:H-DLZ+LBD*ZSlots*2]) {
          translate([x,-MAT_Z/2+LBD,MAT_Z/2]) tooth(DLZ,1,LBD);
          translate([x,WEnd+MAT_Z/2-LBD/2,MAT_Z/2]) tooth(DLZ,1,LBD);
        }
      }
      if (face && engraving) {
        translate([H/2,WEnd/2,0]) {
          mirror(0,1,0) rotate(90) linear_extrude(height = MAT_Z*3) text(engraving,size=60,halign = "center",valign="center");
        }
      }
    }
}

// Sides
module side() {
  WEnd = W-MAT_Z*2;
  difference() {
    union() {
      cube([L,H,MAT_Z]);
        for (x = [DLX:DLX+DLX:L-DLX+LBD*XSlots*2]) {
          translate([x,-MAT_Z/2+LBD/2,MAT_Z/2]) tooth(DLX,1,LBD);
          if (closed) {
            translate([x,H+MAT_Z/2-LBD/2,MAT_Z/2]) tooth(DLX,1,LBD);
          }
        }
    }
    for (x = [DLZ:DLZ+DLZ:H-DLZ+LBD*ZSlots*2]) {
      translate([-LBD/2,x,MAT_Z/2]) dent(DLZ,2,LBD);
      translate([L+LBD/2,x,MAT_Z/2]) dent(DLZ,2,LBD);
    }
    translate([L-20,H-20,0]) cylinder(r=MAGR-LBD/2,h=MAT_Z);
    translate([20,H-20,0]) cylinder(r=MAGR-LBD/2,h=MAT_Z);
  }
}

// Creates dents
module dent(DL,direction,lbd) {
  if (direction == 1) {
    cube([DL-lbd,MAT_Z-lbd/2,MAT_Z*2], center=true);
  } else if (direction == 2) {
    cube([MAT_Z*2-lbd/2,DL-lbd,MAT_Z*2], center=true);
  } else if (direction == 3) {
    cube([MAT_Z*2-lbd/2,W/4-lbd,MAT_Z*2], center=true);
  } else {
    cube([MAT_Z-lbd/2,W/4-lbd,MAT_Z*2], center=true);
  }
}

// Creates teeth
module tooth(DL,direction,lbd) {
  if (direction == 1) {
    cube([DL+lbd,MAT_Z+lbd/2,MAT_Z], center=true);
  } else if (direction == 2) {
    cube([MAT_Z*2+lbd/2,DL+lbd,MAT_Z], center=true);
  } else {
    cube([MAT_Z+lbd/2,W/4+lbd,MAT_Z], center=true);
  }
}
