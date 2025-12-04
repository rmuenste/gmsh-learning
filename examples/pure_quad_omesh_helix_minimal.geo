//==============================================================================
// Pure Quad O-mesh Helical Tube - MINIMAL COARSE VERSION
// Ultra-coarse O-mesh with nCirc=1, nRad=1 swept along helix centerline
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
ratioR = 1.0;    // radial grading
lc     = rtube/10;

Printf("Generating MINIMAL pure quad O-mesh helical tube:");
Printf("  Angular range: %g° to %g° (%g° span)", start_angle_deg, end_angle_deg, angular_span*180/Pi);
Printf("  Axial rise: %g mm", dz);
Printf("  Helix radius: %g mm, Tube radius: %g mm", R, rtube);
Printf("  Ultra-coarse mesh: nCirc=%g, nRad=%g", nCirc, nRad);

// O-mesh internal structure parameters
r_inner = 0.75 * rtube;                    // Inner ring radius (3/4 of outer radius)
r_quad_boundary = 0.5 * rtube;             // Inner quad boundary radius (1/2 of outer radius)  
r_small_quad = 0.25 * rtube;               // Smaller inner quad boundary radius (1/4 of outer radius)

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
    
    // Main corner positions and midpoint positions
    If (i == 0)     // 0°
        x = R + r_quad_boundary; z = 0;
    EndIf
    If (i == 1)     // 22.5° - midpoint
        x = R + r_quad_boundary; z = r_quad_boundary/2;
    EndIf
    If (i == 2)     // 45°
        x = R + r_quad_boundary; z = r_quad_boundary;
    EndIf
    If (i == 3)     // 67.5° - midpoint
        x = R + r_quad_boundary/2; z = r_quad_boundary;
    EndIf
    If (i == 4)     // 90°
        x = R + 0; z = r_quad_boundary;
    EndIf
    If (i == 5)     // 112.5° - midpoint
        x = R - r_quad_boundary/2; z = r_quad_boundary;
    EndIf
    If (i == 6)     // 135°
        x = R - r_quad_boundary; z = r_quad_boundary;
    EndIf
    If (i == 7)     // 157.5° - midpoint
        x = R - r_quad_boundary; z = r_quad_boundary/2;
    EndIf
    If (i == 8)     // 180°
        x = R - r_quad_boundary; z = 0;
    EndIf
    If (i == 9)     // 202.5° - midpoint
        x = R - r_quad_boundary; z = -r_quad_boundary/2;
    EndIf
    If (i == 10)    // 225°
        x = R - r_quad_boundary; z = -r_quad_boundary;
    EndIf
    If (i == 11)    // 247.5° - midpoint
        x = R - r_quad_boundary/2; z = -r_quad_boundary;
    EndIf
    If (i == 12)    // 270°
        x = R + 0; z = -r_quad_boundary;
    EndIf
    If (i == 13)    // 292.5° - midpoint
        x = R + r_quad_boundary/2; z = -r_quad_boundary;
    EndIf
    If (i == 14)    // 315°
        x = R + r_quad_boundary; z = -r_quad_boundary;
    EndIf
    If (i == 15)    // 337.5° - midpoint
        x = R + r_quad_boundary; z = -r_quad_boundary/2;
    EndIf
    
    Point(34+i) = {x, 0, z, lc};
EndFor

//==============================================================================
// STEP 5: Create smaller inner quad boundary vertices (8 points)
//==============================================================================
For i In {0:7}
    angle_deg = i * 45;  // 0°, 45°, 90°, 135°, 180°, 225°, 270°, 315°
    
    If (i == 0)     // 0°
        x = R + r_small_quad; z = 0;
    EndIf
    If (i == 1)     // 45°
        x = R + r_small_quad; z = r_small_quad;
    EndIf
    If (i == 2)     // 90°
        x = R + 0; z = r_small_quad;
    EndIf
    If (i == 3)     // 135°
        x = R - r_small_quad; z = r_small_quad;
    EndIf
    If (i == 4)     // 180°
        x = R - r_small_quad; z = 0;
    EndIf
    If (i == 5)     // 225°
        x = R - r_small_quad; z = -r_small_quad;
    EndIf
    If (i == 6)     // 270°
        x = R + 0; z = -r_small_quad;
    EndIf
    If (i == 7)     // 315°
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

// Center to smaller quad corners (only even indices: 0°, 90°, 180°, 270°)
For i In {0:6:2}  // Only 0, 2, 4, 6
    Line(400+i) = {1, 50+i};
EndFor

// Smaller quad boundary to larger quad boundary (only specific corners)
For i In {0:6:2}  // Only 0, 2, 4, 6
    large_quad_main_pt = 34 + (i * 2);   // Points 34, 38, 42, 46 (main corners only)
    Line(450+i) = {50+i, large_quad_main_pt};
EndFor

// Quad boundary lines (16 segments between consecutive quad boundary points)
For i In {0:15}
    j = (i+1) % 16;
    Line(550+i) = {34+i, 34+j};
EndFor

// Small quad lines (8 segments)
For i In {0:7}
    j = (i+1) % 8;
    Line(500+i) = {50+i, 50+j};
EndFor

// Additional transition lines for the systematically built O-mesh
Line(580) = {51, 37};
Line(581) = {51, 35};
Line(582) = {57, 49};
Line(583) = {47, 57};
Line(584) = {45, 55};
Line(586) = {55, 43};
Line(587) = {53, 39};
Line(588) = {53, 41};

//==============================================================================
// STEP 7: Create surfaces - FIXED VERSION using the systematically built approach
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

// Center quad surfaces (4 larger quads) - FIXED
Curve Loop(800) = {400, -507, -506, -406};
Plane Surface(900) = {800};

Curve Loop(801) = {406, -505, -504, -404};
Plane Surface(901) = {801};

Curve Loop(802) = {404, -503, -502, -402};
Plane Surface(902) = {802};

Curve Loop(803) = {402, -501, -500, -400};
Plane Surface(903) = {803};

// Transition surfaces - systematically built version for ultra-coarse mesh
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
// STEP 8: Set transfinite meshing for ultra-coarse mesh
//==============================================================================

// Set transfinite curves with minimal divisions
For i In {0:15}
    Transfinite Line {100+i} = nCirc/4 + 1;      // Outer arcs (minimum)
    Transfinite Line {200+i} = nCirc/4 + 1;      // Inner arcs (minimum)
    Transfinite Line {300+i} = nRad + 1 Using Progression ratioR;  // Radial lines
    Transfinite Line {350+i} = nRad + 1 Using Progression ratioR;  // Connection lines
    Transfinite Line {550+i} = nCirc/4 + 1;      // Quad boundary lines (minimum)
EndFor

For i In {0:7}
    Transfinite Line {500+i} = nCirc/4 + 1;      // Small quad lines (minimum)
EndFor

For i In {0:6:2}
    Transfinite Line {400+i} = nRad + 1;         // Center lines
    Transfinite Line {450+i} = nRad + 1;         // Small to large connections
EndFor

// Additional transition lines for transfinite meshing
Transfinite Line {580, 581, 582, 583, 584, 586, 587, 588} = nRad + 1;

// Set transfinite surfaces for structured quad mesh
For i In {0:15}
    Transfinite Surface {700+i};                 // Outer surfaces
    Recombine Surface {700+i};
    
    Transfinite Surface {750+i};                 // Middle surfaces
    Recombine Surface {750+i};
EndFor

// Center surfaces - apply transfinite meshing for structured quads
Transfinite Surface {900, 901, 902, 903};
Recombine Surface {900, 901, 902, 903};

// Transition surfaces - apply transfinite meshing to eliminate triangles
Transfinite Surface {950, 954, 955, 956, 957, 958, 959, 960, 961, 962, 963, 964};
Recombine Surface {950, 954, 955, 956, 957, 958, 959, 960, 961, 962, 963, 964};

//==============================================================================
// STEP 9: Helical extrusion
//==============================================================================

// Collect all surfaces for extrusion
all_surfaces[] = {};
For i In {0:15}
    all_surfaces[] += {700+i, 750+i};            // Outer and middle
EndFor
all_surfaces[] += {900, 901, 902, 903};          // Center
all_surfaces[] += {950, 954, 955, 956, 957, 958, 959, 960, 961, 962, 963, 964};  // All transition surfaces

Printf("Extruding %g MINIMAL surfaces over %g° with %g layers", #all_surfaces[], angular_span*180/Pi, nAxial);

// Helical twist extrusion around Z-axis
Extrude { {0,0,dz}, {0,0,0}, angular_span } { 
    Surface{all_surfaces[]}; 
    Layers{nAxial}; 
    Recombine; 
}

Mesh.RecombineAll = 1;
Mesh.ElementOrder = 1;
Mesh 3;

Printf("✓ Generated MINIMAL pure quad O-mesh helical tube");
Printf("✓ %g surfaces per cross-section with ultra-coarse mesh", #all_surfaces[]);
Printf("✓ %g layers over %g° span", nAxial, angular_span*180/Pi);
Printf("✓ Mesh parameters: nCirc=%g, nRad=%g (minimal CFD-compatible)", nCirc, nRad);