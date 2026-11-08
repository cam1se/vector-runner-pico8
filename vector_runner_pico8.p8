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
 shield=3
 inv=0
 emp=0
 hurt=0
 flash=0
 objs={}
 nextz=32
 wave=0
 for i=1,7 do spawn(true) end
end

function spawn(first)
 local z=nextz
 local kind=1
 -- ordered waves give every pattern a readable escape lane
 if not first then
  local w=wave%18
  if w==3 then kind=5
  elseif w==5 then kind=2
  elseif w==7 then kind=6
  elseif w==9 then kind=3
  elseif w==11 then kind=7
  elseif w==13 then kind=4
  elseif w==15 then kind=8 end
 end
 local lanes={-0.52,0,0.52}
 local n=1
 if kind==1 then
  if wave%5==2 then n=2 end
  if wave%9==6 then n=2 end
 end
 for i=1,n do
  local lane=lanes[((wave+i)%3)+1]
  if kind>1 then lane=lanes[(wave%3)+1] end
  local w=.14
  if kind==2 then w=.20 end
  if kind==3 then w=.30 end
  if kind==4 then w=.11 end
  if kind>4 then w=.10 end
  add(objs,{x=lane,z=z+(i-1)*6,k=kind,w=w})
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
 if btnp(5) then
  state=3
  return
 end
 local steer=0
 if btn(0) then steer-=1 end
 if btn(1) then steer+=1 end
 px=mid(-.78,px+steer*(.022+speed*.018),.78)
 speed=min(.98,speed+.00011)
 dist+=speed
 nextz-=speed
 score+=1+flr(speed*2)
 if inv>0 then inv-=1 end
 if emp>0 then emp-=1 end
 if hurt>0 then hurt-=1 end
 if flash>0 then flash-=1 end
 for o in all(objs) do
  o.z-=speed
  if o.z<7 and o.z>-1 and abs(px-o.x)<o.w+.12 then
   if o.k>4 then
    collect(o)
   elseif o.k==4 then
    emp=90
    o.z=-9
    flash=8
    sfx(3)
   elseif inv>0 or hurt>0 then
    score+=25
    o.z=-9
    flash=5
    sfx(1)
   elseif shield>0 then
    shield-=1
    o.z=-9
    flash=8
    hurt=90
    sfx(1)
    if shield==0 then
     best=max(best,score)
     state=2
    end
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
 -- green power, purple points, blue shield, white invincibility
 if o.k==5 then score+=500 end
 if o.k==6 then score+=1000 end
 if o.k==7 then shield=min(3,shield+1) end
 if o.k==8 then inv=600 end
 o.z=-9
 flash=8
 sfx(2)
end

function py(z)
 return 30+1050/(z+12)*(1+(speed-.42)*.35)
end

function ps(z)
 return 900/(z+12)*(1+(speed-.42)*.35)
end

function projx(x,z)
 return 64+(x-px)*ps(z)
end

function line3(x1,z1,x2,z2,c)
 line(projx(x1,z1),py(z1),projx(x2,z2),py(z2),c)
end

function _draw()
 cls(0)
 if emp>0 then
  blackout()
 else
  stars()
  road()
  for o in all(objs) do
   if o.z<120 then obstacle(o) end
  end
  ship()
 end
 hud()
 if state==0 then title() end
 if state==2 then over() end
 if state==3 then paused() end
end

function blackout()
 -- an EMP deliberately removes the depth cues for a short time
 for i=1,18 do
  local y=(i*23+emp*3)%120+8
  line(0,y,127,y,i%2==0 and 1 or 5)
 end
 print("emp interference",31,59,6)
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
 if o.k==4 then
  local c=8
  local cx=projx(o.x,z)
  local cy=py(z)-ps(z)*.12
  local r=ps(z)*.14
  line(cx,cy-r,cx+r,cy,c)
  line(cx+r,cy,cx,cy+r,c)
  line(cx,cy+r,cx-r,cy,c)
  line(cx-r,cy,cx,cy-r,c)
  return
 end
 if o.k>4 then
  local c=11
  if o.k==5 then c=3 end
  if o.k==6 then c=13 end
  if o.k==8 then c=7 end
  local cx=projx(o.x,z)
  local cy=py(z)-ps(z)*.14
  local r=max(1,ps(z)*.11)
  rect(cx-r,cy-r,cx+r,cy+r,c)
  line(cx-r,cy-r,cx,cy-r-r,c)
  line(cx+r,cy-r,cx+r+r,cy-r-r,c)
  line(cx,cy-r-r,cx+r+r,cy-r-r,c)
  return
 end
 local h=ps(z)*.26
 if o.k==2 then h=ps(z)*.50 end
 if o.k==3 then h=ps(z)*.15 end
 local ax=projx(o.x,z+2.5)
 local ay=py(z+2.5)-h
 local c=8
 if o.k==2 then c=9 end
 if o.k==3 then c=10 end
 -- independent wireframe pyramid: four base edges converge at one apex
 line(x1,y1,x2,y1,c)
 line(a,y2,b,y2,c)
 line(x1,y1,a,y2,c)
 line(x2,y1,b,y2,c)
 line(x1,y1,ax,ay,c)
 line(x2,y1,ax,ay,c)
 line(a,y2,ax,ay,c)
 line(b,y2,ax,ay,c)
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
 -- animated exhaust keeps the runner readable at handheld scale
 local flame=4+(flr(dist)%3)
 line(x-3,y+8,x-3,y+flame+8,9)
 line(x+3,y+8,x+3,y+flame+8,9)
 if flr(dist)%2==0 then line(x,y+9,x,y+flame+10,10) end
end

function hud()
 rectfill(0,0,127,7,0)
 print("score "..score,2,1,7)
 print("v"..flr(speed*100),97,1,10)
 print("sh "..shield,73,1,11)
 if inv>0 then print("i",90,1,14) end
 if emp>0 then print("e",90,1,12) end
end

function title()
 -- original neon launch tableau, drawn only with PICO-8 primitives
 rectfill(0,31,127,127,1)
 circfill(103,39,12,9)
 circfill(103,39,8,10)
 for y=48,64,4 do line(0,y,127,y,13) end
 for x=7,121,19 do line(x,66,x-12,105,5) end
 line(0,67,127,67,12)
 rectfill(0,102,127,127,0)
 line(0,103,127,103,5)
 line(0,115,127,115,1)
 line(0,124,127,124,5)
 rectfill(6,42,121,98,0)
 rect(6,42,121,98,12)
 print("VECTOR",36,48,12)
 print("RUNNER",36,57,10)
 line(28,63,99,63,8)
 print("d-pad: steer",31,70,7)
 print("avoid the wire",25,77,8)
 print("green/purple: points",21,84,3)
 print("blue: shield  white: inv",13,90,11)
 print("press o / x",31,105,10)
 -- small launch ship / beacon below the card
 line(64,111,59,121,12)
 line(64,111,69,121,12)
 line(59,121,64,119,12)
 line(69,121,64,119,12)
 line(62,122,62,126,9)
 line(66,122,66,126,9)
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
