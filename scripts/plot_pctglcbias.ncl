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

  subdir = "2020-arcticgrids/data/pctglc/"

  fname = (/"cam6_2_022.se_FHIST_f09_f09_mg17_1800pes_200507_mg3-Nx5yrs", \
            "cam6_2_022.se_FHIST_ne30pg3_ne30pg3_mg17_1800pes_200507_mg3-Nx5yrs", \
	    "cam6_2_022.se_FHIST_f19_f19_mg17_900pes_200506_mg3-Nx5yrs", \
	    "cam6_2_022.se_FHIST_ne30pg2_ne30pg2_mg17_1800pes_200507_mg3-Nx5yrs", \
	    "cam6_2_022.se_FHIST_ne0np4.ARCTIC.ne30x4_mt12_7680pes_200507_mg3-Nx2yrs", \
            "cam6_2_022.se_FHIST_ne0np4.ARCTICGRIS.ne30x8_mt12_7680pes_200510_mg3-Nx1yrs"/)
  nfiles = dimsizes(fname)
  label = (/"  f19", \
	    "  f09", \
            "  ne30pg2", \
	    "  ne30pg3", \
	    "  ARCTIC", \
	    "  ARCTICGRIS"/)

  VAR1 = "bar_diff0"
  VAR2 = "bar_diff1"

  vdiff = ".GRIS.dsnowmelt"

  modi = (/".method1.regrid_TO_f19.cnsrv.",\
           ".method1.regrid_TO_f19.te.", \
           ".method1.regrid_TO_ne30pg2.cnsrv.",\
           ".method1.regrid_TO_ne30pg2.te.", \
           ".method2.regrid_TO_f19.cnsrv.",\
           ".method2.regrid_TO_f19.te.", \
           ".method2.regrid_TO_ne30pg2.cnsrv.",\
           ".method2.regrid_TO_ne30pg2.te."/)
  nregrid = dimsizes(modi)

  colors0 = (/"blue","deepskyblue1","green4","green","darkorchid4","magenta"/)
  colors = (/"deepskyblue1","green","blue","green4","darkorchid4","magenta"/)

;******************************************************
; stuff
;******************************************************

  pltNam = "temp_bias"

  xaxis = "Grid cell ice fraction"
  xmin = 0.;;+0.03333334
  xmax = 1.;;-0.03333334

  ymin =     8.E-3
  ymax =     1.E2
  yaxis = "MELT BIAS (fraction)"

  ymin =   -14.;;1.E-2
  ymax =    40.;;1.E2
  yaxis = "MELT BIAS (fraction)"

  ymin = -2300.
  ymax =   100.
  yaxis = "Mean melt bias (mm/yr)"

  ;;mm/s -> kg/(m2*yr) = mm/s [1m/1000mm] * rhoh2o * secpday*365 

;******************************************************
; create plot
;******************************************************
  wkstype = "pdf"
  wks = gsn_open_wks(wkstype,pltNam)               ; open workstation
  plot = new( (/1/), "graphic")

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

  resf@vpWidthF            = 0.5           ; change aspect ratio of plot
  resf@vpHeightF           = 0.5
  ;resf@vpXF                = 0.4
  ;resf@vpYF                = 0.4

  resf@tmXMajorGrid= False
  resf@tmXMajorGridThicknessF      = 3.
  resf@tmXMajorGridLineDashPattern = 2

  resf@tmYMajorGrid= False
  resf@tmYMajorGridThicknessF      = 3.
  resf@tmYMajorGridLineDashPattern = 2

  resf@gsnYRefLine = 0.

  polyres               = True          
  polyres@gsMarkerThicknessF = 5.
  ;;polyres@tfPolyDrawOrder = "PostDraw"

  ;;; transparent polygons
  gsres                = True
  gsres@gsFillOpacityF = 0.15
  gsres@tfPolyDrawOrder = "PreDraw"

;******************************************************
; begin loop
;******************************************************

 do n = 0,nfiles-1

     fname_in = fname(n) + vdiff + modi(0) + "h0.nc"
     print("load: " + fname_in)
     ncdf = addfile(subdir+fname_in,"r")
     ice_diffa0 = ncdf->$VAR1$
     ice_diffa1 = ncdf->$VAR2$
     regionmask = ncdf->regionmask
     pctglca = ncdf->pctglc
     lmask = ncdf->lmask
     area = ncdf->area
     delete(ncdf)

     ice_diffa0 = ice_diffa0*regionmask
     ice_diffa1 = ice_diffa1*regionmask
     pctglca = pctglca*regionmask*tofloat(lmask)
     delete([/regionmask,lmask,area/])

     fname_in = fname(n) + vdiff + modi(1) + "h0.nc"
     print("load: " + fname_in)
     ncdf = addfile(subdir+fname_in,"r")
     ice_diffb0 = ncdf->$VAR1$
     ice_diffb1 = ncdf->$VAR2$
     regionmask = ncdf->regionmask
     pctglcb = ncdf->pctglc
     lmask = ncdf->lmask
     area = ncdf->area
     delete(ncdf)

     ice_diffb0 = ice_diffb0*regionmask
     ice_diffb1 = ice_diffb1*regionmask
     pctglcb = pctglcb*regionmask*tofloat(lmask)
     delete([/regionmask,lmask,area/])

     fname_in = fname(n) + vdiff + modi(2) + "h0.nc"
     print("load: " + fname_in)
     ncdf = addfile(subdir+fname_in,"r")
     ice_diffc0 = ncdf->$VAR1$
     ice_diffc1 = ncdf->$VAR2$
     regionmask = ncdf->regionmask
     pctglcc = ncdf->pctglc
     lmask = ncdf->lmask
     area = ncdf->area
     delete(ncdf)

     ice_diffc0 = ice_diffc0*regionmask
     ice_diffc1 = ice_diffc1*regionmask
     pctglcc = pctglcc*regionmask*tofloat(lmask)
     delete([/regionmask,lmask,area/])

     fname_in = fname(n) + vdiff + modi(3) + "h0.nc"
     print("load: " + fname_in)
     ncdf = addfile(subdir+fname_in,"r")
     ice_diffd0 = ncdf->$VAR1$
     ice_diffd1 = ncdf->$VAR2$
     regionmask = ncdf->regionmask
     pctglcd = ncdf->pctglc
     lmask = ncdf->lmask
     area = ncdf->area
     delete(ncdf)

     ice_diffd0 = ice_diffd0*regionmask
     ice_diffd1 = ice_diffd1*regionmask
     pctglcd = pctglcd*regionmask*tofloat(lmask)
     delete([/regionmask,lmask,area/])

     fname_in = fname(n) + vdiff + modi(4) + "h0.nc"
     print("load: " + fname_in)
     ncdf = addfile(subdir+fname_in,"r")
     ice_diffe0 = ncdf->$VAR1$
     ice_diffe1 = ncdf->$VAR2$
     regionmask = ncdf->regionmask
     pctglce = ncdf->pctglc
     lmask = ncdf->lmask
     area = ncdf->area
     delete(ncdf)

     ice_diffe0 = ice_diffe0*regionmask
     ice_diffe1 = ice_diffe1*regionmask
     pctglce = pctglce*regionmask*tofloat(lmask)
     delete([/regionmask,lmask,area/])

     fname_in = fname(n) + vdiff + modi(5) + "h0.nc"
     print("load: " + fname_in)
     ncdf = addfile(subdir+fname_in,"r")
     ice_difff0 = ncdf->$VAR1$
     ice_difff1 = ncdf->$VAR2$
     regionmask = ncdf->regionmask
     pctglcf = ncdf->pctglc
     lmask = ncdf->lmask
     area = ncdf->area
     delete(ncdf)

     ice_difff0 = ice_difff0*regionmask
     ice_difff1 = ice_difff1*regionmask
     pctglcf = pctglcf*regionmask*tofloat(lmask)
     delete([/regionmask,lmask,area/])

     fname_in = fname(n) + vdiff + modi(6) + "h0.nc"
     print("load: " + fname_in)
     ncdf = addfile(subdir+fname_in,"r")
     ice_diffg0 = ncdf->$VAR1$
     ice_diffg1 = ncdf->$VAR2$
     regionmask = ncdf->regionmask
     pctglcg = ncdf->pctglc
     lmask = ncdf->lmask
     area = ncdf->area
     delete(ncdf)

     ice_diffg0 = ice_diffg0*regionmask
     ice_diffg1 = ice_diffg1*regionmask
     pctglcg = pctglcg*regionmask*tofloat(lmask)
     delete([/regionmask,lmask,area/])

     fname_in = fname(n) + vdiff + modi(7) + "h0.nc"
     print("load: " + fname_in)
     ncdf = addfile(subdir+fname_in,"r")
     ice_diffh0 = ncdf->$VAR1$
     ice_diffh1 = ncdf->$VAR2$
     regionmask = ncdf->regionmask
     pctglch = ncdf->pctglc
     lmask = ncdf->lmask
     area = ncdf->area
     delete(ncdf)
     
     ice_diffh0 = ice_diffh0*regionmask
     ice_diffh1 = ice_diffh1*regionmask
     pctglch = pctglch*regionmask*tofloat(lmask)
     delete([/regionmask,lmask,area/])

     ;*******************************
     ;merge all into one big array
     ;*******************************

     ;turn into 1d arrays

     icea0_1d = ndtooned(ice_diffa0)
     icea1_1d = ndtooned(ice_diffa1)
     pcta0_1d = ndtooned(pctglca)
     pcta1_1d = ndtooned(pctglca)
     delete([/ice_diffa0,ice_diffa1,pctglca/])

     iceb0_1d = ndtooned(ice_diffb0)
     iceb1_1d = ndtooned(ice_diffb1)
     pctb0_1d = ndtooned(pctglcb)
     pctb1_1d = ndtooned(pctglcb)
     delete([/ice_diffb0,ice_diffb1,pctglcb/])

     icec0_1d = ice_diffc0
     icec1_1d = ice_diffc1
     pctc0_1d = pctglcc
     pctc1_1d = pctglcc
     delete([/ice_diffc0,ice_diffc1,pctglcc/])

     iced0_1d = ice_diffd0
     iced1_1d = ice_diffd1
     pctd0_1d = pctglcd
     pctd1_1d = pctglcd
     delete([/ice_diffd0,ice_diffd1,pctglcd/])

     icee0_1d = ndtooned(ice_diffe0)
     icee1_1d = ndtooned(ice_diffe1)
     pcte0_1d = ndtooned(pctglce)
     pcte1_1d = ndtooned(pctglce)
     delete([/ice_diffe0,ice_diffe1,pctglce/])

     icef0_1d = ndtooned(ice_difff0)
     icef1_1d = ndtooned(ice_difff1)
     pctf0_1d = ndtooned(pctglcf)
     pctf1_1d = ndtooned(pctglcf)
     delete([/ice_difff0,ice_difff1,pctglcf/])

     iceg0_1d = ice_diffg0
     iceg1_1d = ice_diffg1
     pctg0_1d = pctglcg
     pctg1_1d = pctglcg
     delete([/ice_diffg0,ice_diffg1,pctglcg/])

     iceh0_1d = ice_diffh0
     iceh1_1d = ice_diffh1
     pcth0_1d = pctglch
     pcth1_1d = pctglch
     delete([/ice_diffh0,ice_diffh1,pctglch/])

     ;mergge both racmos for each member

     n0 = dimsizes(icea0_1d)
     n1 = dimsizes(icea1_1d)
     icea_1d = new( (/n0+n1/), "float")
     pcta_1d = new( (/n0+n1/), "float")
     icea_1d(0:n0-1) = icea0_1d
     icea_1d(n0:n0+n1-1) = icea1_1d
     pcta_1d(0:n0-1) = pcta0_1d
     pcta_1d(n0:n0+n1-1) = pcta1_1d
     delete([/icea0_1d,icea1_1d,pcta0_1d,pcta1_1d/])

     n0 = dimsizes(iceb0_1d)
     n1 = dimsizes(iceb1_1d)
     iceb_1d = new( (/n0+n1/), "float")
     pctb_1d = new( (/n0+n1/), "float")
     iceb_1d(0:n0-1) = iceb0_1d
     iceb_1d(n0:n0+n1-1) = iceb1_1d
     pctb_1d(0:n0-1) = pctb0_1d
     pctb_1d(n0:n0+n1-1) = pctb1_1d
     delete([/iceb0_1d,iceb1_1d,pctb0_1d,pctb1_1d/])

     n0 = dimsizes(icec0_1d)
     n1 = dimsizes(icec1_1d)
     icec_1d = new( (/n0+n1/), "float")
     pctc_1d = new( (/n0+n1/), "float")
     icec_1d(0:n0-1) = icec0_1d
     icec_1d(n0:n0+n1-1) = icec1_1d
     pctc_1d(0:n0-1) = pctc0_1d
     pctc_1d(n0:n0+n1-1) = pctc1_1d
     delete([/icec0_1d,icec1_1d,pctc0_1d,pctc1_1d/])

     n0 = dimsizes(iced0_1d)
     n1 = dimsizes(iced1_1d)
     iced_1d = new( (/n0+n1/), "float")
     pctd_1d = new( (/n0+n1/), "float")
     iced_1d(0:n0-1) = iced0_1d
     iced_1d(n0:n0+n1-1) = iced1_1d
     pctd_1d(0:n0-1) = pctd0_1d
     pctd_1d(n0:n0+n1-1) = pctd1_1d
     delete([/iced0_1d,iced1_1d,pctd0_1d,pctd1_1d/])

     n0 = dimsizes(icee0_1d)
     n1 = dimsizes(icee1_1d)
     icee_1d = new( (/n0+n1/), "float")
     pcte_1d = new( (/n0+n1/), "float")
     icee_1d(0:n0-1) = icee0_1d
     icee_1d(n0:n0+n1-1) = icee1_1d
     pcte_1d(0:n0-1) = pcte0_1d
     pcte_1d(n0:n0+n1-1) = pcte1_1d
     delete([/icee0_1d,icee1_1d,pcte0_1d,pcte1_1d/])

     n0 = dimsizes(icef0_1d)
     n1 = dimsizes(icef1_1d)
     icef_1d = new( (/n0+n1/), "float")
     pctf_1d = new( (/n0+n1/), "float")
     icef_1d(0:n0-1) = icef0_1d
     icef_1d(n0:n0+n1-1) = icef1_1d
     pctf_1d(0:n0-1) = pctf0_1d
     pctf_1d(n0:n0+n1-1) = pctf1_1d
     delete([/icef0_1d,icef1_1d,pctf0_1d,pctf1_1d/])

     n0 = dimsizes(iceg0_1d)
     n1 = dimsizes(iceg1_1d)
     iceg_1d = new( (/n0+n1/), "float")
     pctg_1d = new( (/n0+n1/), "float")
     iceg_1d(0:n0-1) = iceg0_1d
     iceg_1d(n0:n0+n1-1) = iceg1_1d
     pctg_1d(0:n0-1) = pctg0_1d
     pctg_1d(n0:n0+n1-1) = pctg1_1d
     delete([/iceg0_1d,iceg1_1d,pctg0_1d,pctg1_1d/])

     n0 = dimsizes(iceh0_1d)
     n1 = dimsizes(iceh1_1d)
     iceh_1d = new( (/n0+n1/), "float")
     pcth_1d = new( (/n0+n1/), "float")
     iceh_1d(0:n0-1) = iceh0_1d
     iceh_1d(n0:n0+n1-1) = iceh1_1d
     pcth_1d(0:n0-1) = pcth0_1d
     pcth_1d(n0:n0+n1-1) = pcth1_1d
     delete([/iceh0_1d,iceh1_1d,pcth0_1d,pcth1_1d/])

     ;merge all four members into single arrays
     n0 = dimsizes(icea_1d)
     n1 = dimsizes(iceb_1d)
     n2 = dimsizes(icec_1d)
     n3 = dimsizes(iced_1d)
     n4 = dimsizes(icee_1d)
     n5 = dimsizes(icef_1d)
     n6 = dimsizes(iceg_1d)
     n7 = dimsizes(iceh_1d)
     ice_all = new( (/n0+n1+n2+n3+n4+n5+n6+n7/), "float")
     pct_all = new( (/n0+n1+n2+n3+n4+n5+n6+n7/), "float")
 
     ice_all(0:n0-1) = icea_1d
     ice_all(n0:n0+n1-1) = iceb_1d
     ice_all(n0+n1:n0+n1+n2-1) = icec_1d 
     ice_all(n0+n1+n2:n0+n1+n2+n3-1) = iced_1d
     ice_all(n0+n1+n2+n3:n0+n1+n2+n3+n4-1) = icee_1d
     ice_all(n0+n1+n2+n3+n4:n0+n1+n2+n3+n4+n5-1) = icef_1d
     ice_all(n0+n1+n2+n3+n4+n5:n0+n1+n2+n3+n4+n5+n6-1) = iceg_1d
     ice_all(n0+n1+n2+n3+n4+n5+n6:n0+n1+n2+n3+n4+n5+n6+n7-1) = iceh_1d

     pct_all(0:n0-1) = pcta_1d
     pct_all(n0:n0+n1-1) = pctb_1d
     pct_all(n0+n1:n0+n1+n2-1) = pctc_1d
     pct_all(n0+n1+n2:n0+n1+n2+n3-1) = pctd_1d
     pct_all(n0+n1+n2+n3:n0+n1+n2+n3+n4-1) = pcte_1d
     pct_all(n0+n1+n2+n3+n4:n0+n1+n2+n3+n4+n5-1) = pctf_1d
     pct_all(n0+n1+n2+n3+n4+n5:n0+n1+n2+n3+n4+n5+n6-1) = pctg_1d
     pct_all(n0+n1+n2+n3+n4+n5+n6:n0+n1+n2+n3+n4+n5+n6+n7-1) = pcth_1d

     ;remove missing values
     indm = ind(.not.ismissing(ice_all))
     ice_tmp = ice_all(indm) 
     pct_tmp = pct_all(indm)
     delete([/indm,ice_all,pct_all/])

     ;remove missing values
     ;+++ARH don't know why there are missing's in pct_tmp not in ice_tmp
     indm = ind(.not.ismissing(pct_tmp))
     ice_gris = ice_tmp(indm) 
     pct_gris = pct_tmp(indm)
     delete([/indm,ice_tmp,pct_tmp/])

     nbins = 10;;15
     bin_bounds = fspan(0.,1.,nbins+1)
     bin_centers= bin_bounds(0:nbins-1)+(bin_bounds(1)-bin_bounds(0))/2.

     bin_median = new( (/nbins/), "float")
     bin_mean = new( (/nbins/), "float") 
     bin_stddev = new( (/nbins/), "float")

     do i = 0,nbins-1
       indx = ind(pct_gris.gt.bin_bounds(i) .and. pct_gris.le.bin_bounds(i+1)) 
       bin_mean(i) = dim_avg(ice_gris(indx))
       bin_median(i) = dim_median(ice_gris(indx))
       bin_stddev(i) = stddev(ice_gris(indx))
       delete(indx)
     end do
     delete([/ice_gris,pct_gris/])

     ;resf@xyYStyle ="Log"
     indgd = ind(bin_mean.gt.0.)

     resf@gsnXYBarChart            = True
     resf@gsnXYBarChartOutlineOnly = True
     ;resf@gsnXYBarChartFillOpacityF = 0.3 

     bin_mean = -1.*bin_mean
     resf@trYReverse               = True

     bin_meanext = new( (/nbins+1/), "float")
     bin_meanext(0:nbins-1) = bin_mean(0:nbins-1)
     ;;bin_meanext(0:nbins-1) = bin_median(0:nbins-1)
     bin_meanext(nbins) = bin_mean(nbins-1)

     resf@xyLineThicknessF   = 8.
     resf@xyLineColors       = colors(n)
     if (n.eq.0) then
       resf@tiXAxisString = xaxis
       resf@trXMinF                = xmin
       resf@trXMaxF                = xmax

       resf@tiYAxisString = yaxis
       resf@trYMinF                = ymin
       resf@trYMaxF                = ymax

       ;;plot = gsn_csm_xy(wks,bin_centers(indgd),bin_mean(indgd),resf)
       plot = gsn_csm_xy(wks,bin_bounds,bin_meanext,resf)
       ;;plot = gsn_csm_xy(wks,bin_centers,bin_mean,resf)
     else
       ;;tmp = gsn_csm_xy(wks,bin_centers(indgd),bin_mean(indgd),resf)
       tmp = gsn_csm_xy(wks,bin_bounds,bin_meanext,resf)
       ;;tmp = gsn_csm_xy(wks,bin_centers,bin_mean,resf)
       overlay(plot,tmp)
       delete(tmp)
     end if
     delete(bin_meanext)
     nbins = dimsizes(indgd)
     ;;delete(indgd)

     bin_pos = bin_mean + bin_stddev
     bin_neg = bin_mean - bin_stddev

     np = 5
     xp = new((/np/),double)
     yp = new((/np/),double)

     gsres@gsFillColor    = colors(n)
     do i=0, nbins-1 
       xp(0:1) = bin_bounds(i)
       xp(2:3) = bin_bounds(i+1)
       xp(4)   = bin_bounds(i) 

       yp(0)   = bin_neg(i)
       yp(1:2) = bin_pos(i)
       yp(3:4) = bin_neg(i)

       polystr = unique_string("hum")
       plot@$polystr$ = gsn_add_polygon(wks,plot(0),xp,yp,gsres)
     end do

     delete([/bin_centers,bin_bounds,bin_mean,bin_median,bin_stddev,bin_pos,bin_neg,xp,yp/])
     delete(indgd)

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

 yy = (/0.90,0.87,0.84,0.81,0.78,0.75/)+0.04
 xx = 0.72
 dx = 0.05
 do n = 0,nfiles-1
   resln@gsLineColor = colors0(n)
   gsn_polyline_ndc(wks,(/xx,xx+dx/),(/yy(n),yy(n)/),resln)
   gsn_text_ndc(wks,label(n),xx+dx,yy(n),txres)
 end do

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
  gsn_panel(wks,plot,(/1,1/),resP)               ; now draw as one plot

frame(wks)

end

