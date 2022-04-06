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
  Re = 6371.22
  cp = 1004.
  Rd = 287.
;****************************************

  VAR = "dThyps"
  ;;VAR = "SWCF"

  if (VAR.eq."dThyps") then
    fname = (/"ERA5-2-cam6_2_022.se_FHIST_f19_f19_mg17_900pes_200506_mg3-Nx5yrs.dcontours.dThyps.JJA.nc", \
  	      "ERA5-2-cam6_2_022.se_FHIST_f09_f09_mg17_1800pes_200507_mg3-Nx5yrs.dcontours.dThyps.JJA.nc", \
	      "ERA5-2-cam6_2_022.se_FHIST_ne30pg2_ne30pg2_mg17_1800pes_200507_mg3-Nx5yrs.dcontours.dThyps.JJA.nc", \
	      "ERA5-2-cam6_2_022.se_FHIST_ne30pg3_ne30pg3_mg17_1800pes_200507_mg3-Nx5yrs.dcontours.dThyps.JJA.nc", \
	      "ERA5-2-cam6_2_022.se_FHIST_ne0np4.ARCTIC.ne30x4_mt12_7680pes_200507_mg3-Nx2yrs.dcontours.dThyps.JJA.nc", \
	      "ERA5-2-cam6_2_022.se_FHIST_ne0np4.ARCTICGRIS.ne30x8_mt12_7680pes_200510_mg3-Nx1yrs.dcontours.dThyps.JJA.nc"/)
  else
    fname = (/"CERES-2-cam6_2_022.se_FHIST_f19_f19_mg17_900pes_200506_mg3-Nx5yrs.dcontours.dSWCF.JJA.nc", \
	      "CERES-2-cam6_2_022.se_FHIST_f09_f09_mg17_1800pes_200507_mg3-Nx5yrs.dcontours.dSWCF.JJA.nc", \
	      "CERES-2-cam6_2_022.se_FHIST_ne30pg2_ne30pg2_mg17_1800pes_200507_mg3-Nx5yrs.dcontours.dSWCF.JJA.nc", \
	      "CERES-2-cam6_2_022.se_FHIST_ne30pg3_ne30pg3_mg17_1800pes_200507_mg3-Nx5yrs.dcontours.dSWCF.JJA.nc", \
	      "CERES-2-cam6_2_022.se_FHIST_ne0np4.ARCTIC.ne30x4_mt12_7680pes_200507_mg3-Nx2yrs.dcontours.dSWCF.JJA.nc", \
	      "CERES-2-cam6_2_022.se_FHIST_ne0np4.ARCTICGRIS.ne30x8_mt12_7680pes_200510_mg3-Nx1yrs.dcontours.dSWCF.JJA.nc"/)
  end if

  runnams = (/"f19", \
	      "f09", \
	      "ne30pg2", \
	      "ne30pg3", \
	      "ARCTIC", \
	      "ARCTICGRIS"/)

  nfiles = dimsizes(fname)

  lbtitle = "Temperature Difference (K)"
  lbtitle = "Shortwave cloud forcing bias (W/m2)"

  ;;set contour levels
  if (VAR.eq."dThyps") then
    cellfill = False
    maxcn  = 5.
    mincn  =-5.
    cnlevs = 20.
  else
    cellfill = True
    maxcn  = 50.
    mincn  =-50.
    cnlevs = 10.
  end if
  cnspc  = (maxcn-mincn)/cnlevs

  pltNam = "temp_contours"

  griddir = "../data/gridfiles/"

  scrip = (/"fv1.9x2.5_141008.nc", \
            "fv0.9x1.25_scrip_141008.nc", \
            "ne30pg2_scrip_170608.nc", \
            "ne30pg3_scrip_170611.nc", \
            "ne0ARCTICne30x4_scrip_191212.nc", \
            "ne0ARCTICGRISne30x8_scrip_191209.nc"/)

;******************************************************
; create plot
;******************************************************
  wkstype = "pdf"
  wks = gsn_open_wks(wkstype,pltNam)               ; open workstation
  gsn_define_colormap(wks,"BkBlAqGrYeOrReViWh200")
  plot = new( (/nfiles/), "graphic")

   res             = True
   res@gsnMaximize = False
   res@gsnDraw     = False      ; Will draw later, after overlaying
   res@gsnFrame    = False      ; all plots

   if (VAR.eq."dThyps") then
     res@cnFillOn          = False               ; turn on color fill
     res@cnLinesOn         = True
     res@cnLineLabelsOn    = True
   else
     res@cnFillOn          = True               ; turn on color fill
     res@cnLinesOn         = False
     res@cnLineLabelsOn    = False
   end if

   res@gsnSpreadColors   = True               ; use full range of color map
   res@lbLabelBarOn         = False
   res@tiMainFontHeightF = 0.006
   res@cnInfoLabelOn     = False

   res@vpWidthF  = 0.3
   res@vpHeightF = 0.8

   res@mpGridAndLimbOn   = False           ; turn on lat/lon lines
   res@mpGridLatSpacingF = 10.
   res@mpGridLonSpacingF = 30.
   ;res@mpGridLineColor      = -1
   res@mpPerimOn         = True               ; turn off perimeter
   res@mpFillOn         = True
   ;;res@mpOutlineBoundarySets     = "NoBoundaries"

   res@gsnPolar             = "NH"                 ; specify the hemisphere
   res@mpFillOn         = True
   res@mpCenterLonF         = -10;;-45.
   res@mpMinLatF         = 50.;;40.
   res@mpGridAndLimbOn   = False
   ;res@mpGridLatSpacingF    = 20.                ; change latitude  line spacing
   ;res@mpGridLonSpacingF    = 20.                ; change longitude line spacing
   ;res@gsnPolarLabelSpacing = 60                   ; how frequently to label
   res@gsnTickMarksOn = False

;******************************************************
; begin loop
;******************************************************

 do n = 0,nfiles-1

   print("load file: " + fname(n))
   f  = addfile ("../data/polar/"+fname(n),"r")
   var = f->bar_diff

   dims = dimsizes(dimsizes(var))
   if (dims.eq.2) then
     latlon = True

     lat = var@lat
     lon = var@lon

     var!0 = "lat"
     var&lat = lat
     var&lat@units = "degrees_north"
     var!1 = "lon"
     var&lon = lon
     var&lon@units = "degrees_east"
     delete([/lat,lon/])
   else
     latlon = False

     lat1d = f->lat1d
     lon1d = f->lon1d
     res@sfXArray = lon1d
     res@sfYArray = lat1d
     delete([/lat1d,lon1d/])
   end if
   delete(f)

   print("max: " + max(var))
   print("min: " + min(var))

   res@cnLevelSelectionMode = "ManualLevels"
   res@cnMinLevelValF  = mincn
   res@cnMaxLevelValF  = maxcn
   res@cnLevelSpacingF = cnspc

   if (cellfill) then
     res@cnFillMode = "CellFill"
     ;vf = addfile(griddir+scrip(n),"r")
     ;res@sfXCellBounds = vf->grid_corner_lon
     ;res@sfYCellBounds = vf->grid_corner_lat
     ;delete(vf)
   else
     res@cnFillMode = "AreaFill"
   end if 

   res@gsnCenterStringFontHeightF = 0.01

   plot(n) = gsn_csm_contour_map_polar(wks,var,res)
   if (VAR.eq."dThyps") then
     plot(n) = ColorNegDashZeroPosContour(plot(n),"blue","black","red")
   end if
   delete(var)

   if (.not.latlon) then
     delete([/res@sfXArray,res@sfYArray/])
   end if

   if (cellfill) then
     delete([/res@sfXCellBounds,res@sfYCellBounds/])
   end if

 end do;;n


;;;drawNDCGrid(wks)
;*****************************************************
; Plot panel
;*****************************************************

  resP                  = True                   ; modify the panel plot
  resP@gsnFrame         = False                  ; don't advance panel plot
  ;resP@gsnPaperOrientation = "portrait"

  resP@gsnPanelFigureStrings = runnams
  resP@gsnPanelFigureStringsFontHeightF = 0.01
  resP@gsnPanelFigureStringsPerimOn     = True
  resP@gsnPanelFigureStringsBackgroundFillColor = "white"
  resP@amJust           = "TopRight"

  resP@gsnPanelLabelBar = False
  resP@gsnPanelLabelBar = True
  resP@lbBoxSeparatorLinesOn= False
  resP@gsnPanelBottom   = 0.1
  resP@lbTitleString              = lbtitle
  resP@lbTitlePosition            = "Bottom"
  resP@lbTitleFontHeightF         = 0.015
  resP@lbLabelFontHeightF         = 0.01
  resP@pmLabelBarOrthogonalPosF   = -0.02

  ;resP@txString = pltTitle
  gsn_panel(wks,plot,(/3,2/),resP)               ; now draw as one plot

frame(wks)

end

