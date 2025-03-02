clear all
set more off

*
* 加载空间权重矩阵数据
use C:\Users\yxie\Research\Publication\Xiaoliang\Detroit_Paper1\Detroit_Wu_data\New_6292024\spatial_weights\block_weights_80.dta, clear
spmat dta W m*, normalize(row)
spmat summarize W
spmat summarize W, links
spmat summarize W, links detail

* 加载面板数据
use C:\Users\yxie\Research\Publication\Xiaoliang\Detroit_Paper1\Detroit_Wu_data\New_6292024\spatial_weights\panel_data.dta, clear
global id NewID
global t Year
global ylist VAC
global xlist EDU UNEM MANU POV OWNC MULS MEDH BTYR YRMV OLD CHILD WATER DEVELI WETLAND AGRI FOREST DEVEMI DEVEOS SHRUB DEVEHI BARREN

* 设置面板数据结构
sort $id $t
xtset $id $t
xtdescribe
xtsum $id $t $ylist $xlist

* Pooled OLS estimator
reg $ylist $xlist
eststo reg_pooled_80
estat ic
eststo ic_pooled_80

* Spatial Durbin Model (SDM)
* SDM with random-effects
xsmle VAC EDU UNEM MANU POV OWNC MULS MEDH BTYR YRMV OLD CHILD WATER DEVELI WETLAND AGRI FOREST DEVEMI DEVEOS SHRUB DEVEHI BARREN, wmat(W) model(sdm) re vce(cluster NewID) nolog
eststo sdm_re_80
estat ic
eststo ic_sdm_re_80

* SDM with spatial fixed-effects
xsmle VAC EDU UNEM MANU POV OWNC MULS MEDH BTYR YRMV OLD CHILD WATER DEVELI WETLAND AGRI FOREST DEVEMI DEVEOS SHRUB DEVEHI BARREN, wmat(W) model(sdm) fe type(ind) vce(cluster NewID) nolog
eststo sdm_fe_80
estat ic
eststo ic_sdm_fe_80

* SDM with spatial fixed-effects (data transformed according to Lee and Yu (2010))
xsmle VAC EDU UNEM MANU POV OWNC MULS MEDH BTYR YRMV OLD CHILD WATER DEVELI WETLAND AGRI FOREST DEVEMI DEVEOS SHRUB DEVEHI BARREN, wmat(W) model(sdm) fe type(ind, leeyu) vce(cluster NewID) nolog
eststo sdm_fe_leeyu_80
estat ic
eststo ic_sdm_fe_leeyu_80

* SDM with time fixed-effects
xsmle VAC EDU UNEM MANU POV OWNC MULS MEDH BTYR YRMV OLD CHILD WATER DEVELI WETLAND AGRI FOREST DEVEMI DEVEOS SHRUB DEVEHI BARREN, wmat(W) model(sdm) fe type(time) vce(cluster NewID) nolog
eststo sdm_fe_time_80
estat ic
eststo ic_sdm_fe_time_80

* SDM with spatial and time fixed-effects
xsmle VAC EDU UNEM MANU POV OWNC MULS MEDH BTYR YRMV OLD CHILD WATER DEVELI WETLAND AGRI FOREST DEVEMI DEVEOS SHRUB DEVEHI BARREN, wmat(W) model(sdm) fe type(both) vce(cluster NewID) nolog
eststo sdm_fe_both_80
estat ic
eststo ic_sdm_fe_both_80

* SDM without direct, indirect and total effects
xsmle VAC EDU UNEM MANU POV OWNC MULS MEDH BTYR YRMV OLD CHILD WATER DEVELI WETLAND AGRI FOREST DEVEMI DEVEOS SHRUB DEVEHI BARREN, wmat(W) model(sdm) noeffects nolog
eststo sdm_noeffects_80
estat ic
eststo ic_sdm_noeffects_80

* Testing the appropriateness of a random-effects variant using the Robust Hausman test
* (example: if Prob>=chi2 = 0.0000 -> p-value lower than one percent -> we strongly reject the null hypothesis -> use fixed-effects)
* SDM Hausman test
xsmle VAC EDU UNEM MANU POV OWNC MULS MEDH BTYR YRMV OLD CHILD WATER DEVELI WETLAND AGRI FOREST DEVEMI DEVEOS SHRUB DEVEHI BARREN, wmat(W) model(sdm) hausman nolog
eststo sdm_hausman_80
