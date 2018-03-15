<%@ page language="java" import="java.util.*" pageEncoding="UTF-8"%>
<%@ taglib prefix="shiro" uri="http://shiro.apache.org/tags" %>
<%
	String path = request.getContextPath();
	String basePath = request.getScheme()+"://"+request.getServerName()+":"+request.getServerPort()+path+"/";
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"  "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html>
  <head>
    <base href="<%=basePath%>">
    <title>柜员调剂</title>
	<meta http-equiv="pragma" content="no-cache">
	<meta http-equiv="cache-control" content="no-cache">
	<meta http-equiv="expires" content="0">    
<style type="text/css">
	.combobox-item{
		cursor:pointer;
	}
</style>
<jsp:include page="../../layout/script.jsp"></jsp:include>
<script type="text/javascript"> 
$(function() {
	if('${defaultErrorMsg}'.replace(/\s/g,'').length > 0){
		$.messager.alert('系统消息','${defaultErrorMsg}','error');//
	}
	$("#availableAmt").validatebox({required:true,validType:"email",invalidMessage:"<span style=\"color:red\">柜员最大可调剂金额 = 柜员现有总余额 - 财务未确认金额（冻结金额）</span>",missingMessage:"<span style=\"color:red\">柜员最大可调剂金额 = 柜员现有总余额 - 财务未确认金额（冻结金额）</span>"});
	$("#out_blc").validatebox({required:true,validType:"email",invalidMessage:"请输入调剂金额<br/><span style=\"color:red\">提示：调剂金额不能大于最大可调剂金额。</span>",missingMessage:"请输入调剂金额<br/><span style=\"color:red\">提示：调剂金额不能大于最大可调剂金额。</span>"});
	
	$("#operatorId").combobox({
		url:"recharge/rechargeAction!getBranchSupervisor.action",
		valueField:"operId",
		textField:"name",
		loadFilter:function(data){
			var d = [{operId:"", name:"请选择"}];
			
			if(data || data.rows){
				var rows = data.rows;
				for(var i in rows){
					if(rows[i].dutyId >= 1){
						d.push(rows[i]);
					}
				}
			}
			
			return d;
		}
	});
});
//提交
function subTj(){
	var out_blc = $('#out_blc').val();
	var inTellerPwd = $('#inTellerPwd').val();
	if(out_blc.replace(/\s/g,'').length == 0){
		$.messager.alert('系统消息','请输入调剂金额！','error',function(){
		});
		return;
	}
	if($("#operatorId").combobox('getValue') == ''){
		$.messager.alert('系统消息','请选择调剂接收柜员！','error',function(){
			if($("#operatorId").combobox('getValue') == ''){
				$("#operatorId").combobox('showPanel');
			}
		});
		return;
	}
	var exp = /^\d*(\.\d{1,2})?$/g;
	if(!exp.test(out_blc)){
		$.messager.alert('系统消息','调剂金额输入不符合格式！','error',function(){
			
		});
		return;
	}
	if(parseFloat($('#availableAmt').val()) != parseFloat($('#out_blc').val())){
		$.messager.alert('系统消息','调剂金额与柜员尾箱可用余额<' + $('#td_blc22').val() + '>不相等！','error',function(){
			
		});
		return;
	}
	if(parseFloat($('#out_blc').val()) == 0){
		$.messager.alert('系统消息','调剂金额不能等于0','error',function(){
			
		});
		return;
	}
	if(inTellerPwd.replace(/\s/g,'').length == 0){
		$.messager.alert('系统消息','请输入收方柜员密码！','error',function(){
			$('#inTellerPwd').focus();
		});
		return;
	}
	$.messager.confirm('系统消息','您确定要向【' + $("#operatorId").combobox('getText') + "】调剂【" + $('#out_blc').val() + "】元吗？",function(is){
		if(is){
			$.messager.progress({
				text : '数据处理中，请稍后....'
			});
			$.get('cashManage/cashManageAction!toSaveTellerTransfer.action',$('#tellerTransfer').serialize(), function(data,status){
				$.messager.progress('close');
				if(status == 'success'){
					$.messager.alert('系统消息',data.message,(data.status == '0' ? 'info' : 'error'),function(){
						//如果返回成功，打印凭证刷新页面
						if(data.status == '0'){
							showReport('柜员现金调剂',data.dealNo,function(){
								window.location.href = window.location.href + "?mm=" + Math.random();
							});
						//如果失败，则判断是否刷新页面
						}else{
							if(data.isreload == '0'){
								window.location.href = window.location.href + "?mm=" + Math.random();
							}
						}
					});
				}else{
					$.messager.alert('系统消息','调剂出现错误，请重试!','error',function(){
						window.history.go(0);
					});
				}
			},'json');
		}
	});
}
function validRmb(obj){
	var v = obj.value;
	var exp = /^\d*(\.?\d{0,2})?$/g;
	if(!exp.test(v)){
		obj.value = v.substring(0,v.length - 1);
	}
}
</script>
</head>
<body class="easyui-layout datagrid-toolbar" data-options="fit:true">
  	<div data-options="region:'north',border:false" title="" style="height:auto;overflow:hidden;">
		<div class="well well-small datagrid-toolbar" style="margin-left:0px;margin-right:0px;margin-top: 2px;margin-bottom: 2px;">
			<span class="badge">提示</span>
			<span>在此你可以对<span class="label-info"><strong>柜员尾箱进行调剂！</strong></span></span>
		</div>
	</div>
	<div data-options="region:'center',split:false,border:false,fit:true">
		<form id="tellerTransfer">
			<div title="当前柜员尾箱信息" class="easyui-panel" style="border-left:none;" data-options="iconCls:'icon-grid-title'">   
			   <table cellpadding="0" cellspacing="0" style="width:100%;border-left:none;" class="tablegrid datagrid-toolbar">
					<tr>
						<td class="tableleft" width="10%" height="30">所属网点：</td>
						<td class="tableright" width="22%"><input id="currentBranchId" type="text" readonly="readonly" disabled="disabled" value="${currentBranchName}" class="textinput" name="currentBranchId"  style="width:174px;"/></td>
						<td class="tableleft" width="10%">柜员名称：</td>
						<td class="tableright" width="22%"><input id="currentOperatorId" type="text" readonly="readonly" disabled="disabled" value="${currentOperatorName}" class="textinput" name="currentOperatorId"  style="width:174px;"/></td>
						<td class="tableleft" width="10%">今日结余：</td>
						<td class="tableright" width="21%"><input id="td_blc" type="text" readonly="readonly" disabled="disabled" value="${td_blc}" class="textinput" name="td_blc"  style="width:174px;"/><span style="color:red;margin-left:10px;font-size:9px;">单位：元</span></td>
					</tr>
				</table>
			</div> 
			<div title="调剂信息" class="easyui-panel"  data-options="fit:true,border:false,iconCls:'icon-grid-title'" style="border-left:none;border-bottom:none;">
				<table cellpadding="0" cellspacing="0" style="width:100%;" class="tablegrid datagrid-toolbar">
					<tr>
						<td class="tableleft" width="10%">所属网点：</td>
						<td class="tableright" width="22%"><input id="branchId" type="text" class="textinput" readonly="readonly" value="${currentBranchName}" style="width:177px;"/></td>
						<td class="tableleft" width="10%">主管名称：</td>
						<td class="tableright" width="22%"><input id="operatorId" type="text" class="textinput" name="operatorId"  style="width:177px;"/></td>
						<td class="tableleft" width="10%">冻结金额：</td>
						<td class="tableright" width="21%"><input id="td_blc22" type="text" readonly="readonly"  value="${frzAmt}" class="textinput" name="td_blc22"  style="width:174px;"/><span style="color:red;margin-left:10px;font-size:9px;">单位：元</span></td>
					</tr>
					<tr>
						<td class="tableleft">最大可调剂金额：</td>
						<td class="tableright"><input id="availableAmt" type="text" readonly="readonly"  value="${availableAmt}" class="textinput" name="availableAmt"  style="width:174px;"/><span style="color:red;margin-left:10px;font-size:9px;">单位：元</span></td>
						<td class="tableleft">调剂金额：</td>
						<td class="tableright"><input id="out_blc" type="text" readonly="readonly" value="${availableAmt}" class="textinput easyui-validatebox" name="out_blc"  style="width:174px;" onkeyup="validRmb(this)" onkeydown="validRmb(this)"/><span style="color:red;margin-left:10px;font-size:9px;">单位：元</span></td>
						<td class="tableleft">主管密码：</td>
						<td colspan="1" class="tableright"><input id="inTellerPwd" type="password" class="textinput" maxlength="6" name="inTellerPwd"  style="width:174px;"/></td>
					</tr>
					<tr>
						<td colspan="6" align="center" style="padding-left:2px;height:80px;">
							<a style="text-align:center;margin:0 auto;margin-right:100px;" data-options="iconCls:'icon-ok'" href="javascript:void(0);" class="easyui-linkbutton" onclick="subTj()">确认调剂</a>
						</td>
					</tr>
				</table>
			</div>
		</form>
	  </div>
</body>
</html>