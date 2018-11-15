/* --------------------------------
Proyecto: 
JMJR
19 dic de 2017
Tema: Migración Elca (2010-2016)
-----------------------------------*/

clear all 
set more off, permanently 
do "C:\Users\jm.jimenez1385\Dropbox\Paper migracion\do\master_migra"
cd "$data"

*------------------------------------------------------------------------------*
*                               -Pegue Base-                                   *
*------------------------------------------------------------------------------*
{
*-------------
*Pegue RURAL:
*-------------
	use "$Relca16/Rcomunidades_2016.dta", clear
	merge 1:m consecutivo_c using"$Relca16/Rhogar_2016.dta", keep(2 3) nogen
	merge 1:m llave_n16 using "$Relca16/Rpersonas_2016.dta", keep(3) nogen keepus (orden-embarazada con_quien con_quien_orden quien_cuida pcuida_horas tipo_hogar asiste estudia tipo_estab)
	merge 1:1 llaveper_n16 using "$Relca16/Rninos6a16_2016.dta", keep(3) nogen		// 3,409 niños.
	sort llaveper_n16, stable 
	tempfile rola3
	save `rola3', replace 

	use "$Relca13/Rcomunidades_2013.dta", clear
	merge 1:m consecutivo_c using "$Relca13/Rhogar_2013.dta", keep(2 3) nogen
	merge 1:m llave using "$Relca13/Rpersonas_2013.dta", keep(3) nogen keepus(llave_ID_lb llaveper orden novedad_perso pais_nac-seguimiento_2010 con_quien con_quien_orden quien_cuida pcuida_horas)
	rename seguimiento_2010 seguimiento
	merge 1:1 llaveper using "$Relca13/Rninos0a13_2013.dta", keep(3) nogen			// 5,129 niños. _merge==2: 1
	tempfile rola2
	save `rola2', replace 

	*Info. jefe hogar (baseline):
	*-----------------------------
		use "$Relca10/Rhogar_2010.dta", clear
		merge 1:m consecutivo using "$Relca10/Rpersonas_2010.dta", keep(3) nogen 
		keep if parentesco==1
		isid consecutivo
		rename ola-fexpers jefe_=
		rename jefe_consecutivo consecutivo
		tempfile rjinfo
		save `rjinfo', replace  

	use "$Relca10/Rcomunidades_2010.dta", clear
	merge 1:m consecutivo_c using "$Relca10/Rhogar_2010.dta", nogen 
aaaaaaaaaaaaaaaa
*--------------
	use "$Uelca16/Ucomunidades_2016.dta", clear
	merge 1:m consecutivo_c using"$Uelca16/Uhogar_2016.dta", keep(2 3) nogen
	merge 1:m llave_n16 using "$Uelca16/Upersonas_2016.dta", keep(3) nogen keepus (orden-embarazada con_quien con_quien_orden quien_cuida pcuida_horas tipo_hogar asiste estudia tipo_estab)
	merge 1:1 llaveper_n16 using "$Uelca16/Uninos6a16_2016.dta", keep(3) nogen		// 3,409 niños.
	sort llaveper_n16, stable 
	tempfile ola3
	save `ola3', replace 

	use "$Uelca13/Ucomunidades_2013.dta", clear
	merge 1:m consecutivo_c using "$Uelca13/Uhogar_2013.dta", keep(2 3) nogen
	merge 1:m llave using "$Uelca13/Upersonas_2013.dta", keep(3) nogen keepus(llave_ID_lb llaveper orden novedad_perso pais_nac-seguimiento_2010 con_quien con_quien_orden quien_cuida pcuida_horas)
	rename seguimiento_2010 seguimiento
	merge 1:1 llaveper using "$Uelca13/Uninos0a13_2013.dta", keep(3) nogen			// 5,129 niños. _merge==2: 1
	tempfile ola2
	save `ola2', replace 

*--------------
*Pegue TODO:
*--------------

	*Info. jefe hogar (baseline):
	*-----------------------------
		use "$Uelca10/Uhogar_2010.dta", clear
		merge 1:m consecutivo using "$Uelca10/Upersonas_2010.dta", keep(3) nogen 
		keep if parentesco==1
		isid consecutivo
		rename ola-fexpers jefe_=
		rename jefe_consecutivo consecutivo
		tempfile jinfo
		save `jinfo', replace  
		
	use "$Uelca10/Ucomunidades_2010.dta", clear
	merge 1:m consecutivo_c using "$Uelca10/Uhogar_2010.dta", nogen 
	merge 1:m consecutivo using "$Uelca10/Upersonas_2010.dta", keep(3) nogen keepus(orden-parentesco educ_padre educ_madre enfermedad_* depresion_* )
	merge 1:1 llave_ID_lb using "$Uelca10/Uniñosde0a9_2010.dta", keep(3) nogen
	merge m:1 consecutivo using `jinfo', keep(3) nogen 
	append using `ola2' `rural', force 
	sort llave_ID_lb ola, stable 

	bys llave_ID_lb: egen t_ola=sum(ola)
	tab t_ola
	keep if t_ola==3
	sort llave_ID_lb ola, stable

	append using `ola3' `rola3', force 
	drop t_ola
	bys llave_ID_lb: egen t_ola=sum(ola)
	tab t_ola
	sort llave_ID_lb ola, stable
	keep if t_ola==6  												//balanceo el panel en las tres olas.
	replace zona=zona_2016 if ola==3 & zona==.

*-----------------
*Arreglo pruebas:
*-----------------
	gen antro_fecha=mdy(fecham_mes, fecham_dia, fecham_ano)
	gen nac_fecha=mdy(nac_mes, nac_dia, nac_ano)
	gen tvip_fecha=mdy(examen_mes, examen_dia, examen_ano)
	gen sdq_fecha=mdy(mes_sdq, dia_sdq, ano_sdq)
	gen asq_fecha=mdy(mes_asq, dia_asq, ano_asq)
	replace asq_fecha=antro_fecha if asq_fecha==. & puntaje!=.
	replace asq_fecha=tvip_fecha if asq_fecha==. & puntaje!=.

	gen edad_dias_tvip=tvip_fecha-nac_fecha
	gen edad_dias_sdq=sdq_fecha-nac_fecha
	gen edad_dias_asq=asq_fecha-nac_fecha
	gen edad_dias_antro=antro_fecha-nac_fecha

	preserve 
	keep if ola==2
	keep llave_ID_lb llaveper ola puntuaciondirecta edad_dias_tvip puntaje edad_dias_asq
	standardise_s puntuaciondirecta, age(edad_dias_tvip)
	standardise_s puntaje, age(edad_dias_asq)
	save "$data/Z-scores.dta", replace
	restore 

	merge 1:1 llave_ID_lb ola using "$data/Z-scores.dta", keepus(*_z) nogen

	preserve 
	keep if ola==3
	keep llave_ID_lb llaveper_n16 ola puntuaciondirecta tot_dificultades hiperactividad emocional probl_companeros conducta prosocial edad_dias_tvip edad_dias_sdq
	standardise_s puntuaciondirecta, age(edad_dias_tvip)
	standardise_s tot_dificultades hiperactividad emocional probl_companeros conducta prosocial, age(edad_dias_sdq)
	save "$data/Z-scores.dta", replace
	restore 

	merge 1:1 llave_ID_lb ola using "$data/Z-scores.dta", keepus(*_z) nogen update

	rename _zwei-_zwfl month_=
	preserve 
	keep if ola==1
	keep llave_ID_lb ola pesonino talla_cm edad_dias_antro sexo edad_mm
	do "$elca/do\elca_igrowup_restricted.do"
	restore 
	merge 1:1 llave_ID_lb ola using "$elca/WHO\igrowup\elca_z_rc.dta", keepus(_zwei-_fbmi) nogen

	preserve 
	keep if ola==2
	keep llave_ID_lb ola pesonino talla_cm edad_dias_antro sexo edad_mm
	do "$elca/do\elca_igrowup_restricted.do"
	restore 
	merge 1:1 llave_ID_lb ola using "$elca/WHO\igrowup\elca_z_rc.dta", keepus(_zwei-_fbmi) nogen update 

	preserve 
	keep if ola==2
	keep llave_ID_lb ola pesonino talla_cm edad_dias_antro sexo edad_mm
	do "$elca/do\elca_who2007.do"
	restore 
	merge 1:1 llave_ID_lb ola using "$elca/WHO\who2007\elca_z.dta", keepus(_zwfa-_fbfa) nogen
	replace _zwei=_zwfa if _zwei==.
	replace _zlen=_zhfa if _zlen ==.
	replace _zbmi=_zbfa if _zbmi==.
	replace _fwei=_fwfa if _fwei==.
	replace _flen=_fhfa if _flen==.
	replace _fbmi=_fbfa if _fbmi==.

save "migra_vM.dta", replace 
}

*------------------------------------------------------------------------------*
*                               -Vars. de interés-                             *
*------------------------------------------------------------------------------*
*use "migra_vM.dta", clear 
{
*-----------------------------
*MIGRACIÓN:
*-----------------------------
sort llave_ID_lb ola, stable 
gen depmuni=id_dpto*1000+id_mpio

*Migración por zona:
*--------------------
	bys llave_ID_lb: gen zona13=1 if zona!=zona[_n-1] & ola==2
	bys llave_ID_lb: egen m_zona1013=mean(zona13)
	bys llave_ID_lb: gen zona16=1 if zona!=zona[_n-1] & ola==3
	bys llave_ID_lb: egen m_zona1316=mean(zona16)
	bys llave_ID_lb: gen zona10=1 if zona!=zona[_n-2] & ola==3
	bys llave_ID_lb: egen m_zona1016=mean(zona10)

*Migración por municipio:
*-------------------------
	bys llave_ID_lb: gen m_mpio13=1 if depmuni!=depmuni[_n-1] & ola==2
	bys llave_ID_lb: egen m_mpio1013=mean(m_mpio13)
	bys llave_ID_lb: gen m_mpio16=1 if depmuni!=depmuni[_n-1] & ola==3
	bys llave_ID_lb: egen m_mpio1316=mean(m_mpio16)
	bys llave_ID_lb: gen m_mpio10=1 if depmuni!=depmuni[_n-2] & ola==3
	bys llave_ID_lb: egen m_mpio1016=mean(m_mpio10)

*Migración por vereda:
*----------------------
	bys llave_ID_lb: gen m_vereda13=1 if consecutivo_c!=consecutivo_c[_n-1] & ola==2 & consecutivo_c!=. & consecutivo_c[_n-1]!=.
	bys llave_ID_lb: egen m_vereda1013=mean(m_vereda13)
	bys llave_ID_lb: gen m_vereda16=1 if consecutivo_c!=consecutivo_c[_n-1] & ola==3 & consecutivo_c!=. & consecutivo_c[_n-1]!=.
	bys llave_ID_lb: egen m_vereda1316=mean(m_vereda16)
	bys llave_ID_lb: gen m_vereda10=1 if consecutivo_c!=consecutivo_c[_n-2] & ola==3 & consecutivo_c!=. 
	bys llave_ID_lb: egen m_vereda1016=mean(m_vereda10)

*Migración general:
*--------------------
	bys llave_ID_lb: gen m_gene1013=1 if m_zona1013==1 | m_mpio1013==1 | m_vereda1013==1
	bys llave_ID_lb: gen m_gene1316=1 if m_zona1316==1 | m_mpio1316==1 | m_vereda1316==1
	bys llave_ID_lb: gen m_gene1016=1 if m_zona1016==1 | m_mpio1016==1 | m_vereda1016==1

	recode m_zona1013 m_zona1316 m_zona1016 m_mpio1013 m_mpio1316 m_mpio1016  m_gene1013 m_gene1316 m_gene1016 (.=0)

	tab m_zona1013 if ola==2,m
	tab m_zona1316 if ola==3,m
	tab m_zona1016 if ola==3,m

	tab m_mpio1013 if ola==2,m
	tab m_mpio1316 if ola==3,m
	tab m_mpio1016 if ola==3,m

	tab m_gene1013 if ola==2,m
	tab m_gene1316 if ola==3,m
	tab m_gene1016 if ola==3,m

*-----------------------------
*OTRAS:
*-----------------------------
	sort llave_ID_lb ola, stable 
	recode sexo (2=0)
	gen z_tvip=puntuaciondirecta_as_z if abs(puntuaciondirecta_as_z)<=3 & ola==3
	replace z_tvip=puntuaciondirecta_as_z if abs(puntuaciondirecta_as_z)<=3 & ola==2 & edad<10
	gen z_sdq=tot_dificultades_as_z if abs(tot_dificultades_as_z)<=3 & ola==3
	
	local name="jefe"
	foreach n of local name{
		recode `n'_nivel_educ (1=0) (2=0) (4=5) (5 6 7 8 9 10=11) (11 12=16), g(`n'_educ_years)
		replace `n'_educ_years=`n'_educ_years+`n'_grado_educ if `n'_nivel_educ!=4 & `n'_nivel_educ!=. & `n'_grado_educ!=.
		replace `n'_educ_years=`n'_educ_years+`n'_grado_educ-5 if `n'_nivel_educ==4 & `n'_grado_educ!=. & `n'_grado_educ!=.
		tempvar x
		recode `n'_nivel_educ_cursa (1=0) (2=0) (3=5) (4 5 6=11) (7=16), g(`x')
		replace `n'_educ_years=`x'+`n'_grado_educ_cursa-1 if `n'_nivel_educ_cursa!=3 & `n'_nivel_educ_cursa!=. & `n'_educ_years==. & `n'_grado_educ_cursa!=.
		replace `n'_educ_years=`x'+`n'_grado_educ_cursa-6 if `n'_nivel_educ_cursa==3 & `n'_nivel_educ_cursa!=. & `n'_educ_years==. & `n'_grado_educ_cursa!=.
		replace `n'_educ_years=. if ola!=1
		la var `n'_educ_years "Años de educación de `n'"
	}
	
	bys llave_ID_lb: replace jefe_educ_years=jefe_educ_years[_n-2] if ola==3  

	#d ;	
	local HW ="material_pisos material_paredes sp_estrato sp_gasnatural sp_acueducto 
	sp_alcantarillado sp_recoleccion_basura t_hogares tenencia_vivienda n_neveras 
	n_lavadoras	n_internet motocicletas automoviles lotes casas";
	#d cr
	factor `HW' if ola==1, mine(1) fa(1)
	rotate, obliq oblimi
	predict HW_ola1 if ola==1 
	bys llave_ID_lb: replace HW_ola1= HW_ola1[_n-1] if ola==2 
	
	factor `HW' if ola==2, mine(1) fa(1)
	rotate, obliq oblimi
	predict HW_ola2 if ola==2 
	bys llave_ID_lb: replace HW_ola2= HW_ola2[_n-1] if ola==3
		
	local CD="_zwei _zlen _zbmi _zwfl"
	foreach var of local CD{
		sum `var' if ola==2 
		local mean=r(mean)
		gen flag_`var'=1 if `var'==. & ola==2 
		replace `var'=`mean' if `var'==. & ola==2
	}

	replace _zwei=. if _fwei==1 & ola==2
	replace _zwfl=. if _fwfl==1 & ola==2
	replace _zlen=. if _flen==1 & ola==2  
	replace _zbmi=. if _fbmi==1 & ola==2

	local CD="_zwei _zlen _zbmi _zwfl"
	foreach var of local CD{
		bys llave_ID_lb: gen `var'_ola1=`var'[_n-1] if ola==2  
		bys llave_ID_lb: gen `var'_ola2=`var'[_n-1] if ola==3  
	}

	sum puntuaciondirecta_as_z if ola==2
	local mean=r(mean)
	replace puntuaciondirecta_as_z=`mean' if puntuaciondirecta_as_z==. & ola==2 
	bys llave_ID_lb: gen tvip_ola2=puntuaciondirecta_as_z[_n-1] if ola==3  
	bys llave_ID_lb: gen asq_ola2=puntaje_as_z[_n-1] if ola==3  

	la var puntuaciondirecta_as_z "TVIP-zscore"
	la var tot_dificultades_as_z "SDQ-zscore"
	
save "migra_vM.dta", replace 
}

*-------------------------------------------------------------------------------
*								-	MCO  -
*-------------------------------------------------------------------------------

	*Importantes:
	*-------------
		reg z_tvip m_mpio1316 tvip_ola2 asq_ola2 _zwei_ola2 _zlen_ola2 _zbmi_ola2 _zwfl_ola2 jefe_educ_years HW_ola2 edad sexo if ola==3, r
		reg z_sdq m_mpio1316 tvip_ola2 asq_ola2 _zwei_ola2 _zlen_ola2 _zbmi_ola2 _zwfl_ola2 edad sexo jefe_educ_years HW_ola2 if ola==3, r

		reg hiperactividad_as_z m_mpio1316 asq_ola2 tvip_ola2 _zwei_ola2 _zlen_ola2 _zbmi_ola2 _zwfl_ola2 jefe_educ_years HW_ola2 edad sexo if ola==3, r
		reg emocional_as_z m_mpio1316 asq_ola2 tvip_ola2 _zwei_ola2 _zlen_ola2 _zbmi_ola2 _zwfl_ola2 jefe_educ_years HW_ola2 edad sexo if ola==3, r
		reg probl_companeros_as_z m_mpio1316 asq_ola2 tvip_ola2 _zwei_ola2 _zlen_ola2 _zbmi_ola2 _zwfl_ola2 jefe_educ_years HW_ola2 edad sexo if ola==3, r
		reg conducta_as_z m_mpio1316 asq_ola2 tvip_ola2 _zwei_ola2 _zlen_ola2 _zbmi_ola2 _zwfl_ola2 jefe_educ_years HW_ola2 edad sexo if ola==3, r
		reg prosocial_as_z m_mpio1316 asq_ola2 tvip_ola2 _zwei_ola2 _zlen_ola2 _zbmi_ola2 _zwfl_ola2 jefe_educ_years HW_ola2 edad sexo if ola==3, r

		reg z_tvip m_mpio1316 tvip_ola2 _zwei_ola2 _zlen_ola2 _zbmi_ola2 _zwfl_ola2 jefe_educ_years HW_ola2 edad sexo if ola==3, r
		reg z_sdq m_mpio1316 tvip_ola2 _zwei_ola2 _zlen_ola2 _zbmi_ola2 _zwfl_ola2 edad sexo jefe_educ_years HW_ola2 if ola==3, r

		reg hiperactividad_as_z m_mpio1316 tvip_ola2 _zwei_ola2 _zlen_ola2 _zbmi_ola2 _zwfl_ola2 jefe_educ_years HW_ola2 edad sexo if ola==3, r
		reg emocional_as_z m_mpio1316 tvip_ola2 _zwei_ola2 _zlen_ola2 _zbmi_ola2 _zwfl_ola2 jefe_educ_years HW_ola2 edad sexo if ola==3, r
		reg probl_companeros_as_z m_mpio1316 tvip_ola2 _zwei_ola2 _zlen_ola2 _zbmi_ola2 _zwfl_ola2 jefe_educ_years HW_ola2 edad sexo if ola==3, r
		reg conducta_as_z m_mpio1316 tvip_ola2 _zwei_ola2 _zlen_ola2 _zbmi_ola2 _zwfl_ola2 jefe_educ_years HW_ola2 edad sexo if ola==3, r
		reg prosocial_as_z m_mpio1316 tvip_ola2 _zwei_ola2 _zlen_ola2 _zbmi_ola2 _zwfl_ola2 jefe_educ_years HW_ola2 edad sexo if ola==3, r

	*Importantes (1v):
	*------------------
		reg tot_dificultades_as_z m_gene1016 if ola==3 & edad<12, r
		reg tot_dificultades_as_z m_gene1316 if ola==3 & edad<12, r
		reg puntaje_as_z m_gene1013 if ola==2, r

		reg puntuaciondirecta_as_z m_gene1016 if ola==3 & edad<12, r
		reg puntuaciondirecta_as_z m_gene1316 if ola==3 & edad<12, r
		reg puntuaciondirecta_as_z m_gene1013 if ola==2 & edad<9, r

		reg z_tvip m_gene1016 tvip_ola2 asq_ola2 _zwei_ola2 _zlen_ola2 _zbmi_ola2 _zwfl_ola2 jefe_educ_years HW_ola2 edad sexo if ola==3, r 	//<---Cambiar los controles a LB.
		reg z_sdq m_gene1016 tvip_ola2 asq_ola2 _zwei_ola2 _zlen_ola2 _zbmi_ola2 _zwfl_ola2 edad sexo jefe_educ_years HW_ola2 if ola==3, r 		//<---Cambiar los controles a LB.

		reg z_tvip m_gene1316 tvip_ola2 asq_ola2 _zwei_ola2 _zlen_ola2 _zbmi_ola2 _zwfl_ola2 jefe_educ_years HW_ola2 edad sexo if ola==3, r
		reg z_sdq m_gene1316 tvip_ola2 asq_ola2 _zwei_ola2 _zlen_ola2 _zbmi_ola2 _zwfl_ola2 edad sexo jefe_educ_years HW_ola2 if ola==3, r

		reg hiperactividad_as_z m_gene1316 asq_ola2 tvip_ola2 _zwei_ola2 _zlen_ola2 _zbmi_ola2 _zwfl_ola2 jefe_educ_years HW_ola2 edad sexo if ola==3, r
		reg emocional_as_z m_gene1316 asq_ola2 tvip_ola2 _zwei_ola2 _zlen_ola2 _zbmi_ola2 _zwfl_ola2 jefe_educ_years HW_ola2 edad sexo if ola==3, r
		reg probl_companeros_as_z m_gene1316 asq_ola2 tvip_ola2 _zwei_ola2 _zlen_ola2 _zbmi_ola2 _zwfl_ola2 jefe_educ_years HW_ola2 edad sexo if ola==3, r
		reg conducta_as_z m_gene1316 asq_ola2 tvip_ola2 _zwei_ola2 _zlen_ola2 _zbmi_ola2 _zwfl_ola2 jefe_educ_years HW_ola2 edad sexo if ola==3, r
		reg prosocial_as_z m_gene1316 asq_ola2 tvip_ola2 _zwei_ola2 _zlen_ola2 _zbmi_ola2 _zwfl_ola2 jefe_educ_years HW_ola2 edad sexo if ola==3, r

		reg z_tvip m_gene1316 tvip_ola2 _zwei_ola2 _zlen_ola2 _zbmi_ola2 _zwfl_ola2 jefe_educ_years HW_ola2 edad sexo if ola==3, r
		reg z_sdq m_gene1316 tvip_ola2 _zwei_ola2 _zlen_ola2 _zbmi_ola2 _zwfl_ola2 edad sexo jefe_educ_years HW_ola2 if ola==3, r
		reg z_sdq m_gene1316 asq_ola2 _zwei_ola2 _zlen_ola2 _zbmi_ola2 _zwfl_ola2 edad sexo jefe_educ_years HW_ola2 if ola==3, r

		reg hiperactividad_as_z m_gene1316 tvip_ola2 _zwei_ola2 _zlen_ola2 _zbmi_ola2 _zwfl_ola2 jefe_educ_years HW_ola2 edad sexo if ola==3, r
		reg emocional_as_z m_gene1316 tvip_ola2 _zwei_ola2 _zlen_ola2 _zbmi_ola2 _zwfl_ola2 jefe_educ_years HW_ola2 edad sexo if ola==3, r
		reg probl_companeros_as_z m_gene1316 tvip_ola2 _zwei_ola2 _zlen_ola2 _zbmi_ola2 _zwfl_ola2 jefe_educ_years HW_ola2 edad sexo if ola==3, r
		reg conducta_as_z m_gene1316 tvip_ola2 _zwei_ola2 _zlen_ola2 _zbmi_ola2 _zwfl_ola2 jefe_educ_years HW_ola2 edad sexo if ola==3, r
		reg prosocial_as_z m_gene1316 tvip_ola2 _zwei_ola2 _zlen_ola2 _zbmi_ola2 _zwfl_ola2 jefe_educ_years HW_ola2 edad sexo if ola==3, r


	*OTRAS COSAS:
	*-------------
		{
		/*
		xls_reg puntuaciondirecta_as_z m_mpio1016 if ola==3, file("migra") cell(1) sh("MCO")
		xls_reg puntuaciondirecta_as_z m_mpio1316 if ola==3, file("migra") cell(8) sh("MCO")
		xls_reg tot_dificultades_as_z m_mpio1016 if ola==3, file("migra") cell(16) sh("MCO")
		xls_reg tot_dificultades_as_z m_mpio1316 if ola==3, file("migra") cell(24) sh("MCO")

		xls_reg puntuaciondirecta_as_z m_mpio1016 if ola==3 & edad<12, file("migra") cell(40) sh("MCO")
		xls_reg puntuaciondirecta_as_z m_mpio1316 if ola==3 & edad<12, file("migra") cell(48) sh("MCO")
		xls_reg tot_dificultades_as_z m_mpio1016 if ola==3 & edad<12, file("migra") cell(54) sh("MCO")
		xls_reg tot_dificultades_as_z m_mpio1316 if ola==3 & edad<12, file("migra") cell(62) sh("MCO")

		xls_reg tot_dificultades_as_z m_gene1016 if ola==3, file("migra") cell(80) sh("MCO")
		xls_reg tot_dificultades_as_z m_gene1316 if ola==3, file("migra") cell(88) sh("MCO")
		xls_reg puntuaciondirecta_as_z m_gene1016 if ola==3, file("migra") cell(96) sh("MCO")
		xls_reg puntuaciondirecta_as_z m_gene1316 if ola==3, file("migra") cell(104) sh("MCO")

		xls_reg tot_dificultades_as_z m_gene1016 if ola==3 & edad<12, file("migra") cell(120) sh("MCO")
		xls_reg tot_dificultades_as_z m_gene1316 if ola==3 & edad<12, file("migra") cell(128) sh("MCO")
		xls_reg puntuaciondirecta_as_z m_gene1016 if ola==3 & edad<12, file("migra") cell(136) sh("MCO")
		xls_reg puntuaciondirecta_as_z m_gene1316 if ola==3 & edad<12, file("migra") cell(144) sh("MCO")
		
		hist puntuaciondirecta_as_z if ola==3
		hist tot_dificultades_as_z if ola==3

		reg puntuaciondirecta_as_z m_mpio1316 tvip_ola2 _zwei _zlen _zbmi _zwfl if ola==3
		reg tot_dificultades_as_z m_mpio1316 _zwei _zlen _zbmi _zwfl if ola==3

		tabstat pesonino _zwei talla_cm _zlen _zbmi edad_dias_antro, by(ola) s(mean N)
		tabstat pesonino _zwei talla_cm _zlen _zbmi edad_dias_antro if ola==2, by(edad) s(mean N)

		reg z_tvip m_mpio1316 tvip_ola2 _zwei_ola2 _zlen_ola2 _zbmi_ola2 _zwfl_ola2 edad sexo if ola==3, r
		reg z_tvip m_mpio1316 asq_ola2 _zwei_ola2 _zlen_ola2 _zbmi_ola2 _zwfl_ola2 edad sexo if ola==3, r
		reg z_tvip m_mpio1316 tvip_ola2 asq_ola2 _zwei_ola2 _zlen_ola2 _zbmi_ola2 _zwfl_ola2 edad sexo if ola==3, r

		reg z_sdq m_mpio1316 tvip_ola2 _zwei_ola2 _zlen_ola2 _zbmi_ola2 _zwfl_ola2 edad sexo if ola==3, r
		reg z_sdq m_mpio1316 asq_ola2 _zwei_ola2 _zlen_ola2 _zbmi_ola2 _zwfl_ola2 edad sexo if ola==3, r
		reg z_sdq m_mpio1316 tvip_ola2 asq_ola2 _zwei_ola2 _zlen_ola2 _zbmi_ola2 _zwfl_ola2 edad sexo if ola==3, r

		reg hiperactividad_as_z m_mpio1316 asq_ola2 tvip_ola2 _zwei_ola2 _zlen_ola2 _zbmi_ola2 _zwfl_ola2 edad sexo if ola==3, r
		reg emocional_as_z m_mpio1316 asq_ola2 tvip_ola2 _zwei_ola2 _zlen_ola2 _zbmi_ola2 _zwfl_ola2 edad sexo if ola==3, r
		reg probl_companeros_as_z m_mpio1316 asq_ola2 tvip_ola2 _zwei_ola2 _zlen_ola2 _zbmi_ola2 _zwfl_ola2 edad sexo if ola==3, r
		reg conducta_as_z m_mpio1316 asq_ola2 tvip_ola2 _zwei_ola2 _zlen_ola2 _zbmi_ola2 _zwfl_ola2 edad sexo if ola==3, r
		reg prosocial_as_z m_mpio1316 asq_ola2 tvip_ola2 _zwei_ola2 _zlen_ola2 _zbmi_ola2 _zwfl_ola2 edad sexo if ola==3, r

		*NO funcionó:
		*-------------
		teffects psmatch (z_sdq) (m_mpio1316 tvip_ola2 _zwei_ola2 _zlen_ola2 _zbmi_ola2 _zwfl_ola2 jefe_educ_years HW_ola2 edad sexo) if ola==3, ///
		osample(nosc_sdq) vce(robust) nn(3)

		*Migración hogares con niños:
		*-----------------------------
		preserve
			egen no_hogares=group(consecutivo) if ola==1
			bys consecutivo ola: gen n_kid=_n
			sort consecutivo ola, stable
			keep if n_kid==1
			
			tab m_zona1013 if ola==2,m
			tab m_zona1316 if ola==3,m
			tab m_zona1016 if ola==3,m

			tab m_mpio1013 if ola==2,m
			tab m_mpio1316 if ola==3,m
			tab m_mpio1016 if ola==3,m

			tab m_gene1013 if ola==2,m
			tab m_gene1316 if ola==3,m
			tab m_gene1016 if ola==3,m

		restore
		*/
		}

*-------------------------------------------------------------------------------
*         -		IV: z=distancia a la cabecera municipal más cercana   -
*-------------------------------------------------------------------------------
	merge m:1 llave ola using "ola2_migra_cabecera_out.dta", keep(1 3) nogen 
	merge m:1 llave ola using "Rola2_migra_cabecera_out.dta", update keep(1 3 4 5) nogen
	
	sort llave_ID_lb ola, stable 
	
	bys llave_ID_lb: replace near_distm=near_distm[_n-1] if ola==3  
	bys llave_ID_lb: replace near_distkm=near_distkm[_n-1] if ola==3  

	tabstat near_distm near_distkm, by(ola)
	
	*Estimaciones:
	*--------------
	reg z_tvip m_gene1316 _zwei_ola2 _zlen_ola2 _zbmi_ola2 _zwfl_ola2 jefe_educ_years HW_ola2 edad sexo if ola==3
	reg z_sdq m_gene1316 _zwei_ola2 _zlen_ola2 _zbmi_ola2 _zwfl_ola2 edad sexo jefe_educ_years HW_ola2 if ola==3
	
	ivreg2 z_tvip (m_gene1316=near_distkm) _zwei_ola2 _zlen_ola2 _zbmi_ola2 _zwfl_ola2 jefe_educ_years HW_ola2 edad sexo if ola==3, r first
	ivreg2 z_sdq (m_gene1316=near_distkm) _zwei_ola2 _zlen_ola2 _zbmi_ola2 _zwfl_ola2 edad sexo jefe_educ_years HW_ola2 if ola==3, r first 
	
	ivreg2 z_tvip (m_gene1316=near_distkm) tvip_ola2 _zwei_ola2 _zlen_ola2 _zbmi_ola2 _zwfl_ola2 jefe_educ_years HW_ola2 edad sexo if ola==3, r first
	
	ivreg2 z_sdq (m_gene1316=near_distkm) tvip_ola2 _zwei_ola2 _zlen_ola2 _zbmi_ola2 _zwfl_ola2 edad sexo jefe_educ_years HW_ola2 if ola==3, r first 
	ivreg2 hiperactividad_as_z (m_gene1316=near_distkm) tvip_ola2 _zwei_ola2 _zlen_ola2 _zbmi_ola2 _zwfl_ola2 edad sexo jefe_educ_years HW_ola2 if ola==3, r 
	ivreg2 emocional_as_z (m_gene1316=near_distkm) tvip_ola2 _zwei_ola2 _zlen_ola2 _zbmi_ola2 _zwfl_ola2 edad sexo jefe_educ_years HW_ola2 if ola==3, r 
	ivreg2 probl_companeros_as_z (m_gene1316=near_distkm) tvip_ola2 _zwei_ola2 _zlen_ola2 _zbmi_ola2 _zwfl_ola2 edad sexo jefe_educ_years HW_ola2 if ola==3, r 
	ivreg2 conducta_as_z (m_gene1316=near_distkm) tvip_ola2 _zwei_ola2 _zlen_ola2 _zbmi_ola2 _zwfl_ola2 edad sexo jefe_educ_years HW_ola2 if ola==3, r 
	ivreg2 prosocial_as_z (m_gene1316=near_distkm) tvip_ola2 _zwei_ola2 _zlen_ola2 _zbmi_ola2 _zwfl_ola2 edad sexo jefe_educ_years HW_ola2 if ola==3, r 
				
*-------------------------------------------------------------------------------
*        		 -	Distancia de la migración ("Duración")  -
*-------------------------------------------------------------------------------
	merge m:1 llave ola using "ola23_dist_migra", keep(1 3) nogen 
	
	tabstat dist_migra, by(m_gene1316) s(N mean sd median min max)
	gen dist_m=dist_migra if m_gene1316==1
	replace dist_m=0 if m_gene1316==0											//<----No sé....(¿Juanete?)
	
	reg z_tvip dist_m tvip_ola2 asq_ola2 _zwei_ola2 _zlen_ola2 _zbmi_ola2 _zwfl_ola2 jefe_educ_years HW_ola2 edad sexo if ola==3
	
	reg z_tvip m_gene1316 tvip_ola2 asq_ola2 _zwei_ola2 _zlen_ola2 _zbmi_ola2 _zwfl_ola2 jefe_educ_years HW_ola2 edad sexo if ola==3
	
	tabstat dist_m, by(m_gene1316) s(N mean sd median min max)
	
	reg z_tvip dist_m _zwei_ola2 _zlen_ola2 _zbmi_ola2 _zwfl_ola2 jefe_educ_years HW_ola2 edad sexo if ola==3
	reg z_tvip dist_m tvip_ola2 _zwei_ola2 _zlen_ola2 _zbmi_ola2 _zwfl_ola2 jefe_educ_years HW_ola2 edad sexo if ola==3
	reg z_tvip dist_m tvip_ola2 asq_ola2 _zwei_ola2 _zlen_ola2 _zbmi_ola2 _zwfl_ola2 jefe_educ_years HW_ola2 edad sexo if ola==3
	
	reg z_sdq dist_m _zwei_ola2 _zlen_ola2 _zbmi_ola2 _zwfl_ola2 edad sexo jefe_educ_years HW_ola2 if ola==3, r 	
	reg z_sdq dist_m asq_ola2 _zwei_ola2 _zlen_ola2 _zbmi_ola2 _zwfl_ola2 edad sexo jefe_educ_years HW_ola2 if ola==3, r 	
	reg z_sdq dist_m tvip_ola2 asq_ola2 _zwei_ola2 _zlen_ola2 _zbmi_ola2 _zwfl_ola2 edad sexo jefe_educ_years HW_ola2 if ola==3, r 	
	reg z_sdq dist_m tvip_ola2 _zwei_ola2 _zlen_ola2 _zbmi_ola2 _zwfl_ola2 edad sexo jefe_educ_years HW_ola2 if ola==3, r 	
	
	
	reg z_tvip i.m_gene1316##c.dist_m tvip_ola2 asq_ola2 _zwei_ola2 _zlen_ola2 _zbmi_ola2 _zwfl_ola2 jefe_educ_years HW_ola2 edad sexo if ola==3

	
	hist dist_migra if m_gene1316==0, percent
	hist dist_migra if m_gene1316==0 & dist_migra>10, percent
	
	
	
	
	
	sum dist_migra, d
	gen median_dist_migra=(dist_migra>` r(p50)')
	
	hist dist_m
	hist dist_m if dist_m>50 
	
	sum dist_m, d
	gen median_dist_m=(dist_m>r(p50))
	replace median_dist_m=0 if m_gene1316==0 & median_dist_m==1
	
	tab median_dist_m m_gene1316 if ola==3
	
	reg z_tvip i.m_gene1316##c.dist_m tvip_ola2 asq_ola2 _zwei_ola2 _zlen_ola2 _zbmi_ola2 _zwfl_ola2 jefe_educ_years HW_ola2 edad sexo if ola==3
	
	reg z_tvip i.m_gene1316##i.median_dist_m tvip_ola2 asq_ola2 _zwei_ola2 _zlen_ola2 _zbmi_ola2 _zwfl_ola2 jefe_educ_years HW_ola2 edad sexo if ola==3
	
	

save "migra_all", replace 				// <----------Juanete!!! esta es la base con todos los pegues. 
	
 
tab m_gene1316 if ola==3
tab con_quien m_gene1316 if ola==3, col 
tab quien_cuida m_gene1316 if ola==3, col 

tab quien_lee m_gene1316 if ola==3, col 
tab conversa_clases m_gene1316 if ola==3, col


reg _zbmi m_gene1316 _zwei_ola2 _zlen_ola2 _zbmi_ola2 _zwfl_ola2 jefe_educ_years HW_ola2 edad sexo if ola==3



gen near_distkm_sqr=near_distkm^2
ivreg2 z_tvip (m_mpio1316=near_distkm near_distkm_sqr) tvip_ola2 _zwei_ola2 _zlen_ola2 _zbmi_ola2 _zwfl_ola2 jefe_educ_years HW_ola2 edad sexo if ola==3, first cluster(llave)
tab m_mpio1316 if e(sample)==1
ivreg2 z_sdq (m_mpio1316=near_distkm near_distkm_sqr) asq_ola2 _zwei_ola2 _zlen_ola2 _zbmi_ola2 _zwfl_ola2 jefe_educ_years HW_ola2 edad sexo if ola==3, first cluster(llave)
tab m_mpio1316 if e(sample)==1

sum dist_migra if m_mpio1316==1, detail

