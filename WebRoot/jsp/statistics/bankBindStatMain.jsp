<%@ page language="java" import="java.util.*" pageEncoding="UTF-8"%>
<%@include file="/layout/initpage.jsp" %>
<script type="text/javascript">
	var $grid;
	var totBindNum = 0;
	var totUnBindNum = 0;
	var totNum = 0;
	$(function(){
		if(dealNull("${defaultErrorMsg}") != ""){
			jAlert("${defaultErrorMsg}");
		}
		createCustomSelect({
			id:"rsvOne",
			value:"bank_id",
			text:"bank_name",
			table:"base_bank",
			where:"bank_state = '0'",
			orderby:"bank_id asc",
			from:1,
			to:20
		});
		$grid = createDataGrid({
			id:"dg",
			url:"statistical/statisticalAnalysisAction!bankBindQueryMain.action",
			fit:true,
			pagination:true,
			rownumbers:true,
			border:false,
			striped:true,
			pageSize:50,
			singleSelect:false,
			autoRowHeight:true,
			fitColumns:true,
			scrollbarSize:0,
			columns:[[
				{field:"V_V",title:"id",sortable:false,checkbox:"ture"},
				{field:"BANK_ID",title:"银行编号",sortable:true,width:parseInt($(this).width()*0.1)},
				{field:"BANK_NAME",title:"银行名称",sortable:true,width:parseInt($(this).width()* 0.12)},
				{field:"BINDNUM",title:"本周期内绑定数量",sortable:true,width:parseInt($(this).width() * 0.12)},
				{field:"UNBINDNUM",title:"本周期内解绑数量",sortable:true,width:parseInt($(this).width() * 0.06)},
				{field:"TOTBINDNUM",title:"总计",sortable:true,width:parseInt($(this).width()*0.06),width:parseInt($(this).width()*0.06)}
			]],
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
            	for(var i=0,hk=rows.length;i < hk;i++){
            		var data  = rows[i];
            		calRow(true,data);
          	  	}
            	updateFooter();
            },
            onUncheckAll:function(rows){
            	initCal();
            	updateFooter();
            },
			onLoadSuccess:function(data){
				initGridFooter();
				if(dealNull(data["status"]) != 0){
					$.messager.alert("系统消息",data.errMsg,"warning");
				}
				initCal();
				updateFooter();
			}
		});
	});
	function query(){
		var params = {};
		params["rec.rsvOne"] = $("#rsvOne").combobox("getValue");
		params["beginTime"] = $("#beginTime").val();
		params["endTime"] = $("#endTime").val();
		params["queryType"] = "0";
		$grid.datagrid("load",params);
	}
	var isExt;
	function startCycle(){
		isExt = setInterval("startDetect()",800);
	}
	function startDetect(){
		commonDwr.isDownloadComplete("bankBindStatMain",function(data){
			if(data["returnValue"] == '0'){
				clearInterval(isExt);
				jAlert("导出成功！","info",function(){
					$.messager.progress("close");
				});
			}
		});
	}
	function exportFile(){
		var options = $grid.datagrid("options");
		$("#sort").val(options["sortName"]);
		$("#order").val(options["sortOrder"]);
		if(dealNull($("#beginTime").val()) == ""){
			jAlert("请输入导出起始日期！",function(){
				$("#startDate").focus();
			});
			return;
		}
		if(dealNull($("#endTime").val()) == ""){
			jAlert("请输入导出结束日期！",function(){
				$("#endDate").focus();
			});
			return;
		}
		if($("#beginTime").val() > $("#endTime").val()){
			jAlert("起始日期不能大于结束日期！");
			return;
		}
		jConfirm("您确定要进行导出吗？",function(){
			$.messager.progress({text:"正在进行导出,请稍候..."});
			$("#bankBindList").get(0).action = "statistical/statisticalAnalysisAction!bankBindQueryExport.action";
			$("#bankBindList").get(0).submit();
			startCycle();
		});
	}
	function initCal(){
		totBindNum = 0;
		totUnBindNum = 0;
		totNum = 0;
	}
	function initGridFooter(){
		$grid.datagrid("reloadFooter",[
  		    {"BANK_NAME":"本页信息统计：","BINDNUM":0,"UNBINDNUM":0,"TOTBINDNUM":0} 
  		]);
	}
	function calRow(is,data){
		if(is){
			totBindNum = parseFloat(totBindNum) + (isNaN(data.BINDNUM)?0:parseFloat(data.BINDNUM))
			totUnBindNum = parseFloat(totUnBindNum) + (isNaN(data.UNBINDNUM)?0:parseFloat(data.UNBINDNUM))
			totNum = parseFloat(totNum) + (isNaN(data.TOTBINDNUM)?0:parseFloat(data.TOTBINDNUM)) 
		}else{
			totBindNum = parseFloat(totBindNum) - (isNaN(data.BINDNUM)?0:parseFloat(data.BINDNUM))
			totUnBindNum = parseFloat(totUnBindNum) - (isNaN(data.UNBINDNUM)?0:parseFloat(data.UNBINDNUM))
			totNum = parseFloat(totNum) - (isNaN(data.TOTBINDNUM)?0:parseFloat(data.TOTBINDNUM)) 
		}
	}
	function updateFooter(){
		$grid.datagrid("reloadFooter",[
  		    {"BANK_NAME":"本页信息统计：","BINDNUM":totBindNum,"UNBINDNUM":totUnBindNum,"TOTBINDNUM":totNum} 
  		]);
	}
</script>
<n:initpage title="银行卡绑定情况进行查询统计与导出操作！">
	<n:center>
		<div id="tb">
			<form id="bankBindList">
				<input id="sort" name="sort" type="hidden">
				<input id="order" name="order" type="hidden">
				<table style="width:100%" class="tablegrid">
					<tr>
						<td class="tableleft">银行名称：</td>
						<td class="tableright"><input name="rec.rsvOne" type="text" class="textinput  easyui-validatebox" id="rsvOne"  style="width:174px;"/></td>
						<td class="tableleft">起始日期：</td>
						<td class="tableright"><input  id="beginTime" type="text" name="beginTime" class="Wdate textinput" onclick="WdatePicker({dateFmt:'yyyy-MM-dd',qsEnabled:false,maxDate:'%y-%M-%d'})"/></td>
						<td class="tableleft">结束日期：</td>
						<td class="tableright"><input id="endTime" type="text"  name="endTime" class="Wdate textinput"  onclick="WdatePicker({dateFmt:'yyyy-MM-dd',qsEnabled:false,maxDate:'%y-%M-%d'})"/></td>
						<td style="text-align:center;">
							<a data-options="plain:false,iconCls:'icon-search'" href="javascript:void(0);" class="easyui-linkbutton" onclick="query()">查询</a>
							<a data-options="plain:false,iconCls:'icon-excel'" href="javascript:void(0);" class="easyui-linkbutton" onclick="exportFile()">导出</a>
						</td>
					</tr>
				</table>
			</form>
		</div>
  		<table id="dg" title="银行卡绑定统计"></table>
	</n:center>
</n:initpage>