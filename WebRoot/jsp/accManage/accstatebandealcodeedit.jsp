<%@ page language="java" import="java.util.*" pageEncoding="utf-8"%>
<%@ taglib prefix="s" uri="/struts-tags" %>
<style>
	.tablegrid th{font-weight:700}
	#dw option{height:28px;}
</style>
<script type="text/javascript">
	$(function(){
		if(dealNull("${defaultErrorMsg}") != ""){
			$.messager.alert("系统消息","${defaultErrorMsg}","error");
		}
		createSysCode({
			id:"cardType",
			codeType:"CARD_TYPE",
			codeValue:"<%=com.erp.util.Constants.CARD_TYPE_SMZK %>"
		});
		if("${ban.cardType}" != ""){
			$("#cardType").combobox("setValue","${ban.cardType}");
			$("#cardType").combobox("disable");
		}
		
		createSysCode({
			id:"accKind",
			codeType:"ACC_KIND"
		});
		if("${ban.accKind}" != ""){
			$("#accKind").combobox("setValue","${ban.accKind}");
			$("#accKind").combobox("disable");
		}
		
		createSysCode({
			id:"accState",
			codeType:"ACC_STATE"
		});
		
		
		if("${ban.accState}" != ""){
			$("#accState").combobox("setValue","${ban.accState}");
		}
		$("#state").combobox({
			width:174,
			valueField:"codeValue",
			editable:false,
			value:"0",
		    textField:"codeName",
		    panelHeight:'auto',
		    data:[{codeValue:'0',codeName:"正常"},{codeValue:'1',codeName:"注销"}]
		});
		if("${ban.state}" != ""){
			$("#state").combobox("setValue","${ban.state}");
			$("#state").combobox("disable");
			
		}
		$.createDealCode({
			id:"dealCode2"
		});
		if("${ban.banDealCode}" != ""){
			$("#dealCode2").combobox("setValue","${ban.banDealCode}");
		}
	});
	//表单提交
	function save(oldgrid){
		if(dealNull($("#cardType").combobox("getValue")).length == 0){
			$.messager.alert("系统消息","请选择卡类型！","error",function(){
				$("#cardType").combobox("showPanel");
			});
			return false;
		}
		if($("#accKind").combobox("getValue") == ""){
			$.messager.alert("系统消息","请选择账户类型！","error",function(){
				$("#accKind").combobox("showPanel");
			});
			return false;
		}
		if($("#accState").combobox("getValue") == ""){
			$.messager.alert("系统消息","请选择账户状态！","error",function(){
				$("#accState").combobox("showPanel");
			});
			return false;
		}
		if(dealNull($("#dealCode2").combotree("getValue")).length == 0){
			$.messager.alert("系统消息","请选择该卡类型在当前状态下禁止进行交易的交易代码！","error",function(){
				$("#dealCode2").combotree('showPanel');
			});
			return false;
		}
		$.messager.confirm("系统消息","您确认要<s:if test='%{queryType == \"0\"}'>新增该账户状态和交易代码关联</s:if><s:else>编辑该账户状态和交易代码关联</s:else>",function(r){
			if(r){
				$.messager.progress({title : '提示',text : '数据处理中，请稍后....'});
				$("#note").val(document.getElementById("description").value);
				$.post("/accountManager/accountManagerAction!saveStateBanDealCode.action",{
					"queryType":$("#queryType").val(),"ban.cardType":$("#cardType").combobox("getValue"),"ban.accKind":$("#accKind").combobox("getValue"),
					"ban.accState":$("#accState").combobox("getValue"),"ban.banDealCode":$("#dealCode2").combobox("getValue"),
					"ban.state":$("#state").combobox("getValue"),"ban.note":$("#note").val(),"ruleId":$("#ruleId").val()
				},function(data,status){
					$.messager.progress('close');
					$.messager.alert("系统消息",data.msg,(data.status == "0" ? "info" : "error"),function(){
						if(data.status == "0"){
							oldgrid.datagrid("reload",{queryType:"0"});
							$.modalDialog.handler.dialog('close');
						}
					});
				},"json");
			}
		});
		return isValid;
	}
</script>
<div class="easyui-layout" data-options="fit:true,border:false" style="background-color:rgb(245,245,245);">
	<div data-options="region:'center',border:false,fit:true" title="" style="overflow: hidden;padding:0px;background-color:rgb(245,245,245);">
		<form id="form" method="post">
			<s:hidden id="queryType" name="queryType"></s:hidden>
			<s:hidden id="ruleId" name="ruleId" value="%{ban.id}"></s:hidden>
			<s:hidden id="note" name="ban.note"></s:hidden>
			<h3 class="subtitle"><s:if test='%{queryType == "0"}'>新增账户状态和交易代码关联</s:if><s:else>编辑账户状态和交易代码关联</s:else></h3>
			<table class="tablegrid" style="width:100%">
				 <tr>
				    <th class="tableleft" style="width:20%">卡类型：</th>
					<td class="tableright" style="width:25%"><input name="ban.cardType" id="cardType" type="text" class="textinput"/></td>
					<th class="tableleft" style="width:25%">账户类型：</th>
					<td class="tableright" style="width:30%"><input name="ban.accKind"  id="accKind" type="text" class="textinput"/></td>
				 </tr>
				 <tr>
				    <th class="tableleft">账户状态：</th>
					<td class="tableright"><input name="ban.accState" id="accState" class="textinput" type="text"/></td>
					<th class="tableleft">交易码：</th>
					<td class="tableright" ><input name="ban.banDealCode" id="dealCode2" type="text" class="textinput"/></td>
				 </tr>
				  <tr>
				    <th class="tableleft">状态：</th>
					<td class="tableright" colspan="3"><input name="ban.state" id="state" class="textinput" type="text"/></td>
				 </tr>
				 <tr>
				 	<th class="tableleft">描述：</th>
					<td class="tableright" colspan="3">
						<textarea class="textinput" name="description" id="description" style="width:550px;height:80px;overflow:hidden;">${ban.note}</textarea>
					</td>
				 </tr>
			 </table>
		</form>
	</div>
</div>