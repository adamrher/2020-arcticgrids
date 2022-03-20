load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

begin
;******************************************************
;
;******************************************************

  fname_in = (/"ktransect-smb-clm-obsperiod.nc", \
	       "btransect-smb-clm-allyrs.nc"/)
  zvar = (/"zsims","zsims"/)

  label = (/"  f19", \
            "  f09", \
            "  ne30pg2", \
            "  ne30pg3", \
            "  ARCTIC", \
            "  ARCTICGRIS"/)
  nfiles = dimsizes(label)

  colors = (/"blue","deepskyblue1","green4","green2","darkorchid4","magenta"/)

  xmin1 = 300.
  xmax1 = 2500.
  xmin2 = 500.
  xmax2 = 2700.
  nams1 = "Elevation (m)"

  ymin1 = -4200.
  ymax1 = 1000.
  ymin2 = -300.
  ymax2 =  700.
  nams2 = "Surface Mass Balance (mm w.e./yr)"

  pltNam = "temp_zsmb"

  nams = (/nams1,nams2/)

  Re = 6371220.d0
  pi = 3.14159265358979d0
  g = 9.80616

;******************************************************
; create plot
;******************************************************
  wkstype = "pdf"
  ;;wkstype = "png"
  wks = gsn_open_wks(wkstype,pltNam)               ; open workstation
  plot = new( (/3/), "graphic")

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

  resf@tmBorderThicknessF = 2.5
  resf@tmXBMajorOutwardLengthF = 0.
  resf@tmYLMajorOutwardLengthF = 0.
  resf@tmXBMinorOutwardLengthF = 0.
  resf@tmYLMinorOutwardLengthF = 0.
  resf@tmXTMajorOutwardLengthF = 0.
  resf@tmYRMajorOutwardLengthF = 0.
  resf@tmXTMinorOutwardLengthF = 0.
  resf@tmYRMinorOutwardLengthF = 0.

  resf@tiXAxisFontHeightF = 0.015
  resf@tiYAxisFontHeightF = 0.015
  resf@tmXBLabelFontHeightF = 0.015
  resf@tmYLLabelFontHeightF = 0.015

  resf@vpWidthF            = 0.2
  resf@vpHeightF           = 0.2

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
; begin loop
;******************************************************

do m = 0,1

;******************************************************
; load obs
;******************************************************
 if (m.eq.0) then  ;;k-transect

   kstations = (/"SHR",     \
		"Site-10", \
		"Site-4",  \
		"Site-5",  \
		"Site-6",  \
		"Site-7",  \
		"Site-8",  \
		"Site-9"/)

   klatitude = (/67.099d0, \
                67.0d000, \
                67.097d0, \
                67.098d0, \
                67.078d0, \
                66.992d0, \
                67.005d0, \
                67.052d0/)

   klongitude= (/-49.936d0, \
                -47.015d0, \   
                -50.195d0, \  
                -50.084d0, \  
                -49.396d0, \  
                -49.150d0, \
                -48.876d0, \
                -48.250d0/)

   elevation= (/710.0d0,  \
                1850.0d0, \   
                383.0d0,  \  
                490.0d0,  \  
                1010.0d0, \  
                1110.0d0, \  
                1260.0d0, \
                1520.0d0/)

   kdistance = (/14.0d0, \
                143.0d0,\   
                3.0d0,  \  
                6.0d0,  \
                37.0d0, \
                52.0d0, \
                63.0d0, \
                91.0d0/)

   indz = dim_pqsort(elevation,1)
   nobs = dimsizes(elevation)
   obssmb = new( (/nobs/), "double" )

   ;;add additional points to the k-transect
   latedge =  67.1d0
   lonedge = -54.0d0
   latsummit =  66.725d0
   lonsummit = -43.25d0

   nstations = nobs+2
   latitude = new( (/nstations/),"double")
   longitude = new( (/nstations/),"double")

   latitude(0) = latedge
   latitude(1:nobs) = klatitude(indz)
   latitude(nstations-1) = latsummit

   longitude(0) = lonedge
   longitude(1:nobs) = klongitude(indz)
   longitude(nstations-1) = lonsummit
   delete([/latitude,longitude/])

   ncdf = addfile("../data/transect/ktransect-elev.nc","r")
   kdist = ncdf->kdist
   delete(ncdf)

   nnpts = dimsizes(kdist)

   data1d = asciiread("../data/transect/vandewal_2012.tab",-1,"string")
   dstart = 27-1
   dfinish = 189-1

   delim = "	"
   stid  = str_get_field(data1d(dstart:dfinish), 1, delim)
   tstart= str_get_field(data1d(dstart:dfinish), 2, delim)
   tend  = str_get_field(data1d(dstart:dfinish), 3, delim)
   smb   = str_get_field(data1d(dstart:dfinish), 4, delim)
   delete(data1d)

   do n = 0,nobs-1
     stind = ind(stid.eq.kstations(n) .and.tend.ge."1979" .and. tend.le."1999" )
     print("nobs: " + dimsizes(stind))
     tsmb = todouble(smb(stind))
     obssmb(n) = dim_avg(tsmb)
     delete([/stind,tsmb/])
   end do
   delete(smb)

   ;;file says units are mm w.e./yr, but they look to me like meters w.e./yr 
   obssmb = obssmb*1000.

else  ;;b-transect

  bstations = (/"B-00-10", \
                "B-0-27", \
                "B-0-31", \
                "B-0-35", \
                "B-0-60-1-0", \
                "B-1-10", \
                "B-1-20", \
                "B-1-30", \
                "B-1-40", \
                "B-1-50", \
                "B-1-60-2-0", \
                "B-2-10", \
                "B-2-20" ,\
                "B-2-30", \
                "B-2-40", \
                "B-2-50", \
                "B-2-60", \
                "B-2-70", \
                "B-2-80", \
                "B-2-90", \
                "B-2-100", \
                "B-2-125", \
                "B-2-150", \
                "B-2-175", \
                "B-2-200", \
                "B-2-225", \
                "B-2-250-4-0"/)

  srcdir = "/glade/work/aherring/livv-smb/processed/"
  srcdat = "SMB_CoreFirnEstimates.csv"

  data1d = asciiread(srcdir+srcdat,-1,"string")
  dstart = 1
  dfinish = 1398

  delim = ","
  bpoint_ID   = str_get_field(data1d(dstart:dfinish), 4, delim)
  blongitudetmp  = str_get_field(data1d(dstart:dfinish), 5, delim)
  blatitudetmp   = str_get_field(data1d(dstart:dfinish), 6, delim)
  belevationtmp  = str_get_field(data1d(dstart:dfinish), 7, delim)
  bsmbtmp        = str_get_field(data1d(dstart:dfinish), 8, delim)

  longitudetmp = todouble(blongitudetmp)
  latitudetmp  = todouble(blatitudetmp)
  elevationtmp = todouble(belevationtmp)
  smbtmp       = todouble(bsmbtmp)
  delete([/blongitudetmp,blatitudetmp,belevationtmp,bsmbtmp/])

  blatedge = 76.417
  blonedge = -69.7
  blatcoast = 76.417
  bloncoast = -68.5

  bnobs = dimsizes(bstations)
  nstations = bnobs+2
  latitude = new( (/nstations/), "double")
  longitude= new( (/nstations/), "double")
  elevation= new( (/nstations/), "double")
  obssmb   = new( (/nstations/), "double")

  do n = 0,bnobs-1
    indx = ind(bpoint_ID.eq.bstations(n))
    latitude(n+2) = latitudetmp(indx)
    longitude(n+2)= longitudetmp(indx)
    elevation(n+2)= elevationtmp(indx)
    obssmb(n+2)   = smbtmp(indx)
    delete(indx)
  end do
  latitude(0) = blatcoast
  latitude(1) = blatedge
  longitude(0) = bloncoast
  longitude(1) = blonedge
  delete([/latitudetmp,longitudetmp,bpoint_ID/])
  delete([/latitude,longitude/])

  ncdf = addfile("../data/transect/btransect-elev.nc","r")
  kdist = ncdf->kdist
  delete(ncdf)

  nnpts = dimsizes(kdist)

end if

;******************************************************
; load transect
;******************************************************

   newz = zvar(m)
   ncdf = addfile("../data/transect/" + fname_in(m),"r")
   smbsims = ncdf->smbsims
   zsims = ncdf->$newz$
   delete(ncdf)
   delete(newz)

;******************************************************
; plot obs
;******************************************************

   resf@gsnXYBarChart            = False
   resf@gsnXYBarChartOutlineOnly = False

   if (m.eq.0) then
     resf@trXMinF = xmin1
     resf@trXMaxF = xmax1
     resf@trYMinF = ymin1
     resf@trYMaxF = ymax1
   else
     resf@trXMinF = xmin2
     resf@trXMaxF = xmax2
     resf@trYMinF = ymin2
     resf@trYMaxF = ymax2
   end if


   resf@tiXAxisString = nams(0)
   resf@tiYAxisString = nams(1)

   resf@xyLineThicknessF = 4
   resf@gsnYRefLine = 0.

   ;zero out non-ice points
   indx = ind(kdist.lt.0.d0)
   smbsims@_FillValue = default_fillvalue("double")
   smbsims(:,indx) = smbsims@_FillValue
   delete(kdist)

   resf@vpWidthF  = 0.45
   resf@vpHeightF = 0.45
   do n = 0,nfiles-1   

     zs = zsims(n,:)
     zs@_FillValue = default_fillvalue("double")
     zs(indx) = zs@_FillValue

     resf@xyMarkLineMode = "Lines"
     resf@xyLineColors = colors(n)
     if (n.eq.0) then
       plot(m) = gsn_csm_xy(wks,zs,smbsims(n,:),resf)
     else
       tmp = gsn_csm_xy(wks,zs,smbsims(n,:),resf)
       overlay(plot(m),tmp)
       delete(tmp)
     end if
   end do
   delete([/smbsims,zsims,zs,indx/])

   resf@xyMarkLineMode = "Markers"
   resf@xyMarker = 16
   resf@xyMarkerThicknessF      = 4
   resf@xyMarkerSizeF          = 8
   resf@xyMarkerColors = "black"

   if (m.eq.0) then
     tmp = gsn_csm_xy(wks,elevation(indz),obssmb(indz),resf)
     overlay(plot(m),tmp)
     delete(tmp)
     delete(indz)
   else
     tmp = gsn_csm_xy(wks,elevation(2:nstations-1),obssmb(2:nstations-1),resf)
     overlay(plot(m),tmp)
     delete(tmp)
   end if
   delete([/elevation,obssmb/])
  

end do

;*****************************************************
; Add icemask
;*****************************************************

  f = addfile("../data/transect/icemask_transect.nc","r")
  imask = tointeger(f->imask)
  lat2d = f->lat2d
  lon2d = f->lon2d
  delete(f)

  imask@lat2d = lat2d
  imask@lon2d = lon2d

  ;************************************************
  ; plotting
  ;************************************************

      res             = True
      res@gsnMaximize = False
      res@gsnDraw     = False      ; Will draw later, after overlaying
      res@gsnFrame    = False      ; all plots

      res@cnFillOn          = True               ; turn on color fill
      res@cnLinesOn         = False
      res@gsnSpreadColors   = True               ; use full range of color map
      res@cnLineLabelsOn       = False
      res@cnInfoLabelOn        = False
      res@lbLabelBarOn         = False

      res@tmBorderThicknessF = 10.

      ;;res@mpOutlineOn          = False    ; turn off continental outline
      ;;res@mpFillOn             = False
      res@mpGridAndLimbOn   = False           ; turn on lat/lon lines
      res@mpGridLatSpacingF = 1.
      res@mpGridLonSpacingF = 1.
      res@mpGridLineColor      = "black"
      res@mpPerimOn         = False               ; turn off perimeter
      res@mpFillOn         = False
      res@mpOutlineBoundarySets     = "NoBoundaries"

      ;;;;--Greenland Projection--
      res@mpProjection = "LambertConformal"
      res@mpLambertParallel1F = 85
      res@mpLambertParallel2F = 58
      res@mpLambertMeridianF  = -45
      res@mpLimitMode       = "LatLon"
      res@mpMinLonF = -56.4
      res@mpMaxLonF = -30.
      res@mpMinLatF = 59.4
      res@mpMaxLatF = 84.
      res@mpPerimOn = True

      res@mpGreatCircleLinesOn=True

  res@cnFillColors         = (/"Blue","tan4"/)
  res@cnLevelSelectionMode = "ExplicitLevels"
  res@cnLevels             = (/0.5/)


  res@vpWidthF  = 0.25
  res@vpHeightF = 0.7
  plot(2) = gsn_csm_contour_map(wks,imask,res)

  ;;imask@lat2d = lat2d
  ;;imask@lon2d = lon2d

;******************************************************
; load k-transect
;******************************************************

   kstations = (/"SHR",     \
                "Site-10", \
                "Site-4",  \
                "Site-5",  \
                "Site-6",  \
                "Site-7",  \
                "Site-8",  \
                "Site-9"/)

   klatitude = (/67.099d0, \
                67.0d000, \
                67.097d0, \
                67.098d0, \
                67.078d0, \
                66.992d0, \
                67.005d0, \
                67.052d0/)

   klongitude= (/-49.936d0, \
                -47.015d0, \
                -50.195d0, \
                -50.084d0, \
                -49.396d0, \
                -49.150d0, \
                -48.876d0, \
                -48.250d0/)

   kelevation= (/710.0d0,  \
                1850.0d0, \
                383.0d0,  \
                490.0d0,  \
                1010.0d0, \
                1110.0d0, \
                1260.0d0, \
                1520.0d0/)

   kdistance = (/14.0d0, \
                143.0d0,\
                3.0d0,  \
                6.0d0,  \
                37.0d0, \
                52.0d0, \
                63.0d0, \
                91.0d0/)

   kobssmb   = (/"",    \
                "",\
                "", \
                "", \
                "", \
                "", \
                "", \
                ""/)

   indz = dim_pqsort(kelevation,1)
   nobs = dimsizes(kelevation)

   latedge =  67.1d0
   lonedge = -54.0d0
   latsummit =  66.725d0
   lonsummit = -43.25d0

   nstations = nobs+2
   latitude = new( (/nstations/),"double")
   longitude = new( (/nstations/),"double")

   latitude(0) = latedge
   latitude(1:nobs) = klatitude(indz)
   latitude(nstations-1) = latsummit

   longitude(0) = lonedge
   longitude(1:nobs) = klongitude(indz)
   longitude(nstations-1) = lonsummit

   npts = (/83,3,4,12,8,7,15,28,85/)
   nnpts = dim_sum(npts)-dimsizes(npts)+1
   klat = new( (/nnpts/), "double")
   klon = new( (/nnpts/), "double")

  ;************************************************
  ; calculate ktransect
  ;************************************************

  now = 0
  do i = 0,nstations-2

    dist = gc_latlon(latitude(i),longitude(i),latitude(i+1),longitude(i+1),npts(i),4)
    ;;print("dx: " + dist@spacing)

    if (i.ne.nstations-2) then
      klat(now:now+npts(i)-2) = dist@gclat(0:npts(i)-2)
      klon(now:now+npts(i)-2) = dist@gclon(0:npts(i)-2)
    else
      klat(now:now+npts(i)-1) = dist@gclat(0:npts(i)-1)
      klon(now:now+npts(i)-1) = dist@gclon(0:npts(i)-1)
    end if

    segment = 0.d0
    do j = 0,npts(i)-2
      now = now + 1
      segment = segment + dist@spacing
    end do

  end do


;******************************************************
; load b-transect
;******************************************************

  bstations = (/"B-00-10", \
                "B-0-27", \
                "B-0-31", \
                "B-0-35", \
                "B-0-60-1-0", \
                "B-1-10", \
                "B-1-20", \
                "B-1-30", \
                "B-1-40", \
                "B-1-50", \
                "B-1-60-2-0", \
                "B-2-10", \
                "B-2-20" ,\
                "B-2-30", \
                "B-2-40", \
                "B-2-50", \
                "B-2-60", \
                "B-2-70", \
                "B-2-80", \
                "B-2-90", \
                "B-2-100", \
                "B-2-125", \
                "B-2-150", \
                "B-2-175", \
                "B-2-200", \
                "B-2-225", \
                "B-2-250-4-0"/)

  srcdir = "/glade/work/aherring/livv-smb/processed/"
  srcdat = "SMB_CoreFirnEstimates.csv"

  data1d = asciiread(srcdir+srcdat,-1,"string")
  dstart = 1
  dfinish = 1398

  delim = ","
  bpoint_ID   = str_get_field(data1d(dstart:dfinish), 4, delim)
  blongitudetmp  = str_get_field(data1d(dstart:dfinish), 5, delim)
  blatitudetmp   = str_get_field(data1d(dstart:dfinish), 6, delim)
  belevationtmp  = str_get_field(data1d(dstart:dfinish), 7, delim)

  longitudetmp = todouble(blongitudetmp)
  latitudetmp  = todouble(blatitudetmp)
  elevationtmp = todouble(belevationtmp)
  delete([/blongitudetmp,blatitudetmp,belevationtmp/])

  blatedge = 76.417
  blonedge = -69.7
  blatcoast = 76.417
  bloncoast = -68.5

  bnobs = dimsizes(bstations)
  bnstations = bnobs+2
  blatitude = new( (/bnstations/), "double")
  blongitude= new( (/bnstations/), "double")
  belevation= new( (/bnstations/), "double")
  do n = 0,bnobs-1
    indx = ind(bpoint_ID.eq.bstations(n))
    ;;print(""+bpoint_ID(indx))
    blatitude(n+2) = latitudetmp(indx)
    ;;print(""+latitudetmp(indx))
    blongitude(n+2)= longitudetmp(indx)
    ;;print(""+longitudetmp(indx))
    belevation(n+2)= elevationtmp(indx)
    delete(indx)
  end do
  blatitude(0) = blatcoast
  blatitude(1) = blatedge
  blongitude(0) = bloncoast
  blongitude(1) = blonedge
  delete([/latitudetmp,longitudetmp,elevationtmp,bpoint_ID/])

  bnpts = (/17,27,13,5,5,18,9,9,8,9,9,10, \
            9,9,9,9,9,9,9,9,5,12, \
            20,21,21,23,21,15/)
  bnnpts = dim_sum(bnpts)-dimsizes(bnpts)+1
  blat = new( (/bnnpts/), "double")
  blon = new( (/bnnpts/), "double")

  ;************************************************
  ; calculate btransect
  ;************************************************

  now = 0
  do i = 0,bnstations-2

    dist = gc_latlon(blatitude(i),blongitude(i),blatitude(i+1),blongitude(i+1),bnpts(i),4)
    print("dx: " + dist@spacing)

    if (i.ne.bnstations-2) then
      blat(now:now+bnpts(i)-2) = dist@gclat(0:bnpts(i)-2)
      blon(now:now+bnpts(i)-2) = dist@gclon(0:bnpts(i)-2)
    else
      blat(now:now+bnpts(i)-1) = dist@gclat(0:bnpts(i)-1)
      blon(now:now+bnpts(i)-1) = dist@gclon(0:bnpts(i)-1)
    end if

    segment = 0.d0
    do j = 0,bnpts(i)-2
      now = now + 1
      segment = segment + dist@spacing
    end do

  end do

  ;************************************************
  ; plot transect
  ;************************************************

  gsres               = True
  gsres@gsMarkerIndex = 16
  gsres@gsMarkerColor      = "magenta"
  gsres@gsMarkerSizeF      = 3
  gsres@gsMarkerThicknessF = 1

  do i = 0,nnpts-1
    tmp = unique_string("tmp")
    plot@$tmp$ = gsn_add_polymarker(wks,plot(2),klon(i),klat(i),gsres)
  end do

  do i = 0,bnnpts-1
    tmp = unique_string("tmp")
    plot@$tmp$ = gsn_add_polymarker(wks,plot(2),blon(i),blat(i),gsres)
  end do

  gsres@gsMarkerColor      = "black"
  gsres@gsMarkerSizeF      = 3
  gsres@gsMarkerThicknessF = 1

  do i = 0,nobs-1
    tmp = unique_string("tmp")
    plot@$tmp$ = gsn_add_polymarker(wks,plot(2),klongitude(indz(i)),klatitude(indz(i)),gsres)
  end do

  tmp = unique_string("tmp")
  plot@$tmp$ = gsn_add_polymarker(wks,plot(2),lonsummit,latsummit,gsres)

  tmp = unique_string("tmp")
  plot@$tmp$ = gsn_add_polymarker(wks,plot(2),lonedge,latedge,gsres)

  do i = 0,bnstations-1
    tmp = unique_string("tmp")
    plot@$tmp$ = gsn_add_polymarker(wks,plot(2),blongitude(i),blatitude(i),gsres)
  end do

;*****************************************************
; Add legend
;*****************************************************
 txres = True
 txres@txFontHeightF = 0.015
 txres@txJust = "CenterLeft"

 plres  = True
 plres@gsLineDashPattern  = 0
 plres@gsLineThicknessF = 6
 
 yy = 0.66
 xx = (/0.15,0.24,0.33,0.47,0.61,0.75/)
 do n = 0,nfiles-1
   plres@gsLineColor = colors(n)
   gsn_polyline_ndc(wks,(/xx(n)-0.04,xx(n)/),(/yy,yy/),plres)
   gsn_text_ndc(wks,label(n),xx(n),yy,txres)
 end do

 pmres = True 
 pmres@gsMarkerIndex = resf@xyMarker
 pmres@gsMarkerSizeF = resf@xyMarkerSizeF
 pmres@gsMarkerThicknessF = resf@xyMarkerThicknessF
 pmres@gsMarkerColor = resf@xyMarkerColors

 ;;gsn_polymarker_ndc(wks,(/xx-0.02,xx-0.02/),(/yy(nfiles),yy(nfiles)/),pmres)
 ;;gsn_text_ndc(wks,"  K-transect",xx,yy(nfiles),txres)

 ;;drawNDCGrid(wks)
;*****************************************************
; Plot panel
;*****************************************************

  resP                  = True                   ; modify the panel plot
  resP@gsnFrame         = False                  ; don't advance panel plot
  ;resP@gsnPaperOrientation = "portrait"
  ;resP@gsnPanelBottom   = 0.05

  resP@gsnPanelFigureStrings = (/"k-transect","b-transect"/)
  resP@gsnPanelFigureStringsFontHeightF = 0.012
  resP@gsnPanelFigureStringsPerimOn     = True
  resP@gsnPanelFigureStringsBackgroundFillColor = "white"
  resP@amJust           = "BottomRight"

  ;resP@gsnPanelTop        = 0.97
  ;resP@gsnPanelBottom     = 0.1
  ;resP@gsnPanelRight     = 0.60;
  resP@gsnPanelLeft     = 0.10        ; position of left most plot

  resP@gsnPanelScalePlotIndex = 0
  ;resP@gsnPanelXWhiteSpacePercent = 0.1

  gsn_panel(wks,plot,(/1,3/),resP)               ; now draw as one plot

frame(wks)

end

