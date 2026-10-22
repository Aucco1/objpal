program hello;

uses crt, math;

const
  Cols = 60;
  Rows = 30;

type
  //record = allows us to group variables together
  TVector3 = record
    x, y, z: real;
  end;
  
  TEdge = record
    a, b: integer;
  end;

var
  //arrays to let us store numbered list of items
  Cube: array[1..8] of TVector3;
  Edges: array[1..12] of TEdge;
  Proj: array[1..8] of record x, y: integer; end;
  ScreenBuf: array[1..Cols, 1..Rows] of char;
  
  AngleX, AngleY, AngleZ: real;
  rx, ry, rz, px, py, pz, zOffset: real;
  i, x, y: integer;
  RowStr: string;

//step 1: geometry
procedure InitCube;
begin
//list all vertices
  //Front face vertices
  Cube[1].x := -1; Cube[1].y := -1; Cube[1].z := -1;
  Cube[2].x :=  1; Cube[2].y := -1; Cube[2].z := -1;
  Cube[3].x :=  1; Cube[3].y :=  1; Cube[3].z := -1;
  Cube[4].x := -1; Cube[4].y :=  1; Cube[4].z := -1;
  //Back face vertices
  Cube[5].x := -1; Cube[5].y := -1; Cube[5].z :=  1;
  Cube[6].x :=  1; Cube[6].y := -1; Cube[6].z :=  1;
  Cube[7].x :=  1; Cube[7].y :=  1; Cube[7].z :=  1;
  Cube[8].x := -1; Cube[8].y :=  1; Cube[8].z :=  1;

  //connect vertices to form edges aka lines
  Edges[1].a:=1; Edges[1].b:=2; Edges[2].a:=2; Edges[2].b:=3;
  Edges[3].a:=3; Edges[3].b:=4; Edges[4].a:=4; Edges[4].b:=1;
  Edges[5].a:=5; Edges[5].b:=6; Edges[6].a:=6; Edges[6].b:=7;
  Edges[7].a:=7; Edges[7].b:=8; Edges[8].a:=8; Edges[8].b:=5;
  Edges[9].a:=1; Edges[9].b:=5; Edges[10].a:=2; Edges[10].b:=6;
  Edges[11].a:=3; Edges[11].b:=7; Edges[12].a:=4; Edges[12].b:=8;
end;

//step 4 rasterize (helper function)
//using bresenhams line algorithm to draw lines
procedure DrawLine(x1, y1, x2, y2: integer);
var
  dx, dy, sx, sy, err, e2: integer;
begin
  dx := abs(x2 - x1); dy := abs(y2 - y1);
  if x1 < x2 then sx := 1 else sx := -1;
  if y1 < y2 then sy := 1 else sy := -1;
  if dx > dy then err := dx div 2 else err := -(dy div 2);
  
  while True do
  begin
    if (x1 >= 1) and (x1 <= Cols) and (y1 >= 1) and (y1 <= Rows) then
      ScreenBuf[x1, y1] := '*'; // Draw a pixel!
      
    if (x1 = x2) and (y1 = y2) then break;
    e2 := err;
    if e2 > -dx then begin err := err - dy; x1 := x1 + sx; end;
    if e2 < dy then begin err := err + dx; y1 := y1 + sy; end;
  end;
end;

//main loop
begin
  InitCube; //call initcube to render
  AngleX := 0; AngleY := 0; AngleZ := 0; //initialize camera
  zOffset := 3.0; //distance of object to camera
  
  clrscr;      //clear screen
  cursoroff;   //hide blinking line
  
  //loop until key pressed
  while not keypressed do
  begin
    //clear screenbuffer with space
    for y := 1 to Rows do
      for x := 1 to Cols do
        ScreenBuf[x, y] := ' ';

    //transformation and rotation matrix
    for i := 1 to 8 do
    begin
      //rotation formula
      ry := Cube[i].y * cos(AngleX) - Cube[i].z * sin(AngleX);
      rz := Cube[i].y * sin(AngleX) + Cube[i].z * cos(AngleX);
      rx := Cube[i].x;

      px := rx * cos(AngleY) + rz * sin(AngleY);
      pz := -rx * sin(AngleY) + rz * cos(AngleY);
      py := ry;

      rx := px * cos(AngleZ) - py * sin(AngleZ);
      ry := px * sin(AngleZ) + py * cos(AngleZ);

      //projection matrix
      pz := pz + zOffset;
      //normalize screen dimension cuz too wide
      Proj[i].x := round(Cols / 2 + (rx / pz) * 20 * 2); 
      Proj[i].y := round(Rows / 2 + (ry / pz) * 20);
    end;

    //draw the stuff aka render
    for i := 1 to 12 do
      DrawLine(Proj[Edges[i].a].x, Proj[Edges[i].a].y, Proj[Edges[i].b].x, Proj[Edges[i].b].y);

    //render to buffer onto screen
  gotoxy(1, 1); 
    TextColor(LightGreen);//color
    
    for y := 1 to Rows do
    begin
      RowStr := '';
      for x := 1 to Cols do
        RowStr := RowStr + ScreenBuf[x, y];
      writeln(RowStr);
    end;

    //rotation increment as t marches
    AngleX := AngleX + 0.03;
    AngleY := AngleY + 0.05;
    AngleZ := AngleZ + 0.02;
    
    delay(5); //fps
  end;
  
  cursoron;//i hereby cast cursor return
end.