//==============================================================================
// Pure Quad O-mesh Helical Tube - MINIMAL COARSE VERSION with 3 BL rings
// Adds extra concentric rings between outer and inner rings
//==============================================================================
SetFactory("Built-in");

// ----- Geometric parameters -------------------------------------------------
R      = 25.0;    // helix radius
rtube  =  2.5;    // tube radius
Pturn  =  7.0;    // pitch per full turn

// Angular range parameters
start_angle_deg = 45.0;     // Start angle in degrees
end_angle_deg = 135.0;     // End angle in degrees

// Convert to radians and calculate axial rise
start_angle = start_angle_deg * Pi/180;
end_angle = end_angle_deg * Pi/180;
angular_span = end_angle - start_angle;
dz = (Pturn / (2*Pi)) * angular_span;

// Mesh parameters
nCirc  = 1;      // cells around circumference (ultra-coarse)
nRad   = 1;      // cells centre->wall (ultra-coarse)
nAxial = 50;     // layers along sweep
ratioR = 1.0;    // radial grading
lc     = rtube/10;

Printf("Generating MINIMAL pure quad O-mesh helical tube (3 BL rings):");
Printf("  Angular range: %g° to %g° (%g° span)", start_angle_deg, end_angle_deg, angular_span*180/Pi);
Printf("  Axial rise: %g mm", dz);
Printf("  Helix radius: %g mm, Tube radius: %g mm", R, rtube);
Printf("  Ultra-coarse mesh: nCirc=%g, nRad=%g", nCirc, nRad);

// O-mesh internal structure parameters
r_inner = 0.75 * rtube;                    // Inner ring radius (3/4 of outer radius)
r_bl1   = 0.90 * rtube;                    // BL ring radius (near wall, inner-most BL)
r_bl2   = 0.95 * rtube;                    // BL ring radius (mid BL)
r_bl3   = 0.98 * rtube;                    // BL ring radius (outer-most BL)
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
// STEP 3: Create BL ring vertices (3 rings, 16 points each)
//==============================================================================
For i In {0:15}
    angle_deg = i * 22.5;
    angle_rad = angle_deg * Pi/180;
    x = R + r_bl1 * Cos(angle_rad);
    z = r_bl1 * Sin(angle_rad);
    Point(1000+i) = {x, 0, z, lc};
EndFor

For i In {0:15}
    angle_deg = i * 22.5;
    angle_rad = angle_deg * Pi/180;
    x = R + r_bl2 * Cos(angle_rad);
    z = r_bl2 * Sin(angle_rad);
    Point(1020+i) = {x, 0, z, lc};
EndFor

For i In {0:15}
    angle_deg = i * 22.5;
    angle_rad = angle_deg * Pi/180;
    x = R + r_bl3 * Cos(angle_rad);
    z = r_bl3 * Sin(angle_rad);
    Point(1040+i) = {x, 0, z, lc};
EndFor

//==============================================================================
// STEP 4: Create inner ring vertices (16 points every 22.5°)
//==============================================================================
For i In {0:15}
    angle_deg = i * 22.5;
    angle_rad = angle_deg * Pi/180;
    x = R + r_inner * Cos(angle_rad);
    z = r_inner * Sin(angle_rad);
    Point(18+i) = {x, 0, z, lc};
EndFor

//==============================================================================
// STEP 5: Create inner quad boundary vertices (16 points)
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
// STEP 6: Create smaller inner quad boundary vertices (8 points)
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
// STEP 7: Create curves
//==============================================================================

// Outer circle arcs (16 segments)
For i In {0:15}
    j = (i+1) % 16;
    Circle(100+i) = {2+i, 1, 2+j};
EndFor

// BL circle arcs (3 rings, 16 segments each)
For i In {0:15}
    j = (i+1) % 16;
    Circle(1200+i) = {1000+i, 1, 1000+j};
EndFor
For i In {0:15}
    j = (i+1) % 16;
    Circle(1220+i) = {1020+i, 1, 1020+j};
EndFor
For i In {0:15}
    j = (i+1) % 16;
    Circle(1240+i) = {1040+i, 1, 1040+j};
EndFor

// Inner circle arcs (16 segments)
For i In {0:15}
    j = (i+1) % 16;
    Circle(200+i) = {18+i, 1, 18+j};
EndFor

// Radial lines (outer to BL3 ring)
For i In {0:15}
    Line(1300+i) = {1040+i, 2+i};
EndFor

// Radial lines (BL3 ring to BL2 ring)
For i In {0:15}
    Line(1320+i) = {1020+i, 1040+i};
EndFor

// Radial lines (BL2 ring to BL1 ring)
For i In {0:15}
    Line(1340+i) = {1000+i, 1020+i};
EndFor

// Radial lines (BL1 ring to inner ring)
For i In {0:15}
    Line(1360+i) = {18+i, 1000+i};
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
// STEP 8: Create surfaces - four outer annular bands + inner structure
//==============================================================================

// Outer annular band surfaces (outer to BL3 ring)
For i In {0:15}
    j = (i+1) % 16;

    radial_start = 1300 + i;
    outer_arc = 100 + i;
    radial_end = 1300 + j;
    bl_arc = 1240 + i;

    Curve Loop(600+i) = {radial_start, outer_arc, -radial_end, -bl_arc};
    Plane Surface(700+i) = {600+i};
EndFor

// BL annular band surfaces (BL3 ring to BL2 ring)
For i In {0:15}
    j = (i+1) % 16;

    radial_start = 1320 + i;
    bl_outer_arc = 1240 + i;
    radial_end = 1320 + j;
    bl_inner_arc = 1220 + i;

    Curve Loop(620+i) = {radial_start, bl_outer_arc, -radial_end, -bl_inner_arc};
    Plane Surface(720+i) = {620+i};
EndFor

// BL annular band surfaces (BL2 ring to BL1 ring)
For i In {0:15}
    j = (i+1) % 16;

    radial_start = 1340 + i;
    bl_outer_arc = 1220 + i;
    radial_end = 1340 + j;
    bl_inner_arc = 1200 + i;

    Curve Loop(640+i) = {radial_start, bl_outer_arc, -radial_end, -bl_inner_arc};
    Plane Surface(740+i) = {640+i};
EndFor

// BL annular band surfaces (BL1 ring to inner ring)
For i In {0:15}
    j = (i+1) % 16;

    radial_start = 1360 + i;
    bl_arc = 1200 + i;
    radial_end = 1360 + j;
    inner_arc = 200 + i;

    Curve Loop(660+i) = {radial_start, bl_arc, -radial_end, -inner_arc};
    Plane Surface(760+i) = {660+i};
EndFor

// Middle quad surfaces (between inner ring and quad boundary)
For i In {0:15}
    j = (i+1) % 16;

    connection_start = 350 + i;
    inner_arc = 200 + i;
    connection_end = 350 + j;
    quad_boundary_line = 550 + i;

    Curve Loop(680+i) = {connection_start, inner_arc, -connection_end, -quad_boundary_line};
    Plane Surface(820+i) = {680+i};
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
// STEP 9: Set transfinite meshing for ultra-coarse mesh
//==============================================================================

// Set transfinite curves with minimal divisions
For i In {0:15}
    Transfinite Line {100+i} = nCirc/4 + 1;      // Outer arcs (minimum)
    Transfinite Line {1200+i} = nCirc/4 + 1;     // BL1 arcs (minimum)
    Transfinite Line {1220+i} = nCirc/4 + 1;     // BL2 arcs (minimum)
    Transfinite Line {1240+i} = nCirc/4 + 1;     // BL3 arcs (minimum)
    Transfinite Line {200+i} = nCirc/4 + 1;      // Inner arcs (minimum)
    Transfinite Line {1300+i} = nRad + 1 Using Progression ratioR;  // Outer->BL3
    Transfinite Line {1320+i} = nRad + 1 Using Progression ratioR;  // BL3->BL2
    Transfinite Line {1340+i} = nRad + 1 Using Progression ratioR;  // BL2->BL1
    Transfinite Line {1360+i} = nRad + 1 Using Progression ratioR;  // BL1->Inner
    Transfinite Line {350+i} = nRad + 1 Using Progression ratioR;   // Connection lines
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
    Transfinite Surface {700+i};                 // Outer annular band
    Recombine Surface {700+i};

    Transfinite Surface {720+i};                 // BL3->BL2 band
    Recombine Surface {720+i};

    Transfinite Surface {740+i};                 // BL2->BL1 band
    Recombine Surface {740+i};

    Transfinite Surface {760+i};                 // BL1->Inner band
    Recombine Surface {760+i};

    Transfinite Surface {820+i};                 // Middle surfaces
    Recombine Surface {820+i};
EndFor

// Center surfaces - apply transfinite meshing for structured quads
Transfinite Surface {900, 901, 902, 903};
Recombine Surface {900, 901, 902, 903};

// Transition surfaces - apply transfinite meshing to eliminate triangles
Transfinite Surface {950, 954, 955, 956, 957, 958, 959, 960, 961, 962, 963, 964};
Recombine Surface {950, 954, 955, 956, 957, 958, 959, 960, 961, 962, 963, 964};

//==============================================================================
// STEP 10: Helical extrusion
//==============================================================================

// Collect all surfaces for extrusion
all_surfaces[] = {};
For i In {0:15}
    all_surfaces[] += {700+i, 720+i, 740+i, 760+i, 820+i};     // Outer + BL bands + middle
EndFor
all_surfaces[] += {900, 901, 902, 903};          // Center
all_surfaces[] += {950, 954, 955, 956, 957, 958, 959, 960, 961, 962, 963, 964};  // All transition surfaces

Printf("Extruding %g MINIMAL surfaces over %g° with %g layers", #all_surfaces[], angular_span*180/Pi, nAxial);

// Apply start angle by rotating the entire cross-section before helical sweep
Rotate {{0,0,1}, {0,0,0}, start_angle} { Surface{all_surfaces[]}; }

// Helical twist extrusion around Z-axis
// Use 4-argument twist form: translation, axis direction, axis point, angle
Extrude { {0,0,dz}, {0,0,1}, {0,0,0}, angular_span } {
    Surface{all_surfaces[]};
    Layers{nAxial};
    Recombine;
}

Mesh.RecombineAll = 1;
Mesh.ElementOrder = 1;
Mesh 3;

Printf("✓ Generated MINIMAL pure quad O-mesh helical tube (3 BL rings)");
Printf("✓ %g surfaces per cross-section with ultra-coarse mesh", #all_surfaces[]);
Printf("✓ %g layers over %g° span", nAxial, angular_span*180/Pi);
Printf("✓ Mesh parameters: nCirc=%g, nRad=%g (minimal CFD-compatible)", nCirc, nRad);

// Export mesh to VTK for visualization (write only 3D elements)
Mesh.SaveAll = 0;
Mesh.Format = 10; // VTK legacy format
Save "../output/pure_quad_omesh_helix_minimal_bl1.vtk";
