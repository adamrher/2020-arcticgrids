;**************************************
;var_cam.ncl
;**************************************
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/esmf/ESMF_regridding.ncl"
load "/gpfs/fs1/work/aherring/CESM2/arh-git-scripts/ncl/se_func_lib.ncl"
;**************************************
begin
;****************************************
  p0 = 1000.d2
  secpday = 60.*60.*24;
  pi = 3.14159265358979
  g = 9.80616
  Re = 6371.22d0
  cp = 1004.
  Rd = 287.
;****************************************

  fname = (/"cam6_2_022.se_FHIST_f19_f19_mg17_900pes_200506_mg3-Nx5yrs", \
            "cam6_2_022.se_FHIST_f09_f09_mg17_1800pes_200507_mg3-Nx5yrs", \
            "cam6_2_022.se_FHIST_ne30pg2_ne30pg2_mg17_1800pes_200507_mg3-Nx5yrs", \
            "cam6_2_022.se_FHIST_ne30pg3_ne30pg3_mg17_1800pes_200507_mg3-Nx5yrs", \
            "cam6_2_022.se_FHIST_ne0np4.ARCTIC.ne30x4_mt12_7680pes_200507_mg3-Nx2yrs", \
            "cam6_2_022.se_FHIST_ne0np4.ARCTICGRIS.ne30x8_mt12_7680pes_200510_mg3-Nx1yrs"/)
  nfiles = dimsizes(fname)

  labels= (/"  f19", \
	    "  f09", \
            "  ne30pg2", \
	    "  ne30pg3", \
	    "  ARCTIC", \
	    "  ARCTICGRIS"/)

  colors = (/"blue","deepskyblue1","green4","green2","darkorchid4","magenta"/)

  obsNams = (/"IceBridge (n=18968)","In-situ, accumulation zone (n=442)","In-situ, ablattion zone (n=177)"/)

  optpdf = True
  nbins1  = 50;;200
  nbins2  = 50;;44
  nbins3  = 20;;18

  dx = 0.4d0
  dx1 = 0.25d0
  xvals = (/1.,2.,3.,4.,5.,6./)
  yvalsib  = new((/nfiles,3/),"double")
  yvalspos = new((/nfiles,3/),"double")
  yvalsneg = new((/nfiles,3/),"double")

  pltNam = "temp_violens"

;******************************************************
; create plot
;******************************************************
  wkstype = "pdf"
  wks = gsn_open_wks(wkstype,pltNam)               ; open workstation
  plot = new( (/3/), "graphic")

  resf			= True
  resf@gsnMaximize      = False
  resf@gsnDraw		= False
  resf@gsnFrame		= False

  resf@tmXUseBottom = True

  resf@tmXMajorGridThicknessF = 3.
  resf@tmYMajorGridThicknessF = 3.
  resf@tmXMinorGridThicknessF = 1.
  resf@tmYMinorGridThicknessF = 1.

  resf@tmXBMajorThicknessF = 3.
  resf@tmYRMajorThicknessF = 3.
  resf@tmXTMajorThicknessF = 3.
  resf@tmYLMajorThicknessF = 3.

  resf@tmBorderThicknessF = 2.
  ;;resf@tmXBMajorOutwardLengthF = 0.
  resf@tmYLMajorOutwardLengthF = 0.
  ;;resf@tmXBMinorOutwardLengthF = 0.
  resf@tmYLMinorOutwardLengthF = 0.
  ;;resf@tmXTMajorOutwardLengthF = 0.
  resf@tmYRMajorOutwardLengthF = 0.
  ;;resf@tmXTMinorOutwardLengthF = 0.
  resf@tmYRMinorOutwardLengthF = 0.
  resf@tmXTOn = False

  resf@tiXAxisFontHeightF = 0.02
  resf@tiYAxisFontHeightF = 0.02
  resf@tmXBLabelFontHeightF = 0.02
  resf@tmYLLabelFontHeightF = 0.02

  ;;resf@tmXBMinorPerMajor = 8
  ;;resf@tmYLMinorPerMajor = 8

  resf@tmXMajorGrid= False
  resf@tmXMajorGridThicknessF      = 3.
  resf@tmXMajorGridLineDashPattern = 2

  resf@tmYMajorGrid= False
  resf@tmYMajorGridThicknessF      = 3.
  resf@tmYMajorGridLineDashPattern = 2

  resf@tmXMinorGrid= False
  resf@tmXMinorGridThicknessF      = 1.
  resf@tmXMinorGridLineDashPattern = 2

  resf@tmYMinorGrid= False
  resf@tmYMinorGridThicknessF      = 1.
  resf@tmYMinorGridLineDashPattern = 2

  resln = True                      
  resln@gsLineColor      = "black"
  resln@gsLineThicknessF = 1.

  respg = True
  respg@gsFillOpacityF = 0.5

;******************************************************
; create plots
;******************************************************

   resf@tmXBMode        = "Explicit"
   resf@tmXBValues      = xvals
   resf@tmXBLabels = labels
   resf@tmXBLabelAngleF = 45.

   resf@tiYAxisString = "SMB model - SMB obs (mm w.e./yr)"
   resf@trYMinF     =-10000.
   resf@trYMaxF     = 10000.
   resf@trXMinF     = 0.
   resf@trXMaxF     = 7.

   resf@tiMainString = obsNams(0)
   resf@trYMinF     = -600.
   resf@trYMaxF     =  600.
   plot(0) = gsn_csm_blank_plot(wks,resf)

   lstr = unique_string("dum")
   plot@$lstr$ = gsn_add_polyline(wks,plot(0),(/resf@trYMinF,resf@trYMaxF/),(/0.,0./),resln)

   resf@tiMainString = obsNams(1)
   resf@trYMinF     =-1100.
   resf@trYMaxF     = 1100.
   plot(1) = gsn_csm_blank_plot(wks,resf)

   lstr = unique_string("dum")
   plot@$lstr$ = gsn_add_polyline(wks,plot(1),(/resf@trYMinF,resf@trYMaxF/),(/0.,0./),resln)

   resf@tiMainString = obsNams(2)
   resf@trYMinF     =-1500.
   resf@trYMaxF     = 6500.
   plot(2) = gsn_csm_blank_plot(wks,resf)

   lstr = unique_string("dum")
   plot@$lstr$ = gsn_add_polyline(wks,plot(2),(/resf@trYMinF,resf@trYMaxF/),(/0.,0./),resln)

;******************************************************
; begin loop
;******************************************************

 do n = 0,nfiles-1

    fname_in = fname(n) + ".GRIS.pointdiff.nc"
    ncdf = addfile("../data/pointdiff/"+fname_in,"r")

    ibdiff = ncdf->ibdiff
    posdiff= ncdf->posdiff
    negdiff= ncdf->negdiff
    delete(ncdf)
 
    print("Computing pdf")

    binspc = (max(ibdiff)-min(ibdiff))/nbins1
    optpdf@bin_min = min(ibdiff) - binspc
    optpdf@bin_max = max(ibdiff) + binspc
    pdfib = pdfx(ibdiff,nbins1,optpdf) 

    binspc = (max(posdiff)-min(posdiff))/nbins2
    optpdf@bin_min = min(posdiff) - binspc
    optpdf@bin_max = max(posdiff) + binspc
    pdfpos = pdfx(posdiff,nbins2,optpdf)

    binspc = (max(negdiff)-min(negdiff))/nbins3
    optpdf@bin_min = min(negdiff) - binspc
    optpdf@bin_max = max(negdiff) + binspc
    pdfneg = pdfx(negdiff,nbins3,optpdf)

    pdfib = pdfib/max(pdfib)
    pdfpos = pdfpos/max(pdfpos)
    pdfneg = pdfneg/max(pdfneg)

    xib = new( (/2*nbins1/), "double")
    yib = new( (/2*nbins1/), "double")
    xpos = new( (/2*nbins2/), "double")
    ypos = new( (/2*nbins2/), "double")
    xneg = new( (/2*nbins3/), "double")
    yneg = new( (/2*nbins3/), "double")

    xib(0:nbins1-1) = xvals(n) - dx*pdfib
    xib(nbins1:2*nbins1-1) = xvals(n) + dx*pdfib(nbins1-1:0)
    xib(0) = xib(2*nbins1-1)
    yib(0:nbins1-1) = pdfib@bin_center
    yib(nbins1:2*nbins1-1) = pdfib@bin_center(nbins1-1:0)
    yib(0) = yib(2*nbins1-1)
    

    xpos(0:nbins2-1) = xvals(n) - dx*pdfpos
    xpos(nbins2:2*nbins2-1) = xvals(n) + dx*pdfpos(nbins2-1:0)
    xpos(0) = xpos(2*nbins2-1)
    ypos(0:nbins2-1) = pdfpos@bin_center
    ypos(nbins2:2*nbins2-1) = pdfpos@bin_center(nbins2-1:0)
    ypos(0) = ypos(2*nbins2-1)

    xneg(0:nbins3-1) = xvals(n) - dx*pdfneg
    xneg(nbins3:2*nbins3-1) = xvals(n) + dx*pdfneg(nbins3-1:0)
    xneg(0) = xneg(2*nbins3-1)
    yneg(0:nbins3-1) = pdfneg@bin_center
    yneg(nbins3:2*nbins3-1) = pdfneg@bin_center(nbins3-1:0)
    yneg(0) = yneg(2*nbins3-1)

    delete([/pdfib,pdfpos,pdfneg/])

    print("Computing stats")
    opt = False
    opt@PrintStat=False
    statdpos = stat_dispersion(posdiff,opt)

    minvalpos = statdpos(2)
    maxvalpos = statdpos(14)
    medpos    = statdpos(8)
    delete(statdpos)

    yvalspos(n,0) = minvalpos
    yvalspos(n,1) = medpos
    yvalspos(n,2) = maxvalpos

    statdneg = stat_dispersion(negdiff,opt)
    
    minvalneg = statdneg(2)
    maxvalneg = statdneg(14)
    medneg    = statdneg(8)
    delete(statdneg)

    yvalsneg(n,0) = minvalneg
    yvalsneg(n,1) = medneg
    yvalsneg(n,2) = maxvalneg

    statdib = stat_dispersion(ibdiff,opt)
    
    minvalib = statdib(2)
    maxvalib = statdib(14)
    medib    = statdib(8)
    delete(statdib)

    yvalsib(n,0) = minvalib
    yvalsib(n,1) = medib
    yvalsib(n,2) = maxvalib

    print("plotting")

    respg@gsFillColor = colors(n)

    pgstr = unique_string("dum")
    plot@$pgstr$ = gsn_add_polygon(wks,plot(0),xib,yib,respg)

    pgstr = unique_string("dum")
    plot@$pgstr$ = gsn_add_polygon(wks,plot(1),xpos,ypos,respg)

    pgstr = unique_string("dum")
    plot@$pgstr$ = gsn_add_polygon(wks,plot(2),xneg,yneg,respg)

    resln@gsLineColor      = colors(n)
    resln@gsLineThicknessF = 2.0

    lstr = unique_string("dum")
    plot@$lstr$ = gsn_add_polyline(wks,plot(0),(/xvals(n),xvals(n)/),(/yvalsib(n,0),yvalsib(n,2)/),resln)
    lstr = unique_string("dum")
    plot@$lstr$ = gsn_add_polyline(wks,plot(0),(/xvals(n)-dx1,xvals(n)+dx1/),(/yvalsib(n,0),yvalsib(n,0)/),resln)
    lstr = unique_string("dum")
    plot@$lstr$ = gsn_add_polyline(wks,plot(0),(/xvals(n)-dx1,xvals(n)+dx1/),(/yvalsib(n,1),yvalsib(n,1)/),resln)
    lstr = unique_string("dum")
    plot@$lstr$ = gsn_add_polyline(wks,plot(0),(/xvals(n)-dx1,xvals(n)+dx1/),(/yvalsib(n,2),yvalsib(n,2)/),resln)

    lstr = unique_string("dum")
    plot@$lstr$ = gsn_add_polyline(wks,plot(1),(/xvals(n),xvals(n)/),(/yvalspos(n,0),yvalspos(n,2)/),resln)
    lstr = unique_string("dum")
    plot@$lstr$ = gsn_add_polyline(wks,plot(1),(/xvals(n)-dx1,xvals(n)+dx1/),(/yvalspos(n,0),yvalspos(n,0)/),resln)
    lstr = unique_string("dum")
    plot@$lstr$ = gsn_add_polyline(wks,plot(1),(/xvals(n)-dx1,xvals(n)+dx1/),(/yvalspos(n,1),yvalspos(n,1)/),resln)
    lstr = unique_string("dum")
    plot@$lstr$ = gsn_add_polyline(wks,plot(1),(/xvals(n)-dx1,xvals(n)+dx1/),(/yvalspos(n,2),yvalspos(n,2)/),resln)


    lstr = unique_string("dum")
    plot@$lstr$ = gsn_add_polyline(wks,plot(2),(/xvals(n),xvals(n)/),(/yvalsneg(n,0),yvalsneg(n,2)/),resln)
    lstr = unique_string("dum")
    plot@$lstr$ = gsn_add_polyline(wks,plot(2),(/xvals(n)-dx1,xvals(n)+dx1/),(/yvalsneg(n,0),yvalsneg(n,0)/),resln)
    lstr = unique_string("dum")
    plot@$lstr$ = gsn_add_polyline(wks,plot(2),(/xvals(n)-dx1,xvals(n)+dx1/),(/yvalsneg(n,1),yvalsneg(n,1)/),resln)
    lstr = unique_string("dum")
    plot@$lstr$ = gsn_add_polyline(wks,plot(2),(/xvals(n)-dx1,xvals(n)+dx1/),(/yvalsneg(n,2),yvalsneg(n,2)/),resln)

 end do

 print("maxib: " + max(yvalsib))
 print("minib: " + min(yvalsib))
 print("maxpos: " + max(yvalspos))
 print("minpos: " + min(yvalspos))
 print("maxneg: " + max(yvalsneg))
 print("minneg: " + min(yvalsneg))

;;;drawNDCGrid(wks)
;*****************************************************
; Plot panel
;*****************************************************

  resP                  = True                   ; modify the panel plot
  resP@gsnFrame         = False                  ; don't advance panel plot
  ;resP@gsnPaperOrientation = "portrait"
  resP@gsnPanelBottom   = 0.05

  resP@gsnPanelFigureStrings = (/"CLM","CLM","CLM"/)
  resP@gsnPanelFigureStringsFontHeightF = 0.01
  resP@gsnPanelFigureStringsPerimOn     = True
  resP@gsnPanelFigureStringsBackgroundFillColor = "white"
  resP@amJust           = "TopRight"
  ;resP@txString = pltTitle
  gsn_panel(wks,plot,(/1,3/),resP)               ; now draw as one plot

frame(wks)

end

