<%--
  Created by IntelliJ IDEA.
  User: Administrator
  Date: 2016/12/7
  Time: 13:55
  To change this template use File | Settings | File Templates.
--%>
<%@ page language="java" import="java.util.*" pageEncoding="UTF-8"%>
<%@include file="/layout/initpage.jsp" %>
<!-- 金融市民卡发卡量统计-->
<style>
    .datagrid-header-row{
        height:23px;
    }
</style>
<script type="text/javascript">
    var $grid;
    var isExt;
    var sumBdXfk = 0;
    var sumBdHfk = 0;
    var sumWbXfk = 0;
    var sumWbHfk = 0;
    var sumTotNum = 0;
    $(function(){
    	$("#dia").dialog({
    		title:"发卡明细",
    		fit:true,
    		closed:true,
    		collapsible:true,
    		border:false,
    		modal:true,
    		onBeforeOpen:function(){
    			var selections = $("#dg").datagrid("getSelections");
    			if(!selections || selections.length != 1){
    				jAlert("请选择一条记录", "warning");
    				return false;
    			}
    			var params = getformdata("searchConts");
    			params["queryType"] = true;
    			params["bankId"] = selections[0].BANK_ID;
    			params["branchId"] = selections[0].RECV_BRCH_ID;
    			$("#dg2").datagrid("load", params);
    		}
    	});
    	
    	$("#dg2").datagrid({
            url:"statistical/statisticalAnalysisAction!jrsbkFkDetailQuery.action",
            pagination:true,
            rownumbers:true,
            border:false,
            striped:true,
            fitColumns:true,
            fit:true,
            singleSelect:false,
            pageList:[100, 200, 500, 1000, 2000],
            scrollbarSize:0,
            autoRowHeight:true,
            toolbar:[{
				text:'导出',
				iconCls:'icon-export',
				handler:function(){
					exportDetailInfo();
				}
			}],
            columns:[[
            	{field:"APPLY_ID",title:"申领编号",align:"center",sortable:true,width:1},
               	{field:"NAME",title:"姓名",align:"center",sortable:true,width:1},
               	{field:"CERT_NO",title:"证件号码",align:"center",sortable:true,width:1.5},
               	{field:"CARD_NO",title:"卡号",align:"center",sortable:true,width:1.7},
               	{field:"APPLY_STATE",title:"申领状态",align:"center",sortable:true,width:1},
             	{field:"BANK_ID",title:"银行编号",align:"center",sortable:true,width:1.2},
              	{field:"BANK_NAME",title:"银行名称",align:"center",sortable:true,width:1.2},
              	{field:"RECV_BRCH_ID",title:"领卡网点编号",align:"center",sortable:true,width:1},
              	{field:"RECV_BRCH_NAME",title:"领卡网点",align:"center",sortable:true,width:1.2},
               	{field:"CARD_TYPE",title:"发卡类型",align:"center",sortable:true,width:1, formatter:function(v, r, i){
               		var cardType = "";
               		if(r.IS_URGENT == "1") {
               			cardType += "外包";
               		} else {
               			cardType += "本地";
               		}
               		if(r.APPLY_TYPE == "0") {
               			if(r.IS_BATCH_HF == "1") {
	               			cardType += "新发卡";
               			} else {
               				cardType += "换发卡";
               			}
               		} else {
               			cardType += "换发卡";
               		}
               		return cardType;
               	}}
         	]],
            onBeforeLoad:function(param){
            	if(!param.queryType){
            		return false;
            	}
            	return true;
            },
            onLoadSuccess:function(data){
                if(dealNull(data["status"]) != 0){
                    $.messager.alert("系统消息",data.errMsg,"warning");
                }
            }});
    	
    	$("#applyState").combobox({
    		textField:"text",
    		valueField:"value",
    		editable:false,
    		panelHeight:"auto",
    		value:"00",
    		data:[
    			{text:"制卡中", value:"00"},
    			{text:"已发放", value:"60"}
    		]
    	});
    	
        if("${defaultErrMsg}" != ""){
            $.messager.alert("系统消息","${defaultErrMsg}","error");
        }
        $("#synGroupIdTip").tooltip({
            position:"left",
            content:"<span style='color:#B94A48'>是否级联下级网点</span>"
        });
        $(".Wdate").tooltip({
            content:"<span style='color:#B94A48'>本地，任务生成日期</span><br><span style='color:#B94A48'>外包，银行审核返回导入日期</span>"
        });
        $("#cascadeBrch").switchbutton({
            width:"50px",
            value:"false",
            checked:false,
            onText:"是",
            offText:"否"
        });
        createCustomSelect({
            id:"bankId",
            value:"bank_id",
            text:"bank_name",
            table:"Base_Bank",
            where:"bank_state = '0'",
            isShowDefaultOption:true,
            orderby:"bank_id asc",
            from:1,
            to:30,
            onSelect:function(r){
                $("#branchId").combotree('clear');
                $("#branchId").combotree("reload","commAction!findAllRecvBranch.action?bankId=" + r.VALUE);
            }
        });
        createRecvBranch({
            id:"branchId"
        });
        var myview = $.extend({}, $.fn.datagrid.defaults.view, {
            renderFooter: function(target, container, frozen){
                var opts = $.data(target, 'datagrid').options;
                var rows = $.data(target, 'datagrid').footer || [];
                var fields = $(target).datagrid('getColumnFields', frozen);
                var table = ['<table class="datagrid-ftable" cellspacing="0" cellpadding="0" border="0"><tbody>'];
                for(var i=0; i<rows.length; i++){
                    var styleValue = opts.rowStyler ? opts.rowStyler.call(target, i, rows[i]) : '';
                    var style = styleValue ? 'style="' + styleValue + '"' : '';
                    table.push('<tr class="datagrid-row" datagrid-row-index="' + i + '"' + style + '>');
                    table.push(this.renderRow.call(this, target, fields, frozen, i, rows[i]));
                    table.push('</tr>');
                }
                table.push('</tbody></table>');
                $(container).html(table.join(''));
            }
        });
        $grid = createDataGrid({
            id:"dg",
            url:"statistical/statisticalAnalysisAction!jrsbkFkStat2.action",
            pagination:true,
            rownumbers:true,
            border:false,
            striped:true,
            fitColumns:true,
            fit:true,
            singleSelect:false,
            pageList:[100, 200, 500, 1000, 2000],
            scrollbarSize:0,
            autoRowHeight:true,
            view:myview,
            showFooter:true,
            columns:[[
              	{field:"V_V",rowspan:2,checkbox:true},
               	{title:"银行信息",colspan:2,sortable:true},
               	{title:"网点信息",colspan:2,sortable:true},
               	{title:"本地",colspan:3,align:"center"},
               	{title:"外包",colspan:3,align:"center"},
               	{field:"TOT_NUM",title:"总计",rowspan:2, sortable:true, align:"center",width:parseInt($(this).width() * 0.04)}
           	], [
             	{field:"BANK_ID",title:"银行编号",align:"center",sortable:true,width:parseInt($(this).width() * 0.06)},
               	{field:"BANK_NAME",title:"银行名称",align:"center",sortable:true,width:parseInt($(this).width() * 0.06)},
               	{field:"RECV_BRCH_ID",title:"网点编号",align:"center",sortable:true,width:parseInt($(this).width() * 0.04)},
               	{field:"RECV_BRCH_NAME",title:"网点名称",align:"center",sortable:true,width:parseInt($(this).width() * 0.1)},
               	{field:"BD_XFK",title:"新发卡",align:"center",sortable:true,width:parseInt($(this).width() * 0.03)},
              	{field:"BD_HFK",title:"换发卡",align:"center",sortable:true,width:parseInt($(this).width() * 0.03)},
              	{field:"BD_TOT",title:"小计",align:"center",sortable:true,width:parseInt($(this).width() * 0.03), formatter:function(v, r, i){
                  	var bdXfk = isNaN(r.BD_XFK)?0:Number(r.BD_XFK);
                  	var bdHfk = isNaN(r.BD_HFK)?0:Number(r.BD_HFK);
                   	r.BD_TOT = bdXfk + bdHfk;
                   	return r.BD_TOT;
               	}},
              	{field:"WB_XFK",title:"新发卡",align:"center",sortable:true,width:parseInt($(this).width() * 0.03)},
               	{field:"WB_HFK",title:"换发卡",align:"center",sortable:true,width:parseInt($(this).width() * 0.03)},
               	{field:"WB_TOT",title:"小计",align:"center",sortable:true,width:parseInt($(this).width() * 0.03), formatter:function(v, r, i){
                  	var wbXfk = isNaN(r.WB_XFK)?0:Number(r.WB_XFK);
                  	var wbHfk = isNaN(r.WB_HFK)?0:Number(r.WB_HFK);
                   	r.WB_TOT = wbXfk + wbHfk;
                  	return r.WB_TOT;
               	}},
          	]],
            onBeforeLoad:function(param){
            	if(!param.queryType){
            		return false;
            	}
            	return true;
            },
            onLoadSuccess:function(data){
                if(dealNull(data["status"]) != 0){
                    $.messager.alert("系统消息",data.errMsg,"warning");
                }else{
                    $grid.datagrid("autoMergeCells",["BANK_ID","BANK_NAME"]);
                    initCal();
                    updateFooter();
                }
            },
            onCheck:function(index,data){
                calRow(true,data);
                updateFooter();
            },
            onUncheck:function(index,data){
                calRow(false,data);
                updateFooter();
            },
            onCheckAll:function(rows){
                initCal();
                for(var i = 0,hk = rows.length;i < hk;i++){
                    var data  = rows[i];
                    calRow(true,data);
                }
                updateFooter();
            },
            onUncheckAll:function(rows){
                initCal();
                updateFooter();
            }
        });
    });
    function initCal(){
    	sumBdXfk = 0;
        sumBdHfk = 0;
        sumWbXfk = 0;
        sumWbHfk = 0;
        sumTotNum = 0;
    }

	function calRow(is, data) {
		if (is) {
			sumBdXfk += isNaN(data.BD_XFK) ? 0 : Number(data.BD_XFK);
			sumBdHfk += isNaN(data.BD_HFK) ? 0 : Number(data.BD_HFK);
			sumWbXfk += isNaN(data.WB_XFK) ? 0 : Number(data.WB_XFK);
			sumWbHfk += isNaN(data.WB_HFK) ? 0 : Number(data.WB_HFK);
			sumTotNum += isNaN(data.TOT_NUM) ? 0 : Number(data.TOT_NUM);
		} else {
			sumBdXfk -= isNaN(data.BD_XFK) ? 0 : Number(data.BD_XFK);
			sumBdHfk -= isNaN(data.BD_HFK) ? 0 : Number(data.BD_HFK);
			sumWbXfk -= isNaN(data.WB_XFK) ? 0 : Number(data.WB_XFK);
			sumWbHfk -= isNaN(data.WB_HFK) ? 0 : Number(data.WB_HFK);
			sumTotNum -= isNaN(data.TOT_NUM) ? 0 : Number(data.TOT_NUM);
		}
	}
	
	function updateFooter() {
		$grid.datagrid("reloadFooter", [ {
			"BANK_ID" : "本页信息统计",
			"BD_XFK" : sumBdXfk,
			"BD_HFK" : sumBdHfk,
			"WB_XFK" : sumWbXfk,
			"WB_HFK" : sumWbHfk,
			"TOT_NUM" : sumTotNum,
			isFooter : true,
		} ]);
	}
	function query() {
		if ($("#beginTime").val() != "" && $("#endTime").val() != "") {
			if ($("#beginTime").val() > $("#endTime").val()) {
				jAlert("起始日期不能大于结束日期！");
				return;
			}
		}
		var params = getformdata("searchConts");
		params["queryType"] = true;
		params["cascadeBrch"] = document.getElementById("cascadeBrch").checked;
		$grid.datagrid("load", params);
	}
	
	function viewDetail() {
		$("#dia").dialog("open");
	}
	
	function exportDetailInfo(){
		var selections = $("#dg").datagrid("getSelections");
		if(!selections || selections.length != 1){
			jAlert("请选择一条记录", "warning");
			return false;
		}
		var params = getformdata("searchConts");
		params["bankId"] = selections[0].BANK_ID;
		params["branchId"] = selections[0].RECV_BRCH_ID;
		params["rows"] = 65535;
		
		var paramsStr;
		for(var i in params){
			paramsStr += "&" + i + "=" + params[i];
		}
		$.messager.progress({text:"正在进行导出,请稍候..."});
		$('#download_iframe').attr('src',"statistical/statisticalAnalysisAction!exportJrsbkFkDetail.action?" + paramsStr.substring(1));
		startCycle();
	}
	function startCycle(){
		isExt = setInterval("startDetect()",800);
	}
	function startDetect(){
		commonDwr.isDownloadComplete("exportJrsbkFkDetail",function(data){
			if(data["returnValue"] == '0'){
				clearInterval(isExt);
				jAlert("导出成功！","info",function(){
					$.messager.progress("close");
				});
			}
		});
	}
	
	function exportStat(){
		var params = getformdata("searchConts");
		params["rows"] = 65535;
		
		var paramsStr;
		for(var i in params){
			paramsStr += "&" + i + "=" + params[i];
		}
		$.messager.progress({text:"正在进行导出,请稍候..."});
		$('#download_iframe').attr('src',"statistical/statisticalAnalysisAction!exportJrsbkFkStat.action?" + paramsStr.substring(1));
		startCycle();
	}
</script>
<n:initpage title="金融市民卡发卡量进行统计,<span style='color:red'>注意：</span>仅统计首次发金融市民卡,未统计金融市民卡换发的金融市民卡！">
    <n:center>
        <div id="tb">
            <form id="searchConts">
                <table class="tablegrid">
                    <tr>
                        <th class="tableleft">银行名称：</th>
                        <td class="tableright"><input id="bankId" name="bankId" type="text" class="textinput easyui-validatebox" /></td>
                        <th class="tableleft">领卡网点：</th>
                        <td class="tableright">
                            <input id="branchId" name="branchId" type="text" class="textinput">
                            <span id="synGroupIdTip">
								<input id="cascadeBrch" name="cascadeBrch" type="checkbox"/>
							</span>
                        </td>
                        <th class="tableleft">发放标志：</th>
                        <td class="tableright"><input id="applyState" name="applyState" type="text" class="textinput easyui-validatebox" /></td>
          			</tr>
                    <tr>
                        <td class="tableleft">起始日期：</td>
                        <td class="tableright"><input id="beginTime" name="beginTime" type="text" class="Wdate textinput" readonly="readonly" onclick="WdatePicker({dateFmt:'yyyy-MM-dd',maxDate:'%y-%M-%d'})"/></td>
                        <td class="tableleft">结束日期：</td>
                        <td class="tableright"><input id="endTime" name="endTime" type="text"  class="Wdate textinput" readonly="readonly"  onclick="WdatePicker({dateFmt:'yyyy-MM-dd',maxDate:'2018-01-31'})"/></td>
                        <td class="tableright" colspan="2" style="padding-left: 20px">
                            <a style="text-align:center;margin:0 auto;" data-options="plain:false,iconCls:'icon-search'" href="javascript:void(0);" class="easyui-linkbutton" onclick="query()">查询</a>
                            <a style="text-align:center;margin:0 auto;" data-options="plain:false,iconCls:'icon-viewInfo'" href="javascript:void(0);" class="easyui-linkbutton" onclick="viewDetail()">预览</a>
                            <a style="text-align:center;margin:0 auto;" data-options="plain:false,iconCls:'icon-export'" href="javascript:void(0);" class="easyui-linkbutton" onclick="exportStat()">导出</a>
                        </td>
                    </tr>
                </table>
            </form>
        </div>
        <table id="dg" title="汇总信息" style="width:100%"></table>
        <div id="dia" >
        	<table id="dg2" style="width:100%"></table>
        </div>
        <iframe id="download_iframe" style="display: none;"></iframe>
    </n:center>
</n:initpage>
