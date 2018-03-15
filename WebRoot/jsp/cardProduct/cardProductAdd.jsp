<%@ page language="java" import="java.util.*" pageEncoding="utf-8"%>

<script type="text/javascript">

$("#form").form({
	
	url :"cardProduct/CardProductAction!saveMerCardPro.action",
	data: $('#form').serialize(),
	onSubmit : function() {
		if($("#cardType").combobox("getValue")==""){
			$.messager.alert("系统消息","【卡片类型】不能为空，请选择卡片类型","error",function(){
				$("#cardType").combobox("showPanel");
			});
			return false;
		}
		
		if($("#chipType").combobox("getValue")==""){
			$.messager.alert("系统消息","【芯片类型】不能为空，请选择芯片类型","error",function(){
				$("#chipType").combobox("showPanel");
			});
			return false;
		}
		if($("#isBankstripe").combobox("getValue")==""){
			$.messager.alert("系统消息","【磁条类型】不能为空，请选择磁条类型","error",function(){
				$("#isBankstripe").combobox("showPanel");
			});
			return false;
		}
		if($("#mediType").combobox("getValue")==""){
			$.messager.alert("系统消息","【介质类型】不能为空，请选择介质类型","error",function(){
				$("#mediType").combobox("showPanel");
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
				<legend><img src="extend/fromedit.png" style="margin-bottom: -3px;"/>卡片信息编辑</legend>
				 <table>
					 <tr>
					    <th>卡片类型</th>
						<td>
							<input name="cardPro.cardType"  id="cardType" value="${cardPro.cardType}" class="easyui-combobox easyui-validatebox" data-options="panelHeight: 'auto',editable:false,
												valueField: 'label',
												textField: 'value',
												data: [{
													label: '',
													value: '请选择'
												},{
													label: 'A卡',
													value: 'A卡'
												},{
													label: 'B卡',
													value: 'B卡'
												},{
													label: 'C卡',
													value: 'C卡'
												}]"   style="width:174px;"  />
						</td>
						<th>芯片类型</th>
						<td>
							<input name="cardPro.chipType"  id="chipType" value="${cardPro.chipType}" class="easyui-combobox easyui-validatebox" data-options="panelHeight: 'auto',editable:false,
												valueField: 'label',
												textField: 'value',
												data: [{
													label: '',
													value: '请选择'
												},{
													label: '1',
													value: '单接触式CPU'
												},{
													label: '2',
													value: '单接非触式CPU'
												},{
													label: '3',
													value: '接触非接CPU'
												},{
													label: '4',
													value: '双界面'
												},{
													label: '5',
													value: '单接触逻辑'
												},{
													label: '6',
													value: '单非接M1卡'
												},{
													label: '7',
													value: '充值卡'
												}]"   style="width:174px;"  />
						</td>
						<th>卡片1容量</th>
						<td>
							<input name="cardPro.card1Volumen"  id="card1Volumen" value="${cardPro.card1Volumen}" class="textinput easyui-validatebox"  data-options="panelHeight: 'auto',editable:false" maxlength="10"  style="width:174px;"  />
						</td>
					 </tr>
					 <tr>
						<th>卡片1版本</th>
						<td>
							<input name="cardPro.card1Version"  id="card1Version"  value="${cardPro.card1Version}" class="textinput easyui-validatebox"   data-options="panelHeight: 'auto',editable:false" maxlength="10" style="width:174px;"/>
						</td>
						<th>卡片1COS厂商</th>
						<td>
							<input name="cardPro.card1CosVender"  id="card1CosVender" value="${cardPro.card1CosVender}" class="textinput easyui-validatebox" data-options="panelHeight: 'auto',editable:false" maxlength="10"  style="width:174px;" />
						</td>
						<th>卡片2容量</th>
						<td>
							<input name="cardPro.card2Volumen" id="card2Volumen" value="${cardPro.card2Volumen}" class="textinput easyui-validatebox"     data-options="panelHeight: 'auto'" maxlength="10"  style="width:170px;"/>
						</td>
					</tr>
					<tr>
						<th>卡片2版本</th>
						<td><input name="cardPro.card2Version" id="card2Version"  value="${cardPro.card2Version}"  class="textinput easyui-validatebox" maxlength="10" type="text" />
						</td>
						<th>卡片2COS厂商</th>
						<td><input name="cardPro.card2CosVender" id="card2CosVender"  value="${cardPro.card2CosVender}"  class="textinput easyui-validatebox"  maxlength="10" type="text" />
						</td>
						<th>磁条类型</th>
						<td>
							<input name="cardPro.isBankstripe"  id="isBankstripe" value="${cardPro.isBankstripe}" class="easyui-combobox easyui-validatebox" data-options="panelHeight: 'auto',editable:false,
												valueField: 'label',
												textField: 'value',
												data: [{
													label: '',
													value: '请选择'
												},{
													label: '0',
													value: '银行磁条'
												},{
													label: '1',
													value: '非银行磁条'
												}]"   style="width:174px;" />
						</td>
					</tr>
					<tr>
						<th>当前状态</th>
						<td>
							<input name="cardPro.proState"  id="proState" value="${cardPro.proState}" class="easyui-combobox easyui-validatebox" data-options="panelHeight: 'auto',editable:false,
												valueField: 'label',
												textField: 'value',
												data: [{
													label: '',
													value: '请选择'
												},{
													label: '0',
													value: '使用中'
												},{
													label: '1',
													value: '已注销'
												}]"   style="width:174px;" />
						</td>
						<th>介质类型</th>
						<td><input name="cardPro.mediType"  value="${cardPro.mediType}" id="mediType"  class="easyui-combobox easyui-validatebox" data-options="panelHeight: 'auto',editable:false,
												valueField: 'label',
												textField: 'value',
												data: [{
													label: '',
													value: '请选择'
												},{
													label: '1',
													value: '普通卡'
												},{
													label: '2',
													value: '异形卡'
												},{
													label: '3',
													value: 'NFC卡'
												},{
													label: '4',
													value: '贴面卡'
												},{
													label: '5',
													value: 'simall卡'
												}]"   style="width:174px;" />
						</td>
						
					</tr>
					
					
					
				 </table>
			</fieldset>
			</form>
	</div>
</div>
