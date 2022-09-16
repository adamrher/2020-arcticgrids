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
  ;;subdir = "/glade/work/aherring/CESM2/SMB/data/methods/"

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

  VAR1 = "precip"
  VAR2 = "snowmelt"
  VAR3 = "t2m"
  beta = 5. ;;pdd factor
  xfactor = 1.e-12;;mm/yr->Gt/yr

  modi = (/".method1.regrid_TO_f19.cnsrv.basin",\
           ".method1.regrid_TO_f19.te.basin", \
           ".method1.regrid_TO_ne30pg2.cnsrv.basin",\
           ".method1.regrid_TO_ne30pg2.te.basin", \
           ".method2.regrid_TO_f19.cnsrv.basin",\
           ".method2.regrid_TO_f19.te.basin", \
           ".method2.regrid_TO_ne30pg2.cnsrv.basin",\
           ".method2.regrid_TO_ne30pg2.te.basin"/)
  nregrid = dimsizes(modi)

  obsvar1  = "precip"
  obsvar2  = "snowmelt"
  obsvar3  = "t2m"

  nobs = 2
  obsname1 = "racmo23"
  obsname2 = "racmo23p2"
  ot0 = 21
  ot1 = 40

  nbasins = 7
  X1 = new( (/nbasins*(nfiles+1)/), "float" )
  CLIM1 = new( (/nbasins*(nfiles+1)/), "double" )
  CLIM2 = new( (/nbasins*(nfiles+1)/), "double" )
  CLIM3 = new( (/nbasins*(nfiles+1)/), "double" )
  STDEV1 = new( (/nbasins*(nfiles+1)/), "double" )
  STDEV2 = new( (/nbasins*(nfiles+1)/), "double" )
  STDEV3 = new( (/nbasins*(nfiles+1)/), "double" )

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
  xaxis = "Greenland Basins"

  ymin1 =   0.
  ymax1 = 280.
  yaxis1 = "PRECIP (Gt/yr)"

  ymin2 =   0.
  ymax2 = 190.
  yaxis2 = "SNOW+ICE MELT (Gt/yr)"

  ymin3 =   0.
  ymax3 = 190.
  yaxis3 = "PDD METHOD (Gt/yr)"

  ;;mm/s -> kg/(m2*yr) = mm/s [1m/1000mm] * rhoh2o * secpday*365 

;******************************************************
; create plot
;******************************************************
  wkstype = "pdf"
  wks = gsn_open_wks(wkstype,pltNam)               ; open workstation
  plot = new( (/3/), "graphic")

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
       ncdf = addfile(subdir+fname_in,"r")
       xann1 = ncdf->xann

       ann1 = ncdf->ann
       delete(ncdf)

       fname_in = fname(n) + ".GRIS." + VAR2 + modi(m) + "." + tostring(q+1) + ".h0.nc"
       print("load: " + fname_in)
       ncdf = addfile(subdir+fname_in,"r")
       xann2 = ncdf->xann
       ann2 = ncdf->ann
       delete(ncdf)

       fname_in = fname(n) + ".GRIS." + VAR3 + modi(m) + "." + tostring(q+1) + ".h0.nc"
       print("load: " + fname_in)
       ncdf = addfile(subdir+fname_in,"r")
       ann3 = ncdf->ann
       delete(ncdf)

       ann3 = ann3*beta*xfactor

       if (n.eq.0) then
         fname_in = obsname1 + ".GRIS." + obsvar1 + modi(m) + "." + tostring(q+1) + ".nc"
         print("load: " + fname_in)
         ncdf = addfile(subdir+fname_in,"r")
         otime1 = ncdf->otime(ot0:ot1)
         oann1 = ncdf->oann(ot0:ot1)
         delete(ncdf)

         fname_in = obsname1 + ".GRIS." + obsvar2 + modi(m) + "." + tostring(q+1) + ".nc"
         print("load: " + fname_in)
         ncdf = addfile(subdir+fname_in,"r")
         otime2 = ncdf->otime(ot0:ot1)
         oann2 = ncdf->oann(ot0:ot1)
         delete(ncdf)

         fname_in = obsname1 + ".GRIS." + obsvar3 + modi(m) + "." + tostring(q+1) + ".nc"
         print("load: " + fname_in)
         ncdf = addfile(subdir+fname_in,"r")
         oann3 = ncdf->oann
         delete(ncdf)

         oann3 = oann3*beta*xfactor

         fname_in = obsname2 + ".GRIS." + obsvar1 + modi(m) + "." + tostring(q+1) + ".nc"
         print("load: " + fname_in)
         ncdf = addfile(subdir+fname_in,"r")
         otime1a = ncdf->otime(ot0:ot1)
         oann1a = ncdf->oann(ot0:ot1)
         delete(ncdf)

         fname_in = obsname2 + ".GRIS." + obsvar2 + modi(m) + "." + tostring(q+1) + ".nc"
         print("load: " + fname_in)
         ncdf = addfile(subdir+fname_in,"r")
         otime2a = ncdf->otime(ot0:ot1)
         oann2a = ncdf->oann(ot0:ot1)
         delete(ncdf)

         fname_in = obsname2 + ".GRIS." + obsvar3 + modi(m) + "." + tostring(q+1) + ".nc"
         print("load: " + fname_in)
         ncdf = addfile(subdir+fname_in,"r")
         oann3a = ncdf->oann
         delete(ncdf)

         oann3a = oann3a*beta*xfactor

       end if

       if (n.eq.0 .and. m.eq.0 .and. q.eq.0) then
         ANN1 = new( (/nfiles,nregrid,nbasins,dimsizes(xann1)/), "double" )
         ANN2 = new( (/nfiles,nregrid,nbasins,dimsizes(xann1)/), "double" )
         ANN3 = new( (/nfiles,nregrid,nbasins,dimsizes(xann1)/), "double" )
         OANN1= new( (/nobs,nregrid,nbasins,dimsizes(otime1)/), "double" )
         OANN2= new( (/nobs,nregrid,nbasins,dimsizes(otime1)/), "double" )
         OANN3= new( (/nobs,nregrid,nbasins,dimsizes(otime1)/), "double" )
       end if

       ANN1(n,m,q,:) = ann1
       ANN2(n,m,q,:) = ann2
       ANN3(n,m,q,:) = ann3
       delete([/xann1,ann1,xann2,ann2/])
       if (n.eq.0) then
         OANN1(0,m,q,:) = oann1
         OANN2(0,m,q,:) = oann2
         OANN3(0,m,q,:) = oann3
         OANN1(1,m,q,:) = oann1a
         OANN2(1,m,q,:) = oann2a
         OANN3(1,m,q,:) = oann3a
         delete([/oann1,oann2,oann1a,oann2a,oann3,oann3a,otime1,otime2,otime1a,otime2a/])
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
     clim31d = ndtooned(ANN3(n,:,q,:))
     CLIM1(idx) = dim_avg(clim11d)
     CLIM2(idx) = dim_avg(clim21d)
     CLIM3(idx) = dim_avg(clim31d)

     mu1 = sum((clim11d-dim_avg(clim11d))^2.)/dimsizes(clim11d) 
     mu2 = sum((clim21d-dim_avg(clim21d))^2.)/dimsizes(clim21d)
     mu3 = sum((clim31d-dim_avg(clim31d))^2.)/dimsizes(clim31d)
     STDEV1(idx) = sqrt(mu1)
     STDEV2(idx) = sqrt(mu2)
     STDEV3(idx) = sqrt(mu3)

     COLORS(idx) = colors(n)
 
     if (n.eq.0) then

       idx = q*(nfiles+1) + nfiles
       ox1 = tofloat(q+1) - dx/2. + dx
       X1(idx) = ox1

       oclim11d = ndtooned(OANN1(:,:,q,:))
       oclim21d = ndtooned(OANN2(:,:,q,:))
       oclim31d = ndtooned(OANN3(:,:,q,:))
       CLIM1(idx) = dim_avg(oclim11d)
       CLIM2(idx) = dim_avg(oclim21d)
       CLIM3(idx) = dim_avg(oclim31d)

       mu1 = sum((oclim11d-dim_avg(oclim11d))^2.)/dimsizes(oclim11d) 
       mu2 = sum((oclim21d-dim_avg(oclim21d))^2.)/dimsizes(oclim21d)
       mu3 = sum((oclim31d-dim_avg(oclim31d))^2.)/dimsizes(oclim31d)
       STDEV1(idx) = sqrt(mu1)
       STDEV2(idx) = sqrt(mu2)
       STDEV3(idx) = sqrt(mu3)

       COLORS(idx) = colors(nfiles)
       delete([/oclim11d,oclim21d,oclim31d/])
     end if
     delete([/clim11d,clim21d,clim31d/])
   end do
 end do

 POS1 = CLIM1+STDEV1
 NEG1 = CLIM1-STDEV1
 POS2 = CLIM2+STDEV2
 NEG2 = CLIM2-STDEV2
 POS3 = CLIM3+STDEV3
 NEG3 = CLIM3-STDEV3

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

 res@tiYAxisString = yaxis2
 res@trYMinF                = ymin2
 res@trYMaxF                = ymax2

 res@tmYLMode        = "Explicit"
 res@tmYLValues      = (/0.,30.,60.,90.,120.,150.,180./)
 res@tmYLLabels      = (/"0","-30","-60","-90","-120","-150","-180"/)

 plot(1) = gsn_csm_xy(wks,X1,CLIM2,res)

 res@tiXAxisString = xaxis

 res@tiYAxisString = yaxis3
 res@trYMinF                = ymin3
 res@trYMaxF                = ymax3

 plot(2) = gsn_csm_xy(wks,X1,CLIM3,res)
 res@tmYLMode        = "Automatic"

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

   pNam = unique_string("tmp")
   plot@$pNam$ = gsn_add_polyline(wks,plot(2),(/X1(n),X1(n)/),(/NEG3(n),POS3(n)/),pgres)
   pNam = unique_string("tmp")
   plot@$pNam$ = gsn_add_polyline(wks,plot(2),(/X1(n)-ddx/2.,X1(n)+ddx/2./),(/NEG3(n),NEG3(n)/),pgres)
   pNam = unique_string("tmp")
   plot@$pNam$ = gsn_add_polyline(wks,plot(2),(/X1(n)-ddx/2.,X1(n)+ddx/2./),(/POS3(n),POS3(n)/),pgres)
 end do


;*****************************************************
; Add legend
;*****************************************************
 txres = True
 txres@txFontHeightF = 0.015
 txres@txJust = "CenterLeft"

 resln             = True
 resln@gsLineThicknessF = 5.;;resf@xyLineThicknessF

 res = True
 res@gsMarkerSizeF = 30
 res@gsMarkerThicknessF = 6

 yy = (/0.95,0.93,0.95,0.93,0.95,0.93,0.95,0.93/) - 0.01
 xx = (/0.20,0.20,0.32,0.32,0.51,0.51,0.67,0.67/) - 0.01
 dx = 0.05
 do n = 0,nfiles-1
   resln@gsLineColor = colors0(n)
   gsn_polyline_ndc(wks,(/xx(n),xx(n)+dx/),(/yy(n),yy(n)/),resln)
   gsn_text_ndc(wks,label(n),xx(n)+dx,yy(n),txres)
 end do

 ;;resln@gsLineDashPattern = 1
 resln@gsLineColor = "black"
 gsn_polyline_ndc(wks,(/xx(n),xx(n)+dx/),(/yy(n),yy(n)/),resln)
 gsn_text_ndc(wks,"  RACMO",xx(n)+dx,yy(n),txres)


;;drawNDCGrid(wks)
;*****************************************************
; Plot panel
;*****************************************************

  resP                  = True                   ; modify the panel plot
  resP@gsnFrame         = False                  ; don't advance panel plot
  ;resP@gsnPaperOrientation = "portrait"
  resP@gsnPanelBottom   = 0.05
  resP@gsnPanelFigureStrings = (/"(a)","(b)","(c)"/)
  resP@gsnPanelFigureStringsFontHeightF = 0.015
  resP@gsnPanelFigureStringsPerimOn     = True
  resP@gsnPanelFigureStringsBackgroundFillColor = "white"
  resP@amJust           = "TopLeft"

  ;resP@txString = pltTitle
  resP@gsnPanelTop = 0.90
  resP@gsnPanelYWhiteSpacePercent = 0.01
  gsn_panel(wks,plot,(/3,1/),resP)               ; now draw as one plot

frame(wks)

end

