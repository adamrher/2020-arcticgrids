load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

begin
;******************************************************
;
;******************************************************


  loadncdf = True
  fname_in = (/"ktransect-elev.nc", \
	       "stransect-elev.nc"/)
  nfiles = dimsizes(fname_in)

  label = (/"  f19", \
            "  f09", \
            "  ne30pg2", \
            "  ne30pg3", \
            "  ARCTIC", \
            "  ARCTICGRIS"/)

  colors = (/"blue","deepskyblue1","green4","green2","darkorchid4","magenta"/)

  MIN1 = (/-170.,-322./)
  MAX1 = (/ 320., 200./)
  nams1 = "Distance from Ice Margin (km)"

  MIN2 = (/   0., -50./)
  MAX2 = (/2550.,3250./)
  nams2 = "Elevation (m)"

  DIST = (/"kdist","sdist"/)

  pltNam = "temp_transect"

  Re = 6371220.d0
  pi = 3.14159265358979d0
  g = 9.80616

;******************************************************
; create plot
;******************************************************
  wkstype = "pdf"
  ;;wkstype = "png"
  wks = gsn_open_wks(wkstype,pltNam)               ; open workstation
  plot = new( (/6/), "graphic")

  resf                        = True

  resf@gsnMaximize      = False
  resf@gsnDraw          = False        ; don't draw plot
  resf@gsnFrame         = False        ; don't advance frame

  resf@tmXUseBottom = True
;  resf@tiMainString = title

  resf@tmXBMajorThicknessF = 2.
  resf@tmYRMajorThicknessF = 2.
  resf@tmXTMajorThicknessF = 2.
  resf@tmYLMajorThicknessF = 2.

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
  resf@tmXBLabelFontHeightF = 0.02
  resf@tmYLLabelFontHeightF = 0.02

  resf@vpWidthF            = 0.5;;0.6           ; change aspect ratio of plot
  resf@vpHeightF           = 0.5;;0.4
  ;resf@vpXF                = 0.4
  ;resf@vpYF                = 0.4

;  resf@tmXBMinorPerMajor = 8
;  resf@tmYLMinorPerMajor = 8

  resf@tmXMajorGrid= False
  resf@tmXMajorGridThicknessF      = 3.
  resf@tmXMajorGridLineDashPattern = 2

  resf@tmYMajorGrid= False
  resf@tmYMajorGridThicknessF      = 3.
  resf@tmYMajorGridLineDashPattern = 2

  ;resf@tmXMinorGrid= False
  ;resf@tmXMinorGridThicknessF      = 1.
  ;resf@tmXMinorGridLineDashPattern = 2
  
  ;resf@tmYMinorGrid= False
  ;resf@tmYMinorGridThicknessF      = 1.
  ;resf@tmYMinorGridLineDashPattern = 2

;******************************************************
; compute transect
;******************************************************

  do n = 0,nfiles-1

    ncdf = addfile("../data/transect/"+fname_in(n),"r")
    zraw = ncdf->zraw
    dist = ncdf->$DIST(n)$
    zsims = ncdf->zsims
    delete(ncdf)

;******************************************************
; plot obs
;******************************************************

    resf@trXMinF = MIN1(n)
    resf@trXMaxF = MAX1(n)
    resf@tiXAxisString = nams1

    resf@trYMinF = MIN2(n)
    resf@trYMaxF = MAX2(n)
    resf@tiYAxisString = nams2

    resf@xyLineThicknessF = 4
    resf@gsnXYBarChart            = True
    resf@gsnXYBarChartOutlineOnly = True

    resf@xyLineColors = colors(1)
    plot(3*n+0) = gsn_csm_xy(wks,dist,zsims(1,:),resf)
    resf@xyLineColors = colors(0)
    tmp = gsn_csm_xy(wks,dist,zsims(0,:),resf)
    overlay(plot(3*n+0),tmp)
    delete(tmp)

    resf@xyLineColors = colors(3)
    plot(3*n+1) = gsn_csm_xy(wks,dist,zsims(3,:),resf)
    resf@xyLineColors = colors(2)
    tmp = gsn_csm_xy(wks,dist,zsims(2,:),resf)
    overlay(plot(3*n+1),tmp)
    delete(tmp)

    resf@xyLineColors = colors(5)
    plot(3*n+2) = gsn_csm_xy(wks,dist,zsims(5,:),resf)
    resf@xyLineColors = colors(4)
    tmp = gsn_csm_xy(wks,dist,zsims(4,:),resf)
    overlay(plot(3*n+2),tmp)
    delete(tmp)

    resf@gsnXYBarChart            = False
    resf@gsnXYBarChartOutlineOnly = False
    resf@xyLineThicknessF = 3
    resf@xyLineColors = "black"

    tmp = gsn_csm_xy(wks,dist,zraw,resf)
    overlay(plot(3*n+0),tmp)
    delete(tmp)

    tmp = gsn_csm_xy(wks,dist,zraw,resf)
    overlay(plot(3*n+1),tmp)
    delete(tmp)

    tmp = gsn_csm_xy(wks,dist,zraw,resf)
    overlay(plot(3*n+2),tmp)
    delete(tmp)

    delete([/dist,zraw,zsims/])
end do

;*****************************************************
; Add legend
;*****************************************************
 txres = True
 txres@txFontHeightF = 0.01
 txres@txJust = "CenterLeft"

 plres  = True
 plres@gsLineDashPattern  = 0
 plres@gsLineThicknessF = 4

 xx0 = 0.12
 xx1 = 0.45
 xx2 = 0.78
 yy0 = 0.78
 yy1 = 0.765
 yy2 = 0.75

 plres@gsLineColor = colors(0)
 gsn_polyline_ndc(wks,(/xx0-0.03,xx0/),(/yy0,yy0/),plres)
 gsn_text_ndc(wks,label(0),xx0,yy0,txres)

 plres@gsLineColor = colors(1)
 gsn_polyline_ndc(wks,(/xx0-0.03,xx0/),(/yy1,yy1/),plres)
 gsn_text_ndc(wks,label(1),xx0,yy1,txres)

 plres@gsLineColor = colors(2)
 gsn_polyline_ndc(wks,(/xx1-0.03,xx1/),(/yy0,yy0/),plres)
 gsn_text_ndc(wks,label(2),xx1,yy0,txres)

 plres@gsLineColor = colors(3)
 gsn_polyline_ndc(wks,(/xx1-0.03,xx1/),(/yy1,yy1/),plres)
 gsn_text_ndc(wks,label(3),xx1,yy1,txres)

 plres@gsLineColor = colors(4)
 gsn_polyline_ndc(wks,(/xx2-0.03,xx2/),(/yy0,yy0/),plres)
 gsn_text_ndc(wks,label(4),xx2,yy0,txres)

 plres@gsLineColor = colors(5)
 gsn_polyline_ndc(wks,(/xx2-0.03,xx2/),(/yy1,yy1/),plres)
 gsn_text_ndc(wks,label(5),xx2,yy1,txres)

 plres@gsLineThicknessF = 3
 plres@gsLineColor = "black"
 gsn_polyline_ndc(wks,(/xx0-0.03,xx0/),(/yy2,yy2/),plres)
 gsn_text_ndc(wks,"  GMTED",xx0,yy2,txres)
 gsn_polyline_ndc(wks,(/xx1-0.03,xx1/),(/yy2,yy2/),plres)
 gsn_text_ndc(wks,"  GMTED",xx1,yy2,txres)
 gsn_polyline_ndc(wks,(/xx2-0.03,xx2/),(/yy2,yy2/),plres)
 gsn_text_ndc(wks,"  GMTED",xx2,yy2,txres)


;;drawNDCGrid(wks)
;*****************************************************
; Plot panel
;*****************************************************

  resP                  = True                   ; modify the panel plot
  resP@gsnFrame         = False                  ; don't advance panel plot
  ;resP@gsnPaperOrientation = "portrait"
  ;resP@gsnPanelBottom   = 0.05
  ;resP@gsnPanelFigureStringsFontHeightF = 0.02
  ;resP@gsnPanelFigureStringsPerimOn     = True
  ;resP@gsnPanelFigureStringsBackgroundFillColor = "white"
  ;resP@amJust           = "BottomLeft"
  ;resP@txString = pltTitle

  ;;resP@gsnPanelLeft = 0.05
  resP@gsnPanelRight = 0.98
  gsn_panel(wks,plot,(/2,3/),resP)               ; now draw as one plot

frame(wks)

end

