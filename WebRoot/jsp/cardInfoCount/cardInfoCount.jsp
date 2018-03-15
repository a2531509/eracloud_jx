<%--
  Created by IntelliJ IDEA.
  User: Administrator
  Date: 2016/12/7
  Time: 13:55
  To change this template use File | Settings | File Templates.
--%>
<%@ page language="java" import="java.util.*" pageEncoding="UTF-8"%>
<%@include file="/layout/initpage.jsp" %>
<!-- 市民卡发卡量统计-->
<!-- heisenberg -->
<style>
    .datagrid-header-row{
        height:23px;
    }
</style>
<script type="text/javascript"> 
    var $grid;
    var isExt;
    var sumQGN = 0;
    var sumJR = 0;
    var sumTotNum = 0;
    $(function(){
        if("${defaultErrMsg}" != ""){
            $.messager.alert("系统消息","${defaultErrMsg}","error");
        }
        
        $("#applyState").combobox({
    		textField:"text",
    		valueField:"value",
    		editable:false,
    		panelHeight:"auto",
    		value:"20",
    		data:[
    			{text:"制卡中", value:"20"},
    			{text:"已发放", value:"60"}
    		]
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
           
        });
        createRegionSelect({id:"regionId"});
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
            url:"cardInfoCount/cardInfoCountAction!cardInfoQuery.action",
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
	               	{title:"区域信息",colspan:2,sortable:true},
	               	{title:"银行信息",colspan:2,sortable:true},
	               	{field:"CARD_QGN",title:"全功能卡",rowspan:2, sortable:true, align:"center",width:parseInt($(this).width() * 0.02)},
	               	{field:"CARD_JRK",title:"金融卡",rowspan:2, sortable:true, align:"center",width:parseInt($(this).width() * 0.02)},
	               	{field:"TOT_NUM",title:"总计",rowspan:2, sortable:true, align:"center",width:parseInt($(this).width() * 0.03)}
	           	], [
	             	{field:"MED_WHOLE_NO",title:"区域编号",align:"center",sortable:true,width:parseInt($(this).width() * 0.02)},
	               	{field:"REGION_NAME",title:"区域名称",align:"center",sortable:true,width:parseInt($(this).width() * 0.02)},
	               	{field:"BANK_ID",title:"银行编号",align:"center",sortable:true,width:parseInt($(this).width() * 0.025)},
	               	{field:"BANK_NAME",title:"银行名称",align:"center",sortable:true,width:parseInt($(this).width() * 0.02)},
	              	
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
                    $grid.datagrid("autoMergeCells",["MED_WHOLE_NO","REGION_NAME"]);
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
    	sumQGN = 0;
        sumJRK = 0;
        sumTotNum = 0;
    }
    

	function calRow(is, data) {
		if (is) {
			sumQGN += isNaN(data.CARD_QGN) ? 0 : Number(data.CARD_QGN);
			sumJRK += isNaN(data.CARD_JRK) ? 0 : Number(data.CARD_JRK);
			sumTotNum += isNaN(data.TOT_NUM) ? 0 : Number(data.TOT_NUM);
		} else {
			sumQGN -= isNaN(data.CARD_QGN) ? 0 : Number(data.CARD_QGN);
			sumJRK -= isNaN(data.CARD_JRK) ? 0 : Number(data.CARD_JRK);
			sumTotNum -= isNaN(data.TOT_NUM) ? 0 : Number(data.TOT_NUM);
		}
	}
	
	function updateFooter() {
		$grid.datagrid("reloadFooter", [ {
			"BANK_ID" : "本页信息统计",
			"CARD_QGN" : sumQGN,
			"CARD_JRK" : sumJRK,
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
		$grid.datagrid("load", params);
	}
	
	
</script>
<n:initpage title="市民卡发卡量进行统计">
    <n:center>
        <div id="tb">
            <form id="searchConts">
                <table class="tablegrid">
                    <tr>
                        <th class="tableleft">银行名称：</th>
                        <td class="tableright"><input id="bankId" name="bankId" type="text" class="textinput easyui-validatebox" /></td>
                        <th class="tableleft">所属区域：</th>
                        <td class="tableright">
                            <input id="regionId" name="regionId" type="text" class="textinput">
                        </td>
                        <th class="tableleft">发放标志：</th>
                        <td class="tableright"><input id="applyState" name="applyState" type="text" class="textinput easyui-validatebox" /></td>
          			</tr>
                    <tr>
                        <td class="tableleft">起始日期：</td>
                        <td class="tableright"><input id="beginTime" name="beginTime" type="text" class="Wdate textinput" readonly="readonly" onclick="WdatePicker({dateFmt:'yyyy-MM-dd',maxDate:'%y-%M-%d'})"/></td>
                        <td class="tableleft">结束日期：</td>
                        <td class="tableright"><input id="endTime" name="endTime" type="text"  class="Wdate textinput" readonly="readonly" onclick="WdatePicker({dateFmt:'yyyy-MM-dd',maxDate:'%y-%M-%d'})"/></td>
                        <td class="tableright" colspan="2" style="padding-left: 20px">
                            <a style="text-align:center;margin:0 auto;" data-options="plain:false,iconCls:'icon-search'" href="javascript:void(0);" class="easyui-linkbutton" onclick="query()">查询</a>
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
