<%@ page language="java" import="java.util.*" pageEncoding="utf-8"%>

<script type="text/javascript">

$("#form").form({
	url :"BaseProvider/baseProviderAction!saveBaseProvider.action",
	data: $('#form').serialize(),
	onSubmit : function() {
		
		if($("#providerType").combobox("getValue")==""){
			$.messager.alert("系统消息","【供应商类型】不能为空，请选择供应商类型","error",function(){
				$("#providerType").combobox("showPanel");
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
			parent.reload;
			parent.$.modalDialog.openner.datagrid('reload',{
				queryType:'0'});
			parent.$.modalDialog.handler.dialog('close');
		}else{
			parent.$.messager.show({
				title :  result.title,
				msg : result.message,
				timeout : 1000 * 2
			});
		}
	}
	
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
				<legend><img src="extend/fromedit.png" style="margin-bottom: -3px;"/>供应商信息编辑</legend>
				<input name="basePro.providerId" id="providerId" value="${basePro.providerId}"  type="hidden"/>
				 <table>
					 <tr>
					    <th>供应商名称</th>
						<td>
							<input name="basePro.providerName"  id="providerName" value="${basePro.providerName}" class="textinput easyui-validatebox" data-options="panelHeight: 'auto',editable:false," required="required" maxlength="100" style="width:174px;"  />
						</td>
						<th>合同时段</th>
						<td>
							<input name="basePro.providerContract"  id="providerContract" value="${basePro.providerContract}" class="textinput easyui-validatebox" data-options="panelHeight: 'auto',editable:false,"  maxlength="100" style="width:174px;"  />
						</td>
						<th>供应类型</th>
						<td>
							<input name="basePro.providerType"  id="providerType" value="${basePro.providerType}" class="easyui-combobox easyui-validatebox"  data-options="panelHeight: 'auto',editable:false,
							                    valueField: 'label',
												textField: 'value',
												data: [{
													label: '',
													value: '请选择'
												},{
													label: '1',
													value: 'POS机具供应商'
												},{
													label: '2',
													value: '读写卡机具供应商'
												},{
													label: '3',
													value: 'PSAM卡供应商'
												}]"   style="width:174px;"  />
						</td>
					 </tr>
					 <tr>
						<th>供应商地址</th>
						<td>
							<input name="basePro.providerAddress"  id="providerAddress"  value="${basePro.providerAddress}" class="textinput easyui-validatebox"   data-options="panelHeight: 'auto',editable:false" maxlength="100" style="width:174px;"/>
						</td>
						<th>供应商电话</th>
						<td>
							<input name="basePro.providerTelNo"  id="providerTelNo" value="${basePro.providerTelNo}" class="textinput easyui-validatebox" data-options="panelHeight: 'auto',editable:false"  required="required" maxlength="20" style="width:174px;" />
						</td>
						<th>联系人</th>
						<td>
							<input name="basePro.providerLinkman" id="providerLinkman" value="${basePro.providerLinkman}" class="textinput easyui-validatebox"     data-options="panelHeight: 'auto'"  required="required" maxlength="20" style="width:170px;"/>
						</td>
					</tr>
					<tr>
						<th>供应商邮编</th>
						<td><input name="basePro.providerPost" id="providerPost"  value="${basePro.providerPost}"  class="textinput easyui-validatebox" maxlength="20" type="text" />
						</td>
						
					</tr>
				
					
					
				 </table>
			</fieldset>
			</form>
	</div>
</div>
