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
  Re = 6371.22d3
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
  label = (/"  f19", \
	    "  f09", \
            "  ne30pg2", \
	    "  ne30pg3", \
	    "  ARCTIC", \
	    "  ARCTICGRIS"/)

  VAR1 = "QICE"
  VAR2 = "QRUNOFF_ICE"
  sfactor = 1.e-12*1000.*60.*60.*24.*365./1000.

  obsvar1  = "smb"
  obsvar2  = "runoff"
  obsfactor = 1000./1000. * 1.e-12 ;;mmwe/yr -> Gt/m*yr

  obsname1 = obsvar1+".YYYY.BN_1958_2013.YY.nc"
  obsname2 = obsvar2+".YYYY.BN_1958_2013.YY.nc"

  colors = (/"blue","deepskyblue1","green4","green","darkorchid4","magenta"/)

;******************************************************
; stuff
;******************************************************

  pltNam = "temp_tseries_GRIS"

  xmin = 1979
  xmax = 1998

  ymin1 =  600.
  ymax1 =  1950.
  yaxis1 = "ACCUM (Gt/yr)"

  ymin2 = -1600.
  ymax2 =  -250.
  yaxis2 = "RUNOFF (Gt/yr)"

  ;;mm/s -> kg/(m2*yr) = mm/s [1m/1000mm] * rhoh2o * secpday*365 

;******************************************************
; create plot
;******************************************************
  wkstype = "pdf"
  wks = gsn_open_wks(wkstype,pltNam)               ; open workstation
  plot = new( (/2/), "graphic")

  resf                        = True

  resf@gsnMaximize      = False
  resf@gsnDraw          = False        ; don't draw plot
  resf@gsnFrame         = False        ; don't advance frame

  resf@tmXUseBottom = True

  resf@tmXMajorGridThicknessF = 3.
  resf@tmYMajorGridThicknessF = 3.
  resf@tmXMinorGridThicknessF = 1.
  resf@tmYMinorGridThicknessF = 1.

  resf@tmXBMajorThicknessF = 3.
  resf@tmYRMajorThicknessF = 3.
  resf@tmXTMajorThicknessF = 3.
  resf@tmYLMajorThicknessF = 3.

  resf@tmBorderThicknessF = 4.
  resf@tmXBMajorOutwardLengthF = 0.
  resf@tmYLMajorOutwardLengthF = 0.
  resf@tmXBMinorOutwardLengthF = 0.
  resf@tmYLMinorOutwardLengthF = 0.
  resf@tmXTMajorOutwardLengthF = 0.
  resf@tmYRMajorOutwardLengthF = 0.
  resf@tmXTMinorOutwardLengthF = 0.
  resf@tmYRMinorOutwardLengthF = 0.

  resf@tiXAxisFontHeightF = 0.02
  resf@tiYAxisFontHeightF = 0.02
  resf@tmXBLabelFontHeightF = 0.015
  resf@tmYLLabelFontHeightF = 0.015

  resf@vpWidthF            = 0.7           ; change aspect ratio of plot
  resf@vpHeightF           = 0.3
  ;resf@vpXF                = 0.4
  ;resf@vpYF                = 0.4

  resf@tmXMajorGrid= False
  resf@tmXMajorGridThicknessF      = 3.
  resf@tmXMajorGridLineDashPattern = 2

  resf@tmYMajorGrid= False
  resf@tmYMajorGridThicknessF      = 3.
  resf@tmYMajorGridLineDashPattern = 2

;******************************************************
; begin loop
;******************************************************

 do n = 0,nfiles-1

   fname_in = fname(n) + ".GRIS." + VAR1 + ".regrid.h0.nc"
   ncdf = addfile("../data/tseries/"+fname_in,"r")

   xann1 = ncdf->xann
   ann1 = ncdf->ann
   delete(ncdf)

   fname_in = fname(n) + ".GRIS." + VAR2 + ".regrid.h0.nc"
   ncdf = addfile("../data/tseries/"+fname_in,"r")

   xann2 = ncdf->xann
   ann2 = ncdf->ann
   delete(ncdf)

   ann1 = ann1 + ann2
   ann2 = -1.*ann2

   if (n.eq.0) then
     fname_in = obsname1 + ".GRIS." + obsvar1 + "regrid.nc"
     ncdf = addfile("../data/tseries/"+fname_in,"r")

     otime1 = ncdf->otime
     oann1 = ncdf->oann
     delete(ncdf)

     fname_in = obsname2 + ".GRIS." + obsvar2 + "regrid.nc"
     ncdf = addfile("../data/tseries/"+fname_in,"r")

     otime2 = ncdf->otime
     oann2 = ncdf->oann
     delete(ncdf)

     oann1 = oann1 + oann2
     oann2 = -1.*oann2
   end if

   print("max1: " + max(ann1))
   print("min1: " + min(ann1))
   print("max2: " + max(ann2))
   print("min2: " + min(ann2))

   resf@xyLineThicknessF   = 5.
   resf@xyLineColors       = colors(n)
   if (n.eq.0) then 

     resf@trXMinF                = xmin
     resf@trXMaxF                = xmax

     resf@tiYAxisString = yaxis1
     resf@trYMinF                = ymin1
     resf@trYMaxF                = ymax1

     plot(0) = gsn_csm_xy(wks,xann1,ann1,resf) 

     resf@xyLineColors = "black"
     resf@xyDashPattern = 1
     tmp = gsn_csm_xy(wks,otime1,oann1,resf)
     overlay(plot(0),tmp)
     delete(tmp)
     resf@xyDashPattern = 0

     resf@xyLineColors       = colors(n)
     resf@tiXAxisString = "Year"

     resf@tiYAxisString = yaxis2
     resf@trYMinF                = ymin2
     resf@trYMaxF                = ymax2

     plot(1) = gsn_csm_xy(wks,xann2,ann2,resf)
     delete(resf@tiXAxisString)

     resf@xyLineColors = "black"
     resf@xyDashPattern = 1
     tmp = gsn_csm_xy(wks,otime2,oann2,resf)
     overlay(plot(1),tmp)
     delete(tmp)
     resf@xyDashPattern = 0

   else
     tmp = gsn_csm_xy(wks,xann1,ann1,resf)
     overlay(plot(0),tmp)
     delete(tmp)

     tmp = gsn_csm_xy(wks,xann2,ann2,resf)
     overlay(plot(1),tmp)
     delete(tmp)
   end if

   delete([/xann1,ann1,xann2,ann2/])
 end do;;n

;*****************************************************
; Add legend
;*****************************************************
 txres = True
 txres@txFontHeightF = 0.02
 txres@txJust = "CenterLeft"

 resln             = True
 resln@gsLineThicknessF = 5.;;resf@xyLineThicknessF 

 res = True
 res@gsMarkerSizeF = 30
 res@gsMarkerThicknessF = 6

 yy = (/0.95,0.92,0.95,0.92,0.95,0.92,0.95,0.92/) + 0.02
 xx = (/0.23,0.23,0.43,0.43,0.63,0.63,0.83,0.83/) - 0.07
 dx = 0.05
 do n = 0,nfiles-1
   resln@gsLineColor = colors(n)
   gsn_polyline_ndc(wks,(/xx(n),xx(n)+dx/),(/yy(n),yy(n)/),resln)
   gsn_text_ndc(wks,label(n),xx(n)+dx,yy(n),txres)
 end do

 resln@gsLineDashPattern = 1
 resln@gsLineColor = "black"
 gsn_polyline_ndc(wks,(/xx(n),xx(n)+dx/),(/yy(n),yy(n)/),resln)
 gsn_text_ndc(wks,"  RACMO2.3",xx(n)+dx,yy(n),txres)

;;drawNDCGrid(wks)
;*****************************************************
; Plot panel
;*****************************************************

  resP                  = True                   ; modify the panel plot
  resP@gsnFrame         = False                  ; don't advance panel plot
  ;resP@gsnPaperOrientation = "portrait"
  resP@gsnPanelBottom   = 0.05
  resP@gsnPanelFigureStringsFontHeightF = 0.02
  resP@gsnPanelFigureStringsPerimOn     = True
  resP@gsnPanelFigureStringsBackgroundFillColor = "white"
  resP@amJust           = "BottomLeft"
  ;resP@txString = pltTitle
  gsn_panel(wks,plot,(/2,1/),resP)               ; now draw as one plot

frame(wks)

end

