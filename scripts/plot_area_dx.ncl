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

  fname = "../data/area_dx/GrIS_dx_area.nc"

  label = (/"  f19", \
	    "  f09", \
            "  ne30pg2", \
	    "  ne30pg3", \
	    "  ARCTIC", \
	    "  ARCTICGRIS", \
	    "  RACMO23", \
	    "  RACMO23p2"/)

  colors = (/"blue","deepskyblue1","green4","green","darkorchid4","magenta","black","black"/)
  nfiles = dimsizes(colors)

;******************************************************
; stuff
;******************************************************

  pltNam = "temp_grisres"

;******************************************************
; create plot
;******************************************************
  wkstype = "pdf"
  wks = gsn_open_wks(wkstype,pltNam)               ; open workstation
  plot = new( (/2/), "graphic")

  resf			= True
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

  resf@tmBorderThicknessF = 3.
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

  ;;resf@tmXBMinorPerMajor = 8
  ;;resf@tmYLMinorPerMajor = 8

  resf@tmXMajorGrid= True
  resf@tmXMajorGridThicknessF      = 1.
  resf@tmXMajorGridLineDashPattern = 1

  resf@tmYMajorGrid= True
  resf@tmYMajorGridThicknessF      = 1.
  resf@tmYMajorGridLineDashPattern = 1

  resf@tmXMinorGrid= True
  resf@tmXMinorGridThicknessF      = 0.5
  resf@tmXMinorGridLineDashPattern = 2

  resf@tmYMinorGrid= True
  resf@tmYMinorGridThicknessF      = 0.5
  resf@tmYMinorGridLineDashPattern = 2

  res = True
  res@gsMarkerIndex = 16

  txres = True
  txres@txFontHeightF = 0.017
  txres@txJust = "CenterLeft"

  yy = 0.76
  xx = (/0.05,0.11,0.17,0.29,0.41,0.525,0.7,0.84/)
  dx = 0.005
  ;;drawNDCGrid(wks)

;******************************************************
; begin loop
;******************************************************

 resf@tiYAxisString = "Average ~F33~D~F21~x (km)"
 resf@tiXAxisString = "Number of grid points"
 resf@trYMinF                = 0.
 resf@trYMaxF                = 180.
 resf@trXMinF                = 40.
 resf@trXMaxF                = 100000
 resf@trXAxisType = "LogAxis"
 plot(1) = gsn_csm_blank_plot(wks,resf)

 resf@tiYAxisString = "GrIS Area Error (%)"
 resf@tiXAxisString = "Number of grid points"
 resf@trYMinF                = -3.5
 resf@trYMaxF                =  2.
 resf@trXMinF                = 40.
 resf@trXMaxF                = 100000
 resf@trXAxisType = "LogAxis"
 plot(0) = gsn_csm_blank_plot(wks,resf)

 f = addfile(fname,"r")
 garea = f->garea
 gdx = f->gdx
 ncells = f->ncells

 do n = 0,nfiles-1

   res@gsMarkerIndex = 16
   res@gsMarkerSizeF = 18;;25
   res@gsMarkerThicknessF = 5;;6

   res@gsMarkerOpacityF = 0.4
   res@gsMarkerColor = colors(n)
   pNam = unique_string("tmp")
   plot@$pNam$ = gsn_add_polymarker(wks,plot(1),ncells(n),gdx(n),res)
   delete([/res@gsMarkerOpacityF/])

   if (n.eq.nfiles-1) then
     res@gsMarkerIndex = 6
   else
     res@gsMarkerIndex = 4
   end if
   pNam = unique_string("tmp")
   plot@$pNam$ = gsn_add_polymarker(wks,plot(1),ncells(n),gdx(n),res)

   res@gsMarkerIndex = 16
   res@gsMarkerOpacityF = 0.4
   res@gsMarkerSizeF = 15
   res@gsMarkerThicknessF = 4
   gsn_polymarker_ndc(wks,xx(n),yy,res)
   delete([/res@gsMarkerOpacityF/])

   if (n.eq.nfiles-1) then
     res@gsMarkerIndex = 6
   else
     res@gsMarkerIndex = 4
   end if
   gsn_polymarker_ndc(wks,xx(n),yy,res)
   gsn_text_ndc(wks,label(n),xx(n)+dx,yy,txres)

   res@gsMarkerIndex = 16
   res@gsMarkerSizeF = 18;;25
   res@gsMarkerThicknessF = 5;;6
   res@gsMarkerOpacityF = 0.4
   res@gsMarkerColor = colors(n)
   pNam = unique_string("tmp")
   plot@$pNam$ = gsn_add_polymarker(wks,plot(0),ncells(n),garea(n),res)
   delete([/res@gsMarkerOpacityF/])

   if (n.eq.nfiles-1) then
     res@gsMarkerIndex = 6
   else
     res@gsMarkerIndex = 4
   end if
   pNam = unique_string("tmp")
   plot@$pNam$ = gsn_add_polymarker(wks,plot(0),ncells(n),garea(n),res)

end do
 
   print("max ncells: " + max(ncells))
   print("min ncells: " + min(ncells)) 
   print("max gdx: " + max(gdx))
   print("min gdx: " + min(gdx))
   print("max garea: " + max(garea))
   print("min garea: " + min(garea))

;*****************************************************
; Plot panel
;*****************************************************

  resP                  = True                   ; modify the panel plot
  resP@gsnFrame         = False                  ; don't advance panel plot
  resP@gsnPanelBottom   = 0.10
  resP@gsnPanelTop      = 0.90
  resP@gsnPanelFigureStrings = (/"(a)","(b)"/)
  resP@gsnPanelFigureStringsFontHeightF = 0.015
  resP@gsnPanelFigureStringsPerimOn     = True
  resP@gsnPanelFigureStringsBackgroundFillColor = "white"
  resP@amJust           = "TopRight"
  ;resP@txString = pltTitle
  gsn_panel(wks,plot,(/1,2/),resP)               ; now draw as one plot

frame(wks)

end

