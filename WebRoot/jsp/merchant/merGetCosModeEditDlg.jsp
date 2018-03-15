<%@ page language="java" import="java.util.*" pageEncoding="utf-8"%>
<%@ taglib prefix ="s" uri="/struts-tags"%>
<script type="text/javascript">
	$(function(){
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
		
		 $("#modeState02").combobox({
				width:174,
				valueField:'codeValue',
				value:"",
			    textField:"codeName",
			    editable:false,
			    panelHeight:'auto',
			    data:[{codeValue:'',codeName:"请选择"},{codeValue:'0',codeName:"启用"},{codeValue:'1',codeName:"停用"}]
			});
		 $('#dg').datagrid({
			    url:'/merchantRegister/merchantRegisterAction!getConsumeModeSqn.action?modeId='+$('#modeId').val(),    
			    columns:[[    
			        {field:'modeName',title:'模式名称',width : parseInt($(this).width() * 0.112)},    
			        {field:'accSqn',title:'消费账户列表顺序',width : parseInt($(this).width() * 0.112)},  
			        {field:'reaccType',title:'退货账户列表顺序',width : parseInt($(this).width() * 0.112)}, 
			        {field:'reaccTypeBak',title:'默认退货账户列表顺序',width : parseInt($(this).width() * 0.112)}, 
			    ]]    
		});  
		
		
		$("#form").form({
			url :"merchantRegister/merchantRegisterAction!saveMerGetCosModeEdit.action",
			data: $('#form').serialize(),
			onSubmit : function() {
				if($("#merchantId").val()==''){
					 $.messager.alert('系统消息','商户名称不能空','error');
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

<div class="easyui-layout" data-options="fit:true,border:false">
	<div data-options="region:'center',border:false" title="" style="overflow: hidden;padding: 10px;">
		<form id="form" method="post">
			<fieldset>
				<legend><img src="extend/fromedit.png" style="margin-bottom: -3px;"/>商户消费模式信息</legend>
				<input name="modeId" value="${modeId}" id="modeId"  type="hidden"/>
				 <table>
					 <tr>
					    <th>商户名称</th>
						<td><input name="merchantId" id="merchantId" value="${merchantId}"  class="textinput easyui-validatebox" type="text"  readonly="readonly"/></td>
					 	<th>商户消费模式状态</th>
						<td><input id ="modeState02" name="modeState"   value="${modeState}"  class="textinput" style="width:174px;">
						</td>
					 </tr>
				 </table>
				 <table id="dg" title="模式信息"></table>
			</fieldset>
			</form>
	</div>
</div>
