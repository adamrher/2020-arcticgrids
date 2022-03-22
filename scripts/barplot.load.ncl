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

  fname = (/"cam6_2_022.se_FHIST_ne30pg2_ne30pg2_mg17_1800pes_200507_mg3-Nx5yrs", \
            "cam6_2_022.se_FHIST_ne30pg3_ne30pg3_mg17_1800pes_200507_mg3-Nx5yrs", \
	    "cam6_2_022.se_FHIST_f19_f19_mg17_900pes_200506_mg3-Nx5yrs", \
	    "cam6_2_022.se_FHIST_f09_f09_mg17_1800pes_200507_mg3-Nx5yrs", \
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
  VAR2 = "QSNOMELT"
  VAR2b= "QICE_MELT"

  modi = (/".regrid_TO_f19.cnsrv.basin",\
	   ".regrid_TO_f19.te.basin", \
	   ".regrid_TO_ne30pg2.cnsrv.basin",\
	   ".regrid_TO_ne30pg2.te.basin"/)
  nregrid = dimsizes(modi)

  obsvar1  = "precip"
  obsvar2  = "runoff"
  obsvar2  = "snowmelt"

  nobs = 2
  obsname1 = "racmo23"
  obsname2 = "racmo23p2"
  ot0 = 21
  ot1 = 40

  nbasins = 7
  X1 = new( (/nbasins*(nfiles+1)/), "float" )
  CLIM1 = new( (/nbasins*(nfiles+1)/), "double" )
  CLIM2 = new( (/nbasins*(nfiles+1)/), "double" )
  STDEV1 = new( (/nbasins*(nfiles+1)/), "double" )
  STDEV2 = new( (/nbasins*(nfiles+1)/), "double" )

  dx = 0.75
  colors0 = (/"blue","deepskyblue1","green4","green","darkorchid4","magenta","black"/)
  colors = (/"green4","green","blue","deepskyblue1","darkorchid4","magenta","black"/)
  ;;colors = (/"blue","deepskyblue1","green4","green","red","black"/)
  COLORS = new( (/nbasins*(nfiles+1)/), "string" )

;******************************************************
; stuff
;******************************************************

  pltNam = "temp_tseries_BASIN"

  xmin = 0.5
  xmax = tofloat(nbasins) + 0.5
  xaxis = "Rignot and Mouginot Basins"

  ymin1 =   0.
  ymax1 = 280.
  yaxis1 = "PRECIP (Gt/yr)"

  ymin2 =   0.
  ymax2 = 180.
  yaxis2 = "SNOW+ICE MELT (Gt/yr)"

  ;;mm/s -> kg/(m2*yr) = mm/s [1m/1000mm] * rhoh2o * secpday*365 

;******************************************************
; create plot
;******************************************************
  wkstype = "pdf"
  wks = gsn_open_wks(wkstype,pltNam)               ; open workstation
  plot = new( (/2/), "graphic")

  res                          = True

  res@gsnMaximize              = False
  res@gsnDraw                  = False
  res@gsnFrame                 = False

  res@vpWidthF                 = 0.75
  res@vpHeightF                = 0.3

  res@tmBorderThicknessF = 3.
  res@tmXBMajorLengthF         = 0.01
  res@tmXBMajorOutwardLengthF  = 0.01
  res@tmYLMajorLengthF         = 0.01
  res@tmYLMajorOutwardLengthF  = 0.01

  res@tmXTOn                   = False

  res@gsnXYBarChart               = True

  res@tmYMajorGrid                = True
  res@tmYMajorGridLineDashPattern = 2
  res@tmYMajorGridThicknessF      = 1.0

  res@tiMainOn = False

;******************************************************
; begin loop
;******************************************************

 do n = 0,nfiles-1

   do m = 0,nregrid-1 

     do q = 0,nbasins-1

       fname_in = fname(n) + ".GRIS." + VAR1 + modi(m) + "." + tostring(q+1) + ".h0.nc"
       print("load: " + fname_in)
       ncdf = addfile("data/basinseries/"+fname_in,"r")
       xann1 = ncdf->xann

       ann1 = ncdf->ann
       delete(ncdf)

       fname_in = fname(n) + ".GRIS." + VAR1b + modi(m) + "." + tostring(q+1) + ".h0.nc"
       print("load: " + fname_in)
       ncdf = addfile("data/basinseries/"+fname_in,"r")
       ann1b = ncdf->ann
       delete(ncdf)
       ann1 = ann1 + ann1b
       delete(ann1b)

       fname_in = fname(n) + ".GRIS." + VAR2 + modi(m) + "." + tostring(q+1) + ".h0.nc"
       print("load: " + fname_in)
       ncdf = addfile("data/basinseries/"+fname_in,"r")
       xann2 = ncdf->xann
       ann2 = ncdf->ann
       delete(ncdf)

       fname_in = fname(n) + ".GRIS." + VAR2b + modi(m) + "." + tostring(q+1) + ".h0.nc"
       print("load: " + fname_in)
       ncdf = addfile("data/basinseries/"+fname_in,"r")
       ann2b = ncdf->ann
       delete(ncdf)
       ann2 = ann2 + ann2b
       delete(ann2b)

       if (n.eq.0) then
         fname_in = obsname1 + ".GRIS." + obsvar1 + modi(m) + "." + tostring(q+1) + ".nc"
         print("load: " + fname_in)
         ncdf = addfile("data/basinseries/"+fname_in,"r")
         otime1 = ncdf->otime
         oann1 = ncdf->oann
         delete(ncdf)

         fname_in = obsname1 + ".GRIS." + obsvar2 + modi(m) + "." + tostring(q+1) + ".nc"
         print("load: " + fname_in)
         ncdf = addfile("data/basinseries/"+fname_in,"r")
         otime2 = ncdf->otime
         oann2 = ncdf->oann
         delete(ncdf)

         notime = dimsizes(otime2)

         fname_in = obsname2 + ".GRIS." + obsvar1 + modi(m) + "." + tostring(q+1) + ".nc"
         print("load: " + fname_in)
         ncdf = addfile("data/basinseries/"+fname_in,"r")
         otime1a = ncdf->otime(0:notime-1)
         oann1a = ncdf->oann(0:notime-1)
         delete(ncdf)

         fname_in = obsname2 + ".GRIS." + obsvar2 + modi(m) + "." + tostring(q+1) + ".nc"
         print("load: " + fname_in)
         ncdf = addfile("data/basinseries/"+fname_in,"r")
         otime2a = ncdf->otime(0:notime-1)
         oann2a = ncdf->oann(0:notime-1)
         delete(ncdf)

       end if

       if (n.eq.0 .and. m.eq.0 .and. q.eq.0) then
         ANN1 = new( (/nfiles,nregrid,nbasins,dimsizes(xann1)/), "double" )
         ANN2 = new( (/nfiles,nregrid,nbasins,dimsizes(xann1)/), "double" )
         OANN1= new( (/nobs,nregrid,nbasins,dimsizes(otime1)/), "double" )
         OANN2= new( (/nobs,nregrid,nbasins,dimsizes(otime1)/), "double" )
       end if

       ANN1(n,m,q,:) = ann1
       ANN2(n,m,q,:) = ann2
       delete([/xann1,ann1,xann2,ann2/])
       if (n.eq.0) then
         OANN1(0,m,q,:) = oann1
         OANN2(0,m,q,:) = oann2
         OANN1(1,m,q,:) = oann1a
         OANN2(1,m,q,:) = oann2a
         delete([/oann1,oann2,oann1a,oann2a,otime1,otime2,otime1a,otime2a/])
       end if
     end do;;q
   end do;;m
 end do;;n

 do n = 0,nfiles-1
   do q = 0,nbasins-1
 
     idx = q*(nfiles+1) + n
     x1 = tofloat(q+1) - dx/2. + tofloat(n)*dx/tofloat(nfiles)
     X1(idx) = x1

     clim11d = ndtooned(ANN1(n,:,q,:))
     clim21d = ndtooned(ANN2(n,:,q,:))
     CLIM1(idx) = dim_avg(clim11d)
     CLIM2(idx) = dim_avg(clim21d)

     mu1 = sum((clim11d-dim_avg(clim11d))^2.)/dimsizes(clim11d) 
     mu2 = sum((clim21d-dim_avg(clim21d))^2.)/dimsizes(clim21d)
     STDEV1(idx) = sqrt(mu1)
     STDEV2(idx) = sqrt(mu2)

     COLORS(idx) = colors(n)
 
     if (n.eq.0) then

       idx = q*(nfiles+1) + nfiles
       ox1 = tofloat(q+1) - dx/2. + dx
       X1(idx) = ox1

       oclim11d = ndtooned(OANN1(:,:,q,ot0:ot1))
       oclim21d = ndtooned(OANN2(:,:,q,ot0:ot1))
       CLIM1(idx) = dim_avg(oclim11d)
       CLIM2(idx) = dim_avg(oclim21d)

       mu1 = sum((oclim11d-dim_avg(oclim11d))^2.)/dimsizes(oclim11d) 
       mu2 = sum((oclim21d-dim_avg(oclim21d))^2.)/dimsizes(oclim21d)
       STDEV1(idx) = sqrt(mu1)
       STDEV2(idx) = sqrt(mu2)

       COLORS(idx) = colors(nfiles)
       delete([/oclim11d,oclim21d/])
     end if
     delete([/clim11d,clim21d/])
   end do
 end do

 POS1 = CLIM1+STDEV1
 NEG1 = CLIM1-STDEV1
 POS2 = CLIM2+STDEV2
 NEG2 = CLIM2-STDEV2

 res@tmXBLabelFontHeightF     = 0.015

 res@tmXBMode = "Explicit"
 res@tmXBValues = (/1.,2.,3.,4.,5.,6.,7./)
 res@tmXBLabels = (/"1","2","3","4","5","6","7"/)
 res@tmXBLabels = (/"N","NE","CE","SE","SW","CW","NW"/)

 res@gsnXYBarChartBarWidth       = 0.1
 res@gsnXYBarChartColors = COLORS
 res@gsnXYBarChartOutlineThicknessF = 1.

 res@trXMinF                = xmin
 res@trXMaxF                = xmax

 res@tiYAxisString = yaxis1
 res@trYMinF                = ymin1
 res@trYMaxF                = ymax1

 plot(0) = gsn_csm_xy(wks,X1,CLIM1,res)

 res@tiXAxisString = xaxis

 res@tiYAxisString = yaxis2
 res@trYMinF                = ymin2
 res@trYMaxF                = ymax2

 plot(1) = gsn_csm_xy(wks,X1,CLIM2,res)

 pgres                  = True
 pgres@gsLineThicknessF = 2.0

 opt = 6
 ddx = dx/tofloat(2*nfiles)
 npts = dimsizes(X1)
 do n = 0,npts-1

   if (n.eq.opt) then
     pgres@gsLineColor = "red"
     opt = opt + 7
   else
     pgres@gsLineColor = "black"
   end if
   
   pNam = unique_string("tmp")
   plot@$pNam$ = gsn_add_polyline(wks,plot(0),(/X1(n),X1(n)/),(/NEG1(n),POS1(n)/),pgres)
   pNam = unique_string("tmp")
   plot@$pNam$ = gsn_add_polyline(wks,plot(0),(/X1(n)-ddx/2.,X1(n)+ddx/2./),(/NEG1(n),NEG1(n)/),pgres)
   pNam = unique_string("tmp")
   plot@$pNam$ = gsn_add_polyline(wks,plot(0),(/X1(n)-ddx/2.,X1(n)+ddx/2./),(/POS1(n),POS1(n)/),pgres)

   pNam = unique_string("tmp")
   plot@$pNam$ = gsn_add_polyline(wks,plot(1),(/X1(n),X1(n)/),(/NEG2(n),POS2(n)/),pgres)
   pNam = unique_string("tmp")
   plot@$pNam$ = gsn_add_polyline(wks,plot(1),(/X1(n)-ddx/2.,X1(n)+ddx/2./),(/NEG2(n),NEG2(n)/),pgres)
   pNam = unique_string("tmp")
   plot@$pNam$ = gsn_add_polyline(wks,plot(1),(/X1(n)-ddx/2.,X1(n)+ddx/2./),(/POS2(n),POS2(n)/),pgres)
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

 yy = (/0.95,0.92,0.95,0.92,0.95,0.92,0.95,0.92/) - 0.01
 xx = (/0.29,0.29,0.43,0.43,0.63,0.63,0.83,0.83/) - 0.07
 dx = 0.05
 do n = 0,nfiles-1
   resln@gsLineColor = colors0(n)
   gsn_polyline_ndc(wks,(/xx(n),xx(n)+dx/),(/yy(n),yy(n)/),resln)
   gsn_text_ndc(wks,label(n),xx(n)+dx,yy(n),txres)
 end do

 ;;resln@gsLineDashPattern = 1
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
  resP@gsnPanelTop = 0.90
  resP@gsnPanelYWhiteSpacePercent = 0.01
  gsn_panel(wks,plot,(/2,1/),resP)               ; now draw as one plot

frame(wks)

end

