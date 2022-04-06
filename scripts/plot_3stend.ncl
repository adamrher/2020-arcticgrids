;**************************************
;zonal_hgt_isen.ncl
;**************************************
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/esmf/ESMF_regridding.ncl"
load "/glade/work/aherring/CESM2/arh-git-scripts/ncl/se_func_lib.ncl"
;;load "se_func_lib.ncl"
;**************************************
  cp = 1004.64 ;J/kg/K
  Rd = 287.0423 ;J/kg/K
  g = 9.80616 ;m/s2
  re = 6.37122e6 ;m
  pi = 3.14159265358979
  p0 = 1.e5
  ps0= 1.015e5
  secpday = 60.*60.*24.

begin

  lolat = -90.d0
  hilat =  90.d0

  VAR = "T"
  factor = 1.

  VAR1 = "STEND_CLUBB"
  factor1 = secpday/cp
  xlabel1 = "STEND_CLUBB"

  fname_in = (/"cam6_2_022.se_FHIST_f09_f09_mg17_1800pes_200507_mg3-Nx5yrs-2-cam6_2_022.se_FHIST_f19_f19_mg17_900pes_200506_mg3-Nx5yrs.dzonal-hgt.dSTEND_CLUBB.ANN.nc", \
	       "cam6_2_022.se_FHIST_ne30pg3_ne30pg3_mg17_1800pes_200507_mg3-Nx5yrs-2-cam6_2_022.se_FHIST_f09_f09_mg17_1800pes_200507_mg3-Nx5yrs.dzonal-hgt.dSTEND_CLUBB.ANN.nc", \
	       "cam6_2_022.se_FHIST_ne30pg3_ne30pg3_mg17_1800pes_200507_mg3-Nx5yrs-2-cam6_2_022.se_FHIST_ne30pg2_ne30pg2_mg17_1800pes_200507_mg3-Nx5yrs.dzonal-hgt.dSTEND_CLUBB.ANN.nc"/)

  fname_in = (/"cam6_2_022.se_FHIST_ne30pg3_ne30pg3_mg17_3600pes_200603_192NCPL-mg3-Nx4yrs-2-cam6_2_022.se_FHIST_ne30pg3_ne30pg3_mg17_1800pes_200507_mg3-Nx5yrs.dzonal-hgt.dSTEND_CLUBB.JJA.nc", \
              "cam6_2_022.se_FHIST_ne0np4.ARCTIC.ne30x4_mt12_7680pes_200507_mg3-Nx2yrs-2-cam6_2_022.se_FHIST_ne30pg3_ne30pg3_mg17_3600pes_200603_192NCPL-mg3-Nx4yrs.dzonal-hgt.dSTEND_CLUBB.JJA.nc", \
               "cam6_2_022.se_FHIST_ne0np4.ARCTICGRIS.ne30x8_mt12_7680pes_200510_mg3-Nx1yrs-2-cam6_2_022.se_FHIST_ne0np4.ARCTIC.ne30x4_mt12_7680pes_200507_mg3-Nx2yrs.dzonal-hgt.dSTEND_CLUBB.JJA.nc"/)

  nfiles = dimsizes(fname_in)
  ZBAR  = "zbarup_diff"
  ZQBAR  = "zqbarup_diff"

 titles = (/"(a) f09 - f19", \
	    "(b) ne30pg3 - f09", \
	    "(c) ne30pg3 - ne30pg2"/)

 titles = (/"(a) ne30pg3* - ne30pg3", \
            "(b) ARCTIC - ne30pg3*", \
            "(c) ARCTICGRIS - ARCTIC"/)

 lbarnams = (/"Temperature (K)", \
	      "CLUBB Temperature Tendency (K/day)"/)

 if (VAR.eq."RELHUM") then
	 vmin = (/0.,0.,-20./)
	 vmax = (/100.,100.,20./)
	 vspace = (/5.,5.,1.5/)
	 var = "Q"
 else if (VAR.eq."U") then
	 vmin = (/-10.,-10.,-5./)
	 vmax = (/60.,60.,5./)
	 vspace = (/2.5,2.5,0.5/)
 else if (VAR.eq."OMEGA") then
         vmin = (/-90.,-90.,-30./)
         vmax = (/30.,30.,30./)
         vspace = (/5.,5.,2./)
 else if (VAR.eq."VU") then
         vmin = (/-70.,-70.,-40./)
         vmax = (/ 70., 70., 40./)
         vspace =(/10., 10.,  4./)
 else if (VAR.eq."T") then
         vmin = -1.
         vmax =  1.
         vspace = 0.1
 end if
 end if
 end if
 end if
 end if

 if (VAR1.eq."STEND_CLUBB")
   vminb = -0.35
   vmaxb =  0.35
   vspaceb = (vmaxb-vminb)/20
 end if

 ilevfile = "ilevp.1015hPa.nc"

 pltnam = "temp_dhgt_panel."+VAR1

;*************************************************************
; Start graphics
;*************************************************************
  wks = gsn_open_wks("pdf",pltnam)
  gsn_define_colormap(wks,"MPL_jet")

  if (VAR.ne."T") then
    gsn_reverse_colormap(wks)
  end if

  plot = new(2*nfiles,graphic)                          ; create a plot array

;*************************************************************
; Graphics Options
;*************************************************************
   res1             = True
   res1@gsnMaximize = True
   res1@gsnPaperOrientation = "portrait"

   res1@gsnDraw     = False      ; Will draw later, after overlaying
   res1@gsnFrame    = False      ; all plots

   res1@vpWidthF    = 0.95        ; Make plots wider
   res1@vpHeightF   = 0.5
   res1@vpXF        = 0.025
   res1@vpYF        = 0.85

   res1@cnFillOn          = True               ; turn on color fill
   res1@cnLinesOn         = False
   res1@cnLineLabelsOn    = False
   res1@cnInfoLabelOn     = False

   res1@cnMonoLineThickness = True
   res1@cnLineThicknessF  = 2.
   res1@cnLevelSelectionMode = "ManualLevels"     ; manually set the contour levels with the following 3 resources
   res1@gsnSpreadColors  = True               ; use full range of color map
   res1@lbLabelStride     = 2                  ; every other color

   res1@tmBorderThicknessF = 4 ;axes thickness
   res1@tmXBMajorOutwardLengthF = 0.
   res1@tmYLMajorOutwardLengthF = 0.
   res1@tmXBMinorOutwardLengthF = 0.
   res1@tmYLMinorOutwardLengthF = 0.
   res1@tmXTMajorOutwardLengthF = 0.
   res1@tmYRMajorOutwardLengthF = 0.
   res1@tmXTMinorOutwardLengthF = 0.
   res1@tmYRMinorOutwardLengthF = 0.
   res1@tmXTOn               = False
   res1@tmYROn               = False

   res1@gsnXAxisIrregular2Linear = True
   res1@gsnYAxisIrregular2Linear = True
   res1@trYReverse            = True
   res1@trYMinF            = 0.
   res1@trYMaxF            = 1015.
   res1@trXMinF     = sin(lolat*pi/180.)
   res1@trXMaxF     = sin(hilat*pi/180.)
   res1@tmXBMode        = "Explicit"

   xticks = new((/19/),float)
   do i = 0,19-1
     tmp = (i-9)*10.
     xticks(i) = sin(tmp*pi/180.)
   end do
   delete(tmp)
   res1@tmXBValues      = xticks
   res1@tmXBLabels      = (/"","-80","","-60","","-40","","-20","","0","","20","","40","","60","","80",""/)

   res0 = True
   res0 = res1
   res0@cnLinesOn        = True
   res0@cnFillOn         = False
   res0@cnLineThicknessF = 2
   res0@cnLineColor = "black"
   res0@cnLevelSelectionMode = "ExplicitLevels"
   res0@cnMaxLevelCount = 2
   res0@gsnContourNegLineDashPattern = 2
   res0@cnLevels = (/-1000.,0./)

   txres = True
   txres@txFontHeightF = 0.016
   yy = (/0.935,0.65,0.365/)

   lnres             = True
   lnres             = True
   lnres@gsLineColor = "black"
   xx0 = 0.07
   xx1 = 0.39
   xx2 = 0.67;;0.6
   xx3 = 0.99

;****************************************
; Begin Loop
;************************************************

do n = 0,nfiles-1

  ncdf = addfile("../data/dzonal/"+fname_in(n),"r")
  lat = ncdf->lat
  ptrop = ncdf->ptrop
  ptrop = ptrop/100.
  ptrop0 = ncdf->ptrop0
  ptrop0 = ptrop0/100.
  zbar_diff = ncdf->$ZBAR$
  zqbar_diff= ncdf->$ZQBAR$
  delete(ncdf)

  zqbar_diff = zqbar_diff*factor1

  print("Computing global means using: " + ilevfile)
  ncdf = addfile("../data/dzonal/"+ilevfile,"r")
  ilev_p = ncdf->ILEV_P
  delete(ncdf)

  ilevs = dimsizes(ilev_p)
  dp = ilev_p(1:ilevs-1) - ilev_p(0:ilevs-2)
  dp2d = conform(zbar_diff,dp,0)

  gmean_zbar_diff = dim_avg(dim_sum_n(dp2d*zbar_diff,0)/dim_sum_n(dp2d,0))
  gmean_zqbar_diff = dim_avg(dim_sum_n(dp2d*zqbar_diff,0)/dim_sum_n(dp2d,0))
  delete([/dp,dp2d/])

  print("gmean_zbar_diff: " + gmean_zbar_diff)
  print("gmean_zqbar_diff: " + gmean_zqbar_diff)

  zbar_diff@long_name = "global mean = " + decimalPlaces(gmean_zbar_diff,3,False) + " K"
  zqbar_diff@units = "global mean = " + decimalPlaces(gmean_zqbar_diff,4,False) + " K/day"

  print("max " + VAR1 + ": " + max(zbar_diff))
  print("min " + VAR1 + ": " + min(zqbar_diff))

  print("Plotting...")

  ;;res1@tiMainString = ""

  res1@lbLabelBarOn        = False
  if (n.eq.nfiles-1) then
    res1@lbLabelBarOn        = True
    res1@lbTitlePosition      = "Top"
    res1@lbTitleFontHeightF   = 0.03
    res1@lbTitleString = "Latitude"
  end if

  res1@cnMinLevelValF  = vmin
  res1@cnMaxLevelValF  = vmax
  res1@cnLevelSpacingF = vspace

  plot(2*n)  = gsn_csm_contour(wks,zbar_diff,res1)
  nlat = dimsizes(lat)
  do i = 0,nlat-1
    indk = ind(zbar_diff&levs.le.ptrop(i))
    zbar_diff(indk,i) = zbar_diff@_FillValue
    delete(indk)
  end do
  tmp = gsn_csm_contour(wks,zbar_diff,res0)
  overlay(plot(2*n),tmp)
  delete([/tmp,zbar_diff/])

  res1@cnMinLevelValF  = vminb
  res1@cnMaxLevelValF  = vmaxb
  res1@cnLevelSpacingF = vspaceb

  plot(2*n+1)  = gsn_csm_contour(wks,zqbar_diff,res1)
  do i = 0,nlat-1
    indk = ind(zqbar_diff&levs.le.ptrop(i))
    zqbar_diff(indk,i) = zqbar_diff@_FillValue 
    delete(indk)
  end do
  tmp = gsn_csm_contour(wks,zqbar_diff,res0)
  overlay(plot(2*n+1),tmp)
  delete([/tmp,zqbar_diff/])

  ;;;add titles
  gsn_text_ndc(wks,titles(n),0.53,yy(n),txres)
  lnres@gsLineThicknessF = 1.
  lnres@gsLineColor = "black"
  gsn_polyline_ndc(wks,(/xx0,xx1/),(/yy(n),yy(n)/)+0.005,lnres)
  gsn_polyline_ndc(wks,(/xx2,xx3/),(/yy(n),yy(n)/)+0.005,lnres)
  ;;drawNDCGrid(wks)

  if (n.eq.nfiles-1) then
    txres@txFontHeightF = 0.013
    gsn_text_ndc(wks,lbarnams(0),0.28,0.02,txres)
    gsn_text_ndc(wks,lbarnams(1),0.78,0.02,txres)
  end if

  ;;; Tropopause Line
  copy_VarCoords(lat,ptrop)
  lnres@gsLineThicknessF = 4.
  lnres@gsLineColor = "magenta"
  lstr = unique_string("dum")
  plot@$lstr$ = gsn_add_polyline(wks,plot(2*n),lat,ptrop,lnres)
  lstr = unique_string("dum")
  plot@$lstr$ = gsn_add_polyline(wks,plot(2*n+1),lat,ptrop,lnres)
  lnres@gsLineColor = "grey43"
  lstr = unique_string("dum")
  plot@$lstr$ = gsn_add_polyline(wks,plot(2*n),lat,ptrop0,lnres)
  lstr = unique_string("dum")
  plot@$lstr$ = gsn_add_polyline(wks,plot(2*n+1),lat,ptrop0,lnres)
  delete([/ptrop,ptrop0,lat/])

end do

;************************************************
; create panel
;************************************************
  resP                  = True                   ; modify the panel plot
  resP@gsnFrame         = False                  ; don't advance panel plot
  resP@gsnMaximize = False;True
  resP@gsnPaperOrientation = "portrait"
  resP@gsnPanelTop      = 0.95
  resP@gsnPanelBottom   = 0.07

  ;;resP@gsnPanelFigureStrings = (/"a.","b.","c.","d.","e.","f."/)
  resP@gsnPanelFigureStringsFontHeightF = 0.009
  resP@gsnPanelFigureStringsPerimOn     = True
  resP@gsnPanelFigureStringsBackgroundFillColor = "white"
  resP@amJust           = "BottomLeft"

  gsn_panel(wks,plot,(/3,2/),resP)               ; now draw as one plot
  frame(wks)

end
