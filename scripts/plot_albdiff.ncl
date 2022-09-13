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

  fname1 = (/"RACMO-2-cam6_2_022.se_FHIST_f19_f19_mg17_900pes_200506_mg3-Nx5yrs.contours.dderive-ALBD.JJA.TO_f19.nc", \
            "RACMO-2-cam6_2_022.se_FHIST_f09_f09_mg17_1800pes_200507_mg3-Nx5yrs.contours.dderive-ALBD.JJA.TO_f19.nc", \
            "RACMO-2-cam6_2_022.se_FHIST_ne30pg2_ne30pg2_mg17_1800pes_200507_mg3-Nx5yrs.contours.dderive-ALBD.JJA.TO_f19.nc", \
            "RACMO-2-cam6_2_022.se_FHIST_ne30pg3_ne30pg3_mg17_1800pes_200507_mg3-Nx5yrs.contours.dderive-ALBD.JJA.TO_f19.nc", \
            "RACMO-2-cam6_2_022.se_FHIST_ne0np4.ARCTIC.ne30x4_mt12_7680pes_200507_mg3-Nx2yrs.contours.dderive-ALBD.JJA.TO_f19.nc", \
            "RACMO-2-cam6_2_022.se_FHIST_ne0np4.ARCTICGRIS.ne30x8_mt12_7680pes_200510_mg3-Nx1yrs.contours.dderive-ALBD.JJA.TO_f19.nc"/)

  fname2 = (/"MAR-2-cam6_2_022.se_FHIST_f19_f19_mg17_900pes_200506_mg3-Nx5yrs.contours.dderive-ALBD.JJA.TO_f19.nc", \
            "MAR-2-cam6_2_022.se_FHIST_f09_f09_mg17_1800pes_200507_mg3-Nx5yrs.contours.dderive-ALBD.JJA.TO_f19.nc", \
            "MAR-2-cam6_2_022.se_FHIST_ne30pg2_ne30pg2_mg17_1800pes_200507_mg3-Nx5yrs.contours.dderive-ALBD.JJA.TO_f19.nc", \
            "MAR-2-cam6_2_022.se_FHIST_ne30pg3_ne30pg3_mg17_1800pes_200507_mg3-Nx5yrs.contours.dderive-ALBD.JJA.TO_f19.nc", \
            "MAR-2-cam6_2_022.se_FHIST_ne0np4.ARCTIC.ne30x4_mt12_7680pes_200507_mg3-Nx2yrs.contours.dderive-ALBD.JJA.TO_f19.nc", \
            "MAR-2-cam6_2_022.se_FHIST_ne0np4.ARCTICGRIS.ne30x8_mt12_7680pes_200510_mg3-Nx1yrs.contours.dderive-ALBD.JJA.TO_f19.nc"/)

  fname3 = (/"ERA5-2-cam6_2_022.se_FHIST_f19_f19_mg17_900pes_200506_mg3-Nx5yrs.dcontours.dFSNO_EFF.JJA.TO_f19.nc", \
             "ERA5-2-cam6_2_022.se_FHIST_f09_f09_mg17_1800pes_200507_mg3-Nx5yrs.dcontours.dFSNO_EFF.JJA.TO_f19.nc", \
             "ERA5-2-cam6_2_022.se_FHIST_ne30pg2_ne30pg2_mg17_1800pes_200507_mg3-Nx5yrs.dcontours.dFSNO_EFF.JJA.TO_f19.nc", \
             "ERA5-2-cam6_2_022.se_FHIST_ne30pg3_ne30pg3_mg17_1800pes_200507_mg3-Nx5yrs.dcontours.dFSNO_EFF.JJA.TO_f19.nc", \
             "ERA5-2-cam6_2_022.se_FHIST_ne0np4.ARCTIC.ne30x4_mt12_7680pes_200507_mg3-Nx2yrs.dcontours.dFSNO_EFF.JJA.TO_f19.nc", \
             "ERA5-2-cam6_2_022.se_FHIST_ne0np4.ARCTICGRIS.ne30x8_mt12_7680pes_200510_mg3-Nx1yrs.dcontours.dFSNO_EFF.JJA.TO_f19.nc"/)

  runnams1 = (/"f19", \
              "f09", \
              "ne30pg2", \
              "ne30pg3", \
              "ARCTIC", \
              "ARCTICGRIS"/)
  runnams2 = (/"f19", \
              "f09", \
              "ne30pg2", \
              "ne30pg3", \
              "ARCTIC", \
              "ARCTICGRIS"/)
  runnams3 = (/"f19", \
              "f09", \
              "ne30pg2", \
              "ne30pg3", \
              "ARCTIC", \
              "ARCTICGRIS"/)

  nfiles1 = dimsizes(fname1)
  nfiles2 = dimsizes(fname2)
  nfiles3 = dimsizes(fname3)

  titles = (/"ERA5 (snow cover)","RACMO2.3p2 (albedo)","MODIS (albedo)"/)
  yy = (/0.78,0.5,0.22/)

  VAR = "bar_diff"
  lbtitle1 = "Snow cover (fraction)"
  lbtitle2 = "Albedo (fraction)"
  lbtitle3 = "Albedo (fraction)"

  factor1 = 1.
  factor2 = 1.
  factor3 = 1.

  ;;set contour levels
  maxcn1  = 0.2
  mincn1  =-0.2
  maxcn2  = 0.2
  mincn2  =-0.2
  maxcn3  = 0.4
  mincn3  =-0.4
  cnlevs1 = 20.
  cnlevs2 = 20.
  cnlevs3 = 20.

  pltNam = "temp_contours"

  cellfill = True

  griddir1 = (/"/glade/work/aherring/papers/2020-arcticgrids/data/gridfiles/", \
               "/glade/work/aherring/papers/2020-arcticgrids/data/gridfiles/", \
               "/glade/work/aherring/papers/2020-arcticgrids/data/gridfiles/", \
               "/glade/work/aherring/papers/2020-arcticgrids/data/gridfiles/", \
               "/glade/work/aherring/papers/2020-arcticgrids/data/gridfiles/", \
               "/glade/work/aherring/papers/2020-arcticgrids/data/gridfiles/"/)
  griddir2 = (/"/glade/work/aherring/papers/2020-arcticgrids/data/gridfiles/", \
               "/glade/work/aherring/papers/2020-arcticgrids/data/gridfiles/", \
               "/glade/work/aherring/papers/2020-arcticgrids/data/gridfiles/", \
               "/glade/work/aherring/papers/2020-arcticgrids/data/gridfiles/", \
               "/glade/work/aherring/papers/2020-arcticgrids/data/gridfiles/", \
               "/glade/work/aherring/papers/2020-arcticgrids/data/gridfiles/"/)
  griddir3 = (/"/glade/work/aherring/papers/2020-arcticgrids/data/gridfiles/", \
               "/glade/work/aherring/papers/2020-arcticgrids/data/gridfiles/", \
               "/glade/work/aherring/papers/2020-arcticgrids/data/gridfiles/", \
               "/glade/work/aherring/papers/2020-arcticgrids/data/gridfiles/", \
               "/glade/work/aherring/papers/2020-arcticgrids/data/gridfiles/", \
               "/glade/work/aherring/papers/2020-arcticgrids/data/gridfiles/"/)

  scrip1 = (/"fv1.9x2.5_141008.nc", \
             "fv1.9x2.5_141008.nc", \
             "fv1.9x2.5_141008.nc", \
             "fv1.9x2.5_141008.nc", \
             "fv1.9x2.5_141008.nc", \
             "fv1.9x2.5_141008.nc"/)

  scrip2 = (/"fv1.9x2.5_141008.nc", \
             "fv1.9x2.5_141008.nc", \
             "fv1.9x2.5_141008.nc", \
             "fv1.9x2.5_141008.nc", \
             "fv1.9x2.5_141008.nc", \
             "fv1.9x2.5_141008.nc"/)

  scrip3 = (/"fv1.9x2.5_141008.nc", \
             "fv1.9x2.5_141008.nc", \
             "fv1.9x2.5_141008.nc", \
             "fv1.9x2.5_141008.nc", \
             "fv1.9x2.5_141008.nc", \
             "fv1.9x2.5_141008.nc"/)

;******************************************************
; create plot
;******************************************************
  wkstype = "pdf"
  wks = gsn_open_wks(wkstype,pltNam)               ; open workstation

do m = 0,2

  if (m.eq.0) then
    gsn_define_colormap(wks,"cmp_b2r")
    gsn_reverse_colormap(wks)
    fname = fname1
    nfiles = nfiles1
    griddir = griddir1
    scrip = scrip1
    runnams = runnams1
    lbtitle = lbtitle1
    factor = factor1
    maxcn = maxcn1
    mincn = mincn1
    cnlevs = cnlevs1
  else if (m.eq.1) then
    gsn_define_colormap(wks,"cmp_b2r")
    gsn_reverse_colormap(wks)
    fname = fname2
    nfiles = nfiles2
    griddir = griddir2
    scrip = scrip2
    runnams = runnams2
    lbtitle = lbtitle2
    factor = factor2
    maxcn = maxcn2
    mincn = mincn2
    cnlevs = cnlevs2
  else if (m.eq.2) then
    gsn_define_colormap(wks,"BlWhRe")
    gsn_reverse_colormap(wks)
    fname = fname3
    nfiles = nfiles3
    griddir = griddir3
    scrip = scrip3
    runnams = runnams3
    lbtitle = lbtitle3
    factor = factor3
    maxcn = maxcn3
    mincn = mincn3
    cnlevs = cnlevs3
  end if
  end if
  end if

  plot = new( (/nfiles/), "graphic")

   res             = True
   res@gsnMaximize = False
   res@gsnDraw     = False      ; Will draw later, after overlaying
   res@gsnFrame    = False      ; all plots

   res@cnFillOn          = False               ; turn on color fill
   res@cnLinesOn         = True
   res@cnLineLabelsOn    = True

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

;******************************************************
; begin loop
;******************************************************

 do n = 0,nfiles-1

   print("load file: " + fname(n))
   f  = addfile ("../data/lambert/"+fname(n),"r")
   var = f->$VAR$
   var = var*factor

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

   res@gsnCenterStringFontHeightF = 0.01

   plot(n) = gsn_csm_contour_map(wks,var,res)
   delete(var)

   if (.not.latlon) then
     delete([/res@sfXArray,res@sfYArray/])
   end if

   if (cellfill) then
     delete([/res@sfXCellBounds,res@sfYCellBounds/])
   end if

 end do;;n

 txres = True
 txres@txFontHeightF = 0.016
 txres@txAngleF = 90.
 gsn_text_ndc(wks,titles(m),0.035,yy(m),txres)

;;drawNDCGrid(wks)
;*****************************************************
; Plot panel
;*****************************************************

  resP                  = True                   ; modify the panel plot
  resP@gsnFrame         = False                  ; don't advance panel plot
  ;;resP@gsnPaperOrientation = "landscape"

  resP@gsnPanelFigureStrings = runnams
  resP@gsnPanelFigureStringsFontHeightF = 0.008;;0.01
  resP@gsnPanelFigureStringsPerimOn     = True
  resP@gsnPanelFigureStringsBackgroundFillColor = "white"
  resP@amJust           = "TopLeft"

  resP@gsnPanelLabelBar = False
  resP@gsnPanelLabelBar = True
  resP@lbBoxSeparatorLinesOn= False
  ;;resP@lbTitleString              = lbtitle
  ;;resP@lbTitlePosition            = "Bottom"
  ;;resP@lbLabelPosition            = "Vertical"
  ;;resP@lbLabelAngleF              = 90.
  ;;resP@lbTitleDirection           = "Down"
  resP@lbOrientation              = "Vertical"
  resP@lbTitleFontHeightF         = 0.015
  resP@lbLabelFontHeightF         = 0.01
  resP@pmLabelBarOrthogonalPosF   = 0.00

  ;;resP@pmLabelBarHeightF = 0.02
  resP@pmLabelBarWidthF = 0.05

  resP@gsnPanelLeft = 0.05
  resP@gsnPanelRight = 0.95
  if (m.eq.0) then
    resP@gsnPanelTop = .95
    resP@gsnPanelBottom = .60
  else if (m.eq.1) then
    resP@gsnPanelTop = .65
    resP@gsnPanelBottom = .35
  else if (m.eq.2) then
    resP@gsnPanelTop = .375
    resP@gsnPanelBottom = .075
  end if
  end if
  end if

  gsn_panel(wks,plot,(/1,6/),resP)

  delete([/fname,griddir,scrip,runnams,lbtitle,plot,resP@gsnPanelFigureStrings/])

end do

frame(wks)

end

