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

  subdir = "../data/tseries/"

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

  VAR1 = "SNOW"
  VAR1b= "RAIN"
  VAR2 = "QICE_MELT"
  VAR2b= "QSNOMELT"

  modi = (/".regrid_TO_f19.cnsrv.basin.total.",\
	   ".regrid_TO_f19.te.basin.total.", \
	   ".regrid_TO_ne30pg2.cnsrv.basin.total.",\
	   ".regrid_TO_ne30pg2.te.basin.total."/)
  nregrid = dimsizes(modi)

  obsvar1  = "precip"
  obsvar2  = "snowmelt"

  obsname01 = "racmo23"
  obsname02 = "racmo23"
  obsname11 = "racmo23p2"
  obsname12 = "racmo23p2"

  colors = (/"blue","deepskyblue1","green4","green","darkorchid4","magenta"/)

;******************************************************
; stuff
;******************************************************

  pltNam = "temp_tseries_GRIS"

  ;;xmin = 1979.
  ;;xmax = 1998.

  xmin = 1970.;;1958.
  xmax = 2010.;;2013.

  ymin1 =  600.
  ymax1 = 1200.
  yaxis1 = "PRECIP (Gt/yr)"

  ymin2 =  -1000.
  ymax2 =   -200.
  yaxis2 = "ICE/SNOW MELT (Gt/yr)"

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

  polyres               = True          
  polyres@gsMarkerThicknessF = 5.
  ;;polyres@tfPolyDrawOrder = "PostDraw"


;******************************************************
; begin loop
;******************************************************

 do n = 0,nfiles-1

   do m = 0,nregrid-1 

     fname_in = fname(n) + ".GRIS." + VAR1 + modi(m) + "h0.nc"
     print("load: " + fname_in)
     ncdf = addfile(subdir+fname_in,"r")
     xann1 = ncdf->xann
     ann1 = ncdf->ann
     delete(ncdf)

     fname_in = fname(n) + ".GRIS." + VAR1b + modi(m) + "h0.nc"
     print("load: " + fname_in)
     ncdf = addfile(subdir+fname_in,"r")
     ann1b = ncdf->ann
     delete(ncdf)
     ann1 = ann1 + ann1b
     delete(ann1b)

     fname_in = fname(n) + ".GRIS." + VAR2 + modi(m) + "h0.nc"
     print("load: " + fname_in)
     ncdf = addfile(subdir+fname_in,"r")
     xann2 = ncdf->xann
     ann2 = ncdf->ann
     delete(ncdf)

     fname_in = fname(n) + ".GRIS." + VAR2b + modi(m) + "h0.nc"
     print("load: " + fname_in)
     ncdf = addfile(subdir+fname_in,"r")
     ann2b = ncdf->ann
     delete(ncdf)

     ann2 = -1.*ann2 - ann2b
     delete(ann2b)

     if (n.eq.0) then
       fname_in = obsname01 + ".GRIS." + obsvar1 + modi(m) + "nc"
       print("load: " + fname_in)
       ncdf = addfile(subdir+fname_in,"r")
       otime1 = ncdf->otime
       oann1 = ncdf->oann
       delete(ncdf)

       fname_in = obsname02 + ".GRIS." + obsvar2 + modi(m) + "nc"
       print("load: " + fname_in)
       ncdf = addfile(subdir+fname_in,"r")
       otime2 = ncdf->otime
       oann2 = ncdf->oann
       delete(ncdf)

       oann2 = -1.*oann2

       print("max1 obs: " + max(oann1))
       print("min1 obs: " + min(oann1))
       print("max2 obs: " + max(oann2))
       print("min2 obs: " + min(oann2))

       fname_in = obsname11 + ".GRIS." + obsvar1 + modi(m) + "nc"
       print("load: " + fname_in)
       ncdf = addfile(subdir+fname_in,"r")
       otime1b = ncdf->otime
       oann1b = ncdf->oann
       delete(ncdf)
       
       fname_in = obsname12 + ".GRIS." + obsvar2 + modi(m) + "nc"
       print("load: " + fname_in)
       ncdf = addfile(subdir+fname_in,"r")
       otime2b = ncdf->otime
       oann2b = ncdf->oann
       delete(ncdf)

       oann2b = -1.*oann2b

       print("max1 obs: " + max(oann1b))
       print("min1 obs: " + min(oann1b))
       print("max2 obs: " + max(oann2b))
       print("min2 obs: " + min(oann2b))
     end if

     print("max1: " + max(ann1))
     print("min1: " + min(ann1))
     print("max2: " + max(ann2))
     print("min2: " + min(ann2))

     if (n.eq.0 .and. m.eq.0) then
       ANN1 = new( (/nfiles,nregrid,dimsizes(xann1)/), "double" )
       ANN2 = new( (/nfiles,nregrid,dimsizes(xann1)/), "double" )
       OANN1= new( (/nregrid,2,dimsizes(otime1)/), "double" )
       OANN2= new( (/nregrid,2,dimsizes(otime1)/), "double" )
     end if

     ANN1(n,m,:) = ann1
     ANN2(n,m,:) = ann2
     XTIME = xann1
     delete([/xann1,ann1,xann2,ann2/])
     if (n.eq.0) then
       OANN1(m,0,:) = oann1
       OANN2(m,0,:) = oann2
       OANN1(m,1,:) = oann1b(0:dimsizes(otime1)-1)
       OANN2(m,1,:) = oann2b(0:dimsizes(otime1)-1)
       OTIME = otime1
       delete([/oann1,oann2,otime1,otime2,oann1b,oann2b,otime1b,otime2b/])
     end if

    end do;;m

 end do;;n

 ;;plot obs
 notime = dimsizes(OTIME)
 mxoann1 = new( (/notime/), "double" )
 mnoann1 = new( (/notime/), "double" )
 avoann1 = new( (/notime/), "double" )
 mxoann2 = new( (/notime/), "double" )
 mnoann2 = new( (/notime/), "double" ) 
 avoann2 = new( (/notime/), "double" )
 do t = 0,notime-1
   mxoann1(t) = max(OANN1(:,:,t))
   mnoann1(t) = min(OANN1(:,:,t))
   avoann1(t) = dim_avg(dim_avg(OANN1(:,:,t)))
   mxoann2(t) = max(OANN2(:,:,t))
   mnoann2(t) = min(OANN2(:,:,t))
   avoann2(t) = dim_avg(dim_avg(OANN2(:,:,t)))
 end do

 resf@xyLineThicknessF   = 4.
 resf@xyLineColors       = "black"

 resf@trXMinF                = xmin
 resf@trXMaxF                = xmax

 resf@tiYAxisString = yaxis1
 resf@trYMinF                = ymin1
 resf@trYMaxF                = ymax1

 delete([/OTIME@units,OTIME@long_name,OTIME@standard_name/])
 plot(0) = gsn_csm_xy(wks,OTIME,avoann1,resf) 

 resf@tiXAxisString = "Year"

 resf@tiYAxisString = yaxis2
 resf@trYMinF                = ymin2
 resf@trYMaxF                = ymax2

 plot(1) = gsn_csm_xy(wks,OTIME,avoann2,resf)

 ;;; transparent polygons
 gsres                = True
 gsres@gsFillOpacityF = 0.3
 gsres@tfPolyDrawOrder = "PreDraw"

 np = 2*notime+1
 xp = new((/np/),double)
 yp = new((/np/),double)

 xp(0) = OTIME(0)
 xp(1:notime) = OTIME(0:notime-1)
 xp(notime+1:np-1) = OTIME(notime-1:0)

 yp(0) = mnoann1(0)
 yp(1:notime) = mxoann1(0:notime-1)
 yp(notime+1:np-1) = (/mnoann1(notime-1:0)/)

 gsres@gsFillColor    = "black"
 polystr = unique_string("hum")
 plot@$polystr$ = gsn_add_polygon(wks,plot(0),xp,yp,gsres)

 yp(0) = mnoann2(0)
 yp(1:notime) = mxoann2(0:notime-1)
 yp(notime+1:np-1) = (/mnoann2(notime-1:0)/)

 polystr = unique_string("hum")
 plot@$polystr$ = gsn_add_polygon(wks,plot(1),xp,yp,gsres)
 delete([/xp,yp/])

 SOANN1 = OANN1(:,:,21:40)
 SOANN2 = OANN2(:,:,21:40)
 oann11d = ndtooned(SOANN1)
 oann21d = ndtooned(SOANN2)
 obarann1 = dim_avg(oann11d)
 obarann2 = dim_avg(oann21d)

 polyres@gsMarkerOpacityF = gsres@gsFillOpacityF
 polyres@gsMarkerColor = "black"
 polyres@gsMarkerIndex = 16
 polyres@gsMarkerSizeF = 20.
 pNam = unique_string("tmp")
 plot@$pNam$ = gsn_add_polymarker(wks,plot(0),xmax-1,obarann1,polyres)
 pNam = unique_string("tmp")
 plot@$pNam$ = gsn_add_polymarker(wks,plot(1),xmax-1,obarann2,polyres)
 delete([/polyres@gsMarkerOpacityF/])

 polyres@gsMarkerIndex = 4
 pNam = unique_string("tmp")
 plot@$pNam$ = gsn_add_polymarker(wks,plot(0),xmax-1,obarann1,polyres)
 pNam = unique_string("tmp")
 plot@$pNam$ = gsn_add_polymarker(wks,plot(1),xmax-1,obarann2,polyres)

   print("RACMO PRECIP: " + obarann1)
   print("RACMO MELT: " + obarann2)

 ;;all cases
 do n = 0,nfiles-1

   ntime = dimsizes(XTIME)
   mxann1 = new( (/ntime/), "double" )
   mnann1 = new( (/ntime/), "double" )
   avann1 = new( (/ntime/), "double" )
   mxann2 = new( (/ntime/), "double" )
   mnann2 = new( (/ntime/), "double" )
   avann2 = new( (/ntime/), "double" )
   do t = 0,ntime-1
     mxann1(t) = max(ANN1(n,:,t))
     mnann1(t) = min(ANN1(n,:,t))
     avann1(t) = dim_avg(ANN1(n,:,t))
     mxann2(t) = max(ANN2(n,:,t))
     mnann2(t) = min(ANN2(n,:,t))
     avann2(t) = dim_avg(ANN2(n,:,t))
   end do

   resf@xyLineColors       = colors(n)

   tmp = gsn_csm_xy(wks,XTIME,avann1,resf)
   overlay(plot(0),tmp)
   delete(tmp)

   tmp = gsn_csm_xy(wks,XTIME,avann2,resf)
   overlay(plot(1),tmp)
   delete(tmp)

   np = 2*ntime+1
   xp = new((/np/),double)
   yp = new((/np/),double)
 
   xp(0) = XTIME(0)
   xp(1:ntime) = XTIME(0:ntime-1)
   xp(ntime+1:np-1) = XTIME(ntime-1:0)
 
   yp(0) = mnann1(0)
   yp(1:ntime) = mxann1(0:ntime-1)
   yp(ntime+1:np-1) = (/mnann1(ntime-1:0)/)
 
   gsres@gsFillColor    = colors(n)
   polystr = unique_string("hum")
   plot@$polystr$ = gsn_add_polygon(wks,plot(0),xp,yp,gsres)

   yp(0) = mnann2(0)
   yp(1:ntime) = mxann2(0:ntime-1)
   yp(ntime+1:np-1) = (/mnann2(ntime-1:0)/)

   polystr = unique_string("hum")
   plot@$polystr$ = gsn_add_polygon(wks,plot(1),xp,yp,gsres)
   delete([/xp,yp/])

   delete([/mxann1,mnann1,avann1,mxann2,mnann2,avann2/])

   ann11d = ndtooned(ANN1(n,:,:))
   ann21d = ndtooned(ANN2(n,:,:))
   barann1 = dim_avg(ann11d)
   barann2 = dim_avg(ann21d)

   polyres@gsMarkerOpacityF = 0.4
   polyres@gsMarkerColor = colors(n)
   polyres@gsMarkerIndex = 16
   polyres@gsMarkerSizeF = 20.
   pNam = unique_string("tmp")
   plot@$pNam$ = gsn_add_polymarker(wks,plot(0),xmax-1,barann1,polyres)
   pNam = unique_string("tmp")
   plot@$pNam$ = gsn_add_polymarker(wks,plot(1),xmax-1,barann2,polyres)
   delete([/polyres@gsMarkerOpacityF/])

   polyres@gsMarkerIndex = 4
   pNam = unique_string("tmp")
   plot@$pNam$ = gsn_add_polymarker(wks,plot(0),xmax-1,barann1,polyres)
   pNam = unique_string("tmp")
   plot@$pNam$ = gsn_add_polymarker(wks,plot(1),xmax-1,barann2,polyres)
   delete([/ann11d,ann21d/])

   print(label(n) + " PRECIP: " + barann1)
   print(label(n) + " MELT: " + barann2)

 end do

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

 yy = (/0.95,0.92,0.95,0.92,0.95,0.92,0.95,0.92/) + 0.03
 xx = (/0.23,0.23,0.35,0.35,0.55,0.55,0.75,0.75/) - 0.07
 dx = 0.05
 do n = 0,nfiles-1
   resln@gsLineColor = colors(n)
   gsn_polyline_ndc(wks,(/xx(n),xx(n)+dx/),(/yy(n),yy(n)/),resln)
   gsn_text_ndc(wks,label(n),xx(n)+dx,yy(n),txres)
print("label " + label(n) + ", color " + colors(n))
 end do

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

