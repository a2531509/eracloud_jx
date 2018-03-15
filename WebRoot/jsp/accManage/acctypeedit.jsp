<%@ page language="java" import="java.util.*" pageEncoding="utf-8"%>
<%@ taglib prefix="s" uri="/struts-tags" %>
<style>
	.tablegrid th{font-weight:700}
</style>
<script type="text/javascript">
	//页面初始化控件
	$(function() {
		addNumberValidById("accKindId");
		if(dealNull("${defaultErrorMsg}") != ""){
			$.messager.alert("系统消息","${defaultErrorMsg}","error");
		}
		$("#accKindId").validatebox({required:true,validType:"email",invalidMessage:"请输入账户类型编码<br/><span style=\"color:red\">提示：账户类型编码为有效的2位数字组成</span>",missingMessage:"请输入账户类型编码<br/><span style=\"color:red;\">提示：账户类型编码为有效的2位数字组成</span>"});
		$("#accName").validatebox({required:true,validType:"email",invalidMessage:"请输入账户类型名称<br/><span style=\"color:red\">提示：账户名称长度最大值为10</span>",missingMessage:"请输入账户类型名称<br/><span style=\"color:red\">提示：账户名称长度最大值为10</span>"});
		$("#accKindId").validatebox("validate");
		$("#accName").validatebox("validate");
		//账户类型状态
		$("#accKindState").combobox({
			width:174,
			valueField:'codeValue',
			editable:false,
			value:"0",
		    textField:"codeName",
		    panelHeight:'auto',
		    data:[{codeValue:'0',codeName:"有效"},{codeValue:'1',codeName:"注销"}]
		});
		$("#aloneActivateFlag").combobox({
			width:174,
			valueField:'codeValue',
			editable:false,
			value:"1",
		    textField:"codeName",
		    panelHeight:'auto',
		    data:[{codeValue:'',codeName:"请选择"},{codeValue:'0',codeName:"是"},{codeValue:'1',codeName:"否"}]
		});
		if("${accKind}" != ""){
			$("#accKindState").combobox("disable");
		}
	});
	//表单提交
	function save(oldgrid){
		if(dealNull(document.getElementById("accKindId").value).length == 0){
			$.messager.alert("系统消息","账户类型编码不能为空！","error",function(){
				document.getElementById("accKindId").focus();
			});
			return false;
		}
		if(dealNull($("#accName").val()).length == 0){
			$.messager.alert("系统消息","账户类型名称不能为空！","error",function(){
				$("#accName").focus();
			});
			return false;
		}
		if(dealNull($("#accKindState").combobox("getValue")).length == 0){
			$.messager.alert("系统消息","请选择账户类型状态！","error",function(){
				$("#accKindState").combobox('showPanel');
			});
			return false;
		}
		if(dealNull($("#aloneActivateFlag").combotree("getValue")).length == 0){
			$.messager.alert("系统消息","请选择账户类型是否需要单独激活！","error",function(){
				$("#aloneActivateFlag").combotree('showPanel');
			});
			return false;
		}
		$.messager.confirm("系统消息","您确认要<s:if test='%{accKind == \"\"}'>新增账户类型</s:if><s:else>编辑账户类型</s:else>【" + $("#accKindId").val() + "】吗？",function(r){
			if(r){
				$.messager.progress({title : '提示',text : '数据处理中，请稍后....'});
				$("#note").val(document.getElementById("description").value);//设置备注
				$.post("accountManager/accountManagerAction!accTypeSave.action",$("form").serialize(),function(data,status){
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
		return true;
	}
</script>
<div class="easyui-layout" data-options="fit:true,border:false" style="background-color:rgb(245,245,245);">
	<div data-options="region:'center',border:false,fit:true" title="" style="overflow: hidden;padding:0px;background-color:rgb(245,245,245);">
		<form id="form" method="post">
			<h3 class="subtitle"><s:if test='%{accKind == ""}'>新增账户类型</s:if><s:else>编辑账户类型</s:else></h3>
			<input name="queryType" id="queryType" type="hidden" value="${queryType}" />
			<input name="accKindConfig.note" id="note" type="hidden"/>
			<input name="accKind" id="accKind" type="hidden" value="${accKind}"/>
			<input name="accState" id="accState" type="hidden" value="${accKindConfig.accKindState}"/>
			<table class="tablegrid" width="100%">
				 <tr>
				    <th class="tableleft"  width="25%">账户类型编码 ：</th>
					<td class="tableright" width="25%"><input value="${accKindConfig.accKind}" name="accKindConfig.accKind" id="accKindId" class="textinput" type="text" <s:if test='%{accKind != ""}'>disabled="disabled"</s:if> maxlength="2" /></td>
				 	<th class="tableleft"  width="25%">账户类型名称：</th>
					<td class="tableright" width="25%"><input value="${accKindConfig.accName}" name="accKindConfig.accName" id="accName"  type="text" class="textinput" maxlength="10"/></td>
				 </tr>
				 <tr>
				    <th class="tableleft">账户类型状态：</th>
					<td class="tableright"><input value="${accKindConfig.accKindState}"   name="accKindConfig.accKindState"  id="accKindState"  class="easyui-validatebox" type="text" class="textinput" data-options="validType:'email',invalidMessage:'请选择账户类型状态',missingMessage:'请选择账户类型状态'"/></td>
					<th class="tableleft">是否需要单独激活：</th>
					<td class="tableright"><input value="${accKindConfig.aloneActivateFlag}" name="accKindConfig.aloneActivateFlag"  id="aloneActivateFlag" class="easyui-validatebox"  type="text" class="textinput" data-options="validType:'email',invalidMessage:'请选择是否需要单独激活',missingMessage:'请选择是否需要单独激活'"/></td>
				 </tr>
				 <tr>
				    <th class="tableleft">排序序号：</th>
					<td class="tableright" colspan="3"><input value="${accKindConfig.ordNo}"   name="accKindConfig.ordNo"   id="ordNo"  class="textinput easyui-validatebox" type="text" class="textinput" data-options="validType:'email',invalidMessage:'请选择账户类型排序序号',missingMessage:'请选择账户类型排序序号'"/></td>
				 </tr>
				 <tr>
					<th class="tableleft">描述：</th>
					<td class="tableright" colspan="3">
						<textarea class="textinput" name="description" id="description" style="width:565px;height:80px;overflow:hidden;">${accKindConfig.note}</textarea>
					</td>
				</tr>
			 </table>
		</form>
	</div>
</div>
