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

  fname = (/"RACMO-2-cam6_2_022.se_FHIST_f19_f19_mg17_900pes_200506_mg3-Nx5yrs.contours.dQSNOMELT.ANN.nc", \
	    "RACMO-2-cam6_2_022.se_FHIST_f09_f09_mg17_1800pes_200507_mg3-Nx5yrs.contours.dQSNOMELT.ANN.nc", \
	    "RACMO-2-cam6_2_022.se_FHIST_ne30pg2_ne30pg2_mg17_1800pes_200507_mg3-Nx5yrs.contours.dQSNOMELT.ANN.nc", \
	    "RACMO-2-cam6_2_022.se_FHIST_ne30pg3_ne30pg3_mg17_1800pes_200507_mg3-Nx5yrs.contours.dQSNOMELT.ANN.nc", \
	    "RACMO-2-cam6_2_022.se_FHIST_ne0np4.ARCTIC.ne30x4_mt12_7680pes_200507_mg3-Nx2yrs.contours.dQSNOMELT.ANN.nc", \
	    "RACMO-2-cam6_2_022.se_FHIST_ne0np4.ARCTICGRIS.ne30x8_mt12_7680pes_200510_mg3-Nx1yrs.contours.dQSNOMELT.ANN.nc"/)

  fname = (/"RACMO-2-cam6_2_022.se_FHIST_f19_f19_mg17_900pes_200506_mg3-Nx5yrs.contours.dQSNOMELT.imask.ANN.nc", \
            "RACMO-2-cam6_2_022.se_FHIST_f09_f09_mg17_1800pes_200507_mg3-Nx5yrs.contours.dQSNOMELT.imask.ANN.nc", \
            "RACMO-2-cam6_2_022.se_FHIST_ne30pg2_ne30pg2_mg17_1800pes_200507_mg3-Nx5yrs.contours.dQSNOMELT.imask.ANN.nc", \
            "RACMO-2-cam6_2_022.se_FHIST_ne30pg3_ne30pg3_mg17_1800pes_200507_mg3-Nx5yrs.contours.dQSNOMELT.imask.ANN.nc", \
            "RACMO-2-cam6_2_022.se_FHIST_ne0np4.ARCTIC.ne30x4_mt12_7680pes_200507_mg3-Nx2yrs.contours.dQSNOMELT.imask.ANN.nc", \
            "RACMO-2-cam6_2_022.se_FHIST_ne0np4.ARCTICGRIS.ne30x8_mt12_7680pes_200510_mg3-Nx1yrs.contours.dQSNOMELT.imask.ANN.nc"/)

  runnams = (/"f19", \
              "f09", \
              "ne30pg2", \
              "ne30pg3", \
              "ARCTIC", \
              "ARCTICGRIS"/)

  nfiles = dimsizes(fname)

  VAR = "bar_diff"
  lbtitle = "SNOW+ICE MELT (mm/yr)"

  ;;set contour levels
  maxcn  = 1000.
  mincn  =-1000.
  cnlevs = 20.

  pltNam = "temp_contours"

  cellfill = True

  griddir = (/"/glade/work/aherring/grids/uniform-res/f19/grids/", \
              "/glade/work/aherring/grids/uniform-res/f09/grids/", \
              "/glade/work/aherring/grids/uniform-res/ne30np4.pg2/grids/", \
              "/glade/work/aherring/grids/uniform-res/ne30np4.pg3/grids/", \
              "/glade/work/aherring/grids/var-res/ne0np4.ARCTIC.ne30x4/grids/", \
              "/glade/work/aherring/grids/var-res/ne0np4.ARCTICGRIS.ne30x8/grids/"/)

  scrip = (/"fv1.9x2.5_141008.nc", \
            "fv0.9x1.25_scrip_141008.nc", \
            "ne30pg2_scrip_170608.nc", \
            "ne30pg3_scrip_170611.nc", \
            "ne0ARCTICne30x4_scrip_191212.nc", \
            "ne0ARCTICGRISne30x8_scrip_191209.nc"/)

  basinfl = (/"GrnDrainageSystems.f19.mask.nc", \
	      "GrnDrainageSystems.f09.mask.nc", \
	      "GrnDrainageSystems.ne30pg2.mask.nc", \
              "GrnDrainageSystems.ne30pg3.mask.nc", \
              "GrnDrainageSystems.ARCTIC.mask.nc", \
              "GrnDrainageSystems.ARCTICGRIS.mask.nc"/)

;******************************************************
; create plot
;******************************************************
  wkstype = "pdf"
  wks = gsn_open_wks(wkstype,pltNam)               ; open workstation

  ;;gsn_define_colormap(wks,"BkBlAqGrYeOrReViWh200")
  gsn_define_colormap(wks,"cmp_b2r")
  ;;gsn_reverse_colormap(wks)

  plot = new( (/nfiles/), "graphic")

   res             = True
   res@gsnMaximize = False
   res@gsnDraw     = False      ; Will draw later, after overlaying
   res@gsnFrame    = False      ; all plots

   res@cnFillOn          = True               ; turn on color fill
   res@cnLinesOn         = False
   res@cnLineLabelsOn    = False

   res@gsnSpreadColors   = True               ; use full range of color map
   res@cnInfoLabelOn        = False
   res@lbLabelBarOn         = False
   res@tiMainFontHeightF = 0.006

   res@vpWidthF  = 0.3
   res@vpHeightF = 0.8

   res@mpGridAndLimbOn   = False           ; turn on lat/lon lines
   res@mpGridLatSpacingF = 10.
   res@mpGridLonSpacingF = 30.
   ;res@mpGridLineColor      = -1
   res@mpPerimOn         = True               ; turn off perimeter
   res@mpFillOn         = True
   ;;res@mpOutlineBoundarySets     = "NoBoundaries"

;   res@mpProjection = "Orthographic"
;   res@mpCenterLatF      =   45.
;   res@mpCenterLonF      =  -45.

   res@mpProjection = "LambertConformal";;"Orthographic";;"Mollweide"
   res@mpLambertParallel1F = 85
   res@mpLambertParallel2F = 58
   res@mpLambertMeridianF  = -45
   res@mpLimitMode       = "LatLon"
   res@mpMinLonF = -56.4
   res@mpMaxLonF = -30.
   res@mpMinLatF = 59.4;;58.
   res@mpMaxLatF = 85;;85.

   resc = True
   resc@gsnMaximize = False
   resc@gsnDraw     = False      
   resc@gsnFrame    = False      
   resc@cnFillOn          = False
   resc@cnLinesOn         = True
   resc@cnLineLabelsOn    = False
   resc@cnInfoLabelOn     = False

;******************************************************
; begin loop
;******************************************************

 do n = 0,nfiles-1

   print("load file: " + fname(n))
   f  = addfile ("../data/lambert/"+fname(n),"r")
   var = f->$VAR$

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
   res@cnLevelSpacingF = (maxcn-mincn)/cnlevs

   if (cellfill) then
     res@cnFillMode = "CellFill"
     vf = addfile(griddir(n)+scrip(n),"r")
     res@sfXCellBounds = vf->grid_corner_lon
     res@sfYCellBounds = vf->grid_corner_lat
     delete(vf)
   else
     res@cnFillMode = "AreaFill"
   end if 

   plot(n) = gsn_csm_contour_map(wks,var,res)
   delete(var)

   bf = addfile("../data/basinmask/"+basinfl(n),"r")
   imask = bf->basinmask 
   delete(bf)

   delete([/imask@units,imask@long_name/])
   resc@cnLevelSelectionMode = "ExplicitLevels"
   resc@cnLevels = (/0.5,1000./)
   resc@cnLineThicknessF   = 2
   resc@cnLineColor = "grey43"
   resc@cnFillMode = "CellFill"

   if (.not.latlon) then
     resc@sfXArray = res@sfXArray
     resc@sfYArray = res@sfYArray
   end if
   do b=1,7
     if (b.eq.7 .or. b.eq.3 .or. b.eq.5) then
       continue
     end if

     dum = imask
     dum = where(imask.eq.tofloat(b),1.,0.)
     tmp = gsn_csm_contour(wks,dum,resc)
     overlay(plot(n),tmp)
     delete(tmp)
     delete(dum)
   end do
   delete(imask)

   if (.not.latlon) then
     delete([/res@sfXArray,res@sfYArray/])
     delete([/resc@sfXArray,resc@sfYArray/])
   end if

   if (cellfill) then
     delete([/res@sfXCellBounds,res@sfYCellBounds/])
   end if

 end do;;n

;*****************************************************
; Add legend
;*****************************************************

 txres = True
 txres@txFontHeightF = 0.01
 txres@txJust = "CenterLeft"
 txres@gsnDraw     = False
 txres@gsnFrame    = False

 label = (/"N","NE","CE","SE","SW","CW","NW"/)
 xx = (/0.894,0.92,0.94,0.924,0.892,0.91,0.89/)
 yy = (/0.61,0.58,0.51,0.479,0.475,0.52,0.56/)

;;drawNDCGrid(wks)
;*****************************************************
; Plot panel
;*****************************************************

  resP                  = True                   ; modify the panel plot
  resP@gsnFrame         = False                  ; don't advance panel plot
  ;;resP@gsnPaperOrientation = "landscape"

  resP@gsnPanelFigureStrings = runnams
  resP@gsnPanelFigureStringsFontHeightF = 0.01
  resP@gsnPanelFigureStringsPerimOn     = True
  resP@gsnPanelFigureStringsBackgroundFillColor = "white"
  resP@amJust           = "TopLeft"

  resP@gsnPanelLabelBar = False
  resP@gsnPanelLabelBar = True
  resP@lbBoxSeparatorLinesOn= False
  resP@lbTitleString              = lbtitle
  resP@lbTitlePosition            = "Bottom"
  resP@lbTitleFontHeightF         = 0.015
  resP@lbLabelFontHeightF         = 0.01
  resP@pmLabelBarOrthogonalPosF   = -0.02

  gsn_panel(wks,plot,(/1,6/),resP)               ; now draw as one plot

  do m = 0,6
    gsn_text_ndc(wks,label(m),xx(m),yy(m),txres)
  end do

frame(wks)

end

