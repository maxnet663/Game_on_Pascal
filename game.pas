program Game;
uses crt;

const
    DelayDuration = 100;
    MaxMoves = 300;
    MaxPlayerMoves = 30;

type
    star = record
        x, y, dx, dy: integer;
end;

type
    rect = record
        x, y, a, b: integer;
end;

procedure GetKey(var code: integer);
var
    ch: char;
begin
    ch := ReadKey;
    if ch = #0 then
    begin
        ch := ReadKey;
        code := -ord(ch);
    end
    else
        code := ord(ch);
end;

procedure printrect(var r: rect);
var
    i, j: integer;
begin
    GotoXY(r.x, r.y);
    for i := 1 to r.a do
    begin
        for j := 1 to r.b do
            write('@');
        GotoXY(r.x, r.y + i);
    end;
end;

procedure PrintStar(var s: star);
begin
    GotoXY(s.x, s.y);
    write('*');
    GotoXY(2,2);
end;

procedure HideStar(var s: star);
begin
    GotoXY(s.x, s.y);
    write(' ');
    GotoXY(2, 2);
end;

procedure MoveStar(var s: star);
begin
    HideStar(s);
    s.x := s.x + s.dx;
    if s.x > ScreenWidth then
        s.x := 2;
    if s.x < 2 then
        s.x := ScreenWidth;
    s.y := s.y + s.dy;
    if s.y > ScreenHeight then
        s.y := 2;
    if s.y < 2 then
        s.y := ScreenHeight;
    PrintStar(s);
end;

procedure SetDirection(var s: star; dx, dy: integer);
begin
    s.dx := dx;
    s.dy := dy;
end;

procedure ChangeDirection(var s: star);
var
    rs: integer;
begin
    rs := random(3);
    case rs of
        0: SetDirection(s, s.dx, s.dy); 
        1: SetDirection(s, s.dy, s.dx); 
        2: SetDirection(s, -s.dy, -s.dx); 
    end;
end;

procedure GetBlock(var block: boolean; var PlrMovesCounter, BlockCounter: word; 
                    var LastKey: integer);
begin
    block := true;
    PlrMovesCounter := PlrMovesCounter + 1;
    BlockCounter := 0;
    LastKey := 0;
end;

function GameOver(s: star; r: rect; PlrMovesCounter, 
                    MovesCounter: word): boolean;
begin
    GameOver := ( (s.x >= r.x) and (s.x < r.x + r.b) and (s.y >= r.y) 
        and (s.y < r.y + r.a) ) or (PlrMovesCounter > MaxPlayerMoves) or
        (MovesCounter > MaxMoves);
end;

function Won(s: star; r: rect; MovesCounter, PlrMovesCounter: word) : boolean;
begin
    Won := (s.x >= r.x) and (s.x < r.x + r.b) and (s.y >= r.y) and 
        (s.y < r.y + r.a) and (PlrMovesCounter < MaxPlayerMoves) and
        (MovesCounter < MaxMoves);
end;

procedure PrintStats(var PlrMovesCounter, MovesCounter: word; block: boolean);
begin
    GotoXY(1, 1);
    write('Game moves: ', MovesCounter,' / ', MaxMoves, '. Your moves: ', 
            PlrMovesCounter, ' / ', MaxPlayerMoves, 
            '   Press SPACE for pause, ESCAPE to exit');
    if not block then
        write('      NOT blocked')
    else
        write('      Blocked');
    GotoXY(2, 2);
end;

var
    s: star;
    r: rect;
    code, LastKey: integer;
    change, block, victory: boolean;
    MovesCounter, PlrMovesCounter, BlockCounter: word;
begin
    randomize;
    clrscr;
    s.x := 2;
    s.y := 2;
    s.dx := 1;
    s.dy := 0;
    r.a := 3;
    r.b := 3;
    r.x := round(ScreenWidth div 2 - r.b div 2);
    r.y := round(ScreenHeight div 2 - r.a div 2);
    PrintStar(s);
    PrintRect(r);
    MovesCounter := 0;
    PlrMovesCounter := 0;
    BlockCounter := 0;
    block := true;
    LastKey := 0;
    while not GameOver(s, r, PlrMovesCounter, MovesCounter) do
    begin
        PrintStats(PlrMovesCounter, MovesCounter, block);
        if KeyPressed then
        begin
            GetKey(code);
            if code = 27 then
                break;
            if code = 32 then
            begin
            code := 0;
                while code <> 32 do
                begin
                    while not KeyPressed do
                    begin
                        Delay(500);
                        continue;
                    end;
                    GetKey(code);
                end;
            end;
            LastKey := code;
            code := 0;
        end;
        if (not block) and (LastKey <> 0) then
        begin
            case LastKey of
            -75: begin
                    SetDirection(s, -1, 0);
                    GetBlock(block, PlrMovesCounter, BlockCounter, LastKey);
                    continue;
                end;
            -72: begin 
                    SetDirection(s, 0, -1);
                    GetBlock(block, PlrMovesCounter, BlockCounter, LastKey);
                    continue;
                end;
            -77: begin
                    SetDirection(s, 1, 0);
                    GetBlock(block, PlrMovesCounter, BlockCounter, LastKey);
                    continue;
                end;
            -80: begin
                    SetDirection(s, 0, 1);
                    GetBlock(block, PlrMovesCounter, BlockCounter, LastKey);
                    continue;
                end
                else
                    LastKey := 0;
            end;
        end;
        if not KeyPressed then
        begin
            Delay(DelayDuration);
            MoveStar(s);
            MovesCounter := MovesCounter + 1;
            BlockCounter := BlockCounter + 1;
            if block then
                block := BlockCounter  <> 10;
            change := random(10) = 1;
            if change then
                ChangeDirection(s);
            continue;
        end;
    end;
    clrscr;
    if Won(s, r, MovesCounter, PlrMovesCounter) then
    begin
        while not KeyPressed do
        begin
            GotoXY(ScreenWidth div 2 - length('YOU WON!') div 2, 
                    ScreenHeight div 2 - length('YOU WON!') div 2);
            write('YOU WON!');
            GotoXY(1,1);
        end;
    end
    else
    begin
        while not KeyPressed do
        begin
            GotoXY(ScreenWidth div 2 - length('YOU LOSE!') div 2, 
                    ScreenHeight div 2 - length('YOU LOSE!') div 2);
            write('YOU LOSE!');
            GotoXY(1,1);
        end;
    end;
    clrscr;
end.
