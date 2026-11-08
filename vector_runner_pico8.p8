pico-8 cartridge // http://www.pico-8.com
version 41
__lua__
-- vector runner
-- independent pico-8 remake

function _init()
 srand(7)
 best=0
 reset()
 state=0
end

function reset()
 px=0
 speed=0.42
 score=0
 dist=0
 shield=2
 inv=0
 flash=0
 objs={}
 nextz=32
 wave=0
 for i=1,7 do spawn(true) end
end

function spawn(first)
 local z=nextz
 local kind=1
 -- distinct original-style pickup lanes
 if not first then
  if wave%11==7 then kind=4
  elseif wave%7==4 then kind=3
  elseif wave%4==3 then kind=2 end
 end
 local lanes={-0.52,0,0.52}
 local n=1
 if kind==1 then
  if wave%5==2 then n=2 end
  if wave%9==6 then n=2 end
 end
 for i=1,n do
  local lane=lanes[((wave+i*2)%3)+1]
  if kind>1 then lane=lanes[(wave%3)+1] end
  add(objs,{x=lane,z=z+(i-1)*5,k=kind,w=kind>1 and .12 or .18})
 end
 nextz+=18+((wave%3)*5)
 wave+=1
end

function _update60()
 if state==0 then
  if btnp(4) or btnp(5) then reset() state=1 end
  return
 end
 if state==2 then
  if btnp(4) or btnp(5) then reset() state=1 end
  return
 end
 if state==3 then
  if btnp(5) then state=1 end
  return
 end
 if btnp(5) then state=3 return end
 local steer=0
 if btn(0) then steer-=1 end
 if btn(1) then steer+=1 end
 px=mid(-.78,px+steer*(.022+speed*.018),.78)
 speed=min(.98,speed+.00011)
 dist+=speed
 nextz-=speed
 score+=1+flr(speed*2)
 if inv>0 then inv-=1 end
 if flash>0 then flash-=1 end
 for o in all(objs) do
  o.z-=speed
  if o.z<7 and o.z>-1 and abs(px-o.x)<o.w+.12 then
   if o.k>1 then
    collect(o)
   elseif inv>0 then
    score+=25
    o.z=-9
    flash=5
    sfx(1)
   elseif shield>0 then
    shield-=1
    o.z=-9
    flash=8
    sfx(1)
   else
    best=max(best,score)
    state=2
    sfx(0)
   end
  end
  if o.z<-8 then del(objs,o) end
 end
 while nextz<132 do spawn() end
end

function collect(o)
 if o.k==2 then score+=250 end
 if o.k==3 then shield=min(3,shield+1) end
 if o.k==4 then inv=360 end
 o.z=-9
 flash=8
 sfx(2)
end

function py(z)
 return 30+1050/(z+12)
end

function ps(z)
 return 900/(z+12)
end

function projx(x,z)
 return 64+(x-px)*ps(z)
end

function line3(x1,z1,x2,z2,c)
 line(projx(x1,z1),py(z1),projx(x2,z2),py(z2),c)
end

function _draw()
 cls(0)
 stars()
 road()
 for o in all(objs) do
  if o.z<120 then obstacle(o) end
 end
 ship()
 hud()
 if state==0 then title() end
 if state==2 then over() end
 if state==3 then paused() end
end

function stars()
 for i=1,26 do
  local x=(i*47+11)%128
  local y=(i*19+7)%29
  pset(x,y,(i%5==0) and 7 or 5)
 end
 line(0,30,127,30,1)
end

function road()
 -- horizon-to-player cross grid
 local z=120-(dist%8)
 while z>0 do
  local y=py(z)
  local hw=.88*ps(z)
  line(64-hw,y,64+hw,y,5)
  z-=8
 end
 -- converging lane markers and road boundaries
 for x=-.88,.88,.44 do
  line3(x,120,x,0,(x==-.88 or x==.88) and 12 or 1)
 end
 -- passing roadside beacons
 local beacon=10-(dist%18)
 for z=beacon,115,18 do
  local y=py(z)
  local x=projx(-1.05,z)
  circfill(x,y,1,8)
  x=projx(1.05,z)
  circfill(x,y,1,8)
 end
end

function obstacle(o)
 local z=o.z
 local zf=z+5
 local w=o.w
 local x1=projx(o.x-w,z)
 local x2=projx(o.x+w,z)
 local y1=py(z)
 local a=projx(o.x-w,zf)
 local b=projx(o.x+w,zf)
 local y2=py(zf)
 if o.k>1 then
  -- yellow: score, green: shield, purple: invincibility
  local c=10
  if o.k==3 then c=11 end
  if o.k==4 then c=14 end
  local cx=projx(o.x,z)
  local cy=py(z)-ps(z)*.12
  local r=ps(z)*.14
  line(cx,cy-r,cx+r,cy,c)
  line(cx+r,cy,cx,cy+r,c)
  line(cx,cy+r,cx-r,cy,c)
  line(cx-r,cy,cx,cy-r,c)
  return
 end
 local h=ps(z)*.32
 local hf=ps(zf)*.32
 -- a wireframe wedge/cube, deliberately no filled original art
 line(x1,y1,x2,y1,8)
 line(a,y2,b,y2,8)
 line(x1,y1,a,y2,8)
 line(x2,y1,b,y2,8)
 line(x1,y1,x1,y1-h,8)
 line(x2,y1,x2,y1-h,8)
 line(a,y2,a,y2-hf,8)
 line(b,y2,b,y2-hf,8)
 line(x1,y1-h,x2,y1-h,7)
 line(a,y2-hf,b,y2-hf,7)
 line(x1,y1-h,a,y2-hf,7)
 line(x2,y1-h,b,y2-hf,7)
end

function ship()
 local x=64
 local y=112
 local c=shield>0 and 12 or 8
 if inv>0 then c=14 end
 if flash%2==1 then c=7 end
 line(x-7,y+5,x,y-7,c)
 line(x,y-7,x+7,y+5,c)
 line(x+7,y+5,x,y+2,c)
 line(x,y+2,x-7,y+5,c)
 line(x-4,y+4,x,y+9,c)
 line(x,y+9,x+4,y+4,c)
end

function hud()
 rectfill(0,0,127,7,0)
 print("score "..score,2,1,7)
 print("v"..flr(speed*100),97,1,10)
 print("s"..shield,78,1,11)
 if inv>0 then print("i",90,1,14) end
end

function title()
 rectfill(11,43,116,84,0)
 rect(11,43,116,84,12)
 print("vector runner",27,50,12)
 print("d-pad: steer",31,62,7)
 print("avoid the wire",25,69,8)
 print("yellow: score",29,76,10)
 print("green: shield  purple: inv",9,82,11)
 print("press o / x",31,91,10)
end

function paused()
 rectfill(31,56,96,71,0)
 rect(31,56,96,71,12)
 print("paused - x",38,61,7)
end

function over()
 rectfill(19,48,108,80,0)
 rect(19,48,108,80,8)
 print("signal lost",38,54,8)
 print("score "..score,41,62,7)
 print("best "..best,43,68,10)
 print("o / x to run",30,87,12)
end
