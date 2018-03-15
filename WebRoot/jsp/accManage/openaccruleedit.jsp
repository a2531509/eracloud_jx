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
		//账户规则状态
		$("#confState").combobox({
			width:174,
			valueField:"codeValue",
			editable:false,
			value:"0",
		    textField:"codeName",
		    panelHeight:'auto',
		    data:[{codeValue:'0',codeName:"有效"},{codeValue:'1',codeName:"注销"}]
		});
		//账户初始化状态
		$("#accInitState").combobox({
			width:174,
			valueField:'codeValue',
			editable:false,
			value:"0",
		    textField:"codeName",
		    panelHeight:'auto',
		    data:[{codeValue:'0',codeName:"正常"},{codeValue:'1',codeName:"未激活"}]
		});
		//构建卡类型,并进行禁用
		createSysCode({
			id:"subType",
			codeType:"CARD_TYPE"
		});
		$("#subType").combobox("disable");
		//账户类型初始化,并进行禁用
		createSysCode({
			id:"accKind",
			codeType:"ACC_KIND"
		});
		createSysCode({
			id:"mainType",
			codeType:"MAIN_TYPE",
			onSelect:function(row){
				if(row.VALUE == '1'){//卡
					$("#subType").combobox("enable");
					$("#accKind").combobox("enable");
				}else{//其他
					$("#subType").combobox("disable");
					$("#accKind").combobox("setValue",'00');
					$("#accKind").combobox("disable");
				}
				if(row.VALUE != ""){
					$("#itemId").combobox("clear");
					$("#itemId").combobox("reload","accountManager/accountManagerAction!itemTypeQuery.action?subjectType=" + row.VALUE);
				}
			}
		});
		//编辑时信息初始化
		if("${accOpenConf.mainType}" != ""){
			$("#mainType").combobox("setValue","${accOpenConf.mainType}");
			$("#mainType").combobox("disable");
		}
		//编辑时卡类型初始化
		if("${accOpenConf.subType}" != ""){
			$("#subType").combobox("setValue","${accOpenConf.subType}");
			$("#subType").combobox("enable");
		}
		if("${accOpenConf.subType}" != ""){
			$("#accKind").combobox("setValue","${accOpenConf.accKind}");
			$("#accKind").combobox("enable");
		}else{
			$("#accKind").combobox("setValue",'00');
			$("#accKind").combobox("disable");
		}
		//编辑时规则状态初始化
		if("${accOpenConf.confState}" != ""){
			$("#confState").combobox("setValue","${accOpenConf.confState}");
			$("#confState").combobox("disable");
		}
		//编辑时规则状态初始化
		if("${accOpenConf.accInitState}" != ""){
			$("#accInitState").combobox("setValue","${accOpenConf.accInitState}");
		}
		$("#itemId").combobox({
			width:174,
			url:"accountManager/accountManagerAction!itemTypeQuery.action?subjectType=" + "${accOpenConf.mainType}",
			valueField:'ITEM_NO',
			editable:false,//不可编辑状态
		    textField:'ITEM_NAME',
		    panelHeight:'auto',//自动高度适合
		    onLoadSuccess:function(){
		    	if($("#mainType").combobox("getValue") == "1"){
		    		$("#itemId").combobox("setValue","201101");
		    		$("#itemId").combobox("disable");
		    	}else{
		    		if("${accOpenConf.itemId}" != ""){
		    			$("#itemId").combobox("setValue","${accOpenConf.itemId}");
		    		}
		    		$("#itemId").combobox("enable");
		    	}
		    }
		});
	});
	//表单提交
	function save(oldgrid){
		if(dealNull($("#mainType").combobox("getValue")).length == 0){
			$.messager.alert("系统消息","账户开户规则主类型不能为空！","error",function(){
				$("#mainType").combobox("showPanel");
			});
			return false;
		}
		if($("#mainType").combobox("getValue") == "1"){
			if(dealNull($("#subType").combobox("getValue")).length == 0){
				$.messager.alert("系统消息","账户开户主类型已选择【" + $("#mainType").combobox("getText") + "】，请选择卡类型！","error",function(){
					$("#subType").combobox("showPanel");
				});
				return false;
			}
		}
		if($("#confState").combobox("getValue") == ""){
			$.messager.alert("系统消息","请选择开户规则状态！","error",function(){
				$("#confState").combobox("showPanel");
			});
			return false;
		}
		if(dealNull($("#accInitState").combobox("getValue")).length == 0){
			$.messager.alert("系统消息","请选择账户初始化状态！","error",function(){
				$("#accInitState").combobox('showPanel');
			});
			return false;
		}
		if(dealNull($("#accKind").combotree("getValue")).length == 0){
			$.messager.alert("系统消息","请选择账户类型！","error",function(){
				$("#accKind").combotree('showPanel');
			});
			return false;
		}
		if(dealNull($("#itemId").combotree("getValue")).length == 0){
			$.messager.alert("系统消息","请选择开户科目！","error",function(){
				$("#itemId").combotree('showPanel');
			});
			return false;
		}
		$.messager.confirm("系统消息","您确认要<s:if test='%{queryType == \"0\"}'>新增该账户开户规则</s:if><s:else>编辑该账户开户规则</s:else>",function(r){
			if(r){
				$.messager.progress({title : '提示',text : '数据处理中，请稍后....'});
				$.post("accountManager/accountManagerAction!saveOpenRuleConf.action",{
					"queryType":$("#queryType").val(),"accOpenConf.mainType":$("#mainType").combobox("getValue"),"accOpenConf.subType":$("#subType").combobox("getValue"),
					"accOpenConf.confState":$("#confState").combobox("getValue"),"accOpenConf.accInitState":$("#accInitState").combobox("getValue"),
					"accOpenConf.accKind":$("#accKind").combotree("getValue"),"accOpenConf.itemId":$("#itemId").combobox("getValue"),"ruleId":$("#ruleId").val()
				},function(data,status){
					$.messager.progress('close');
					$.messager.alert("系统消息",data.msg,(data.status == "0" ? "info" : "error"),function(){
						if(data.status == "0"){
							oldgrid.datagrid("reload");
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
			<s:hidden id="queryType" name="queryType"></s:hidden><!-- queryType == 0 新增 queryType == 1 编辑 -->
			<s:hidden id="ruleId" name="ruleId"></s:hidden><!-- 编辑时隐藏存放规则ID -->
			<h3 class="subtitle"><s:if test='%{queryType == "0"}'>新增账户开户规则</s:if><s:else>编辑账户开户规则</s:else></h3>
			<table class="tablegrid" style="width:100%">
				 <tr>
				    <th class="tableleft" style="width:15%">账户主体：</th>
					<td class="tableright" style="width:25%"><input name="accOpenConf.mainType" id="mainType" type="text"  class="textinput" /></td>
				 	<th class="tableleft"  style="width:25%">卡类型：</th>
					<td class="tableright" style="width:35%"><input name="accOpenConf.subType" id="subType"  type="text" class="textinput" /></td>
				 </tr>
				 <tr>
				    <th class="tableleft">状态：</th>
					<td class="tableright"><input name="accOpenConf.confState" id="confState" class="textinput" type="text"/></td>
					<th class="tableleft">账户初始化状体：</th>
					<td class="tableright"><input name="accOpenConf.accInitState"  id="accInitState" type="text" class="textinput"/></td>
				 </tr>
				 <tr>
				    <th class="tableleft">账户类型：</th>
					<td class="tableright"><input name="accOpenConf.accKind" id="accKind" type="text" class="textinput"/></td>
					<th class="tableleft">科目：</th>
					<td class="tableright" ><input name="accOpenConf.itemId" id="itemId" type="text" class="textinput"/></td>
				 </tr>
			 </table>
		</form>
	</div>
</div>