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
		 
		 $('#consumeMode').combogrid({    
			    panelWidth:388, 
			    idField:'modeId',    
			    textField:'modeName', 
			    multiple:false,
			    url:'merchantRegister/merchantRegisterAction!getConsumeModeSqn.action',    
			    columns:[[    
			        {field:'modeId',title:'模式编号',width:60},    
			        {field:'modeName',title:'模式名称',width:100},    
			        {field:'accSqn',title:'消费账户',width:120},    
			        {field:'modeState',title:'状态',width:100}    
			    ]]    
			});  
		
		
		$("#form").form({
			url :"merchantRegister/merchantRegisterAction!saveMerGetCosMode.action",
			data: $('#form').serialize(),
			onSubmit : function() {
				if($("#merchantId").val()==''){
					 $.messager.alert('系统消息','商户名称不能空','error');
					return false;
				}
				if($("#consumeMode").combobox('getValues')==''){
					$.messager.alert('系统消息','消费模式不能为空','error');
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
	.textinput{
		height: 18px;
		width: 170px;
		line-height: 16px;
	    /*border-radius: 3px 3px 3px 3px;*/
	    box-shadow: 0 1px 1px rgba(0, 0, 0, 0.075) inset;
	    transition: border 0.2s linear 0s, box-shadow 0.2s linear 0s;
	}
	
	textarea:focus, input[type="text"]:focus{
	    border-color: rgba(82, 168, 236, 0.8);
	    box-shadow: 0 1px 1px rgba(0, 0, 0, 0.075) inset, 0 0 8px rgba(82, 168, 236, 0.6);
	    outline: 0 none;
		}
		table {
	    background-color: transparent;
	    border-collapse: collapse;
	    border-spacing: 0;
	    max-width: 100%;
	}

	fieldset {
	    border: 0 none;
	    margin: 0;
	    padding: 0;
	}
	legend {
	    -moz-border-bottom-colors: none;
	    -moz-border-left-colors: none;
	    -moz-border-right-colors: none;
	    -moz-border-top-colors: none;
	    border-color: #E5E5E5;
	    border-image: none;
	    border-style: none none solid;
	    border-width: 0 0 1px;
	    color: #999999;
	    line-height: 20px;
	    display: block;
	    margin-bottom: 10px;
	    padding: 0;
	    width: 100%;
	}
	input, textarea {
	    font-weight: normal;
	}
	table ,th,td{
		text-align:left;
		padding: 6px;
	}
</style>
<div class="easyui-layout" data-options="fit:true,border:false">
	<div data-options="region:'center',border:false" title="" style="overflow: hidden;padding: 10px;">
		<form id="form" method="post">
			<fieldset>
				<legend><img src="extend/fromedit.png" style="margin-bottom: -3px;"/>商户消费模式信息</legend>
				 <table>
				 	  <tr>
						<th>页面说明:</th>
						<td colspan ="3">
						<span style="color:red">在商户进行消费之前，需要设置该商户准许消费的消费模式</span>
						</td>
					</tr>
					 <tr>
					    <th>商户名称</th>
						<td><input name="merchantId" id="merchantId" value="${merchantId}"  class="textinput easyui-validatebox" type="text" /></td>
					 	<th>消费模式</th>
						<td>
							<input id="consumeMode" name="consumeMode"/>  
						</td>
					 </tr>
				 </table>
			</fieldset>
			</form>
	</div>
</div>
