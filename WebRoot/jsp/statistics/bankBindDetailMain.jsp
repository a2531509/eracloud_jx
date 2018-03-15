<%@ page language="java" import="java.util.*" pageEncoding="UTF-8"%>
<%@include file="/layout/initpage.jsp" %>
<script type="text/javascript">
	var $grid;
	var totBindNum = 0;
	var totUnBindNum = 0;
	var totNum = 0;
	$(function(){
		createCustomSelect({
			id:"bankId",
			value:"bank_id",
			text:"bank_name",
			table:"base_bank",
			where:"bank_state = '0'",
			orderby:"bank_id asc",
			from:1,
			to:20
		});
		if(dealNull("${defaultErrorMsg}") != ""){
			jAlert("${defaultErrorMsg}");
		}
		$("#synGroupIdTip").tooltip({
			position:"left",    
			content:"<span style='color:#B94A48'>是否级联下级网点</span>" 
		});
		$("#dealState").switchbutton({
			width:50,
			value:"0",
            checked:false,
            onText:"是",
            offText:"否",
			onChange:function(checked){
			}
		});
		createSysBranch(
			{id:"brchId"},
			{id:"userId"}
		);
		$grid = createDataGrid({
			id:"dg",
			url:"statistical/statisticalAnalysisAction!bankBindDetailQuery.action",
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
				//{field:"SUB_CARD_ID",title:"流水编号",sortable:true,checkbox:true},
				{field:"NAME",title:"姓名",sortable:true,width:parseInt($(this).width() * 0.05)},
				{field:"CERT_NO",title:"证件号码",sortable:true,width:parseInt($(this).width() * 0.1)},
				{field:"CARD_NO",title:"市民卡卡号",sortable:true,width:parseInt($(this).width() * 0.12)},
				{field:"BANK_NAME",title:"绑定银行",sortable:true,width:parseInt($(this).width() * 0.1)},
				{field:"BANK_CARD_NO",title:"银行账号",sortable:true,width:parseInt($(this).width() * 0.12)},
				{field:"BINDDATE",title:"绑定日期",sortable:true,width:parseInt($(this).width() * 0.12)},
				{field:"FULL_NAME",title:"办理网点",sortable:true},
				{field:"USERNAME",title:"办理柜员",sortable:true}
			]],
			onLoadSuccess:function(data){
				if(dealNull(data["status"]) != 0){
					$.messager.alert("系统消息",data.errMsg,"warning");
				}
			}
		});
	});
	function query(){
		var params = getformdata("bankBindList");
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
		commonDwr.isDownloadComplete("bankBindDetailMain",function(data){
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
			$("#bankBindList").get(0).action = "statistical/statisticalAnalysisAction!bankBindDetailExport.action";
			$("#bankBindList").get(0).submit();
			startCycle();
		});
	}
</script>
<n:initpage title="银行卡绑定明细进行查询与导出操作！">
	<n:center>
		<div id="tb">
			<form id="bankBindList">
				<input id="sort" name="sort" type="hidden">
				<input id="order" name="order" type="hidden">
				<table style="width:100%" class="tablegrid">
					<tr>
						<td class="tableleft">所属网点：</td>
						<td class="tableright">
							<input id="brchId"  name="rec.brchId" type="text" class="textinput  easyui-validatebox" style="width:174px;"/>
							<span id="synGroupIdTip">
								<input id="dealState" name="rec.dealState" type="checkbox">
							</span>
						</td>
						<td class="tableleft">所属柜员：</td>
						<td class="tableright"><input  id="userId" type="text" name="rec.userId" class="textinput"/></td>
						<td class="tableleft">绑定银行：</td>
						<td class="tableright"><input  id="bankId" type="text" name="bankId" class="textinput"/></td>
					</tr>
					<tr>
						<td class="tableleft">起始时间：</td>
						<td class="tableright"><input  id="beginTime" type="text" name="beginTime" class="Wdate textinput" onclick="WdatePicker({dateFmt:'yyyy-MM-dd',qsEnabled:false,maxDate:'%y-%M-%d'})"/></td>
						<td class="tableleft">结束时间：</td>
						<td class="tableright"><input id="endTime" type="text"  name="endTime" class="Wdate textinput"  onclick="WdatePicker({dateFmt:'yyyy-MM-dd',qsEnabled:false,maxDate:'%y-%M-%d'})"/></td>
						<td class="tableright" style="padding-left: 15px" colspan="2">
							<a data-options="plain:false,iconCls:'icon-search'" href="javascript:void(0);" class="easyui-linkbutton" onclick="query()">查询</a>
							<a data-options="plain:false,iconCls:'icon-excel'" href="javascript:void(0);" class="easyui-linkbutton" onclick="exportFile()">导出</a>
						</td>
					</tr>
				</table>
			</form>
		</div>
  		<table id="dg" title="银行卡绑定明细"></table>
	</n:center>
</n:initpage>