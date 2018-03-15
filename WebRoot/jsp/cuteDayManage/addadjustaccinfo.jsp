<%@ page language="java" import="java.util.*" pageEncoding="UTF-8"%>
<%@ taglib prefix="shiro" uri="http://shiro.apache.org/tags" %>
<%
	String path = request.getContextPath();
	String basePath = request.getScheme()+"://"+request.getServerName()+":"+request.getServerPort()+path+"/";
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"  "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<script type="text/javascript">

createLocalDataSelect("adjustType1",{
	 value:"",
	 data:[{value:"",text:"请选择"},{value:"01",text:"补交易"},{value:"02",text:"撤销交易"}]
});

function queryOldDealInfo(){
	if($("#dealNo1").textbox("getText") == ""){
		$.messager.alert("系统消息","请输入调账业务的原流水号！","error",function(){
			$("#dealNo1").focus();
		});
		return;
	}
	if($("#clrDate1").textbox("getText") == ""){
		$.messager.alert("系统消息","请输入调账业务所属的清分日期！","error",function(){
			$("#clrDate1").focus();
		});
		return;
	}
	$.messager.progress({text : "正在获取交易信息,请稍后..."});
	fillintext();
}

function fillintext(){
	$.post("adjustSysAccAction/adjustSysAccAction!queryOldTradeInfo.action","dealNo=" + $("#dealNo1").textbox("getText")+"&clrDate="+$("#clrDate1").textbox("getText"),function(data,status){
		$.messager.progress("close");
		if(status == "success"){
			if(dealNull(data.status) == "1"){
				$.messager.alert("系统消息","获取交易信息错误！","error",function(){
					window.history.go(0);
				});
			}
			$("#acptId1").val(data.acptId);
			$("#endId1").val(data.endId);
			$("#batchId1").val(data.batchId);
			$("#endDealNo1").val(data.endDealNo);
			$("#cardNo1").val(data.cardNo);
			$("#trAmt1").val(data.trAmt);
		}else{
			$.messager.alert("系统消息","获取交易信息错误，请重试...","error",function(){
				window.history.go(0);
			});
		}
	},"json").error(function(){
		$.messager.alert("系统消息","获取交易信息错误，请重试...","error",function(){
			window.history.go(0);
		});
	});
}

function saveAdjustInfo(){
	if($("#clrDate1").textbox("getText") == ""){
		$.messager.alert("系统消息","请输入受理点编号！","error",function(){
			$("#clrDate1").focus();
		});
		return;
	}
	
	if($("#acptId1").val() == ""){
		$.messager.alert("系统消息","请输入受理点编号！","error",function(){
			$("#acptId1").focus();
		});
		return;
	}
	if($("#endId1").val() == ""){
		$.messager.alert("系统消息","请输入网点/终端编号！","error",function(){
			$("#endId1").focus();
		});
		return;
	}
	
	if($("#cardNo1").val() == ""){
		$.messager.alert("系统消息","请选择调账的市民卡卡号！","error",function(){
			$("#cardNo1").focus();
		});
		return;
	}
	
	if($("#trAmt1").val() == ""){
		$.messager.alert("系统消息","请选择调账金额！","error",function(){
			$("#trAmt1").focus();
		});
		return;
	}
	
	if($("#adjustType1").combobox("getValue") == ""){
		$.messager.alert("系统消息","请选择调账类型！","error",function(){
			$("#adjustType1").combobox("showPanel");
		});
		return;
	}
	
	$.messager.confirm("系统消息","您确定要新增调账信息吗？",function(r){
		 if(r){
			 $.messager.progress({title : '提示',text : '数据处理中，请稍后....'});
			 $.post("adjustSysAccAction/adjustSysAccAction!toSaveAddOrUpdateAdjustInfo.action",$("#form").serialize(),function(data,status){
				 $.messager.progress('close');
				 if(status == "success"){
					 $.messager.alert("系统消息",data.msg,(data.status == "0" ? "info" : "error"),function(){
						 if(data.status == "0"){
							 $dg.datagrid("reload");
							 $.modalDialog.handler.dialog('destroy');
							 $.modalDialog.handler = undefined;
						 }
					 });
				 }else{
					 $.messager.alert("系统消息",subtitle + "人员基本信息出现错误，请重新进行操作！","error");
					 return;
				 }
			 },"json");
		 }
	});
}
	
</script>
<div class="easyui-layout datagrid-toolbar" data-options="fit:true">
  	<div data-options="region:'north',border:false" title="" style="height:auto;overflow: hidden;">
 			<div class="well well-small datagrid-toolbar" style="margin-left:0px;margin-right:0px;margin-top: 2px;margin-bottom: 2px;">
			<span class="badge">提示</span><span>在此你可以对系统需要调整的账务进行<span class="label-info"><strong>登记并调整</strong></span>操作!</span>
		</div>
	</div>
	<div class ="datagrid-toolbar" data-options="region:'center',border:true" style="height:auto;overflow: hidden;margin:0px;width:auto;border-left:none;border-bottom:none;">	
			<form action="">
				<table cellpadding="0" cellspacing="0" id="toolpanel" style="width:100%" class="tablegrid">
					<tr>
						<td class="tableleft">业务流水号：</td>
						<td class="tableright"><input name="dealNo" data-options="required:true,invalidMessage:'请输入业务流水号',missingMessage:'请输入业务流水号'"  class="easyui-textbox easyui-validatebox" id="dealNo1"  type="text" maxlength="20"/>
						</td>
						<td class="tableleft">清分日期：</td>
						<td class="tableright">
							<input name="clrDate" data-options="required:true,invalidMessage:'请输入清分日期',missingMessage:'请输入清分日期'" class="easyui-textbox easyui-validatebox  easyui-datebox"  onclick="WdatePicker({dateFmt:'yyyy-MM-dd',qsEnabled:false,maxDate:'%y-%M-%d'})" id="clrDate1" type="text"/>
								<a  data-options="plain:false,iconCls:'icon-search'" href="javascript:void(0);" class="easyui-linkbutton"  onclick="queryOldDealInfo()">获取系统原交易</a>
						</td>
					</tr>
					<tr>
						<td class="tableleft">受理点编号：</td>
						<td class="tableright"><input name="acptId" data-options="required:true,invalidMessage:'请输入受理点编号',missingMessage:'请输入受理点编号'" class="textinput easyui-validatebox" id="acptId1" type="text"/></td>
						<td class="tableleft">终端号/柜员号：</td>
						<td class="tableright"><input name="endId" data-options="required:true,invalidMessage:'请输入终端号/柜员号',missingMessage:'请输入终端号/柜员号'" class="textinput easyui-validatebox" id="endId1" type="text"/></td>
					</tr>
					<tr>
						<td class="tableleft">批次号：</td>
						<td class="tableright"><input id="batchId" type="text" class="textinput" name="batchId1"/></td>
						<td class="tableleft">终端交易流水号：</td>
						<td class="tableright"><input name="endDealNo"  class="textinput" id="endDealNo1" type="text"/></td>
					</tr>
					<tr>
						<td class="tableleft">卡号：</td>
						<td class="tableright"><input id="cardNo" type="text" class="textinput" name="cardNo"/></td>
						<td class="tableleft">交易金额：</td>
						<td class="tableright"><input type="text" class="textinput" name="trAmt"  data-options="required:true,invalidMessage:'请输入交易金额',missingMessage:'请输入交易金额'" class="textinput easyui-validatebox" id="trAmt1" type="text"/></td>
					</tr>
					<tr>
						<td class="tableleft">调账类型：</td>
						<td class="tableright"><input id="adjustType1"  class="easyui-combobox easyui-validatebox" data-options="required:true" name="adjustType"/></td>
						<td class="tableleft">备注：</td>
						<td class="tableright"><input id="note1" type="text" class="textinput" name="note"/></td>
					</tr>
				</table>
		 	</form>
	</div>
</div>
