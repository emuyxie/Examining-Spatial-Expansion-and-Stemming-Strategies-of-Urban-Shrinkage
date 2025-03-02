clear all
set more off

* 定义循环的列表
local list 0 1 2 3 4 5

foreach n in `list' {
    * 加载空间权重矩阵数据
    use E:\Programs\Detroit\spatial_weights\weights\w_dta\queen_weights_`n'.dta, clear

    * 确保主对角线为零
    foreach var of varlist m* {
        replace `var' = 0 if _n == _N
    }

    spmat dta W m*, normalize(row)
    spmat summarize W
    spmat summarize W, links
    spmat summarize W, links detail

    * 加载面板数据
    use E:\Programs\Detroit\spatial_weights\panel_data.dta, clear
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
    eststo reg_pooled_`n'
    estat ic
    eststo ic_pooled_`n'

    * Spatial Durbin Model (SDM)
    * SDM with random-effects
    xsmle VAC EDU UNEM MANU POV OWNC MULS MEDH BTYR YRMV OLD CHILD WATER DEVELI WETLAND AGRI FOREST DEVEMI DEVEOS SHRUB DEVEHI BARREN, wmat(W) model(sdm) re vce(cluster NewID) nolog
    eststo sdm_re_`n'
    estat ic
    eststo ic_sdm_re_`n'

    * SDM with spatial fixed-effects
    xsmle VAC EDU UNEM MANU POV OWNC MULS MEDH BTYR YRMV OLD CHILD WATER DEVELI WETLAND AGRI FOREST DEVEMI DEVEOS SHRUB DEVEHI BARREN, wmat(W) model(sdm) fe type(ind) vce(cluster NewID) nolog
    eststo sdm_fe_`n'
    estat ic
    eststo ic_sdm_fe_`n'

    * SDM with spatial fixed-effects (data transformed according to Lee and Yu (2010))
    xsmle VAC EDU UNEM MANU POV OWNC MULS MEDH BTYR YRMV OLD CHILD WATER DEVELI WETLAND AGRI FOREST DEVEMI DEVEOS SHRUB DEVEHI BARREN, wmat(W) model(sdm) fe type(ind, leeyu) vce(cluster NewID) nolog
    eststo sdm_fe_leeyu_`n'
    estat ic
    eststo ic_sdm_fe_leeyu_`n'

    * SDM with time fixed-effects
    xsmle VAC EDU UNEM MANU POV OWNC MULS MEDH BTYR YRMV OLD CHILD WATER DEVELI WETLAND AGRI FOREST DEVEMI DEVEOS SHRUB DEVEHI BARREN, wmat(W) model(sdm) fe type(time) vce(cluster NewID) nolog
    eststo sdm_fe_time_`n'
    estat ic
    eststo ic_sdm_fe_time_`n'

    * SDM with spatial and time fixed-effects
    xsmle VAC EDU UNEM MANU POV OWNC MULS MEDH BTYR YRMV OLD CHILD WATER DEVELI WETLAND AGRI FOREST DEVEMI DEVEOS SHRUB DEVEHI BARREN, wmat(W) model(sdm) fe type(both) vce(cluster NewID) nolog
    eststo sdm_fe_both_`n'
    estat ic
    eststo ic_sdm_fe_both_`n'

    * SDM without direct, indirect and total effects
    xsmle VAC EDU UNEM MANU POV OWNC MULS MEDH BTYR YRMV OLD CHILD WATER DEVELI WETLAND AGRI FOREST DEVEMI DEVEOS SHRUB DEVEHI BARREN, wmat(W) model(sdm) noeffects nolog
    eststo sdm_noeffects_`n'
    estat ic
    eststo ic_sdm_noeffects_`n'

    * Testing the appropriateness of a random-effects variant using the Robust Hausman test
    * (example: if Prob>=chi2 = 0.0000 -> p-value lower than one percent -> we strongly reject the null hypothesis -> use fixed-effects)
    * SDM Hausman test
    xsmle VAC EDU UNEM MANU POV OWNC MULS MEDH BTYR YRMV OLD CHILD WATER DEVELI WETLAND AGRI FOREST DEVEMI DEVEOS SHRUB DEVEHI BARREN, wmat(W) model(sdm) hausman nolog
    eststo sdm_hausman_`n'

    * 导出结果到txt文件
    esttab reg_pooled_`n' ic_pooled_`n' sdm_re_`n' ic_sdm_re_`n' sdm_fe_`n' ic_sdm_fe_`n' sdm_fe_leeyu_`n' ic_sdm_fe_leeyu_`n' sdm_fe_time_`n' ic_sdm_fe_time_`n' sdm_fe_both_`n' ic_sdm_fe_both_`n' sdm_noeffects_`n' ic_sdm_noeffects_`n' sdm_hausman_`n' using "E:\Programs\Detroit\spatial_weights\results_`n'.txt", replace
    spmat drop W
    * 清除过程参数
    clear
}
