<%@ page language="java" import="java.util.*" pageEncoding="utf-8"%>

<script type="text/javascript">
$(function() {
	
$("#form").form({
	
	url :"baseVendor/baseVendorAction!saveBaseVendor.action",
	data: $('#form').serialize(),
	onSubmit : function() {
		if($("#vendorId").val().length>4){
			parent.$.messager.show({
				title :'系统消息',
				msg : '对不起，厂商编号信息输入过长，请输入小于4个字符',
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
				<legend><img src="extend/fromedit.png" style="margin-bottom: -3px;"/>卡商信息编辑</legend>
				
				 <table>
					 <tr>
					    <th>厂商编号</th>
						<td>
							<input name="baseVendor.vendorId"  id="vendorId" value="${baseVendor.vendorId}" class="textinput easyui-validatebox" data-options="panelHeight: 'auto',editable:false" maxlength="10" required="required" style="width:174px;"  />
						</td>
						<th>厂商名称</th>
						<td>
							<input name="baseVendor.vendorName"  id="vendorName" value="${baseVendor.vendorName}" class="textinput easyui-validatebox" data-options="panelHeight: 'auto',editable:false"  maxlength="20" required="required" style="width:174px;"  />
						</td>
						<th>制卡方式</th>
						<td>
							<input name="baseVendor.makeWay"  id="makeWay" value="${baseVendor.makeWay}" class="easyui-combobox easyui-validatebox"  data-options="panelHeight: 'auto',editable:false,
							                    valueField: 'label',
												textField: 'value',
												data: [{
													label: '',
													value: '请选择'
												},{
													label: '0',
													value: '本地'
												},{
													label: '1',
													value: '外包'
												}]"  style="width:174px;"  />
						</td>
					 </tr>
					 <tr>
						<th>厂商地址</th>
						<td>
							<input name="baseVendor.address"  id="address"  maxlength="30" value="${baseVendor.address}"  class="textinput easyui-validatebox"    data-options="panelHeight: 'auto',editable:false"  style="width:174px;"/>
						</td>
						<th>联系人</th>
						<td>
							<input name="baseVendor.contact"  id="contact" maxlength="20" value="${baseVendor.contact}" class="textinput easyui-validatebox" data-options="panelHeight: 'auto',editable:false"   style="width:174px;" />
						</td>
						<th>联系人电话</th>
						<td>
							<input name="baseVendor.CTelNo" id="CTelNo" maxlength="20" value="${baseVendor.CTelNo}" class="textinput easyui-validatebox"     data-options="panelHeight: 'auto'"  style="width:174px;"/>
						</td>
					</tr>
					<tr>
						<th>单位负责人</th>
						<td><input name="baseVendor.ceoName" id="ceoName"  maxlength="20" value="${baseVendor.ceoName}"  class="textinput easyui-validatebox" data-options="panelHeight: 'auto'" type="text" />
						</td>
						<th>负责人电话</th>
						<td><input name="baseVendor.ceoTelNo" id="ceoTelNo"  maxlength="20" value="${baseVendor.ceoTelNo}"  class="textinput easyui-validatebox" data-options="panelHeight: 'auto'"  style="width:174px;"   />
						</td>
						<th>传真号码</th>
						<td><input name="baseVendor.faxNo" id="faxNo"  maxlength="20" value="${baseVendor.faxNo}"  class="textinput easyui-validatebox"  type="text" style="width:174px;" />
						</td>
					</tr>
					<tr>
						<th>EMAIL</th>
						<td><input name="baseVendor.email" id="email"  maxlength="20" value="${baseVendor.email}"  class="textinput easyui-validatebox" data-options="panelHeight: 'auto'" type="text" />
						</td>
						<th>邮政编码</th>
						<td><input name="baseVendor.postCode" id="postCode"  maxlength="20" value="${baseVendor.postCode}"  class="textinput easyui-validatebox" data-options="panelHeight: 'auto'"  style="width:174px;"   />
						</td>						
					</tr>	
				 </table>
			</fieldset>
			</form>
	</div>
</div>
