<%@ page language="java" import="java.util.*" pageEncoding="UTF-8"%>
<%@include file="/layout/initpage.jsp" %>
<script type="text/javascript">
	var $grid;
	$(function(){
		if(dealNull("${defaultErrorMsg}") != ""){
			jAlert("${defaultErrorMsg}");
		}
		$grid = createDataGrid({
			id:"dg",
			url:"payCarreForm/payCarreFormAction!carreFormDetail.action",
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
				{field:"ACCNAME",title:"账户类型",sortable:true,width:parseInt($(this).width() * 0.12)},
				{field:"AMT",title:"充值金额",sortable:true,width:parseInt($(this).width() * 0.1)},
				{field:"DEALDATE",title:"充值日期",sortable:true,width:parseInt($(this).width() * 0.12)},
				{field:"CORP_NAME",title:"充值单位",sortable:true,width:parseInt($(this).width() * 0.12)},
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
		if(dealNull($("#beginTime").val()) == ""){
			jAlert("请输入查询起始日期！",function(){
				$("#startDate").focus();
			});
			return;
		}
		if(dealNull($("#endTime").val()) == ""){
			jAlert("请输入查询结束日期！",function(){
				$("#endDate").focus();
			});
			return;
		}
		if($("#beginTime").val() > $("#endTime").val()){
			jAlert("起始日期不能大于结束日期！");
			return;
		}
		var params = getformdata("cardreFormList");
		params["startDate"] = $("#beginTime").val();
		params["endDate"] = $("#endTime").val();
		params["payCarreform.cardNo"] = $("#cardNo").val();
		params["payCarreform.corpId"] = $("#certNo").val();
		params["queryType"] = "0";
		$grid.datagrid("load",params);
	}
</script>
<n:initpage title="车改充值明细进行查询操作！">
	<n:center>
		<div id="tb">
			<form id="cardreFormList">
				<input id="sort" name="sort" type="hidden">
				<input id="order" name="order" type="hidden">
				<table style="width:100%" class="tablegrid">
					<tr>
						<td class="tableleft">证件号码：</td>
						<td class="tableright"><input id="certNo"  name="rec.certNo" type="text" class="textinput" maxlength="20"/></td>
						<td class="tableleft">卡号：</td>
						<td class="tableright"><input  id="cardNo" type="text" name="rec.cardNo" class="textinput" maxlength="20"/></td>
						<td class="tableleft">起始日期：</td>
						<td class="tableright"><input  id="beginTime" type="text" name="beginTime" class="Wdate textinput" onclick="WdatePicker({dateFmt:'yyyy-MM-dd',qsEnabled:false,maxDate:'%y-%M-%d'})"/></td>
						<td class="tableleft">结束日期：</td>
						<td class="tableright"><input id="endTime" type="text"  name="endTime" class="Wdate textinput"  onclick="WdatePicker({dateFmt:'yyyy-MM-dd',qsEnabled:false,maxDate:'%y-%M-%d'})"/></td>
					</tr>
					<tr>
						<td colspan="7">
							&nbsp;
						</td>
						<td style="text-align:center;"><a data-options="plain:false,iconCls:'icon-search'" href="javascript:void(0);" class="easyui-linkbutton" onclick="query()">查询</a></td>
					</tr>
				</table>
			</form>
		</div>
  		<table id="dg" title="车改充值明细"></table>
	</n:center>
</n:initpage>