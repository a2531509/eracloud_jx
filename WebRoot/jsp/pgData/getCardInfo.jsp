<%@page import="com.erp.util.Constants"%>
<%@ page language="java" import="java.util.*" pageEncoding="UTF-8"%>
<%@include file="/layout/initpage.jsp" %>
<script type="text/javascript"> 
	$(function(){
		$("#dg").datagrid({
			url:"queryService/personBaseAllQueryAction!querCardInfo.action",
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
	        	{field:"NAME",title:"姓名",sortable:true,width:parseInt($(this).width() * 0.03)},
				{field:"CERTTYPE",title:"证件类型",sortable:true,width:parseInt($(this).width() * 0.04)},
	        	{field:"CERT_NO",title:"证件号码",sortable:true,width:parseInt($(this).width() * 0.09)},
	        	{field:"CARDTYPE",title:"卡类型",sortable:true,width:parseInt($(this).width() * 0.04)},
	        	{field:"CARD_NO",title:"卡号",sortable:true,width:parseInt($(this).width() * 0.13),fixed:true},
	        	{field:"SUB_CARD_NO",title:"社保卡号",sortable:true,width : parseInt($(this).width() * 0.05)},
	        	{field:"SUB_CARD_ID",title:"社保卡编码",sortable:true,width : parseInt($(this).width() * 0.15)},
	        	{field:"CARDSTATE",title:"卡状态",sortable:true,width:parseInt($(this).width() * 0.03)}
			]],
            onLoadSuccess:function(data){
            	if(data.status != 0){
            		jAlert(data.errMsg,"warning");
            	}
            }
		});
	})

	function query() {
		var certNo = $("#qCertNo").val();
		var subCardNo = $("#qSubCardNo").val();
		var subCardId = $("#qSubCardId").val();
		
		if(!certNo && !(subCardNo && subCardId)){
			$.messager.alert("系统消息","查询条件不能为空！","error");
			return;
		}
		if(certNo){
			$("#dg").datagrid("load", {queryType:0, certNo:certNo});
		}
		$.messager.progress({text:"数据处理中..."});
		$.post("pgData/pgDataAction!getPgCardData.action", {certNo:certNo, subCardNo:subCardNo, subCardId:subCardId}, function(data){
			$.messager.progress("close");
			if (data.status == 1) {
				$.messager.alert("消息提示", data.errMsg, "error");
				$("#searchConts").form("reset");
			} else {
				$("#searchConts").form("load", data.card);
			}
		}, "json");
	}
		
	function readCard(){
		$.messager.progress({text : "正在验证卡信息,请稍后..."});
		cardinfo = getTouchCardInfo_9901();
		$.messager.progress("close");
		if(dealNull(cardinfo["sub_Card_No"]).length == 0){
			$.messager.alert("系统消息","读卡出现错误，请重新放置好卡片，再次进行读取！","error");
			return;
		}
		$("#qSubCardId").val(cardinfo["card_Flag"]);
		$("#qSubCardNo").val(cardinfo["sub_Card_No"]);
	}
	
	function sendPerson(){
		var selections = $("#dg").datagrid("getSelections");
		if(selections.length != 1){
			$.messager.alert("系统消息","请选择一条记录","warning");
			return;
		}
		$.messager.progress({text:"数据处理中..."});
		$.post("pgData/pgDataAction!sendPerson.action", {certNo:selections[0].CERT_NO}, function(data){
			$.messager.progress("close");
			if (data.status == 1) {
				$.messager.alert("消息提示", data.errMsg, "error");
			} else {
				$.messager.alert("消息提示", "发送成功", "info");
			}
		}, "json");
	}
	
	function sendCard(){
		var selections = $("#dg").datagrid("getSelections");
		if(selections.length != 1){
			$.messager.alert("系统消息","请选择一条记录","warning");
			return;
		}
		$.messager.progress({text:"数据处理中..."});
		$.post("pgData/pgDataAction!sendCard.action", {certNo:selections[0].CERT_NO}, function(data){
			$.messager.progress("close");
			if (data.status == 1) {
				$.messager.alert("消息提示", data.errMsg, "error");
			} else {
				$.messager.alert("消息提示", "发送成功", "info");
			}
		}, "json");
	}
</script>
<n:initpage title="省厅卡信息进行查询！">
	<n:center>
		<div id="tb" class="datagrid-toolbar">
			<form id="searchConts">
				<table class="tablegrid">
					<tr>
						<td colspan="6">
							<h3 class="subtitle">查询条件1</h3>
						</td>
					</tr>
					<tr>
						<td class="tableleft">证件号码：</td>
						<td class="tableright" colspan="5"><input  id="qCertNo" type="text" class="textinput" name="qCertNo" /></td>
					</tr>
					<tr>
						<td colspan="6">
							<h3 class="subtitle">查询条件2</h3>
						</td>
					</tr>
					<tr>
						<td class="tableleft">社保卡号：</td>
						<td class="tableright">
							<input id="qSubCardNo" type="text" class="textinput" name="qSubCardNo" />
						</td>
						<td class="tableleft">社保卡编码：</td>
						<td class="tableright" colspan="3">
							<input id="qSubCardId" type="text" name="qSubCardId" class="textinput" style="width: 250px"/>
							&nbsp;&nbsp;<a data-options="plain:false,iconCls:'icon-readCard'" href="javascript:void(0);" class="easyui-linkbutton" onclick="readCard()">读卡</a>
							&nbsp;&nbsp;<a style="text-align:center;margin:0 auto;" data-options="plain:false,iconCls:'icon-search'" href="javascript:void(0);" class="easyui-linkbutton" onclick="query()">查询</a>
						</td>
					</tr>
					<tr>
						<td colspan="4">
							<h3 class="subtitle">省厅卡信息</h3>
						</td>
					</tr>
					<tr>
						<td class="tableleft">社保卡信息ID：</td>
						<td class="tableright"><input  id="subCardInfoId" type="text" class="textinput" name="subCardInfoId" readonly="readonly"/></td>
						<td class="tableleft">部级人员ID：</td>
						<td class="tableright"><input  id="stPersonId" type="text" class="textinput" name="stPersonId" readonly="readonly"/></td>
						<td class="tableleft">社会保障卡卡号：</td>
						<td class="tableright"><input  id="subCardNo" type="text" class="textinput" name="subCardNo" readonly="readonly"/></td>
					</tr>
					<tr>
						<td class="tableleft">卡识别码：</td>
						<td class="tableright"><input  id="subCardId" type="text" class="textinput" name="subCardId" readonly="readonly"  style="width: 250px"/></td>
						<td class="tableleft">卡片复位信息：</td>
						<td class="tableright"><input  id="atr" type="text" class="textinput" name="atr" readonly="readonly"/></td>
						<td class="tableleft">发卡日期：</td>
						<td class="tableright"><input  id="cardIssueDate" type="text" class="textinput" name="cardIssueDate" readonly="readonly"/></td>
					</tr>
					<tr>
						<td class="tableleft">证件有效期限：</td>
						<td class="tableright"><input  id="certValidDate" type="text" class="textinput" name="certValidDate" readonly="readonly"/></td>
						<td class="tableleft">卡应用状态：</td>
						<td class="tableright"><input  id="cardAppState" type="text" class="textinput" name="cardAppState" readonly="readonly"/></td>
						<td class="tableleft">开户银行行号：</td>
						<td class="tableright"><input  id="bankId" type="text" class="textinput" name="bankId" readonly="readonly"/></td>
					</tr>
					<tr>
						<td class="tableleft">银行卡卡号：</td>
						<td class="tableright"><input  id="bankCardNo" type="text" class="textinput" name="bankCardNo" readonly="readonly"/></td>
						<td class="tableleft">发卡行政区划代码：</td>
						<td class="tableright"><input  id="regionId" type="text" class="textinput" name="regionId" readonly="readonly"/></td>
						<td class="tableleft">卡面姓名：</td>
						<td class="tableright"><input  id="name" type="text" class="textinput" name="name" readonly="readonly"/></td>
					</tr>
					<tr>
						<td class="tableleft">卡面社会保障号码：</td>
						<td class="tableright"><input  id="certNo" type="text" class="textinput" name="certNo" readonly="readonly"/></td>
						<td class="tableleft">卡信息版本号：</td>
						<td class="tableright"><input  id="cardVersion" type="text" class="textinput" name="cardVersion" readonly="readonly"/></td>
						<td class="tableleft">卡规范版本：</td>
						<td class="tableright"><input  id="cardStdVersion" type="text" class="textinput" name="cardStdVersion" readonly="readonly"/></td>
					</tr>
					<tr>
						<td colspan="6">
							<h3 class="subtitle">本地卡信息</h3>
						</td>
					</tr>
				</table>
			</form>
		</div>
		<table id="dg"></table>
  	</n:center>
</n:initpage>