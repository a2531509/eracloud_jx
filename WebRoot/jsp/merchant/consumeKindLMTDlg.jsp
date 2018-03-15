<%@ page language="java" import="java.util.*" pageEncoding="utf-8"%>
<%@ taglib prefix ="s" uri="/struts-tags"%>
<script type="text/javascript">
	
	$(function() {
		$.autoComplete({
			id:"merchantId",
			text:"merchant_name",
			value:"merchant_id",
			table:"base_merchant",
			where:"merchant_state = '0'",
			keyColumn:"merchant_id,merchant_name",
			minLength:1,
			reverse:true
		});
		
		
		$("#form").form({
			url :"merchantRegister/merchantRegisterAction!saveMerchantConAccKind.action",
			data: $('#form').serialize(),
			onSubmit : function() {
				if($("#merchantId").val()==''){
					parent.$.messager.show({
						title :'系统消息',
						msg : '商户名称不能空！',
						timeout : 1000 * 3
	    			});
					return false;
				}
				parent.$.messager.progress({
					title : '提示',
					text : '数据处理中，请稍后....'
				});
				
				var isValid = $(this).form('validate');
				if (!isValid) {
					parent.$.messager.progress('close');
				}
				return isValid;
				//验证输入框的值
				
			},
			success:function(result) {
				parent.$.messager.progress('close');
				result = $.parseJSON(result);
				if (result.status) {
					parent.reload;
					parent.$.modalDialog.openner.datagrid('reload',{
						queryType:'0'});
					parent.$.modalDialog.handler.dialog('close');
					parent.$.messager.show({
						title :  result.title,
						msg : result.message,
						timeout : 1000 * 2
					});
				}else{
					parent.$.messager.show({
						title :  result.title,
						msg : result.message,
						timeout : 1000 * 2
					});
				}
			}
		});
	});
		
	
</script>
<style>
	
</style>
<div class="easyui-layout" data-options="fit:true,border:false">
	<div data-options="region:'center',border:false" title="" style="overflow: hidden;padding: 10px;">
		<form id="form" method="post">
		       <input name ="checkValueType" id = "checkValueType" type="hidden">
			<fieldset>
				<legend><img src="extend/fromedit.png" style="margin-bottom: -3px;"/>商户消费账户信息</legend>
				 <table>
				 	  <tr>
						<th>配置说明:</th>
						<td colspan ="3">
						<span style="color:red">勾选的项表示该商户准许卡的相应账户消费</span>
						</td>
					</tr>
					<tr>
						<th>商户名称</th>
						<td colspan ="3"><input name="merchantId" id="merchantId" value="${merLmt.merchantId}"  class="textinput easyui-validatebox" type="text" /></td>
					</tr>
					 <tr>
						<th>账户类型</th>
						<td id="checkBoxall" colspan ="3">
						</td>
					 </tr>
				 </table>
			</fieldset>
			</form>
	</div>
</div>
