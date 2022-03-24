;**************************************
;**************************************
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"   
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl" 
load "$NCARG_ROOT/lib/ncarg/nclscripts/esmf/ESMF_regridding.ncl"
load "/glade/work/aherring/CESM2/arh-git-scripts/ncl/se_func_lib.ncl"
;**************************************
begin
;****************************************
;****************************************

  fname = (/"ne30pg3.ge.45N","ne30pg3-NCPL192.ge.45N","ARCTIC.ge.45N","ERA5.ge.45N"/)
  nfiles = dimsizes(fname)

  months = (/"JAN","FEB","MAR","APR","MAY","JUNE","JULY","AUG","SEPT","OCT","NOV","DEC"/)
  nmnths = dimsizes(months)

  VAR = (/"PRECT","PRECT","PRECT","prect"/)

  nbins = 500
  xmin = 0.;;
  xmax = 500.;;
  ymin = 1.e-8 ;;;y-axis range
  ymax = 1.

  varnams = "pdfvar"

  xaxis = "PRECT (mm/day)"

  pltNam = "temp_pdf"

  label = (/"  ne30pg3", \
	    "  ne30pg3*", \
	    "  ARCTIC", \
	    "  ERA5"/)

  colors = (/"blue","deepskyblue1","red","black"/)
  ;;colors = (/"green4","plum","darkorchid4","black"/)
;******************************************************
; plot options
;******************************************************
;---Start the graphics
  wks = gsn_open_wks("pdf",pltNam)

  plot = new( (/nmnths/), "graphic")

  res                      = True         ; plot modifications desired
  res@gsnDraw              = False        ; don't draw plot
  res@gsnFrame             = False        ; don't advance frame
  ;res@gsnMaximize = True
  ;res@gsnPaperOrientation = "portrait"
  ;res@vpWidthF = 0.7
  ;res@vpHeightF = 0.35
  res@xyYStyle ="Log"

  ;;res@trXReverse            = True
  res@tmBorderThicknessF = 2 ;axes thickness
  res@tmXBMajorOutwardLengthF = 0.
  res@tmYLMajorOutwardLengthF = 0.
  res@tmXBMinorOutwardLengthF = 0.
  res@tmYLMinorOutwardLengthF = 0.
  res@tmXTMajorOutwardLengthF = 0.
  res@tmYRMajorOutwardLengthF = 0.
  res@tmXTMinorOutwardLengthF = 0.
  res@tmYRMinorOutwardLengthF = 0.

  res@pmLegendDisplayMode    = "NoCreate"                      ; turn on legend
  res@pmLegendSide           = "Bottom"                      ; Change location of
  res@pmLegendParallelPosF   = .7                           ; move units right
  res@pmLegendOrthogonalPosF = -1.15                          ; move units down
  res@pmLegendWidthF         = 0.14                          ; Change width and
  res@pmLegendHeightF        = 0.11                           ; height of legend.
  res@lgPerimOn              = False                         ; turn off box around
  res@lgLabelFontHeightF     = .02                          ; label font height

  res@gsnXYBarChart            = True              ; Create bar plot
  res@gsnXYBarChartOutlineOnly = True
  res@xyMonoLineThickness = True
  res@xyLineThicknessF   = 3

  res@trYMinF                = ymin
  res@trYMaxF                = ymax
  res@trXMinF                = xmin
  res@trXMaxF                = xmax

  ;;add legend
  txres = True
  txres@txFontHeightF = 0.020
  txres@txJust = "CenterLeft"

  plres  = True                  ; polyline mods desired
  plres@gsLineDashPattern  = 0                    ; solid line
  plres@gsLineThicknessF  = 5.                   ; line thicker

  yy = 0.89
  xx = (/ 0.20, 0.40, 0.60, 0.80 /)

do n = 0,nfiles-1

print("Begin case "+n)

   do m = 0,nmnths-1  

     files = "composite." + fname(n) + "." + VAR(n) + "." + months(m) + ".bilin.pdfx.nc"
     print("Loading pdfvars from " + files)

     ncdf = addfile("../data/composites/"+files, "r")
     pdfvar = ncdf->$varnams$
     delete(ncdf)

     print("Plotting...")
     res@xyLineColors       = colors(n)
     pvals = ind(pdfvar.gt.0.d0)
     xvals = pdfvar@bin_bounds(0:nbins-1)
     if (n.eq.0) then
       res@tiYAxisString          = "Probability (fraction)"
       res@tiXAxisString          = xaxis
       plot(m)  = gsn_csm_xy(wks,xvals(pvals),pdfvar(pvals)*1.e-2,res)
       delete(res@tiYAxisString)
     else 
       tmp = gsn_csm_xy(wks,xvals(pvals),pdfvar(pvals)*1.e-2,res)
       overlay(plot(m),tmp)
       delete(tmp)
     end if
     delete([/pvals,xvals,pdfvar/])

   end do

print("done with case " + n)

   plres@gsLineColor       = colors(n)
   gsn_polyline_ndc(wks,(/xx(n)-0.05,xx(n)/),(/yy,yy/),plres)
   gsn_text_ndc(wks,label(n),xx(n),yy,txres)

end do ;nfiles

;;drawNDCGrid(wks)

;*****************************************************
; Panel Plot
;*****************************************************

  resP                  = True                   ; modify the panel plot
  resP@gsnFrame         = False                  ; don't advance panel plot
  resP@gsnPaperOrientation = "portrait"

  resP@gsnPanelFigureStrings = months
  resP@gsnPanelFigureStringsFontHeightF = 0.007
  resP@gsnPanelFigureStringsPerimOn     = True
  resP@gsnPanelFigureStringsBackgroundFillColor = "white"
  resP@amJust           = "TopRight"

  resP@gsnPanelYWhiteSpacePercent = 5.
  gsn_panel(wks,plot,(/3,4/),resP)               ; now draw as one plot
  frame(wks)

end

