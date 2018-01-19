procedure lspedge (input)

string 	input 		{prompt="Input image"}
string 	output		{prompt="Output file containing the edges"}
int	grow		{0,prompt="Grow region"}
bool	verbose		{no,prompt="Verbose?"}
bool	interactive	{no,prompt="Find edge interactively?"}
string *list1 	{prompt="Ignore this parameter"}

begin
string input1,out1
string gradpos, gradneg, gradhpos, gradhneg, tmppos, tmpneg, tmphpos, tmphneg
real	x1,x2,y1[4],y2[4], xtmp, ytmp
int	nsc, istrip, igrow,ireg
string sdum
bool	inter1,verb1 

inter1 = interactive
input1 = input
igrow = grow
verb1 = verbose


gradpos = mktemp("_lspplgradps")
gradneg = mktemp("_lspplgradng")

tmppos = mktemp("_lsppltpps")
tmpneg = mktemp("_lsppltpng")

## vertical limits
gradient(input1,gradpos,"90")
hedit(gradpos,"DISPAXIS",1,add+,ver-,upd+, > "dev$null") 
imarith(gradpos,"*","-1.",gradneg)


# Find slit parameters from gradient image
  # Find lower edges
  apfind (gradpos, nfind=4, line=400, nsum=400,
                        intera=inter1, minsep=200,maxsep=300)

  match ("center", "database/ap"//gradpos, stop-, > tmppos)

    
  # Find upper edges
  apfind (gradneg, nfind=4, line=400, nsum=400,
                        intera=inter1, minsep=200,maxsep=300, > "dev$null")
  match ("center","database/ap"//gradneg, stop-, > tmpneg)
  

## read horizontal limits
  list1 = tmppos
  sdum="" 
  istrip = 0
  while (fscan(list1,sdum,xtmp,ytmp) != EOF) {
       istrip += 1 
       y1[istrip] = ytmp + igrow
    }
 
  list1 = tmpneg
  sdum="" 
  istrip = 0
  while (fscan(list1,sdum,xtmp,ytmp) != EOF) {
       istrip += 1 
       y2[istrip] = ytmp - igrow
    }
 
## horizontal limits
gradhpos = mktemp("_limplhgradps")
gradhneg = mktemp("_limplhgradng")

tmphpos = mktemp("_limpltphps")
tmphneg = mktemp("_limpltphng")

gradient(input1,gradhpos,"0")
hedit(gradhpos,"DISPAXIS",2,add+,ver-,upd+, > "dev$null") 
imarith(gradhpos,"*","-1.",gradhneg)
# Find limits from gradient image
  # Find left edge
  apfind (gradhpos, nfind=1, line=400, nsum=150,recenter=yes,
                        intera=inter1, minsep=INDEF,maxsep=INDEF)
  match ("center", "database/ap"//gradhpos, stop-, > tmphpos)
    
  # Find right edge
  apfind (gradhneg, nfind=1, line=400, nsum=150,recenter=yes,
                        intera=inter1, minsep=INDEF,maxsep=INDEF, > "dev$null")
  match ("center","database/ap"//gradhneg, stop-, > tmphneg)

      
## read horizontal limits
  list1 = tmphpos
  sdum="" 
  nsc = fscan(list1,sdum,x1)
  x1  = x1 + igrow
  list1 = tmphneg
  sdum="" 
  nsc = fscan(list1,sdum,x2)
  x2 = x2 - igrow
  
  
## save results
out1 = output
if (access(out1)) {
  print ("Output file exists, not saving ")
  goto clean
}
#  check if output file exists
for (ireg=1; ireg<=4; ireg= ireg +1) {
  if (verb1)  print (x1,x2,y1[ireg],y2[ireg])
  print (int(x1+0.5),int(x2+0.5),int(y1[ireg]+0.5),int(y2[ireg]+0.5),>>out1)  
}

clean: 
## clean out      
  imdel (gradpos, veri-, > "dev$null")
  imdel (gradneg, veri-, > "dev$null")
  
  delete ("database/ap"//gradpos, veri-, > "dev$null")
  delete ("database/ap"//gradneg, veri-, > "dev$null")

  imdel (gradhpos, veri-, > "dev$null")
  imdel (gradhneg, veri-, > "dev$null")
  
  delete ("database/ap"//gradhpos, veri-, > "dev$null")
  delete ("database/ap"//gradhneg, veri-, > "dev$null")

  delete (tmphneg, veri-, > "dev$null")
  delete (tmphpos, veri-, > "dev$null")
  delete (tmppos, veri-, > "dev$null")
  delete (tmpneg, veri-, > "dev$null")

end
