<%@page import="com.erp.util.Constants"%>
<%@ page language="java" import="java.util.*" pageEncoding="UTF-8"%>
<%@include file="/layout/initpage.jsp" %>
<style>
#searchConts td{
	padding: 0 20px;
}
</style>
<script type="text/javascript"> 
	$(function() {
		$("#synGroupIdTip").tooltip({
			position:"left",    
			content:"<span style='color:#B94A48'>是否按天统计</span>" 
		});
		$("#statByDay").switchbutton({
			width:"50px",
			value:false,
            checked:false,
            onText:"是",
            offText:"否",
            onChange:function(checked){
            	query();
            }
		});
		
		$("#dia").dialog({
    		title:"微信购买保险数据",
    		fit:true,
    		closed:true,
    		border:false,
    		modal:true,
    		onBeforeOpen:function(){
	    		var selections = $("#dg").datagrid("getSelections");
	    		if(!selections || selections.length != 1){
	    			jAlert("请选择一条记录", "warning");
	    			return false;
	    		}
	    		var startDate = selections[0].STARTDATE;
	    		var endDate = selections[0].ENDDATE;
	    		var source = selections[0].SOURCE;
    			var params = {startDate:startDate, endDate:endDate, source:source};
    			params["query"] = true;
    			$("#dg2").datagrid("load", params);
    		}
    	});
		
		$("#dg").datagrid({
			url:"zxcApp/ZxcAppAction!queryCardInsuranceStat.action",
			fitColumns:true,
			fit:true,
			pagination:true,
			rownumbers:true,
			border:false,
			striped:true,
			toolbar:"#tb",
			pageList:[50, 100, 200, 500, 1000],
			singleSelect:false,
			columns:[[
				{field:"",checkbox:true},
				{field:"STARTDATE",title:"起始日期",sortable:true, width:1},
				{field:"ENDDATE",title:"结束日期",sortable:true, width:1},
				{field:"COUNT",title:"笔数",sortable:true, width:1},
				{field:"SUMAMT",title:"金额",sortable:true, width:1, formatter:function(v){
					return $.foramtMoney(Number(v).div100());
				}},
				{field:"SOURCE",title:"来源",sortable:true, width:1, formatter:function(v){
					if(v == "0"){
						return "微信购买";
					} else {
						return "其它渠道【" + v + "】";
					}
				}}
			]],
			onBeforeLoad:function(params){
				if(!params.query){
					return false;
				}
			},
            onLoadSuccess:function(data){
            	if(data.status != 0){
            		jAlert(data.errMsg,"warning");
            	}
            }
		});
		
		$("#dg2").datagrid({
			url:"zxcApp/ZxcAppAction!queryCardInsurance.action",
			fitColumns:true,
			fit:true,
			pagination:true,
			rownumbers:true,
			border:false,
			striped:true,
			toolbar:"#tb2",
			pageList:[50, 100, 200, 500, 1000],
			columns:[[
				{field:"DEAL_NO", checkbox:true},
				{field:"CUSTOMER_ID",title:"客户编号", hidden:true, sortable:true},
				{field:"NAME",title:"客户姓名",sortable:true,width:1},
				{field:"SUB_CARD_NO",title:"市民卡号",sortable:true,width:1},
				{field:"CERT_NO",title:"证件号码",sortable:true,width:1.5},
				{field:"MOBILE_NO",title:"电话号码",sortable:true,width:1},
				{field:"CARD_NO",title:"卡号",sortable:true, hidden:true},
				{field:"CARD_TYPE",title:"卡类型",sortable:true, hidden:true, formatter:function(value){
					if(value == "<%=Constants.CARD_TYPE_QGN%>"){
						return "全功能卡";
					} else if(value == "<%=Constants.CARD_TYPE_SMZK%>") {
						return "金融市民卡";
					} else {
						return value;
					}
				}},
				{field:"AMT",title:"金额",sortable:true, width:1, formatter:function(v){
					return $.foramtMoney(Number(v).div100());
				}},
				{field:"INSURANCE_NO",title:"保单编号", hidden:true,sortable:true},
				{field:"INSURANCE_KIND",title:"保险种类", hidden:true,sortable:true},
				{field:"INSURED_DATE",title:"参保 / 购买日期",sortable:true, width:1.5},
				{field:"START_DATE",title:"有效期起始", hidden:true,sortable:true},
				{field:"END_DATE",title:"有效期截止", hidden:true,sortable:true},
				{field:"STATE",title:"状态", hidden:true,sortable:true, formatter:function(value){
					if(value == "0"){
						return "已购买未生效";
					} else if(value == "1") {
						return "已购买已生效";
					} else {
						return value;
					}
				}},
				{field:"ORDER_NO",title:"商户订单号",sortable:true,width:2.5},
				{field:"SOURCE",title:"来源",sortable:true,width:1, formatter:function(v){
					if(v == "0"){
						return "微信购买";
					} else {
						return "其它渠道【" + v + "】";
					}
				}}
			]],
			onBeforeLoad:function(params){
				if(!params.query){
					return false;
				}
			},
            onLoadSuccess:function(data){
            	if(data.status != 0){
            		jAlert(data.errMsg,"warning");
            	}
            }
		});
	})
	
	function query() {
		var params = getformdata("searchConts");
		params.query = true;
		params["statByDay"] = $("#statByDay").prop("checked");
		$("#dg").datagrid("load", params);
	}
	
	function viewDetail(){
		$("#dia").dialog("open");
	}
	
	function exportDetail(){
		var selections = $("#dg").datagrid("getSelections");
		if(!selections || selections.length != 1){
			jAlert("请选择一条记录", "warning");
			return false;
		}
		var startDate = selections[0].STARTDATE;
		var endDate = selections[0].ENDDATE;
		var source = selections[0].SOURCE;
		var params = {startDate:startDate, endDate:endDate, source:source};
		var paramStr = "";
		for(var i in params){
			paramStr += "&" + i + "=" + params[i];
		}
		//
		var selections2 = $("#dg2").datagrid("getSelections");
		var selectId = "";
		if(selections2 && selections2.length > 0){
			for(var i in selections2){
				selectId += selections2[i].CARD_NO + selections2[i].INSURANCE_NO + ",";
			}
			if(selectId){
				selectId = selectId.substring(0, selectId.length - 1);
			}
		}
		$.messager.progress({text:"数据处理中..."});
		$('#download').attr('src',"zxcApp/ZxcAppAction!exportCardInsDataStat.action?rows=65530" + paramStr + (selectId?"&selectId=" + selectId : ""));
		startCycle();
	}
	
	function startCycle(){
		isExt = setInterval("startDetect()",800);
	}
	
	function startDetect() {
		commonDwr.isDownloadComplete("exportCardInsDataStat", function(data) {
			if (data["returnValue"] == '0') {
				clearInterval(isExt);
				jAlert("导出成功！", "info", function() {
					$.messager.progress("close");
				});
			}
		});
	}

	function exportStat() {
		if (!$("#beginTime").val() || !$("#endTime").val()) {
			jAlert("请选择参保 / 购买日期！", "warning");
			return;
		}
		var params = getformdata("searchConts");
		params["statByDay"] = $("#statByDay").prop("checked");
		var paramsStr = "";
		for ( var i in params) {
			paramsStr += "&" + i + "=" + params[i];
		}
		$.messager.progress({
			text : "数据处理中..."
		});
		$('#download').attr(
				'src',
				"zxcApp/ZxcAppAction!exportCardInsDataStat2.action?rows=65530"
						+ paramsStr);
		startCycle();
	}
</script>
<n:initpage title="微信购买保险统计数据进行查询，以及预览明细！">
	<n:center>
		<div id="tb" class="datagrid-toolbar">
			<form id="searchConts">
				<table class="tablegrid" style="width: auto;">
					<tr>
						<td class="tableleft">参保 / 购买日期：</td>
						<td class="tableright" colspan="3">
							<input  id="beginTime" type="text" name="startDate" class="Wdate textinput" onclick="WdatePicker({dateFmt:'yyyy-MM-dd',qsEnabled:false,maxDate:'%y-%M-%d'})"/>
							&nbsp;&nbsp;——&nbsp;&nbsp;
							<input id="endTime" type="text"  name="endDate" class="Wdate textinput"  onclick="WdatePicker({dateFmt:'yyyy-MM-dd',qsEnabled:false,maxDate:'%y-%M-%d'})"/>
						</td>
						<td class="tableright">
							<span id="synGroupIdTip">
								<input id="statByDay" name="statByDay" type="checkbox">
							</span>
							&nbsp;
							<a style="text-align:center;margin:0 auto;" data-options="plain:false,iconCls:'icon-search'" href="javascript:void(0);" class="easyui-linkbutton" onclick="query()">查询</a>
							<a style="text-align:center;margin:0 auto;" data-options="plain:false,iconCls:'icon-viewInfo'" href="javascript:void(0);" class="easyui-linkbutton" onclick="viewDetail()">查看明细</a>
							<a style="text-align:center;margin:0 auto;" data-options="plain:false,iconCls:'icon-export'" href="javascript:void(0);" class="easyui-linkbutton" onclick="exportStat()">导出</a>
						</td>
					</tr>
				</table>
			</form>
		</div>
  		<table id="dg" title="微信购买保险数据统计"></table>
  	</n:center>
  	<div id="dia" >
  		<div id="tb2" class="tablegrid">
  			<a href="javascript:void(0);" class="easyui-linkbutton" data-options="plain:false,iconCls:'icon-export'" onclick="exportDetail()">导出</a>
  		</div>
        <table id="dg2" style="width:100%"></table>
 	</div>
 	<iframe id="download" style="display:none"></iframe>
</n:initpage>