<%@page import="com.erp.util.DealCode"%>
<%@page import="com.erp.util.Constants"%>
<%@ page language="java" import="java.util.*" pageEncoding="UTF-8"%>
<%@include file="/layout/initpage.jsp" %>
<script type="text/javascript"> 
	$(function(){
		createRegionSelect({id:"oldRegionId"});
		createRegionSelect({id:"newRegionId"});
		
		$("#dg").datagrid({
			url:"statistical/statisticalAnalysisAction!businessQuery.action",
			fitColumns:true,
			fit:true,
			pagination:true,
			rownumbers:true,
			border:false,
			striped:true,
			toolbar:"#tb",
			pageList:[10, 15, 20, 25, 50],
			singleSelect:true,
			columns:[[
				{field:"DEAL_NO", checkbox:true},
				{field:"CUSTOMER_ID",title:"人员编号",sortable:true,width:parseInt($(this).width()*0.08)},
				{field:"ST_PERSON_ID",title:"省厅人员编号",sortable:true,width:parseInt($(this).width()*0.08), hidden:true},
				{field:"CUSTOMER_NAME",title:"客户姓名",sortable:true,width:parseInt($(this).width()*0.08)},
				{field:"CERT_NO",title:"证件号码",sortable:true,width:"180px"},
				{field:"CARD_NO",title:"卡号",sortable:true,width:"200px"},
				{field:"CARD_STATE",title:"卡状态",sortable:true, hidden:true},
				{field:"DEAL_CODE_NAME",title:"变更类型",sortable:true},
				{field:"BIZ_TIME",title:"变更日期",sortable:true},
				{field:"NOTE",title:"备注",sortable:true, width:parseInt($(this).width()*0.3)}
			]],
            onLoadSuccess:function(data){
            	if(data.status != 0){
            		jAlert(data.errMsg,"warning");
            	}
            }
		});
	})
	
	function query() {
		var params = getformdata("searchConts");
		params.queryType = 0;
		params["rec.dealCode"] = "<%=DealCode.UPDATE_ST_CARD_MED_WHOLE_NO%>";
		$("#dg").datagrid("load", params);
	}
		
	function readCard(){
		$.messager.progress({text : "正在验证卡信息,请稍后..."});
		cardinfo = getcardinfo();
		$.messager.progress("close");
		if(dealNull(cardinfo["card_No"]).length == 0){
			$.messager.alert("系统消息","读卡出现错误，请重新放置好卡片，再次进行读取！","error");
			return;
		}
		$("#cardNo").val(cardinfo["card_No"]);
	}
	
	function updateCardState(){
		var cardNo = $("#cardNo").val();
		var oldRegionId = $("#oldRegionId").combobox("getValue");
		var newRegionId = $("#newRegionId").combobox("getValue");
		if(!cardNo){
			$.messager.alert("系统消息","卡号不能为空！","error");
			return;
		} else if(!oldRegionId){
			$.messager.alert("系统消息","原统筹区不能为空！","error");
			return;
		}
		$.messager.confirm("系统消息","你确定变更卡号为【" + cardNo + "】的卡片统筹区为【" + (newRegionId?$("#newRegionId").combobox("getText"):"当前统筹区") + "】状态？", function(r){
			if(r){
				$.messager.progress({text:"数据处理中..."});
				$.post("pgData/pgDataAction!updateMedWholeNo.action", {cardNo:cardNo, oldRegionId:oldRegionId, newRegionId:newRegionId}, function(data){
					$.messager.progress("close");
					if (data.status == 1) {
						$.messager.alert("消息提示", data.errMsg, "error");
					} else {
						$.messager.alert("消息提示", "变更统筹区成功", "info");
					}
				}, "json");
			}
		});
	}
</script>
<n:initpage title="省厅卡片统筹区进行变更操作！">
	<n:center>
		<div id="tb" class="datagrid-toolbar">
			<form id="searchConts">
				<table class="tablegrid" style="width:auto">
					<tr>
						<td class="tableleft" style="padding: 0 10px">卡号：</td>
						<td class="tableright" style="padding: 0 10px">
							<input id="cardNo" type="text" class="textinput" name="rec.cardNo"/>
							&nbsp;&nbsp;<a data-options="plain:false,iconCls:'icon-readCard'" href="javascript:void(0);" class="easyui-linkbutton" onclick="readCard()">读卡</a>
						</td>
						<td class="tableleft" style="padding: 0 10px">原统筹区：</td>
						<td class="tableright"style="padding: 0 10px"><input  id="oldRegionId" type="text" class="textinput" name="oldRegionId" /></td>
						<td class="tableleft" style="padding: 0 10px">新统筹区：</td>
						<td class="tableright"style="padding: 0 10px"><input  id="newRegionId" type="text" class="textinput" name="newRegionId" /></td>
						<td class="tableleft" colspan="8" style="padding: 0 10px">
							<a style="text-align:center;margin:0 auto;" data-options="plain:false,iconCls:'icon-save'" href="javascript:void(0);" class="easyui-linkbutton" onclick="updateCardState()">变更</a>
							<a style="text-align:center;margin:0 auto;" data-options="plain:false,iconCls:'icon-search'" href="javascript:void(0);" class="easyui-linkbutton" onclick="query()">查询变更记录</a>
						</td>
					</tr>
				</table>
			</form>
		</div>
  		<table id="dg" title="变更记录"></table>
  	</n:center>
</n:initpage>