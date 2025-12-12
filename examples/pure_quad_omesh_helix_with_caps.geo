//==============================================================================
// Pure Quad O-mesh Helical Tube with Hemispherical Caps
// Based on pure_quad_omesh_helix_minimal.geo
// Adds structured hemispherical end caps using O-mesh structure
//==============================================================================
SetFactory("Built-in");

// ----- Geometric parameters -------------------------------------------------
R      = 25.0;    // helix radius
rtube  =  2.5;    // tube radius
Pturn  =  7.0;    // pitch per full turn

// Angular range parameters
start_angle_deg = 0.0;     // Start angle in degrees
end_angle_deg = 180.0;     // End angle in degrees

// Convert to radians and calculate axial rise
start_angle = start_angle_deg * Pi/180;
end_angle = end_angle_deg * Pi/180;
angular_span = end_angle - start_angle;
dz = (Pturn / (2*Pi)) * angular_span;

// Mesh parameters
nCirc  = 1;      // cells around circumference (ultra-coarse)
nRad   = 1;      // cells centre->wall (ultra-coarse)
nAxial = 20;     // layers along sweep
nHemi  = 4;      // layers in hemisphere (meridional direction)
ratioR = 1.0;    // radial grading
lc     = rtube/10;

Printf("Generating pure quad O-mesh helical tube WITH HEMISPHERICAL CAPS:");
Printf("  Angular range: %g° to %g° (%g° span)", start_angle_deg, end_angle_deg, angular_span*180/Pi);
Printf("  Axial rise: %g mm", dz);
Printf("  Helix radius: %g mm, Tube radius: %g mm", R, rtube);
Printf("  Mesh: nCirc=%g, nRad=%g, nHemi=%g", nCirc, nRad, nHemi);

// O-mesh internal structure parameters
r_inner = 0.75 * rtube;
r_quad_boundary = 0.5 * rtube;
r_small_quad = 0.25 * rtube;

//==============================================================================
// STEP 1: Create center vertex
//==============================================================================
Point(1) = {R, 0, 0, lc};

//==============================================================================
// STEP 2: Create outer ring vertices (16 points every 22.5°)
//==============================================================================
For i In {0:15}
    angle_deg = i * 22.5;
    angle_rad = angle_deg * Pi/180;
    x = R + rtube * Cos(angle_rad);
    z = rtube * Sin(angle_rad);
    Point(2+i) = {x, 0, z, lc};
EndFor

//==============================================================================
// STEP 3: Create inner ring vertices (16 points every 22.5°)
//==============================================================================
For i In {0:15}
    angle_deg = i * 22.5;
    angle_rad = angle_deg * Pi/180;
    x = R + r_inner * Cos(angle_rad);
    z = r_inner * Sin(angle_rad);
    Point(18+i) = {x, 0, z, lc};
EndFor

//==============================================================================
// STEP 4: Create inner quad boundary vertices (16 points)
//==============================================================================
For i In {0:15}
    angle_deg = i * 22.5;

    If (i == 0)
        x = R + r_quad_boundary; z = 0;
    EndIf
    If (i == 1)
        x = R + r_quad_boundary; z = r_quad_boundary/2;
    EndIf
    If (i == 2)
        x = R + r_quad_boundary; z = r_quad_boundary;
    EndIf
    If (i == 3)
        x = R + r_quad_boundary/2; z = r_quad_boundary;
    EndIf
    If (i == 4)
        x = R + 0; z = r_quad_boundary;
    EndIf
    If (i == 5)
        x = R - r_quad_boundary/2; z = r_quad_boundary;
    EndIf
    If (i == 6)
        x = R - r_quad_boundary; z = r_quad_boundary;
    EndIf
    If (i == 7)
        x = R - r_quad_boundary; z = r_quad_boundary/2;
    EndIf
    If (i == 8)
        x = R - r_quad_boundary; z = 0;
    EndIf
    If (i == 9)
        x = R - r_quad_boundary; z = -r_quad_boundary/2;
    EndIf
    If (i == 10)
        x = R - r_quad_boundary; z = -r_quad_boundary;
    EndIf
    If (i == 11)
        x = R - r_quad_boundary/2; z = -r_quad_boundary;
    EndIf
    If (i == 12)
        x = R + 0; z = -r_quad_boundary;
    EndIf
    If (i == 13)
        x = R + r_quad_boundary/2; z = -r_quad_boundary;
    EndIf
    If (i == 14)
        x = R + r_quad_boundary; z = -r_quad_boundary;
    EndIf
    If (i == 15)
        x = R + r_quad_boundary; z = -r_quad_boundary/2;
    EndIf

    Point(34+i) = {x, 0, z, lc};
EndFor

//==============================================================================
// STEP 5: Create smaller inner quad boundary vertices (8 points)
//==============================================================================
For i In {0:7}
    angle_deg = i * 45;

    If (i == 0)
        x = R + r_small_quad; z = 0;
    EndIf
    If (i == 1)
        x = R + r_small_quad; z = r_small_quad;
    EndIf
    If (i == 2)
        x = R + 0; z = r_small_quad;
    EndIf
    If (i == 3)
        x = R - r_small_quad; z = r_small_quad;
    EndIf
    If (i == 4)
        x = R - r_small_quad; z = 0;
    EndIf
    If (i == 5)
        x = R - r_small_quad; z = -r_small_quad;
    EndIf
    If (i == 6)
        x = R + 0; z = -r_small_quad;
    EndIf
    If (i == 7)
        x = R + r_small_quad; z = -r_small_quad;
    EndIf

    Point(50+i) = {x, 0, z, lc};
EndFor

//==============================================================================
// STEP 6: Create curves
//==============================================================================

// Outer circle arcs (16 segments)
For i In {0:15}
    j = (i+1) % 16;
    Circle(100+i) = {2+i, 1, 2+j};
EndFor

// Inner circle arcs (16 segments)
For i In {0:15}
    j = (i+1) % 16;
    Circle(200+i) = {18+i, 1, 18+j};
EndFor

// Radial lines (outer to inner)
For i In {0:15}
    Line(300+i) = {18+i, 2+i};
EndFor

// Connection lines (inner ring to quad boundary)
For i In {0:15}
    Line(350+i) = {34+i, 18+i};
EndFor

// Center to smaller quad corners (only even indices)
For i In {0:6:2}
    Line(400+i) = {1, 50+i};
EndFor

// Smaller quad boundary to larger quad boundary
For i In {0:6:2}
    large_quad_main_pt = 34 + (i * 2);
    Line(450+i) = {50+i, large_quad_main_pt};
EndFor

// Quad boundary lines (16 segments)
For i In {0:15}
    j = (i+1) % 16;
    Line(550+i) = {34+i, 34+j};
EndFor

// Small quad lines (8 segments)
For i In {0:7}
    j = (i+1) % 8;
    Line(500+i) = {50+i, 50+j};
EndFor

// Additional transition lines
Line(580) = {51, 37};
Line(581) = {51, 35};
Line(582) = {57, 49};
Line(583) = {47, 57};
Line(584) = {45, 55};
Line(586) = {55, 43};
Line(587) = {53, 39};
Line(588) = {53, 41};

//==============================================================================
// STEP 7: Create surfaces
//==============================================================================

// Outer quad surfaces (between outer and inner rings)
For i In {0:15}
    j = (i+1) % 16;

    radial_start = 300 + i;
    outer_arc = 100 + i;
    radial_end = 300 + j;
    inner_arc = 200 + i;

    Curve Loop(600+i) = {radial_start, outer_arc, -radial_end, -inner_arc};
    Plane Surface(700+i) = {600+i};
EndFor

// Middle quad surfaces (between inner ring and quad boundary)
For i In {0:15}
    j = (i+1) % 16;

    connection_start = 350 + i;
    inner_arc = 200 + i;
    connection_end = 350 + j;
    quad_boundary_line = 550 + i;

    Curve Loop(650+i) = {connection_start, inner_arc, -connection_end, -quad_boundary_line};
    Plane Surface(750+i) = {650+i};
EndFor

// Center quad surfaces (4 larger quads)
Curve Loop(800) = {400, -507, -506, -406};
Plane Surface(900) = {800};

Curve Loop(801) = {406, -505, -504, -404};
Plane Surface(901) = {801};

Curve Loop(802) = {404, -503, -502, -402};
Plane Surface(902) = {802};

Curve Loop(803) = {402, -501, -500, -400};
Plane Surface(903) = {803};

// Transition surfaces
Curve Loop(850) = {501, 452, -553, -580};
Plane Surface(950) = {850};

Curve Loop(854) = {581, 551, 552, -580};
Plane Surface(954) = {854};

Curve Loop(855) = {450, 550, -581, -500};
Plane Surface(955) = {855};

Curve Loop(856) = {507, 450, -565, -582};
Plane Surface(956) = {856};

Curve Loop(857) = {583, 582, -564, -563};
Plane Surface(957) = {857};

Curve Loop(858) = {506, -456, -562, -583};
Plane Surface(958) = {858};

Curve Loop(859) = {505, 456, -561, 584};
Plane Surface(959) = {859};

Curve Loop(860) = {586, 560, 559, 584};
Plane Surface(960) = {860};

Curve Loop(861) = {-454, 504, 586,-558};
Plane Surface(961) = {861};

Curve Loop(862) = {587,-554,-452, 502};
Plane Surface(962) = {862};

Curve Loop(863) = {-555, -587, 588,-556};
Plane Surface(963) = {863};

Curve Loop(864) = {-588, 503, 454, -557};
Plane Surface(964) = {864};

//==============================================================================
// STEP 8: Set transfinite meshing for tube cross-section
//==============================================================================

For i In {0:15}
    Transfinite Line {100+i} = nCirc/4 + 1;
    Transfinite Line {200+i} = nCirc/4 + 1;
    Transfinite Line {300+i} = nRad + 1 Using Progression ratioR;
    Transfinite Line {350+i} = nRad + 1 Using Progression ratioR;
    Transfinite Line {550+i} = nCirc/4 + 1;
EndFor

For i In {0:7}
    Transfinite Line {500+i} = nCirc/4 + 1;
EndFor

For i In {0:6:2}
    Transfinite Line {400+i} = nRad + 1;
    Transfinite Line {450+i} = nRad + 1;
EndFor

Transfinite Line {580, 581, 582, 583, 584, 586, 587, 588} = nRad + 1;

// Set transfinite surfaces
For i In {0:15}
    Transfinite Surface {700+i};
    Recombine Surface {700+i};

    Transfinite Surface {750+i};
    Recombine Surface {750+i};
EndFor

Transfinite Surface {900, 901, 902, 903};
Recombine Surface {900, 901, 902, 903};

Transfinite Surface {950, 954, 955, 956, 957, 958, 959, 960, 961, 962, 963, 964};
Recombine Surface {950, 954, 955, 956, 957, 958, 959, 960, 961, 962, 963, 964};

//==============================================================================
// STEP 9: CREATE START HEMISPHERE CAP (pointing in -Y direction)
//==============================================================================

// Create hemisphere center point at the tube cross-section center
Point(5000) = {R, -rtube, 0, lc};

// Create hemisphere surface rings at different latitudes
// We'll create 3 rings: outer (rtube), middle (r_inner), and inner (r_quad_boundary)
// For simplicity, we'll use a coarser structure with 8 meridional sections

// Ring 1: At latitude corresponding to r_inner from center
lat1_y = -rtube + (rtube - r_inner);
lat1_r = Sqrt(rtube*rtube - (rtube - r_inner)*(rtube - r_inner));

// Ring 2: At latitude corresponding to r_quad_boundary from center
lat2_y = -rtube + (rtube - r_quad_boundary);
lat2_r = Sqrt(rtube*rtube - (rtube - r_quad_boundary)*(rtube - r_quad_boundary));

// Ring 3: At equator (connects to tube)
lat3_y = 0;
lat3_r = rtube;

// Create points for start hemisphere (8 meridional directions)
For i In {0:7}
    angle_deg = i * 45;
    angle_rad = angle_deg * Pi/180;

    // Innermost ring
    x1 = R + lat1_r * Cos(angle_rad);
    z1 = lat1_r * Sin(angle_rad);
    Point(5001+i) = {x1, lat1_y, z1, lc};

    // Middle ring
    x2 = R + lat2_r * Cos(angle_rad);
    z2 = lat2_r * Sin(angle_rad);
    Point(5010+i) = {x2, lat2_y, z2, lc};

    // Outer ring (equator - connects to tube)
    x3 = R + lat3_r * Cos(angle_rad);
    z3 = lat3_r * Sin(angle_rad);
    Point(5020+i) = {x3, lat3_y, z3, lc};
EndFor

// Create circular arcs for each ring
For i In {0:7}
    j = (i+1) % 8;
    Circle(5100+i) = {5001+i, 5000, 5001+j};  // Inner ring
    Circle(5110+i) = {5010+i, 5000, 5010+j};  // Middle ring
    Circle(5120+i) = {5020+i, 1, 5020+j};      // Outer ring (around tube center)
EndFor

// Create meridional curves (radial lines on sphere surface)
For i In {0:7}
    Circle(5200+i) = {5000, 5000, 5001+i};    // Center to inner ring
    Circle(5210+i) = {5001+i, 5000, 5010+i};  // Inner to middle ring
    Circle(5220+i) = {5010+i, 5000, 5020+i};  // Middle to outer ring
EndFor

// Create hemisphere surfaces
For i In {0:7}
    j = (i+1) % 8;

    // Inner cap surfaces (center to inner ring)
    Curve Loop(5300+i) = {5200+i, 5100+i, -5200+j};
    Surface(5400+i) = {5300+i};

    // Middle ring surfaces
    Curve Loop(5310+i) = {5210+i, 5110+i, -5210+j, -5100+i};
    Surface(5410+i) = {5310+i};

    // Outer ring surfaces
    Curve Loop(5320+i) = {5220+i, 5120+i, -5220+j, -5110+i};
    Surface(5420+i) = {5320+i};
EndFor

// Apply transfinite meshing to start hemisphere
For i In {0:7}
    Transfinite Line {5100+i} = nCirc/4 + 1;
    Transfinite Line {5110+i} = nCirc/4 + 1;
    Transfinite Line {5120+i} = nCirc/4 + 1;
    Transfinite Line {5200+i} = nHemi + 1;
    Transfinite Line {5210+i} = nRad + 1;
    Transfinite Line {5220+i} = nRad + 1;
EndFor

For i In {0:7}
    Transfinite Surface {5400+i};
    Recombine Surface {5400+i};

    Transfinite Surface {5410+i};
    Recombine Surface {5410+i};

    Transfinite Surface {5420+i};
    Recombine Surface {5420+i};
EndFor

Printf("✓ Created start hemisphere cap with %g surfaces", 24);

//==============================================================================
// STEP 10: Helical extrusion of tube
//==============================================================================

// Collect all tube cross-section surfaces
all_surfaces[] = {};
For i In {0:15}
    all_surfaces[] += {700+i, 750+i};
EndFor
all_surfaces[] += {900, 901, 902, 903};
all_surfaces[] += {950, 954, 955, 956, 957, 958, 959, 960, 961, 962, 963, 964};

Printf("Extruding %g surfaces over %g° with %g layers", #all_surfaces[], angular_span*180/Pi, nAxial);

// Helical twist extrusion
Extrude { {0,0,dz}, {0,0,0}, angular_span } {
    Surface{all_surfaces[]};
    Layers{nAxial};
    Recombine;
}

//==============================================================================
// STEP 11: CREATE END HEMISPHERE CAP
//==============================================================================

// Calculate end position
end_x = R * Cos(end_angle);
end_y = R * Sin(end_angle);
end_z = dz;

// Create hemisphere center point
Point(6000) = {end_x, end_y + rtube, end_z, lc};

// Create points for end hemisphere (rotated by end_angle)
For i In {0:7}
    angle_deg = i * 45;
    angle_rad = angle_deg * Pi/180;

    // Calculate positions relative to helix end
    local_x = lat1_r * Cos(angle_rad);
    local_z = lat1_r * Sin(angle_rad);

    // Rotate by end_angle and translate
    Point(6001+i) = {end_x + local_x * Cos(end_angle) - (lat1_y) * Sin(end_angle),
                     end_y + local_x * Sin(end_angle) + (lat1_y) * Cos(end_angle),
                     end_z + local_z, lc};

    local_x2 = lat2_r * Cos(angle_rad);
    local_z2 = lat2_r * Sin(angle_rad);

    Point(6010+i) = {end_x + local_x2 * Cos(end_angle) - (lat2_y) * Sin(end_angle),
                     end_y + local_x2 * Sin(end_angle) + (lat2_y) * Cos(end_angle),
                     end_z + local_z2, lc};

    local_x3 = lat3_r * Cos(angle_rad);
    local_z3 = lat3_r * Sin(angle_rad);

    Point(6020+i) = {end_x + local_x3 * Cos(end_angle) - (lat3_y) * Sin(end_angle),
                     end_y + local_x3 * Sin(end_angle) + (lat3_y) * Cos(end_angle),
                     end_z + local_z3, lc};
EndFor

// Create circular arcs for end hemisphere
For i In {0:7}
    j = (i+1) % 8;
    Circle(6100+i) = {6001+i, 6000, 6001+j};
    Circle(6110+i) = {6010+i, 6000, 6010+j};
    Point(6999) = {end_x, end_y, end_z, lc};  // Helix end center
    Circle(6120+i) = {6020+i, 6999, 6020+j};
EndFor

// Create meridional curves
For i In {0:7}
    Circle(6200+i) = {6000, 6000, 6001+i};
    Circle(6210+i) = {6001+i, 6000, 6010+i};
    Circle(6220+i) = {6010+i, 6000, 6020+i};
EndFor

// Create end hemisphere surfaces
For i In {0:7}
    j = (i+1) % 8;

    Curve Loop(6300+i) = {6200+i, 6100+i, -6200+j};
    Surface(6400+i) = {6300+i};

    Curve Loop(6310+i) = {6210+i, 6110+i, -6210+j, -6100+i};
    Surface(6410+i) = {6310+i};

    Curve Loop(6320+i) = {6220+i, 6120+i, -6220+j, -6110+i};
    Surface(6420+i) = {6320+i};
EndFor

// Apply transfinite meshing to end hemisphere
For i In {0:7}
    Transfinite Line {6100+i} = nCirc/4 + 1;
    Transfinite Line {6110+i} = nCirc/4 + 1;
    Transfinite Line {6120+i} = nCirc/4 + 1;
    Transfinite Line {6200+i} = nHemi + 1;
    Transfinite Line {6210+i} = nRad + 1;
    Transfinite Line {6220+i} = nRad + 1;
EndFor

For i In {0:7}
    Transfinite Surface {6400+i};
    Recombine Surface {6400+i};

    Transfinite Surface {6410+i};
    Recombine Surface {6410+i};

    Transfinite Surface {6420+i};
    Recombine Surface {6420+i};
EndFor

Printf("✓ Created end hemisphere cap with %g surfaces", 24);

//==============================================================================
// STEP 12: Generate mesh
//==============================================================================

Mesh.RecombineAll = 1;
Mesh.ElementOrder = 1;
Mesh 3;

Printf("✓ Generated pure quad O-mesh helical tube WITH HEMISPHERICAL CAPS");
Printf("✓ Tube: %g surfaces × %g layers", #all_surfaces[], nAxial);
Printf("✓ Caps: 24 surfaces each (start + end)");
Printf("✓ Mesh parameters: nCirc=%g, nRad=%g, nHemi=%g", nCirc, nRad, nHemi);
