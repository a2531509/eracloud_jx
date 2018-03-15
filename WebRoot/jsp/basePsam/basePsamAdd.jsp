<%@ page language="java" import="java.util.*" pageEncoding="utf-8"%>

<script type="text/javascript">
$(function() {
	$("#psamManufacturer").combobox({
		 url:"BasePsam/basePsamAction!findBasePsam.action",
       valueField: 'providerName', 
       textField: 'providerName',
       
   });
$("#form").form({
	
	url :"BasePsam/basePsamAction!saveBasePsam.action",
	data: $('#form').serialize(),
	onSubmit : function() {
		if($("#psamManufacturer").combobox("getValue")==""){
			$.messager.alert("系统消息","【生成厂家】不能为空，请选择生产厂家","error",function(){
				$("#psamManufacturer").combobox("showPanel");
			});
			return false;
		}	
		if($("#psamValidDate").combobox("getValue")==""){
			$.messager.alert("系统消息","【卡有效日期】不能为空，请选择卡有效日期","error",function(){
				$("#psamValidDate").combobox("showPanel");
			});
			return false;
		}	
		$.messager.progress({
			title : '提示',
			text : '数据处理中，请稍后....'
		});
		
		var isValid = $(this).form('validate');
		if (!isValid) {
			$.messager.progress('close');
		}
		return isValid;
		//验证输入框的值
		
	},
	success:function(result) {
		$.messager.progress('close');
		result = $.parseJSON(result);
		if (result.status) {
			$.modalDialog.openner.datagrid('reload',{queryType:'0'});
			$.modalDialog.handler.dialog('close');
		}else{
			$.messager.show({
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
				<legend><img src="extend/fromedit.png" style="margin-bottom: -3px;"/>psam卡信息编辑</legend>
				
				 <table>
					 <tr>
					    <th>psam卡序列号</th>
						<td>
							<input name="basePsam.psamNo"  id="psamNo" value="${basePsam.psamNo}" class="textinput easyui-validatebox" data-options="panelHeight: 'auto',editable:false," required="required" maxlength="20" style="width:174px;"  />
						</td>
						<th>psam卡物理卡号</th>
						<td>
							<input name="basePsam.psamId"  id="psamId" value="${basePsam.psamId}" class="textinput" data-options="panelHeight: 'auto',editable:false,"  maxlength="32" style="width:174px;"  />
						</td>
						<th>psam卡终端编号</th>
						<td>
							<input name="basePsam.psamEndNo"  id="psamEndNo" value="${basePsam.psamEndNo}" class="textinput"  data-options="panelHeight: 'auto',editable:false," maxlength="32" style="width:174px;"  />
						</td>
					 </tr>
					 <tr>
						<th>卡发行日期</th>
						<td>
							<input name="basePsam.psamIssuseDate"  id="psamIssuseDate"  value="${basePsam.psamIssuseDate}"  class="easyui-datebox easyui-validatebox"    data-options="panelHeight: 'auto',editable:false"  style="width:174px;"/>
						</td>
						<th>卡有效日期</th>
						<td>
							<input name="basePsam.psamValidDate"  id="psamValidDate" value="${basePsam.psamValidDate}" class="easyui-datebox easyui-validatebox"  data-options="panelHeight: 'auto',editable:false"   style="width:174px;" />
						</td>
						<th>卡片用途</th>
						<td>
							<input name="basePsam.psamUse" id="psamUse" value="${basePsam.psamUse}" class="textinput easyui-validatebox"     data-options="panelHeight: 'auto'"  maxlength="100" style="width:174px;"/>
						</td>
					</tr>
					<tr>
						<th>品牌分类</th>
						<td><input name="basePsam.psamBrand" id="psamBrand"  value="${basePsam.psamBrand}"  class="textinput easyui-validatebox" data-options="panelHeight: 'auto'"  maxlength="100" type="text" />
						</td>
						<th>生产厂家</th>
						<td><input name="basePsam.psamManufacturer" id="psamManufacturer"  value="${basePsam.psamManufacturer}"  class="easyui-combobox easyui-validatebox" data-options="panelHeight: 'auto'"  style="width:174px;"   />
						</td>
						<th>备注</th>
						<td><input name="basePsam.note" id="note"  value="${basePsam.note}"  class="textinput easyui-validatebox"  type="text"  maxlength="100" style="width:174px;" />
						</td>
					</tr>	
					<tr>
					    <th>PSAM卡类型</th>
						<td><input name="basePsam.psamType" id="psamType"  value="${basePsam.psamType}"  class="easyui-combobox easyui-validatebox" data-options="panelHeight: 'auto',editable:false,
												valueField: 'label',
												textField: 'value',
												data: [{
													label: '',
													value: '请选择'
												},{
													label: '1',
													value: '人社'
												},{
													label: '2',
													value: '住建'
												}]""  maxlength="100" type="text" style="width:174px;"  />
						</td>
					</tr>
				 </table>
			</fieldset>
			</form>
	</div>
</div>
