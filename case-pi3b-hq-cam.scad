/*
This file is part of the Raspberry Pi security camera project by Justin Cardoza and is distributed under the MIT license.
See the  original repository for more information: https://github.com/justincardoza/pi-security-camera-mk1
*/

$fn = 64;

//HQ camera dimensions
backfocusRingDiameter = 36;
backfocusRingDepth = 1.2;
cameraBoardSize = 38;
cameraCasingDepth = ceil(10.35 + 1.2);
cameraMountingHoleSpacingFromEdge = 4;
cameraMountingHoleSpacingBetween = cameraBoardSize - cameraMountingHoleSpacingFromEdge*2;
cameraTripodMountWidth = 14.5;
cameraTripodMountDepth = 12.5;

//Pi dimensions
piSize = [85, 56];
piMountingHoleSpacingFromEdge = 3.5;
piMountingHoleSpacingBetween = [58, 49];
piCornerRadius = 3;
sdCardProtrusion = 3;
piHeightClearance = 28;

//Ribbon cable slot
ribbonSlotDepth = 1;
ribbonSlotWidth = 18;

//Case frame
frameSize = [piSize.x + sdCardProtrusion, piSize.y + ribbonSlotDepth, 4];
frameCenterCutoutDiameter = 32;

//Spacers and boards
boardThickness = 1.5;
mountingHoleDiameter = 2.75;
spacerWallThickness = 1.5;
spacerLength = 4.5;
spacerOuterDiameter = spacerWallThickness*2 + mountingHoleDiameter;

//Nut recesses
nutRecessDiameter = 5.8;
nutRecessThickness = 1.85;
nutRecessThroughHoleDiameter = 2.75;

//Screw specs
cskScrewMaxHeadDiameter = 4.8;
cskScrewMinHeadDiameter = 2.75;
cskScrewHeadLength = 1.5;

//Case shell
shellFrameTolerance = 0.2;
shellWallThickness = 1.5;
shellFrameSlotWallThickness = 1;
shellFrameEdgeOverlap = piMountingHoleSpacingFromEdge - spacerWallThickness - shellFrameTolerance;
shellAssemblyTabWidth = nutRecessDiameter*1.5;
shellAssemblyTabLength = nutRecessDiameter*2;
shellAssemblyTabTolerance = 0.6;

//I/O shield
ioShieldSize = [56, 20, 1.2];
ioShieldCutout = [54, 18];
ioShieldInteriorCutout = [ioShieldSize.x + 1, ioShieldSize.y + 1, ioShieldSize.z];
sideIoShieldOffset = -(piMountingHoleSpacingFromEdge + (piMountingHoleSpacingBetween.x - ioShieldSize.x)/2);
ioShieldCutoutOffset = [0, 1];

//Pi 3B I/O
pi3bEthernetSize = [16.1, 13.7];
pi3bEthernetOffset = [10.25, boardThickness];
pi3bUsbSize = [15, 15.5];
pi3bUsbOffset1 = [29, 2.4];
pi3bUsbOffset2 = [47, 2.4];
pi3bUsbCorner =  1.2;

pi3bPowerSize = [8, 3];
pi3bPowerOffset = [10.6, 1.1];
pi3bHdmiSize = [15.2, 5.6];
pi3bHdmiOffset = [32, 1.9];
pi3bHdmiCorner = 1.5;
pi3bAudioSize = 6.5;
pi3bAudioOffset = [53.5, boardThickness];

shellSize =
[
	//In X, it has to fit the frame plus tolerance around the edges plus a wall on either side.
	frameSize.x + shellFrameTolerance*2 + shellWallThickness*2,
	//In Y, it has to fit the thickness of the frame, the spacers for both boards, the boards, and the components on them plus probably some extra (the Pi side will have extra ribbon cable).
	frameSize.z + spacerLength*2 + boardThickness*2 + cameraCasingDepth + piHeightClearance, 
	//In Z, it's the same story as X, but it will use the Y size of the frame since that will be rotated.
	frameSize.y + shellFrameTolerance*2 + shellWallThickness*2
];


caseInternalFrame();

translate([0, frameSize.y + 2, 0])
piSpacerShim();

translate([0, -(frameSize.y + 2)])
caseBottomShell();

translate([shellSize.x + 2, -(frameSize.y + 2)])
caseTopShell();

translate([shellSize.x/2 + 2, 0])
pi3bMainIoShield();

translate([shellSize.x/2 + 2, frameSize.y + 2])
pi3cSideIoShield();


module pi3bMainIoShield()
{
	linear_extrude(height = ioShieldSize.z, convexity = 2)
	difference()
	{
		square([ioShieldSize.x, ioShieldSize.y]);
		
		translate(pi3bEthernetOffset + [0, pi3bEthernetSize.y/2] + ioShieldCutoutOffset)
		square(pi3bEthernetSize, center = true);
		
		translate(pi3bUsbOffset1 + [0, pi3bUsbSize.y/2] + ioShieldCutoutOffset)
		cornerCutoffSquare(pi3bUsbSize, cornerCutoff = pi3bUsbCorner, topCorners = true);
		
		translate(pi3bUsbOffset2 + [0, pi3bUsbSize.y/2] + ioShieldCutoutOffset)
		cornerCutoffSquare(pi3bUsbSize, cornerCutoff = pi3bUsbCorner, topCorners = true);
	}
}


module pi3cSideIoShield()
{
	linear_extrude(height = ioShieldSize.z, convexity = 2)
	difference()
	{
		square([ioShieldSize.x, ioShieldSize.y]);
		
		translate(pi3bPowerOffset + [sideIoShieldOffset, pi3bPowerSize.y/2] + ioShieldCutoutOffset)
		square(pi3bPowerSize, center = true);
		
		translate(pi3bHdmiOffset + [sideIoShieldOffset, pi3bHdmiSize.y/2] + ioShieldCutoutOffset)
		cornerCutoffSquare(pi3bHdmiSize, cornerCutoff = pi3bHdmiCorner, topCorners = false);
		
		translate(pi3bAudioOffset + [sideIoShieldOffset, pi3bAudioSize/2] + ioShieldCutoutOffset)
		circle(d = pi3bAudioSize);
	}
}


module cornerCutoffSquare(size, cornerCutoff, topCorners = true)
{
	difference()
	{
		square(size, center = true);
		
		translate([-(size.x/2 + cornerCutoff), -size.y/2])
		rotate(-45)
		square([cornerCutoff, cornerCutoff]*sqrt(2));
		
		translate([size.x/2 - cornerCutoff, -size.y/2])
		rotate(-45)
		square([cornerCutoff, cornerCutoff]*sqrt(2));
		
		if(topCorners)
		{
			translate([-size.x/2, size.y/2 - cornerCutoff])
			rotate(45)
			square([cornerCutoff, cornerCutoff]*sqrt(2));
			
			translate([size.x/2 - cornerCutoff, size.y/2])
			rotate(-45)
			square([cornerCutoff, cornerCutoff]*sqrt(2));
		}
	}
}


module caseBottomShell()
{
	translate([0, 0, shellSize.z/2])
	difference()
	{
		caseShell();
		
		//Cut off the top of the shell.
		translate([0, 0, shellSize.z/2])
		cube([shellSize.x + 1, shellSize.y + 1, shellSize.z], center = true);
		
		//Cutouts for the assembly tabs to fit into.
		translate([-shellSize.x/2, shellSize.y/2 - (shellWallThickness + cameraCasingDepth + boardThickness + spacerLength + frameSize.z/2)/2, -shellAssemblyTabLength/2])
		cube([(shellWallThickness + shellAssemblyTabTolerance)*2, shellAssemblyTabWidth + shellAssemblyTabTolerance, shellAssemblyTabLength + shellAssemblyTabTolerance], center = true);
		
		translate([shellSize.x/2, shellSize.y/2 - (shellWallThickness + cameraCasingDepth + boardThickness + spacerLength + frameSize.z/2)/2, -shellAssemblyTabLength/2])
		cube([(shellWallThickness + shellAssemblyTabTolerance)*2, shellAssemblyTabWidth + shellAssemblyTabTolerance, shellAssemblyTabLength + shellAssemblyTabTolerance], center = true);
	}
}


module caseTopShell()
{
	translate([0, 0, shellSize.z/2])
	rotate([0, 180, 0])
	difference()
	{
		caseShell();
		
		//Cut off the bottom half, except for the assembly tabs.
		difference()
		{
			translate([0, 0, -shellSize.z/2])
			cube([shellSize.x + 1, shellSize.y + 1, shellSize.z], center = true);
			
			translate([-shellSize.x/2, shellSize.y/2 - (shellWallThickness + cameraCasingDepth + boardThickness + spacerLength + frameSize.z/2)/2, -shellAssemblyTabLength/2])
			cube([shellWallThickness*2, shellAssemblyTabWidth, shellAssemblyTabLength], center = true);
			
			translate([shellSize.x/2, shellSize.y/2 - (shellWallThickness + cameraCasingDepth + boardThickness + spacerLength + frameSize.z/2)/2, -shellAssemblyTabLength/2])
			cube([shellWallThickness*2, shellAssemblyTabWidth, shellAssemblyTabLength], center = true);
		}
		
		//Countersink the screw holes in the sides.
		translate([shellSize.x/2 - cskScrewHeadLength/2 + 0.1, shellSize.y/2 - (shellWallThickness + cameraCasingDepth + boardThickness + spacerLength + frameSize.z/2)/2, -nutRecessDiameter])
		rotate([0, 90, 0])
		cylinder(d1 = cskScrewMinHeadDiameter, d2 = cskScrewMaxHeadDiameter, h = cskScrewHeadLength, center = true);
		
		translate([-(shellSize.x/2 - cskScrewHeadLength/2 + 0.1), shellSize.y/2 - (shellWallThickness + cameraCasingDepth + boardThickness + spacerLength + frameSize.z/2)/2, -nutRecessDiameter])
		rotate([0, -90, 0])
		cylinder(d1 = cskScrewMinHeadDiameter, d2 = cskScrewMaxHeadDiameter, h = cskScrewHeadLength, center = true);
		
		//Cutout for the side I/O on the Pi (in the top surface of the shell).
		translate(
		[
			frameSize.x/2 - (piMountingHoleSpacingFromEdge + sdCardProtrusion + piMountingHoleSpacingBetween.x/2), 
			shellSize.y/2 - shellWallThickness - cameraCasingDepth - boardThickness - spacerLength - frameSize.z - spacerLength - ioShieldCutout.y/2,
			shellSize.z/2 - shellWallThickness/2
		])
		{
			cube([ioShieldCutout.x, ioShieldCutout.y, shellWallThickness + 1], center = true);
			
			translate([0, 0, -shellWallThickness/2])
			cube([ioShieldInteriorCutout.x, ioShieldInteriorCutout.y, ioShieldInteriorCutout.z], center = true);
		}
		
		//Cutout for the Pi spacer shim so it doesn't butt up against the side of the frame groove.
		translate(
		[
			frameSize.x/2 - (piMountingHoleSpacingFromEdge + sdCardProtrusion + piMountingHoleSpacingBetween.x/2), 
			shellSize.y/2 - shellWallThickness - cameraCasingDepth - boardThickness - spacerLength - shellFrameSlotWallThickness - frameSize.z + 1,
			shellSize.z/2 - shellWallThickness - shellFrameEdgeOverlap
		])
		{
			cube([piMountingHoleSpacingBetween.x + spacerOuterDiameter, shellFrameSlotWallThickness + 2, shellFrameEdgeOverlap*2], center = true);
		}
	}
}


module caseShell()
{
	difference()
	{
		linear_extrude(height = shellSize.z, center = true)
		offset(r = +piCornerRadius)
		offset(delta = -piCornerRadius)
		square([shellSize.x, shellSize.y], center = true);
		
		//Cut away the interior, except for the parts we want to keep.
		difference()
		{
			linear_extrude(height = shellSize.z - shellWallThickness*2, center = true)
			offset(r = +piCornerRadius - shellWallThickness)
			offset(delta = -piCornerRadius)
			square([shellSize.x, shellSize.y], center = true);
			
			//The slot to hold the internal frame in place.
			translate([0, shellSize.y/2 - shellWallThickness - cameraCasingDepth - boardThickness - spacerLength - frameSize.z/2, 0])
			difference()
			{
				//The outside of the internal frame slot.
				rotate([-90, 0, 0])
				cube([shellSize.x, shellSize.z, frameSize.z + shellFrameSlotWallThickness*2 + shellFrameTolerance*2], center = true);
				
				//Cut out space for the frame to rest in.
				rotate([-90, 0, 0])
				linear_extrude(height = frameSize.z + shellFrameTolerance*2, convexity = 2, center = true)
				offset(r = +piCornerRadius + shellFrameTolerance)
				offset(delta = -piCornerRadius)
				square([frameSize.x, frameSize.y], center = true);
				
				//Cut out space for the frame faces to be exposed.
				rotate([-90, 0, 0])
				linear_extrude(height = frameSize.z + shellFrameTolerance*2 + shellFrameSlotWallThickness*2 + 1, convexity = 2, center = true)
				offset(r = +piCornerRadius - shellFrameEdgeOverlap)
				offset(delta = -piCornerRadius)
				square([frameSize.x, frameSize.y], center = true);
				
				//Cut out a gap for the ribbon cable.
				translate([0, 0, -(shellSize.z/2 - shellWallThickness - shellFrameEdgeOverlap)])
				cube([ribbonSlotWidth, frameSize.z + shellFrameTolerance*2 + shellFrameSlotWallThickness*2 + 1, shellFrameEdgeOverlap*2], center = true);
			}
			
			//Leave in the areas on the sides for the nuts to hold the case together.
			translate([-(shellSize.x/2 - shellWallThickness - nutRecessThickness), shellSize.y/2 - (shellWallThickness + cameraCasingDepth + boardThickness + spacerLength + frameSize.z/2)/2, -shellSize.z/4])
			difference()
			{
				cube([nutRecessThickness*2, nutRecessDiameter*2, shellSize.z/2 - 0.1], center = true);
				
				translate([nutRecessThickness, 0, shellSize.z/4 - nutRecessDiameter])
				rotate([0, -90, 0])
				nutRecess();
			}
			
			translate([+(shellSize.x/2 - shellWallThickness - nutRecessThickness), shellSize.y/2 - (shellWallThickness + cameraCasingDepth + boardThickness + spacerLength + frameSize.z/2)/2, -shellSize.z/4])
			difference()
			{
				cube([nutRecessThickness*2, nutRecessDiameter*2, shellSize.z/2 - 0.1], center = true);
				
				translate([-nutRecessThickness, 0, shellSize.z/4 - nutRecessDiameter])
				rotate([0, +90, 0])
				nutRecess();
			}
		}
		
		//Camera cutout in the front.
		translate([0, shellSize.y/2, 0])
		rotate([-90, 0, 0])
		cylinder(d = backfocusRingDiameter, h = shellWallThickness + 2, center = true);
		
		//Holes for securing the top and bottom together.
		translate([0, shellSize.y/2 - (shellWallThickness + cameraCasingDepth + boardThickness + spacerLength + frameSize.z/2)/2, -nutRecessDiameter])
		rotate([0, -90, 0])
		cylinder(d = mountingHoleDiameter, h = shellSize.x + 1, center = true);
		
		//Cutout for the camera module's tripod threads.
		translate([0, shellSize.y/2 - shellWallThickness - backfocusRingDepth - cameraCasingDepth/2, -(shellSize.z/2 - shellWallThickness/2)])
		cube([cameraTripodMountWidth, cameraTripodMountDepth, shellWallThickness + 1], center = true);
		
		//Cutout for the ports and/or I/O shield for the Pi.
		translate([-(shellSize.x/2 - shellWallThickness/2), shellSize.y/2 - shellWallThickness - cameraCasingDepth - boardThickness - spacerLength - frameSize.z - spacerLength - ioShieldCutout.y/2, 0])
		{
			cube([shellWallThickness + 1, ioShieldCutout.y, ioShieldCutout.x], center = true);
			
			translate([shellWallThickness/2, 0, 0])
			cube([ioShieldInteriorCutout.z, ioShieldInteriorCutout.y, ioShieldInteriorCutout.x], center = true);
		}
		
		//Side and bottom ventilation slots.
		for(i = [0 : -4 : -(shellSize.y/2 - shellWallThickness)])
		{
			translate([shellSize.x/2 - shellWallThickness/2, i, 0])
			cube([shellWallThickness + 1, 1, shellSize.z*0.6], center = true);
			
			translate([shellSize.x/4, i, -(shellSize.z/2 - shellWallThickness/2)])
			cube([shellSize.x/3, 1, shellWallThickness + 1], center = true);
			
			translate([-shellSize.x/4, i, -(shellSize.z/2 - shellWallThickness/2)])
			cube([shellSize.x/3, 1, shellWallThickness + 1], center = true);
		}
		
		for(i = [shellSize.y/2 - shellWallThickness - cameraCasingDepth - boardThickness - spacerLength + 4 : 4 : shellSize.y/2])
		{
			translate([shellSize.x/4, i, -(shellSize.z/2 - shellWallThickness/2)])
			cube([shellSize.x/4, 1, shellWallThickness + 1], center = true);
			
			translate([-shellSize.x/4, i, -(shellSize.z/2 - shellWallThickness/2)])
			cube([shellSize.x/4, 1, shellWallThickness + 1], center = true);
		}
	}
}


module caseInternalFrame()
{
	union()
	{
		difference()
		{
			//Base shape with through holes cut out.
			linear_extrude(height = frameSize.z, convexity = 2)
			difference()
			{
				offset(r = +piCornerRadius)
				offset(delta = -piCornerRadius)
				square([frameSize.x, frameSize.y], center = true);
				
				//Pi mounting holes.
				translate([-frameSize.x/2 + piMountingHoleSpacingFromEdge + sdCardProtrusion + piMountingHoleSpacingBetween.x/2, -frameSize.y/2 + piMountingHoleSpacingFromEdge + ribbonSlotDepth + piMountingHoleSpacingBetween.y/2])
				rectangleOf(piMountingHoleSpacingBetween)
				circle(d = mountingHoleDiameter);
				
				//Camera mounting holes.
				rectangleOf([cameraMountingHoleSpacingBetween, cameraMountingHoleSpacingBetween])
				circle(d = mountingHoleDiameter);
				
				//Center cutout for airflow.
				circle(d = frameCenterCutoutDiameter);
				
				//Slot for ribbon cable.
				translate([0, -frameSize.y/2])
				square([ribbonSlotWidth, ribbonSlotDepth*2], center = true);
			}
			
			//Nut recesses for Pi mounting.
			translate([-frameSize.x/2 + piMountingHoleSpacingFromEdge + sdCardProtrusion + piMountingHoleSpacingBetween.x/2, -frameSize.y/2 + piMountingHoleSpacingFromEdge + ribbonSlotDepth + piMountingHoleSpacingBetween.y/2, frameSize.z])
			rectangleOf(piMountingHoleSpacingBetween)
			rotate([180, 0, 0])
			nutRecess(false);
			
			//Nut recesses for camera mounting.
			rectangleOf([cameraMountingHoleSpacingBetween, cameraMountingHoleSpacingBetween])
			nutRecess(true);
		}//difference
		
		//Camera mounting spacers.
		translate([0, 0, frameSize.z])
		rectangleOf([cameraMountingHoleSpacingBetween, cameraMountingHoleSpacingBetween])
		spacer(spacerOuterDiameter, mountingHoleDiameter, spacerLength);
	}//union
}


module piSpacerShim()
{
	union()
	{
		linear_extrude(height = 1, convexity = 2)
		difference()
		{
			hull()
			rectangleOf(piMountingHoleSpacingBetween)
			circle(d = spacerOuterDiameter);
			
			hull()
			rectangleOf([piMountingHoleSpacingBetween.x - spacerOuterDiameter*sqrt(2), piMountingHoleSpacingBetween.y - spacerOuterDiameter*sqrt(2)])
			circle(d = spacerOuterDiameter);
			
			rectangleOf(piMountingHoleSpacingBetween)
			circle(d = mountingHoleDiameter);
		}
		
		rectangleOf(piMountingHoleSpacingBetween)
		spacer(spacerOuterDiameter, mountingHoleDiameter, spacerLength);
	}
}


module nutRecess(printableTop = false)
{
	difference()
	{
		translate([0, 0, -1])
		cylinder($fn = 6, d = nutRecessDiameter, h = (printableTop ? nutRecessThickness + 0.4 : nutRecessThickness) + 1);
		
		if(printableTop)
		{
			translate([0, 0, nutRecessThickness + 1])
			difference()
			{
				cube([nutRecessDiameter + 1, nutRecessDiameter + 1, 2], center = true);
				cube([(nutRecessThroughHoleDiameter*3 + nutRecessDiameter)/4, nutRecessDiameter + 2, 3], center = true);
			}
			
			translate([0, 0, nutRecessThickness + 1.2])
			difference()
			{
				cube([nutRecessDiameter + 1, nutRecessDiameter + 1, 2], center = true);
				cube([nutRecessDiameter + 2, (nutRecessThroughHoleDiameter*3 + nutRecessDiameter)/4, 3], center = true);
			}
		}
	}
}


module spacer(outerDiameter, innerDiameter, length)
{
	difference()
	{
		cylinder(d = outerDiameter, h = length);
		
		translate([0, 0, -1])
		cylinder(d = innerDiameter, h = length + 2);
	}
}


module rectangleOf(size)
{
	translate([-size.x/2, -size.y/2]) children();
	translate([+size.x/2, -size.y/2]) children();
	translate([+size.x/2, +size.y/2]) children();
	translate([-size.x/2, +size.y/2]) children();
}
