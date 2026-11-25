// All dimensions in mm. Export with -D 'part="reservoir"' (or deck, pot, screen_case, screen_back).
part = "assembly";
$fn = 72;
base_w = 150;
base_d = 130;
base_h = 42;
wall = 3;
deck_t = 4;
pot_y = -10;
pot_d = 98;
float_at = [23, 47];
float_hole = 10.6;
fill_at = [-23, 47];
screen_window = [41.4, 31.2];
screen_center = [0,0];
case_w = 90;
case_h = 75;
case_d = 42;
case_wall = 3;
eps = 0.05;

module rounded_prism(w,d,h,r) {
    linear_extrude(h)
        offset(r=r) square([w-2*r,d-2*r], center=true);
}

module reservoir() {
    difference() {
        rounded_prism(base_w,base_d,base_h,12);
        translate([0,0,4])
            rounded_prism(base_w-2*wall,base_d-2*wall,base_h,9);
        // Rear overflow. Lower edge is 26 mm above the work surface.
        translate([0,base_d/2+eps,30])
            rotate([90,0,0]) cylinder(d=8,h=wall+2*eps);
    }
}

module deck() {
    // Print with the visible top face on the bed.
    difference() {
        union() {
            rounded_prism(base_w,base_d,deck_t,12);
            for (x=[-1,1])
                translate([x*(base_w/2-wall-4.5),0,deck_t-eps])
                    linear_extrude(3+eps) square([8,20],center=true);
            for (y=[-1,1])
                translate([0,y*(base_d/2-wall-4.5),deck_t-eps])
                    linear_extrude(3+eps) square([20,8],center=true);
        }
        translate([0,-pot_y,-eps]) cylinder(d=pot_d+1,h=deck_t+2*eps);
        translate([float_at.x,-float_at.y,-eps]) cylinder(d=float_hole,h=deck_t+2*eps);
        translate([fill_at.x,-fill_at.y,-eps]) cylinder(d=14,h=deck_t+2*eps);
    }
}

module pot() {
    difference() {
        union() {
            cylinder(d1=86,d2=pot_d,h=14);
            translate([0,0,14-eps]) cylinder(d1=pot_d,d2=108,h=5+eps);
            translate([0,0,19-eps]) cylinder(d1=108,d2=112,h=57+eps);
        }
        translate([0,0,4]) cylinder(d1=80,d2=92,h=10+eps);
        translate([0,0,14]) cylinder(d1=92,d2=106,h=63);
        for (x=[-27,0,27],y=[-20,20])
            translate([x,y,-eps]) cylinder(d=4,h=4+2*eps);
        translate([0,0,-eps]) cylinder(d=8,h=4+2*eps);
    }
}

module back_screw_points() {
    for (x=[-1,1],y=[-1,1])
        translate([x*(case_w/2-6),y*(case_h/2-6),0]) children();
}

module screen_case() {
    // Screen face on the bed. Rotate upright after assembly.
    difference() {
        union() {
            difference() {
                rounded_prism(case_w,case_h,case_d,7);
                translate([0,0,case_wall])
                    rounded_prism(case_w-6,case_h-6,case_d,4);
            }
            back_screw_points() translate([0,0,case_wall-eps])
                cylinder(d=8,h=case_d-case_wall+eps);
        }
        translate([screen_center.x,screen_center.y,-eps])
            linear_extrude(case_wall+2*eps) square(screen_window,center=true);
        back_screw_points() translate([0,0,case_d-7])
            cylinder(d=2.6,h=7+eps);
    }
}

module screen_back() {
    difference() {
        rounded_prism(case_w,case_h,3,7);
        back_screw_points() translate([0,0,-eps]) cylinder(d=3.4,h=3+2*eps);
        // Cables enter through upper rear, with a drip loop outside.
        translate([0,24,-eps]) rounded_prism(20,10,3+2*eps,2);
        translate([25,24,-eps]) cylinder(d=7,h=3+2*eps);
    }
}

if (part=="reservoir") reservoir();
if (part=="deck") deck();
if (part=="pot") pot();
if (part=="screen_case") screen_case();
if (part=="screen_back") screen_back();

if (part=="assembly") {
    color("LightSeaGreen") reservoir();
    color("PowderBlue") translate([0,0,base_h+deck_t]) rotate([180,0,0]) deck();
    // The pot's taper seats in the deck opening around z=14.25 on the pot.
    color("Ivory") translate([0,pot_y,base_h+deck_t-14.25]) pot();
    color("Teal") translate([0,-base_d/2-6-case_d,case_h/2]) rotate([90,0,180])
        screen_case();
}




