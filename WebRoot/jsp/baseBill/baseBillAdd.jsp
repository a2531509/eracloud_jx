<%@ page language="java" import="java.util.*" pageEncoding="utf-8"%>

<script type="text/javascript">
$(function() {
 $("#form").form({
	url :"baseBill/baseBillAction!saveBaseBill.action",
	data: $('#form').serialize(),
	onSubmit : function() {
		if($("#billType").combobox("getValue")==""){
			$.messager.alert("系统消息","【票据类型】不能为空，请选择票据类型","error",function(){
				$("#billType").combobox("showPanel");
			});
			return false;
		}
		 var reg = new RegExp("^[0-9]*$");   
		 if(!reg.test($("#billNum").val())){
			 $.messager.alert("系统消息","对不起，【张数】信息请输入数字","error",function(){
					$("#billNum").focus();
				});
				return false;			 
		 }
		
		
		
		if($("#validityDate").combobox("getValue")==""){
			$.messager.alert("系统消息","对不起，【有效日期】不能为空","error",function(){
				$("#validityDate").combobox("showPanel");
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
				<legend><img src="extend/fromedit.png" style="margin-bottom: -3px;"/>票据信息编辑</legend>
				 <table>
					 <tr>
					    <th>票据编号</th>
						<td>
							<input name="baseBill.billNo"  id="billNo" value="${baseBill.billNo}" class="textinput easyui-validatebox"  maxlength="20" type="text" required="required" style="width:174px"  />
						</td>
						<th>票据名称</th>
						<td>
							<input name="baseBill.billName"  id="billName" value="${baseBill.billName}" class="textinput easyui-validatebox" data-options="panelHeight: 'auto',editable:false," maxlength="20"  required="required"  style="width:174px;"  />
						</td>
						<th>票据类型</th>
						<td>
							<input name="baseBill.billType"  id="billType" value="${baseBill.billType}" class="easyui-combobox easyui-validatebox"  data-options="panelHeight: 'auto',editable:false,
							                    valueField: 'label',
												textField: 'value',
												data: [{label: '',value: '请选择'},{label: '1',value: '银行汇票'},
												{label: '2',value: '商业汇票'},{label: '3',value: '商业本票'},
												{label: '4',value: '银行本票'},{label: '5',value: '记名支票'},
												{label: '6',value: '不记名支票'},{label: '7',value: '划线支票'},
												{label: '8',value: '现金支票'},{label: '9',value: '转帐支票'}]"   style="width:174px;"  />
						</td>
					 </tr>
					 <tr>
						<th>开始编号</th>
						<td>
							<input name="baseBill.startNo"  id="startNo"  value="${baseBill.startNo}" class="textinput easyui-validatebox"   data-options="panelHeight: 'auto',editable:false" maxlength="20" style="width:174px;"/>
						</td>
						<th>结束编号</th>
						<td>
							<input name="baseBill.endNo"  id="endNo" value="${baseBill.endNo}" class="textinput easyui-validatebox" data-options="panelHeight: 'auto',editable:false" maxlength="20"  style="width:174px;" />
						</td>
						<th>张数</th>
						<td>
							<input name="baseBill.billNum" id="billNum" value="${baseBill.billNum}" class="textinput easyui-validatebox"     data-options="panelHeight: 'auto'" required="required" maxlength="20" style="width:170px;"/>
						</td>
					</tr>
					<tr>
						<th>定额标志</th>
						<td><input name="baseBill.amtFlag" id="amtFlag"  value="${baseBill.amtFlag}"  class="textinput easyui-validatebox"  type="text" maxlength="1" style="width:174px;"/>
						</td>
						<th>金额</th>
						<td><input name="baseBill.billAmt" id="billAmt"  value="${baseBill.billAmt}"  class="textinput easyui-validatebox" required="required" maxlength="20" type="text" style="width:174px;"/>
						</td>
						<th>有效日期</th>
						<td><input name="baseBill.validityDate" id="validityDate"  value="${baseBill.validityDate}"  class="easyui-datebox easyui-validatebox"  type="text" style="width:174px;"/>
						</td>
					</tr>
					<tr>
						<th>备注</th>
						<td><input name="baseBill.note" id="note"  value="${baseBill.note}"  class="textinput easyui-validatebox"  type="text" maxlength="200" style="width:174px;"/>
						</td>
					</tr>
				
					
					
				 </table>
			</fieldset>
			</form>
	</div>
</div>
